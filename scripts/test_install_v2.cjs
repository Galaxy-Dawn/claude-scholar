const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");
const { pathToFileURL } = require("node:url");
const { test } = require("node:test");

const root = path.resolve(__dirname, "..");
const memory = "skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md";
const skill = "skills/daily-coding/SKILL.md";
const state = ".opencode-scholar-install-state";
const config = "opencode.jsonc";
const legacyURL = (dir) => pathToFileURL(path.join(dir, "plugins/session-summary.ts")).href;

function fixture(t) {
  const project = fs.mkdtempSync(path.join(os.tmpdir(), "scholar test 测试 "));
  const dir = path.join(project, ".opencode");
  t.after(() => fs.rmSync(project, { recursive: true, force: true }));
  return {
    dir,
    project,
    read: (file) => fs.readFileSync(path.join(dir, file), "utf8"),
    has: (file) => fs.existsSync(path.join(dir, file)),
    put(file, contents) {
      fs.mkdirSync(path.dirname(path.join(dir, file)), { recursive: true });
      fs.writeFileSync(path.join(dir, file), contents);
    },
  };
}

function launch(dir, mode, shell, cwd = root) {
  const name = mode === "install" ? "setup" : "uninstall";
  let program = process.execPath;
  let args = ["scripts/install.cjs", mode];
  if (shell === "bash") {
    program = process.env.SCHOLAR_TEST_BASH || "bash";
    args = [`scripts/${name}.sh`];
  } else if (shell) {
    program = shell;
    args = ["-NoProfile", "-NonInteractive", "-File", `scripts/${name}.ps1`];
  }
  const result = spawnSync(program, [...args, path.dirname(dir)], {
    cwd,
    env: process.env,
    encoding: "utf8",
  });
  assert.ifError(result.error);
  return result;
}

function ok(result) {
  assert.equal(result.status, 0, result.stderr + result.stdout);
}

test("an explicit project gets native Scholar config; a different project and global config are untouched", (t) => {
  const f = fixture(t);
  f.put("global/opencode.jsonc", '{ "model": "personal/model" }\n');
  f.put("other/opencode.jsonc", '{ "theme": "other" }\n');
  f.put("target/README.md", "test project");
  const env = {
    ...process.env, HOME: f.dir, USERPROFILE: f.dir, XDG_CONFIG_HOME: f.dir,
    OPENCODE_CONFIG_DIR: path.join(f.dir, "global"), OPENCODE_DIR: path.join(f.dir, "global"),
  };
  const run = (mode, ...args) => spawnSync(process.execPath, ["scripts/install.cjs", mode, ...args], {
    cwd: root, env, encoding: "utf8",
  });
  const project = path.join(f.dir, "target");
  for (const mode of ["install", "uninstall"]) assert.notEqual(run(mode).status, 0);
  assert.notEqual(run("install", path.join(f.dir, "global")).status, 0);
  ok(run("install", project));
  const data = JSON.parse(f.read("target/.opencode/opencode.jsonc"));
  assert.equal(Object.keys(data.agents).length, 6);
  assert.equal(typeof data.agents["paper-miner"].system, "string");
  for (const definition of Object.values(data.agents)) {
    assert.equal(definition.prompt, undefined);
    assert.equal(definition.tools, undefined);
  }
  assert.equal(data.mcp.servers.zotero.type, "local");
  assert.equal(data.mcp.servers.zotero.enabled, undefined);
  assert.deepEqual(Object.keys(data.mcp.servers), ["zotero"]);
  assert.equal(data.mcp.zotero, undefined);
  for (const key of ["agent", "permission", "permissions", "plugin"]) assert.equal(data[key], undefined);
  assert.equal(f.has("target/opencode.jsonc"), false);
  assert.equal(f.has(`target/.opencode/${skill}`), true);
  ok(run("uninstall", project));
  assert.equal(f.has("target/.opencode/opencode.jsonc"), false);
  assert.equal(f.has("other/.opencode"), false);
  assert.deepEqual(fs.readdirSync(path.join(f.dir, "global")), ["opencode.jsonc"]);
  assert.equal(f.read("global/opencode.jsonc"), '{ "model": "personal/model" }\n');
  assert.equal(f.read("other/opencode.jsonc"), '{ "theme": "other" }\n');
});

