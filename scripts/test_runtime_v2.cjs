// Integration test against the installed OpenCode V2 executable, using no credentials or MCP services.
const assert = require("node:assert/strict");
const { spawn, spawnSync } = require("node:child_process");
const { randomBytes } = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { setTimeout: delay } = require("node:timers/promises");
const { test } = require("node:test");

const root = path.resolve(__dirname, "..");
const opencode = process.env.SCHOLAR_TEST_OPENCODE || "opencode";
const python = process.env.SCHOLAR_TEST_PYTHON || (process.platform === "win32" ? "python" : "python3");

function run(program, args, options) {
  const result = spawnSync(program, args, { ...options, encoding: "utf8" });
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stderr + result.stdout);
  return result.stdout;
}

async function until(check, diagnostic) {
  const end = Date.now() + 12_000;
  for (;;) {
    const result = await check();
    if (result) return result;
    if (Date.now() >= end) assert.fail(diagnostic());
    await delay(70);
  }
}

function bootstrap(repo, vault, id, noYaml = false) {
  fs.mkdirSync(repo, { recursive: true });
  run("git", ["init", "-q", repo]);
  fs.mkdirSync(vault, { recursive: true });
  return JSON.parse(run(python, [
    ...(noYaml ? ["-S"] : []), path.join(root, "skills/obsidian-project-kb-core/scripts/project_kb.py"),
    "bootstrap", "--cwd", repo, "--vault-path", vault, "--project-id", id, "--project-name", id,
  ], { env: { ...process.env, PYTHONUTF8: "1", PYTHONDONTWRITEBYTECODE: "1" } }));
}

