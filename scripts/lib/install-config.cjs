const fs = require("node:fs");
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
  if (Array.isArray(config.instructions)) {
    for (const item of ownership.instructions || []) {
      const index = config.instructions.indexOf(item);
      if (index !== -1) config.instructions.splice(index, 1);
    }
  }
  for (const section of [...(ownership.sections || [])].reverse()) {
    const keys = Array.isArray(section) ? section : [section];
    const parent = keys.slice(0, -1).reduce((node, key) => record(node) && own(node, key) ? node[key] : undefined, config);
    const key = keys.at(-1);
    if (!record(parent) || !own(parent, key)) continue;
    const value = parent[key];
    if ((Array.isArray(value) && value.length === 0) ||
      (record(value) && Object.keys(value).length === 0)) delete parent[key];
  }
}

// The destination may not exist yet. Resolve its existing ancestor first.
function realDestination(dir) {
  try {
    return fs.realpathSync.native(dir);
  } catch (error) {
    const parent = path.dirname(dir);
    if (error.code !== "ENOENT" || parent === dir) throw error;
    return path.join(realDestination(parent), path.basename(dir));
  }
}

function legacyPluginItem(item, root) {
  if (typeof item !== "string" || !item.startsWith("file://")) return false;
  try {
    const url = process.platform === "win32" ? item.replace(/^file:\/\/\/([a-z])\//i, "file:///$1:/") : item;
    const file = path.normalize(fileURLToPath(url));
    const name = process.platform === "win32" ? path.basename(file).toLowerCase() : path.basename(file);
    if (path.extname(name) !== ".ts" || !legacyPlugins.has(path.basename(name, ".ts"))) return false;
    return path.relative(realDestination(path.join(root, "plugins")), realDestination(path.dirname(file))) === "";
  } catch { return false; }
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

function mergeConfig(config, template, root, previous, legacy, instructions, warn) {
  // Keep the exact V1 defaults for ownership checks and reuse the existing agent prompts.
  const oldTemplate = require("./legacy-config.json");
  const ownership = { entries: [], sections: [], instructions: [] };
  const previousZotero = record(config.mcp?.zotero) ? { ...config.mcp.zotero } : undefined;
  removeOwned(config, previous.config || {}, warn);
  if (!previous.version && previous.config) removeLegacyConfig(config, oldTemplate, previous.config, warn);

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

  function section(parent, name, keys = [name]) {
    if (!own(parent, name)) {
      parent[name] = Object.create(null);
      ownership.sections.push(keys);
    }
    if (!record(parent[name])) throw new Error(`Expected ${keys.join(".")} to be an object`);
    return parent[name];
  }
  function add(parent, key, value, keys) {
    parent[key] = value;
    ownership.entries.push({ keys, value });
  }
  if (!own(config, "$schema") || (config.$schema === oldSchema && (legacy || previous.config?.addedPluginItems))) {
    add(config, "$schema", template.$schema, ["$schema"]);
  }

  for (const [key, definition] of Object.entries(oldTemplate.agent)) {
    if ([config.agents, config.agent, config.mode].some((map) => record(map) && own(map, key))) {
      warn(`Keeping existing agent: ${key}`);
      continue;
    }
    const { description, prompt } = definition;
    let system = prompt.replaceAll("~/.opencode/", () => `${root.split(path.sep).join("/")}/`);
    if (key === "paper-miner") {
      system = system.replace("Do **not** maintain project-specific writing memory.\nDo **not** create per-project writing notes for mined patterns.",
        "Do **not** write to a global installation or create a second writing-memory file in this project.")
        .replace("and not into per-project writing stores.", "and not into any second project writing store.");
    }
    add(section(config, "agents"), key, { description, system }, ["agents", key]);
  }

  const mcp = section(config, "mcp");
  if (record(mcp.zotero) && !(record(mcp.servers) && own(mcp.servers, "zotero"))) {
    // A surviving user preference still needs the connection fields that ownership cleanup removed.
    const local = previousZotero?.type === "local" && Array.isArray(previousZotero.command);
    const remote = previousZotero?.type === "remote" && typeof previousZotero.url === "string";
    const fields = local ? ["type", "command"] : remote ? ["type", "url"] : [];
    for (const field of fields) {
      if (!own(mcp.zotero, field)) add(mcp.zotero, field, previousZotero[field], ["mcp", "zotero", field]);
    }
  }
  for (const [key, definition] of Object.entries(template.mcp.servers)) {
    if (own(mcp, key) || (record(mcp.servers) && own(mcp.servers, key))) continue;
    add(section(mcp, "servers", ["mcp", "servers"]), key, definition, ["mcp", "servers", key]);
  }

  if (instructions) {
    if (!own(config, "instructions")) {
      config.instructions = [];
      ownership.sections.push("instructions");
    }
    if (!Array.isArray(config.instructions)) throw new Error("Expected instructions to be an array");
    if (!config.instructions.includes(instructions)) {
      config.instructions.push(instructions);
      ownership.instructions.push(instructions);
    }
  }
  return ownership;
}

module.exports = { legacyPluginItem, mergeConfig, parseConfig, realDestination, removeOwned, same };