test("a single existing project-root configuration is reused; two locations are refused", (t) => {
  const f = fixture(t);
  const project = path.join(f.dir, "target");
  const user = JSON.stringify({
    permissions: [{ action: "edit", resource: "*", effect: "ask" }],
    mcp: { servers: {
      zotero: { type: "local", command: ["custom-zotero"], disabled: true },
      "streamable-mcp-server": { type: "remote", url: "http://127.0.0.1:12306/mcp" },
    } },
  });
  f.put("target/opencode.json", user);
  f.put("target/.opencode/opencode.jsonc", "{}");
  const run = (mode) => spawnSync(process.execPath, ["scripts/install.cjs", mode, project], {
    cwd: root, env: { ...process.env, OPENCODE_DIR: path.join(f.dir, "global") }, encoding: "utf8",
  });
  assert.notEqual(run("install").status, 0);
  assert.equal(f.has(`target/.opencode/${skill}`), false);
  fs.unlinkSync(path.join(project, ".opencode", config));
  ok(run("install"));
  assert.equal(f.has("target/.opencode/opencode.jsonc"), false);
  const installed = JSON.parse(f.read("target/opencode.json"));
  assert.deepEqual(installed.mcp, JSON.parse(user).mcp);
  assert.deepEqual(installed.permissions, JSON.parse(user).permissions);
  ok(run("uninstall"));
  assert.deepEqual(JSON.parse(f.read("target/opencode.json")), JSON.parse(user));
});

for (const relative of [config, ".opencode/" + config]) {
  test("config backups use private permissions for " + relative, {
    skip: process.platform === "win32" && "uses POSIX permissions",
  }, (t) => {
    const f = fixture(t);
    const active = path.join(f.project, relative);
    const sidecar = active + ".bak";
    const history = path.join(f.dir, ".opencode-scholar-backups");
    const original = '// original configuration\n{"model":"fixture/model",}\n';
    const userBackup = 'user-owned backup\n';
    const modeOf = (file) => fs.statSync(file).mode & 0o777;
    const run = (operation) => spawnSync("/bin/sh", [
      "-c", 'umask 022; exec "$@"', "scholar-backup-test",
      process.execPath, "scripts/install.cjs", operation, f.project,
    ], { cwd: root, encoding: "utf8" });

    fs.mkdirSync(history, { recursive: true });
    fs.chmodSync(history, 0o755);
    fs.writeFileSync(active, original, { mode: 0o600 });

    function readHistory() {
      assert.equal(modeOf(history), 0o700);
      return fs.readdirSync(history).map((name) => {
        const folder = path.join(history, name);
        const copy = path.join(folder, config);
        assert.equal(modeOf(folder), 0o700);
        assert.equal(modeOf(copy), 0o600);
        return fs.readFileSync(copy, "utf8");
      });
    }

    ok(run("install"));
    const installed = fs.readFileSync(active, "utf8");
    assert.equal(JSON.parse(installed).model, "fixture/model");
    assert.equal(modeOf(active), 0o600);
    assert.equal(modeOf(sidecar), 0o600);
    assert.equal(fs.readFileSync(sidecar, "utf8"), original);
    assert.deepEqual(readHistory(), [original]);

    fs.writeFileSync(sidecar, userBackup);
    fs.chmodSync(sidecar, 0o640);
    ok(run("uninstall"));
    assert.deepEqual(JSON.parse(fs.readFileSync(active, "utf8")), { model: "fixture/model" });
    assert.equal(modeOf(active), 0o600);
    assert.equal(modeOf(sidecar), 0o640);
    assert.equal(fs.readFileSync(sidecar, "utf8"), userBackup);
    assert.deepEqual(readHistory().sort(), [original, installed].sort());
  });
}