test("the real KB helper produces readable JSON and YAML OpenCode bindings", (t) => {
  const home = fs.mkdtempSync(path.join(os.tmpdir(), "scholar-kb-v2-"));
  t.after(() => fs.rmSync(home, { recursive: true, force: true }));
  for (const id of ["yaml-project", "json-project"]) {
    const repo = path.join(home, id);
    const vault = path.join(home, "vault");
    bootstrap(repo, vault, id, id === "json-project");
    const registry = path.join(repo, ".opencode", "project-memory", "registry.yaml");
    assert.ok(fs.existsSync(registry), `helper did not write ${registry}`);
    const raw = fs.readFileSync(registry, "utf8").trim();
    if (id === "json-project") assert.ok(JSON.parse(raw).projects[id]);
    else assert.match(raw, /(?:^\s*projects:|^\{)/);
    assert.ok(fs.existsSync(path.join(path.dirname(registry), `${id}.md`)));
  }
});

test("bootstrap writes a V2 binding without modifying the old registry or hiding old projects", (t) => {
  const home = fs.mkdtempSync(path.join(os.tmpdir(), "scholar-kb-v2-upgrade-"));
  t.after(() => fs.rmSync(home, { recursive: true, force: true }));
  const repo = path.join(home, "research");
  const vault = path.join(home, "vault");
  bootstrap(repo, vault, "old-project", true);
  const current = path.join(repo, ".opencode", "project-memory");
  const legacy = path.join(repo, ".claude", "project-memory");
  fs.mkdirSync(path.dirname(legacy), { recursive: true });
  fs.renameSync(current, legacy);
  const oldRegistry = fs.readFileSync(path.join(legacy, "registry.yaml"), "utf8");
  const result = bootstrap(repo, vault, "new-project", true);
  assert.equal(path.normalize(result.binding_registry), path.join(current, "registry.yaml"));
  assert.ok(fs.existsSync(path.join(current, "new-project.md")));
  assert.equal(fs.readFileSync(path.join(legacy, "registry.yaml"), "utf8"), oldRegistry);
  const resultOld = JSON.parse(run(python, ["-S", path.join(root, "skills/obsidian-project-kb-core/scripts/project_kb.py"),
    "status", "--cwd", repo, "--project-id", "old-project"], { env: { ...process.env, PYTHONDONTWRITEBYTECODE: "1" } }));
  assert.equal(resultOld.project_id, "old-project");
});

test("OpenCode V2 discovers Scholar and handles real created and moved/deleted sessions", { timeout: 40_000 }, async (t) => {
  const home = fs.mkdtempSync(path.join(process.env.SCHOLAR_TEST_TMPDIR || os.tmpdir(), "scholar-runtime-v2-"));
  const cleanup = () => fs.rmSync(home, { recursive: true, force: true, maxRetries: 5, retryDelay: 150 });
  let child;
  t.after(() => { if (!child) cleanup(); });
  // V2 also discovers project configuration above the fixture, including empty
  // .opencode directories. Refuse nonempty ambient sources before starting it.
  const emptyAncestors = new Set();
  for (let dir = path.dirname(home); ; dir = path.dirname(dir)) {
    const ambient = path.join(dir, ".opencode");
    const stat = fs.lstatSync(ambient, { throwIfNoEntry: false });
    if (stat?.isDirectory() && fs.readdirSync(ambient).length === 0) emptyAncestors.add(ambient);
    else assert.ok(!stat, `Ambient config at ${ambient}; set SCHOLAR_TEST_TMPDIR outside that tree`);
    for (const name of ["opencode.json", "opencode.jsonc", "AGENTS.md", "CLAUDE.md"]) {
      assert.ok(!fs.existsSync(path.join(dir, name)), `Ambient ${name} at ${dir}; set SCHOLAR_TEST_TMPDIR outside that tree`);
    }
    if (dir === path.parse(dir).root) break;
  }
  const repo = path.join(home, "research");
  const moved = path.join(home, "moved");
  const vault = path.join(home, "vault");
  bootstrap(repo, vault, "runtime-project");
  bootstrap(moved, vault, "moved-project", true);
  // Cover a legacy binding with real helper output, not a separately authored fixture.
  const current = path.join(moved, ".opencode", "project-memory");
  const legacy = path.join(moved, ".claude", "project-memory");
  fs.mkdirSync(path.dirname(legacy), { recursive: true });
  if (fs.existsSync(current)) fs.renameSync(current, legacy);
  const legacyRegistry = path.join(legacy, "registry.yaml");
  const other = path.join(home, "other");
  bootstrap(other, vault, "other-project", true);
  const unrelated = JSON.parse(fs.readFileSync(path.join(other, ".opencode", "project-memory", "registry.yaml"), "utf8"));
  const registry = JSON.parse(fs.readFileSync(legacyRegistry, "utf8"));
  fs.writeFileSync(legacyRegistry, JSON.stringify({ projects: { ...unrelated.projects, ...registry.projects } }));
  const env = Object.fromEntries(Object.entries(process.env).filter(([key]) =>
    /^(PATH|PATHEXT|SystemRoot|SystemDrive|windir|ComSpec|TEMP|TMP|APPDATA|LOCALAPPDATA)$/i.test(key)));
  for (const [key, dir] of Object.entries({ HOME: home, USERPROFILE: home, XDG_CONFIG_HOME: "config", XDG_DATA_HOME: "data",
    XDG_STATE_HOME: "state", XDG_CACHE_HOME: "cache", APPDATA: "appdata", LOCALAPPDATA: "local", ProgramData: "system",
  })) env[key] = dir === home ? home : path.join(home, dir);
  env.OPENCODE_DISABLE_MODELS_FETCH = "true";
  env.OPENCODE_TEST_HOME = home;
  env.OPENCODE_DISABLE_CLAUDE_CODE = "1";
  env.OPENCODE_CONFIG_CONTENT = JSON.stringify({
    update: "disable",
    policies: [{ action: "provider.use", resource: "*", effect: "deny" }],
  });
  env.OPENCODE_PASSWORD = randomBytes(24).toString("hex");
  const authorization = "Basic " + Buffer.from(`opencode:${env.OPENCODE_PASSWORD}`).toString("base64");
  const globalConfig = path.join(env.XDG_CONFIG_HOME, "opencode");
  fs.mkdirSync(globalConfig, { recursive: true });
  const globalFile = path.join(globalConfig, "opencode.jsonc");
  const globalData = JSON.stringify({ update: "disable" });
  fs.writeFileSync(globalFile, globalData);
  const install = path.join(repo, ".opencode");
  run(process.execPath, ["scripts/install.cjs", "install", repo], { cwd: root, env });
  assert.deepEqual(fs.readdirSync(globalConfig), ["opencode.jsonc"]);
  assert.equal(fs.readFileSync(globalFile, "utf8"), globalData);
  const cfg = path.join(install, "opencode.jsonc");
  const config = JSON.parse(fs.readFileSync(cfg, "utf8"));
  assert.equal(config.permission, undefined);
  assert.equal(config.permissions, undefined);
  // Exercise V2 discovery without starting Zotero.
  for (const server of Object.values(config.mcp.servers)) server.disabled = true;
  fs.writeFileSync(cfg, JSON.stringify(config));
  child = spawn(opencode, ["serve", "--hostname", "127.0.0.1", "--port", "0", "--print-logs"], { cwd: repo, env });
  let logs = "";
  for (const stream of [child.stdout, child.stderr]) stream.on("data", (chunk) => logs += chunk);
  let spawnError;
  child.once("error", (error) => { spawnError = error; });
  t.after(async () => {
    const evidence = process.env.SCHOLAR_TEST_EVIDENCE_DIR;
    if (evidence) {
      fs.mkdirSync(evidence, { recursive: true });
      fs.writeFileSync(path.join(evidence, "runtime.log"), logs.replaceAll(env.OPENCODE_PASSWORD, "[redacted]"));
    }
    if (child.pid && child.exitCode === null) {
      const exited = new Promise((resolve) => child.once("exit", resolve));
      if (process.platform === "win32") spawnSync("taskkill", ["/pid", String(child.pid), "/t", "/f"]);
      else child.kill();
      await Promise.race([exited, delay(2_000)]);
    }
    child.stdout.destroy();
    child.stderr.destroy();
    cleanup();
  });
  const base = await until(() => {
    if (spawnError) throw spawnError;
    return logs.match(/http:\/\/127\.0\.0\.1:\d+/)?.[0];
  }, () => `server address missing:\n${logs}`);

  async function api(route, method = "GET", body) {
    const response = await fetch(base + "/api/" + route, {
      method, headers: { "content-type": "application/json", authorization }, body: JSON.stringify(body),
      signal: AbortSignal.timeout(10_000),
    });
    const text = await response.text();
    assert.ok(response.ok, `${method} ${route}: ${response.status} ${text}\n${logs}`);
    if (!text) return;
    const decoded = JSON.parse(text);
    return decoded.data ?? decoded;
  }
  const atDirectory = (dir) => `?location%5Bdirectory%5D=${encodeURIComponent(dir)}`;
  const at = atDirectory(repo);
  const sources = await api("config" + at);
  t.diagnostic(`config sources: ${sources.map((item) => item.path || "(inline)").join(", ")}`);
  assert.ok(sources.some((item) => item.path === cfg), "installed configuration missing");
  for (const { path: file } of sources) {
    if (!file || emptyAncestors.has(file)) continue;
    const rel = path.relative(home, file);
    assert.ok(!path.isAbsolute(rel) && !rel.startsWith(`..${path.sep}`) && rel !== "..", `external config source: ${file}`);
  }
  // A cold location publishes the first session before its lazy plugin activation.
  await api("session", "POST", { title: "Activate location plugins", location: { directory: repo } });
  const expectedPlugins = ["scholar-security-guard", "scholar-session-start", "scholar-session-summary", "scholar-skill-eval"];
  const plugins = await until(async () => {
    const active = (await api("plugin" + at)).map((plugin) => plugin.id).filter((id) => id.startsWith("scholar-")).sort();
    return active.length === expectedPlugins.length ? active : false;
  }, () => `Scholar plugins did not activate:\n${logs}`);
  assert.deepEqual(plugins, expectedPlugins);
  const skills = await api("skill" + at);
  const commands = await api("command" + at);
  const agents = await api("agent" + at);
  const sourceSkillsDir = path.join(root, "skills");
  const expectedSkillFiles = fs.readdirSync(sourceSkillsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map(({ name }) => path.join(name, "SKILL.md"))
    .filter((file) => fs.statSync(path.join(sourceSkillsDir, file), { throwIfNoEntry: false })?.isFile())
    .sort();
  const installedSkillsDir = path.join(install, "skills");
  const installedSkills = skills.filter(({ path: file }) => {
    const relative = path.relative(installedSkillsDir, file);
    return relative && !relative.startsWith("..") && !path.isAbsolute(relative);
  });
  const discoveredSkillFiles = installedSkills.map(({ path: file }) => path.relative(installedSkillsDir, file)).sort();
  assert.deepEqual(discoveredSkillFiles, expectedSkillFiles);
  for (const id of ["obsidian-project-kb-core", "granola-meeting-ingest"]) {
    assert.ok(installedSkills.some((skill) => skill.id === id), `missing ${id}`);
  }
  for (const name of ["kb-init", "mine-writing-patterns", "promote"]) {
    assert.ok(commands.some((command) => command.name === name), `missing ${name}`);
  }
  const expectedAgents = Object.keys(config.agents);
  assert.equal(expectedAgents.length, 6);
  for (const id of expectedAgents) assert.ok(agents.some((agent) => agent.id === id), `missing ${id}`);
  const expectedMcp = Object.keys(config.mcp.servers).sort();
  assert.deepEqual(expectedMcp, ["zotero"]);
  const mcp = await api("mcp" + at);
  assert.deepEqual(mcp.map(({ name, id }) => name ?? id).sort(), expectedMcp, JSON.stringify(mcp));
  const otherLocation = atDirectory(other);
  assert.ok(!(await api("config" + otherLocation)).some(({ path: file }) => file === cfg));
  assert.ok(!(await api("plugin" + otherLocation)).some(({ id }) => expectedPlugins.includes(id)));
  assert.ok(!(await api("agent" + otherLocation)).some(({ id }) => expectedAgents.includes(id)));
  assert.ok(!(await api("skill" + otherLocation)).some(({ id }) => id === "obsidian-project-kb-core"));
  assert.ok(!(await api("command" + otherLocation)).some(({ name }) => name === "kb-init"));
  assert.deepEqual(await api("mcp" + otherLocation), []);
  t.diagnostic(`catalogs: ${plugins.length} Scholar plugins, ${installedSkills.length} installed skills, ${commands.length} commands total, ${expectedAgents.length} Scholar agents; MCP: ${expectedMcp.join(", ")}`);
  const session = await api("session", "POST", { title: "V2 migration smoke", location: { directory: repo } });
  await until(() => logs.includes("Obsidian project memory: bound (runtime-project)"), () => logs);
  assert.equal(logs.split("Obsidian project memory: bound (runtime-project)").length, 2);
  const requested = `session/${session.id}/permission`;
  for (const [action, resources, expected] of [
    ["read", ["README.md"], "allow"],
    ["edit", ["sample.txt"], "allow"],
    ["external_directory", [vault], "allow"],
  ]) {
    const result = await api(requested, "POST", { action, resources });
    assert.equal(result.effect, expected, `${action}: ${resources[0]}`);
    if (expected === "ask") await api(`${requested}/${result.id}/reply`, "POST", { decision: "reject" });
  }
  t.diagnostic("No Scholar permission policy was injected; native V2 defaults apply");
  await api(`session/${session.id}/move`, "POST", { directory: moved });
  await until(async () => (await api(`session/${session.id}`)).location.directory.toLowerCase() === moved.toLowerCase(), () => logs);
  await api(`session/${session.id}`, "DELETE");
  const logDir = path.join(moved, ".opencode", "logs");
  const logFile = await until(() => fs.existsSync(logDir) && fs.readdirSync(logDir)[0], () => logs);
  const worklog = fs.readFileSync(path.join(logDir, logFile), "utf8");
  assert.match(worklog, /Work Log - moved/);
  assert.match(worklog, /Obsidian Minimum Write-back/);
  assert.match(worklog, /moved-project\.md/);
  assert.ok(!fs.existsSync(path.join(repo, ".opencode", "logs")));
  const userRules = [{ action: "edit", resource: "*.txt", effect: "deny" }];
  fs.writeFileSync(cfg, JSON.stringify({ ...config, permissions: userRules }));
  run(process.execPath, ["scripts/install.cjs", "install", repo], { cwd: root, env });
  assert.deepEqual(JSON.parse(fs.readFileSync(cfg, "utf8")).permissions, userRules);
  const override = await api("session", "POST", { title: "User permission override", location: { directory: repo } });
  const overridePath = `session/${override.id}/permission`;
  await until(async () => {
    const result = await api(overridePath, "POST", { action: "edit", resources: ["sample.txt"] });
    if (result.effect === "ask") await api(`${overridePath}/${result.id}/reply`, "POST", { decision: "reject" });
    return result.effect === "deny";
  }, () => `OpenCode did not apply the explicit user rule:\n${logs}`);
  t.diagnostic("User-owned project permissions continue to apply after reinstall");
  const evidence = process.env.SCHOLAR_TEST_EVIDENCE_DIR;
  if (evidence) {
    fs.mkdirSync(evidence, { recursive: true });
    fs.writeFileSync(path.join(evidence, logFile), worklog);
  }
});
