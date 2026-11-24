const { fileURLToPath } = require("node:url");
const path = require("node:path");

const own = (object, key) => Object.hasOwn(object, key);
const record = (value) => value !== null && typeof value === "object" && !Array.isArray(value);
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);
const legacyPlugins = new Set(["session-start", "session-summary", "security-guard", "skill-eval", "stop-summary"]);
const oldSchema = "https://opencode.ai/schema.json";

// Parse JSONC without treating comment text as a value or silently accepting duplicate keys.
function parseConfig(text) {
  text = text.replace(/^\uFEFF/, "");
  const token = /(?:[\t\r\n ]|\/\/[^\r\n]*|\/\*[\s\S]*?\*\/)*("(?:\\.|[^"\\])*"|[{}\[\]:,]|true|false|null|-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?|$)/sy;
  let next;
  function advance() {
    const match = token.exec(text);
    if (!match) throw new Error("Invalid JSONC");
    next = match[1];
  }
  function consume(expected) {
    if (next !== expected) throw new Error(`Invalid JSONC: expected ${expected}`);
    advance();
  }
  function value() {
    if (next === "{" || next === "[") {
      const object = next === "{";
      const result = object ? Object.create(null) : [];
      const close = object ? "}" : "]";
      advance();
      while (next !== close) {
        if (object) {
          if (!next.startsWith('"')) throw new Error("Invalid JSONC object key");
          const key = JSON.parse(next);
          if (own(result, key)) throw new Error(`Duplicate JSONC key: ${key}`);
          advance();
          consume(":");
          result[key] = value();
        } else {
          result.push(value());
        }
        if (next === close) break;
        consume(",");
      }
      consume(close);
      return result;
    }
    const result = JSON.parse(next);
    advance();
    return result;
  }
  advance();
  const parsed = value();
  if (next || !record(parsed)) throw new Error("Expected a single JSONC object");
  return parsed;
}

function removeOwned(config, ownership, warn) {
  for (const { keys, value } of [...(ownership.entries || [])].reverse()) {
    const parent = keys.slice(0, -1).reduce((node, key) => record(node) && own(node, key) ? node[key] : undefined, config);
    const key = keys.at(-1);
    if (!record(parent) || !own(parent, key)) continue;
    if (same(parent[key], value)) delete parent[key];
    else warn(`Keeping changed config entry: ${keys.join(".")}`);
  }
  if (Array.isArray(config.permissions)) {
    for (const rule of ownership.rules || []) {
      // We inserted the first matching rule, before user rules.
      const index = config.permissions.findIndex((existing) => same(existing, rule));
      if (index !== -1) config.permissions.splice(index, 1);
    }
  }
  for (const section of ownership.sections || []) {
    if (config[section] && Object.keys(config[section]).length === 0) delete config[section];
  }
}