const shells = ["bash"];
if (process.platform === "win32") shells.push("powershell.exe", "pwsh.exe");
for (const shell of shells) {
  test(`${shell}: install, reinstall and uninstall share ownership`, (t) => {
    const f = fixture(t);
    ok(launch(f.dir, "install", shell));
    const data = JSON.parse(f.read(config));
    assert.equal(data.permission, undefined);
    assert.equal(data.permissions, undefined);
    assert.equal(data.plugin, undefined);
    assert.deepEqual(data.instructions, [".opencode/AGENTS.md"]);
    assert.equal(f.has(skill), true);
    assert.equal(f.has(memory), true);
    assert.equal(f.read("AGENTS.md"), fs.readFileSync(path.join(root, "AGENTS.md"), "utf8"));
    ok(launch(f.dir, "install", shell));
    ok(launch(f.dir, "uninstall", shell));
    assert.equal(f.has(config), false);
    assert.equal(f.has(state), false);
    assert.equal(f.has(skill), false);
    assert.equal(f.has(memory), true);
  });
}

test("JSONC, user rules, same-name agent and changed managed content survive reinstall and remove", (t) => {
  const f = fixture(t);
  const user = `// note\n{"permission":{"*":"allow","edit":{"*":"ask",},},` +
    `"agent":{"code-reviewer":{"description":"custom"}},` +
    `"mcp":{"zotero":{"enabled":false}},"plugin":["file:///user/keep.ts"],}`;
  f.put(config, user);
  f.put("AGENTS.md", "my own instructions");
  ok(launch(f.dir, "install"));
  const first = JSON.parse(f.read(config));
  assert.equal(first.agent["code-reviewer"].description, "custom");
  assert.equal(first.agents["code-reviewer"], undefined);
  assert.deepEqual(first.permission, { "*": "allow", edit: { "*": "ask" } });
  assert.deepEqual(first.mcp, { zotero: { enabled: false } });
  assert.equal(first.plugin[0], "file:///user/keep.ts");
  assert.equal(f.read("opencode.jsonc.bak"), user);
  assert.equal(f.read("AGENTS.md"), "my own instructions");
  assert.equal(f.has("AGENTS.scholar.md"), true);
  assert.equal(first.instructions, undefined);
  f.put(skill, "custom skill contents");
  f.put(memory, "user research");
  first.agents["paper-miner"].description = "mine now";
  f.put(config, JSON.stringify(first));
  ok(launch(f.dir, "install"));
  ok(launch(f.dir, "uninstall"));
  assert.equal(f.read(skill), "custom skill contents");
  assert.equal(f.read(memory), "user research");
  assert.equal(f.read("AGENTS.md"), "my own instructions");
  assert.equal(f.has("AGENTS.scholar.md"), false);
  const remaining = JSON.parse(f.read(config));
  assert.equal(remaining.agents["paper-miner"].description, "mine now");
  assert.equal(remaining.agent["code-reviewer"].description, "custom");
  assert.deepEqual(remaining.permission, { "*": "allow", edit: { "*": "ask" } });
  assert.deepEqual(remaining.mcp.zotero, { enabled: false });
  assert.equal(remaining.mcp.servers, undefined);
  assert.deepEqual(remaining.plugin, ["file:///user/keep.ts"]);
});

test("malformed and ambiguous JSONC stops installation before writing assets", (t) => {
  const f = fixture(t);
  for (const input of ['{ "mcp": [ }', '{"permission":{"edit":"deny","edit":"allow"}}']) {
    f.put(config, input);
    assert.notEqual(launch(f.dir, "install").status, 0);
    assert.equal(f.read(config), input);
    assert.equal(f.has(skill), false);
  }
});

for (const variant of ["nested", "different case", "linked ancestor"]) {
  test(`install refuses a source checkout destination (${variant}) before writes`, (t) => {
    const f = fixture(t);
    const source = path.join(f.dir, "source");
    for (const rel of ["scripts/install.cjs", "scripts/lib/install-config.cjs",
      "scripts/lib/utils.js", config, "AGENTS.md", "AGENTS.zh-CN.md"]) {
      f.put(`source/${rel}`, fs.readFileSync(path.join(root, rel)));
    }
    let destination = path.join(source, "new");
    fs.mkdirSync(destination);
    if (variant === "different case") {
      destination = path.join(f.dir, "SOURCE");
      if (!fs.existsSync(destination)) return t.skip("case-sensitive filesystem");
    } else if (variant === "linked ancestor") {
      const link = path.join(f.dir, "source-link");
      fs.symlinkSync(source, link, process.platform === "win32" ? "junction" : "dir");
      destination = path.join(link, "new");
    }
    const result = launch(path.join(destination, ".opencode"), "install", undefined, source);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /outside the source checkout/);
    assert.equal(f.has(`source/${state}`), false);
    assert.equal(f.has("source/new/.opencode"), false);
    assert.equal(f.has("source/.opencode"), false);
  });
}

