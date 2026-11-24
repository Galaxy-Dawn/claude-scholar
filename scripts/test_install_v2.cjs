const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");
const { pathToFileURL } = require("node:url");
const { test } = require("node:test");
const { parseConfig } = require("./lib/install-config.cjs");

const root = path.resolve(__dirname, "..");
const memory = "skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md";
const skill = "skills/daily-coding/SKILL.md";
const state = ".opencode-scholar-install-state";
const config = "opencode.jsonc";
const legacyURL = (dir) => pathToFileURL(path.join(dir, "plugins/session-summary.ts")).href;

function fixture(t) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "scholar test 测试 "));
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
  return {
    dir,
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
  const result = spawnSync(program, args, {
    cwd,
    env: { ...process.env, OPENCODE_DIR: dir },
    encoding: "utf8",
  });
  assert.ifError(result.error);
  return result;
}

function ok(result) {
  assert.equal(result.status, 0, result.stderr + result.stdout);
}

const shells = ["bash"];
if (process.platform === "win32") shells.push("powershell.exe", "pwsh.exe");
for (const shell of shells) {
  test(`${shell}: install, reinstall and uninstall share ownership`, (t) => {
    const f = fixture(t);
    ok(launch(f.dir, "install", shell));
    const data = JSON.parse(f.read(config));
    assert.equal(data.permission.external_directory, "deny");
    assert.equal(data.permission.shell["git reset --hard *"], "deny");
    assert.equal(data.permission.write, undefined);
    assert.equal(data.plugin, undefined);
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
  assert.equal(first.permission.edit["*"], "ask");
  assert.equal(Object.keys(first.permission.edit).at(-1), "*");
  assert.equal(first.permission["*"], "allow");
  assert.equal(first.mcp.zotero.enabled, false);
  assert.equal(first.plugin[0], "file:///user/keep.ts");
  assert.equal(f.read("opencode.jsonc.bak"), user);
  assert.equal(f.read("AGENTS.md"), "my own instructions");
  assert.equal(f.has("AGENTS.scholar.md"), true);
  f.put(skill, "custom skill contents");
  f.put(memory, "user research");
  first.agent["paper-miner"].description = "mine now";
  f.put(config, JSON.stringify(first));
  ok(launch(f.dir, "install"));
  ok(launch(f.dir, "uninstall"));
  assert.equal(f.read(skill), "custom skill contents");
  assert.equal(f.read(memory), "user research");
  assert.equal(f.read("AGENTS.md"), "my own instructions");
  assert.equal(f.has("AGENTS.scholar.md"), false);
  const remaining = JSON.parse(f.read(config));
  assert.equal(remaining.agent["paper-miner"].description, "mine now");
  assert.equal(remaining.agent["code-reviewer"].description, "custom");
  assert.deepEqual(remaining.permission, { "*": "allow", edit: { "*": "ask" } });
  assert.deepEqual(remaining.mcp.zotero, { enabled: false });
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
    let destination = path.join(source, "new", "config");
    if (variant === "different case") {
      destination = path.join(f.dir, "SOURCE");
      if (!fs.existsSync(destination)) return t.skip("case-sensitive filesystem");
    } else if (variant === "linked ancestor") {
      const link = path.join(f.dir, "source-link");
      fs.symlinkSync(source, link, process.platform === "win32" ? "junction" : "dir");
      destination = path.join(link, "new", "config");
    }
    const result = launch(destination, "install", undefined, source);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /outside the source checkout/);
    assert.equal(f.has(`source/${state}`), false);
    assert.equal(f.has("source/new"), false);
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
  const template = parseConfig(fs.readFileSync(path.join(root, config), "utf8"));
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
  assert.equal(upgraded.permission.read, "ask");
  assert.equal(upgraded.permission.bash["git status *"], "allow");
  assert.equal(upgraded.permission.bash["npm publish*"], "deny");
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
  const { agent } = JSON.parse(f.read(config));
  for (const key of ["paper-miner", "kaggle-miner", "rebuttal-writer"]) {
    assert.ok(agent[key].prompt.includes(f.dir.replaceAll("\\", "/")), key);
    assert.doesNotMatch(agent[key].prompt, /~\/\.opencode\//);
  }
  const current = spawnSync(process.execPath, ["-p", "require('./scripts/lib/utils').getOpenCodeConfigDir()"], {
    cwd: root, env: { ...process.env, OPENCODE_DIR: f.dir }, encoding: "utf8",
  });
  ok(current);
  assert.equal(current.stdout.trim(), f.dir);
});