function legacyPluginItem(item, root) {
  if (typeof item !== "string" || !item.startsWith("file://")) return false;
  let file;
  try {
    const url = process.platform === "win32" ? item.replace(/^file:\/\/\/([a-z])\//i, "file:///$1:/") : item;
    file = path.normalize(fileURLToPath(url));
  } catch { return false; }
  if (process.platform === "win32") {
    file = file.toLowerCase();
    root = root.toLowerCase();
  }
  return path.dirname(file) === path.join(root, "plugins") &&
    path.extname(file) === ".ts" && legacyPlugins.has(path.basename(file, ".ts"));
}

function removeLegacyConfig(config, template, meta, warn) {
  const entries = [];
  for (const [section, keys, fields] of [
    ["agent", meta.addedAgentKeys], ["mcp", meta.addedMcpKeys, meta.addedMcpFields],
    ["permission", meta.addedPermissionKeys, meta.addedPermissionFields],
  ]) {
    for (const key of keys || []) {
      if (own(template[section], key)) entries.push({ keys: [section, key], value: template[section][key] });
    }
    for (const { key, field } of fields || []) {
      if (record(template[section][key]) && own(template[section][key], field)) {
        entries.push({ keys: [section, key, field], value: template[section][key][field] });
      }
    }
  }
  removeOwned(config, { entries }, warn);
}

function mergeConfig(config, template, root, previous, legacy, warn) {
  const ownership = { entries: [], sections: [], rules: [] };
  removeOwned(config, previous.config || {}, warn);
  if (!previous.version && previous.config) removeLegacyConfig(config, template, previous.config, warn);

  // Migrate only local URLs explicitly associated with the five old Scholar plugins.
  for (const section of ["plugin", "plugins"]) {
    if (!Array.isArray(config[section])) continue;
    const kept = config[section].filter((item) => !legacyPluginItem(item, root) ||
      (!legacy && !previous.config?.addedPluginItems?.includes(item)));
    if (kept.length !== config[section].length) {
      warn(`Removed ${config[section].length - kept.length} obsolete Scholar URL(s) from ${section}`);
      if (kept.length) config[section] = kept;
      else delete config[section];
    }
  }

  function section(name) {
    if (!own(config, name)) {
      config[name] = Object.create(null);
      ownership.sections.push(name);
    }
    if (!record(config[name])) throw new Error(`Expected ${name} to be an object`);
    return config[name];
  }
  function add(parent, key, value, keys) {
    parent[key] = value;
    ownership.entries.push({ keys, value });
  }
  if (!own(config, "$schema") || (config.$schema === oldSchema && (legacy || previous.config?.addedPluginItems))) {
    add(config, "$schema", template.$schema, ["$schema"]);
  }

  const agents = section("agent");
  for (const [key, definition] of Object.entries(template.agent)) {
    if (record(config.agents) && own(config.agents, key)) {
      warn(`Keeping existing agent: ${key}`);
      continue;
    }
    const value = typeof definition.prompt === "string"
      ? { ...definition, prompt: definition.prompt.replaceAll("~/.opencode/", () => `${root.split(path.sep).join("/")}/`) }
      : definition;
    if (!own(agents, key)) add(agents, key, value, ["agent", key]);
    else if (!same(agents[key], value)) warn(`Keeping existing agent: ${key}`);
  }

  const mcp = section("mcp");
  for (const [key, definition] of Object.entries(template.mcp)) {
    if (record(mcp.servers) && own(mcp.servers, key)) continue;
    if (!own(mcp, key)) add(mcp, key, definition, ["mcp", key]);
    else if (record(mcp[key])) {
      for (const [field, value] of Object.entries(definition)) {
        if (!own(mcp[key], field)) add(mcp[key], field, value, ["mcp", key, field]);
      }
    }
  }

  // The V1 write denies are a subset of edit. V2 maps both to the same tool.
  const { bash, write, ...defaults } = template.permission;
  defaults.shell = bash;
  defaults.edit = { ...write, ...defaults.edit };
  if (own(config, "permissions")) {
    if (!Array.isArray(config.permissions)) throw new Error("Expected permissions to be an array");
    const userRules = config.permissions;
    for (const [action, value] of Object.entries(defaults)) {
      for (const [resource, effect] of record(value) ? Object.entries(value) : [["*", value]]) {
        const rule = { action, resource, effect };
        if (!userRules.some((entry) => same(entry, rule))) ownership.rules.push(rule);
      }
    }
    if (userRules.length) warn("Existing permissions take precedence; wildcard rules can override Scholar denies (shell, edit, external_directory)");
    config.permissions = [...ownership.rules, ...userRules];
  } else if (typeof config.permission === "string") {
    warn("Keeping existing permission policy without adding Scholar defaults");
  } else {
    const userRules = section("permission");
    // Keep both action and resource order: OpenCode applies the last match.
    const result = Object.create(null);
    for (const [action, value] of Object.entries(defaults)) {
      const alias = action === "shell" && own(userRules, "bash") ? "bash" :
        action === "edit" && !own(userRules, "edit") && own(userRules, "write") ? "write" : action;
      if (!own(userRules, alias)) add(result, action, value, ["permission", action]);
      else if (record(value) && record(userRules[alias])) {
        const merged = Object.create(null);
        for (const [resource, effect] of Object.entries(value)) {
          if (!own(userRules[alias], resource)) add(merged, resource, effect, ["permission", alias, resource]);
        }
        userRules[alias] = { ...merged, ...userRules[alias] };
      }
    }
    if (Object.keys(userRules).length) warn("Existing permissions take precedence; wildcard rules can override Scholar denies (shell, edit, external_directory)");
    config.permission = Object.assign(result, userRules);
  }
  return ownership;
}

module.exports = { legacyPluginItem, mergeConfig, parseConfig, removeOwned, same };