test("the installed PowerShell or Bash entrypoint can uninstall verified files without the checkout", (t) => {
  const f = fixture(t);
  const shell = process.platform === "win32" ? "powershell.exe" : "bash";
  ok(launch(f.dir, "install", shell));
  f.put("commands/user.md", "custom command");
  ok(launch(f.dir, "uninstall", shell, f.dir));
  assert.equal(f.has(state), false);
  assert.equal(f.has(skill), false);
  assert.equal(f.read("commands/user.md"), "custom command");
  assert.equal(f.has(memory), true);
});

test("uninstall preserves assets and ownership when a renamed config was edited", (t) => {
  const f = fixture(t);
  ok(launch(f.dir, "install"));
  const renamed = "opencode.json";
  const before = f.read(state);
  const manifest = ".opencode-scholar-manifest.txt";
  const manifestBefore = f.read(manifest);
  const edited = JSON.stringify({ ...JSON.parse(f.read(config)), theme: "user-edit" });
  fs.renameSync(path.join(f.dir, config), path.join(f.dir, renamed));
  f.put(renamed, edited);
  const reinstall = launch(f.dir, "install");
  assert.notEqual(reinstall.status, 0);
  assert.match(reinstall.stderr, /opencode\.json.+opencode\.jsonc/);
  const result = launch(f.dir, "uninstall");
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /opencode\.json.+opencode\.jsonc/);
  assert.equal(f.read(renamed), edited);
  assert.equal(f.read(state), before);
  assert.equal(f.read(manifest), manifestBefore);
  assert.equal(f.has(skill), true);
  fs.renameSync(path.join(f.dir, renamed), path.join(f.dir, config));
  ok(launch(f.dir, "uninstall"));
  assert.deepEqual(JSON.parse(f.read(config)), { theme: "user-edit" });
  assert.equal(f.has(state), false);
  assert.equal(f.has(skill), false);
});

test("uninstall still accepts a renamed config with the same contents", (t) => {
  const f = fixture(t);
  ok(launch(f.dir, "install"));
  fs.renameSync(path.join(f.dir, config), path.join(f.dir, "opencode.json"));
  ok(launch(f.dir, "uninstall"));
  assert.equal(f.has("opencode.json"), false);
});

test("known same-root V1 URL is removed without claiming a different unmanaged file", (t) => {
  const f = fixture(t);
  f.put(config, JSON.stringify({ plugin: [legacyURL(f.dir), "file:///unrelated/keep.ts"] }));
  f.put(skill, fs.readFileSync(path.join(root, skill)));
  f.put("commands/learn.md", "user command");
  ok(launch(f.dir, "install"));
  assert.deepEqual(JSON.parse(f.read(config)).plugin, ["file:///unrelated/keep.ts"]);
  ok(launch(f.dir, "uninstall"));
  assert.equal(f.has(skill), false);
  assert.equal(f.read("commands/learn.md"), "user command");
});

test("same-root V1 upgrade replaces a verified older plugin and uninstalls only recorded config entries", (t) => {
  const f = fixture(t);
  const old = spawnSync("git", ["show", "2f6a860:plugins/session-start.ts"], { cwd: root });
  ok({ ...old, stderr: old.stderr.toString(), stdout: old.stdout.toString() });
  const plugin = "plugins/session-start.ts";
  const url = pathToFileURL(path.join(f.dir, plugin)).href;
  const msysURL = process.platform === "win32" ? url.replace(/^file:\/\/\/([a-z]):/i, "file:///$1") : url;
  const template = require("./lib/legacy-config.json");
  const original = {
    $schema: "https://opencode.ai/schema.json",
    agent: { "paper-miner": template.agent["paper-miner"] },
    mcp: { zotero: { ...template.mcp.zotero, enabled: false }, "streamable-mcp-server": template.mcp["streamable-mcp-server"] },
    permission: { ...template.permission, read: "ask", bash: { ...template.permission.bash, "git status *": "allow" } },
    plugin: [msysURL, "file:///unrelated/keep.ts"],
  };
  f.put(plugin, old.stdout);
  f.put(".opencode-scholar-manifest.txt", `${plugin}\n`);
  f.put(state, JSON.stringify({ managedPaths: [plugin], config: {
    addedAgentKeys: ["paper-miner"], addedMcpKeys: ["streamable-mcp-server"],
    addedMcpFields: Object.keys(template.mcp.zotero).filter((field) => field !== "enabled").map((field) => ({ key: "zotero", field })),
    addedPermissionKeys: Object.keys(template.permission).filter((key) => key !== "bash"),
    addedPermissionFields: Object.keys(template.permission.bash).map((field) => ({ key: "bash", field })),
    addedPluginItems: [msysURL],
  } }));
  f.put(config, JSON.stringify(original));
  ok(launch(f.dir, "install"));
  assert.match(f.read(plugin), /Plugin\.define/);
  const upgraded = JSON.parse(f.read(config));
  assert.deepEqual(upgraded.plugin, ["file:///unrelated/keep.ts"]);
  assert.equal(upgraded.$schema, "https://opencode.ai/config.json");
  assert.deepEqual(upgraded.permission, { read: "ask", bash: { "git status *": "allow" } });
  assert.equal(upgraded.permissions, undefined);
  assert.equal(upgraded.agent["paper-miner"], undefined);
  assert.equal(typeof upgraded.agents["paper-miner"].system, "string");
  assert.deepEqual(upgraded.mcp, { zotero: { enabled: false } });
  ok(launch(f.dir, "uninstall"));
  const remaining = JSON.parse(f.read(config));
  assert.equal(f.has(plugin), false);
  assert.deepEqual(remaining.mcp, { zotero: { enabled: false } });
  assert.deepEqual(remaining.permission, { read: "ask", bash: { "git status *": "allow" } });
  assert.deepEqual(remaining.plugin, ["file:///unrelated/keep.ts"]);
});

test("unverified V1 plugin blocks upgrade before writing assets", (t) => {
  const f = fixture(t);
  const plugin = "plugins/session-start.ts";
  f.put(plugin, "custom old plugin");
  f.put(".opencode-scholar-manifest.txt", `${plugin}\n`);
  f.put(state, JSON.stringify({ managedPaths: [plugin] }));
  const result = launch(f.dir, "install");
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /plugins\/session-start\.ts/);
  assert.equal(f.has(skill), false);
  assert.equal(f.read(plugin), "custom old plugin");
});

test("a previous Scholar project install drops only its recorded V2-era legacy entries and permission rules", (t) => {
  const f = fixture(t);
  const oldAgent = { description: "old Scholar definition", prompt: "old prompt" };
  const oldServer = { type: "local", command: ["zotero-mcp", "serve"], enabled: true };
  const scholarRule = { action: "external_directory", resource: "*", effect: "deny" };
  const userRule = { action: "shell", resource: "git status", effect: "ask" };
  const permission = { read: "ask", edit: { "*": "ask", "private.txt": "deny" } };
  f.put(config, JSON.stringify({
    agent: { "paper-miner": oldAgent }, mcp: { zotero: oldServer }, permissions: [scholarRule, userRule], permission,
  }));
  f.put(".opencode-scholar-manifest.txt", "");
  f.put(state, JSON.stringify({ version: 2, configFile: config, managedPaths: [], config: {
    entries: [
      { keys: ["agent", "paper-miner"], value: oldAgent },
      { keys: ["mcp", "zotero"], value: oldServer },
      { keys: ["permission", "edit", "*"], value: "deny" },
      { keys: ["permission", "edit", "private.txt"], value: "deny" },
    ],
    rules: [scholarRule], sections: ["agent", "mcp"],
  } }));
  ok(launch(f.dir, "install"));
  const data = JSON.parse(f.read(config));
  assert.equal(data.agent, undefined);
  assert.equal(typeof data.agents["paper-miner"].system, "string");
  assert.equal(data.mcp.zotero, undefined);
  assert.equal(data.mcp.servers.zotero.enabled, undefined);
  assert.deepEqual(data.permissions, [userRule]);
  assert.deepEqual(data.permission, { read: "ask", edit: { "*": "ask" } });
  ok(launch(f.dir, "uninstall"));
  assert.deepEqual(JSON.parse(f.read(config)), { permissions: [userRule], permission: data.permission });
});

for (const edited of [false, true]) {
  test(`reinstall ${edited ? "preserves an edited" : "removes the unchanged"} browser MCP from a previous project install`, (t) => {
    const f = fixture(t);
    const name = "streamable-mcp-server";
    const previous = { type: "remote", url: "http://127.0.0.1:12306/mcp" };
    const current = edited ? { ...previous, disabled: true } : previous;
    f.put(config, JSON.stringify({ mcp: { servers: { [name]: current } } }));
    f.put(".opencode-scholar-manifest.txt", "");
    f.put(state, JSON.stringify({ version: 3, configFile: ".opencode/opencode.jsonc", managedPaths: [], config: {
      entries: [{ keys: ["mcp", "servers", name], value: previous }],
      sections: ["mcp", ["mcp", "servers"]],
    } }));
    ok(launch(f.dir, "install"));
    const data = JSON.parse(f.read(config));
    assert.deepEqual(data.mcp.servers[name], edited ? current : undefined);
    assert.equal(data.mcp.servers.zotero.type, "local");
    ok(launch(f.dir, "uninstall"));
    assert.deepEqual(JSON.parse(f.read(config)), edited ? { mcp: { servers: { [name]: current } } } : {});
  });
}

test("V1 ownership survives checkout line endings but not content edits", (t) => {
  const f = fixture(t);
  const changed = "commands/tdd.md";
  const alternate = (file) => {
    const current = fs.readFileSync(path.join(root, file), "utf8");
    const lf = current.replaceAll("\r\n", "\n");
    return current === lf ? lf.replaceAll("\n", "\r\n") : lf;
  };
  f.put(skill, alternate(skill));
  const userEdit = alternate(changed) + "\nUser's addition.\n";
  f.put(changed, userEdit);
  f.put(".opencode-scholar-manifest.txt", `${skill}\n${changed}\n`);
  f.put(state, JSON.stringify({ managedPaths: [skill, changed] }));

  ok(launch(f.dir, "install"));
  assert.ok(JSON.parse(f.read(state)).fileHashes[skill], "unchanged V1 skill was not adopted");
  ok(launch(f.dir, "uninstall"));
  assert.equal(f.has(skill), false);
  assert.equal(f.read(changed), userEdit);
});

test("install follows a renamed config and rejects two coexisting configs on reinstall", (t) => {
  const f = fixture(t);
  ok(launch(f.dir, "install"));
  const data = f.read(config);
  f.put("opencode.json", data);
  assert.notEqual(launch(f.dir, "install").status, 0);
  assert.equal(f.read("opencode.json"), data);
  fs.unlinkSync(path.join(f.dir, config));
  ok(launch(f.dir, "install"));
  assert.equal(f.has(config), false);
  ok(launch(f.dir, "uninstall"));
  assert.equal(f.has("opencode.json"), false);
});

test("installed agent paths use the active root rather than the V1 default", (t) => {
  const f = fixture(t);
  ok(launch(f.dir, "install"));
  const { agents } = JSON.parse(f.read(config));
  for (const key of ["paper-miner", "kaggle-miner", "rebuttal-writer"]) {
    assert.ok(agents[key].system.includes(f.dir.replaceAll("\\", "/")), key);
    assert.doesNotMatch(agents[key].system, /~\/\.opencode\//);
  }
  const current = spawnSync(process.execPath, ["-p", "require('./scripts/lib/utils').getOpenCodeConfigDir()"], {
    cwd: root, env: { ...process.env, OPENCODE_DIR: f.dir }, encoding: "utf8",
  });
  ok(current);
  assert.equal(current.stdout.trim(), f.dir);
});
