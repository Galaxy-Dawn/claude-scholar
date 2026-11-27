const { isUtf8 } = require("node:buffer");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { createHash } = require("node:crypto");
const { legacyPluginItem, mergeConfig, parseConfig, removeOwned } = require("./lib/install-config.cjs");

const source = path.resolve(__dirname, "..");
let project;
let root;
const manifest = ".opencode-scholar-manifest.txt";
const stateFile = ".opencode-scholar-install-state";
const memory = "skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md";
const stopSummary = "plugins/stop-summary.ts";
const components = ["skills", "commands", "plugins", "scripts", "utils", "templates"];
// Git blob IDs of replaced upstream V1 files; new installs record SHA-256 instead.
const knownV1 = {
  "AGENTS.md": "7fb2323575517594f657757f11d887e776dd44a8",
  "AGENTS.zh-CN.md": "3c827b5beb67d10d75cb5e9d84fdcc00f7879d6e",
  "commands/kb-archive.md": "bae1e78893a93f876988cea461a5f2a8af66a8a5",
  "commands/kb-index.md": "0eca721cb4ea23f85dd0719b478dafeccfbc2ef6",
  "commands/kb-init.md": "a5bf7570855049c57c61d73eae3c13e746155b4e",
  "commands/kb-lint.md": "2b114f0b379f16ac5387d0bb152aeee60738cb4a",
  "commands/kb-status.md": "89c2a236bfdc3dbbeef98eefbc29ee21618309fd",
  "commands/kb-sync.md": "c9beb0adf47639398ef1d28341a18ed56abf1fb8",
  "commands/learn.md": "cdd729b87c5ee33e87ef283f4f34649f26517a3e",
  "commands/mine-writing-patterns.md": "3603d100a81bbe139762cc6e5ff8f7bfbd3eee36",
  "commands/sc/README.md": "4160378f48f19c093987595b9ceac5bfc1678cde",
  "commands/setup-pm.md": "adecdebbc12ceaf77b35210de6d9933fb3e3feca",
  "commands/update-memory.md": "923fc7ec5327d954f94713125b5a88a4f9e683ea",
  "commands/zotero-notes.md": "d3536eb12303d204c5c452ff17ef76d20378608f",
  "plugins/lib/common.ts": "85d9400061bc4f4b0a26daeba0aae8c6d757f4a7",
  "plugins/security-guard.ts": "c0c087b33bc5c9a1993ad29f407adf4a7e06f474",
  "plugins/session-start.ts": "0f082b4af5de39c1cb004819f7a0dd0c0e6f3409",
  "plugins/session-summary.ts": "fa896b7cacfaa386b8241baf51c664b12059aa6c",
  "plugins/skill-eval.ts": "2d0f28e191d96be2d1d88346a3ca8130a52b854a",
  [stopSummary]: "daed2203055867e6e20ac0d725cd64bc8af72671",
  "scripts/lib/utils.js": "4c8072da37c9db7a3da904cd84fcf7b446c54f23",
  "scripts/setup.sh": "ac14c6f211026e8aac13b368d7c51ebc8e69475e",
  "scripts/uninstall.sh": "c780aec7ffe60b02afc34c546cca49936e43907f",
  "skills/obsidian-literature-workflow/references/CANVAS-WORKFLOW.md": "17cae724831174e149df8ffb98f6ae6a5b1b888e",
  "skills/obsidian-literature-workflow/references/GRAPH-WORKFLOW.md": "eb9ffdbffd69ec46f9a964b429e934cdcba4eb51",
  "skills/obsidian-project-kb-core/scripts/kb_common.py": "6801fe7e5756988ad182817959fc90cb0d9fd4a9",
  "skills/ml-paper-writing/SKILL.md": "e982dbdc6b64630ef291ccb93bbc63fdcaf61052",
  "skills/ml-paper-writing/references/knowledge/README.md": "4d08e55f8c49bec2345bba17f57fa3237760d3b4",
  "skills/review-response/SKILL.md": "702a8156a0e300d8680c9c458c2d4c4dad7452d9",
  "skills/zotero-obsidian-bridge/references/WORKFLOW.md": "cf193b1eec45cb470dd69ea5140e65178bd38ce5",
};
// Earlier V1 plugin revisions between 8f82fc5 and 835db0d.
const earlierPlugins = {
  "plugins/lib/common.ts": ["c9a7f99771ff7940fa799d25abf969392446531b", "5e98351dbbd709ce2e5bd6a85b52c483892fb5c8"],
  "plugins/session-start.ts": ["b104554fe6f07c507a2804fdb548c7c4f2b6f070", "d7d320142af3224eaf348025e227089ed6a94006"],
  "plugins/session-summary.ts": ["d91041e715650c5e012911bbbb3ce0b2ba863ac4"],
  "plugins/skill-eval.ts": ["845208d5c99d79aa545675e8df1cff617f273b40", "e24ebf86e53bb78b38c171dd73f135da2a167383",
    "3700e17b604cf108fea8e2167213b41325a24a70", "1c39712446288d6e272c33741089d8f8171308c3"],
};
const info = (message) => console.log(`[INFO] ${message}`);
const warn = (message) => console.warn(`[WARN] ${message}`);
const hash = (data) => createHash("sha256").update(data).digest("hex");
const stat = (file) => fs.lstatSync(file, { throwIfNoEntry: false });
const json = (value) => JSON.stringify(value, null, 2) + "\n";
const backupDirectory = ".opencode-scholar-backups";
const backupRoot = `${backupDirectory}/${new Date().toISOString().replace(/[:.]/g, "-")}-${process.pid}`;
const backupFileOptions = { mode: 0o600, flag: "wx" };
let backedUp = false;

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

function contains(parent, child) {
  const relative = path.relative(parent, child);
  return !path.isAbsolute(relative) && relative !== ".." && !relative.startsWith(`..${path.sep}`);
}

function selectProject(dir) {
  project = fs.realpathSync.native(path.resolve(dir));
  if (!stat(project)?.isDirectory() || project === path.parse(project).root) {
    throw new Error("Choose an existing project directory, not a filesystem root");
  }
  root = path.join(project, ".opencode");
  const home = os.homedir();
  const globalDirs = [
    path.join(home, ".config", "opencode"), path.join(home, ".opencode"),
    process.env.XDG_CONFIG_HOME && path.join(process.env.XDG_CONFIG_HOME, "opencode"),
    process.env.OPENCODE_CONFIG_DIR, process.env.OPENCODE_DIR,
  ].filter(Boolean).map((folder) => realDestination(path.resolve(folder)));
  if (globalDirs.some((dir) => contains(dir, project) || contains(dir, realDestination(root)))) {
    throw new Error("Choose a project directory outside the global OpenCode configuration");
  }
}

function requireOutsideCheckout() {
  const checkout = fs.realpathSync.native(source);
  if (contains(checkout, project) || contains(checkout, realDestination(root))) {
    throw new Error("Choose an installation directory outside the source checkout");
  }
}

// Never follow links beneath the target, including Windows junctions.
function target(rel, base = root) {
  const names = rel.split("/");
  if (names.some((name) => !name || name === "." || name === ".." || /[\\:\r\n]/.test(name))) {
    throw new Error(`Invalid install path: ${rel}`);
  }
  let file = base;
  if (stat(file)?.isSymbolicLink()) throw new Error(`Refusing linked install directory: ${base}`);
  for (const name of names) {
    file = path.join(file, name);
    if (stat(file)?.isSymbolicLink()) throw new Error(`Refusing linked install path: ${file}`);
  }
  return file;
}

function read(rel, base = root) {
  const file = target(rel, base);
  const meta = stat(file);
  if (!meta) return undefined;
  if (!meta.isFile()) throw new Error(`Not a regular file: ${file}`);
  return fs.readFileSync(file);
}

function write(rel, value, mode, base = root) {
  const file = target(rel, base);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, value, { mode });
}

function backup(rel, content) {
  const file = target(`${backupRoot}/${rel}`);
  if (!backedUp) {
    const directory = target(backupDirectory);
    fs.mkdirSync(directory, { recursive: true, mode: 0o700 });
    if (process.platform !== "win32") {
      // Older installs may have created a searchable backup directory.
      const { O_RDONLY, O_DIRECTORY, O_NOFOLLOW } = fs.constants;
      const fd = fs.openSync(directory, O_RDONLY | O_DIRECTORY | O_NOFOLLOW);
      try {
        fs.fchmodSync(fd, 0o700);
      } finally {
        fs.closeSync(fd);
      }
    }
  }
  fs.mkdirSync(path.dirname(file), { recursive: true, mode: 0o700 });
  fs.writeFileSync(file, content, backupFileOptions);
  if (!backedUp) info(`Previous files backed up in ${path.join(root, backupRoot)}`);
  backedUp = true;
}

function knownV1File(rel, content) {
  const key = rel.replace(/\.scholar\.md$/, ".md");
  if (!knownV1[key]) return false;
  const normalized = Buffer.from(content.toString("utf8").replace(/\r\n/g, "\n"));
  const gitBlob = createHash("sha1").update(`blob ${normalized.length}\0`).update(normalized).digest("hex");
  return gitBlob === knownV1[key] || !!earlierPlugins[key]?.includes(gitBlob);
}

function* collect(dir) {
  for (const item of fs.readdirSync(path.join(source, dir), { withFileTypes: true })) {
    if (["__pycache__", ".pytest_cache"].includes(item.name) || /\.py[co]$/.test(item.name)) continue;
    const rel = `${dir}/${item.name}`;
    if (item.isDirectory()) yield* collect(rel);
    else if (item.isFile() && rel !== stopSummary && !/^scripts\/test_/.test(rel)) yield rel;
  }
}

function loadInstall() {
  const oldPaths = read(manifest)?.toString("utf8").split(/\r?\n/).filter(Boolean);
  const previous = JSON.parse(read(stateFile)?.toString("utf8") || "{}");
  if (!previous || typeof previous !== "object" || Array.isArray(previous)) throw new Error("Invalid install state");
  const paths = new Set(oldPaths || []);
  if (oldPaths && previous.managedPaths) {
    const verified = new Set(previous.managedPaths);
    for (const rel of paths) if (!verified.has(rel)) paths.delete(rel);
  }
  return { previous, paths, hasState: !!oldPaths && Object.hasOwn(previous, "managedPaths") };
}

function ownedFile(previous, paths, rel, content) {
  if (!paths.has(rel)) return false;
  if (previous.fileHashes?.[rel]) return hash(content) === previous.fileHashes[rel];
  if (knownV1File(rel, content)) return true;
  const original = path.join(source, rel);
  if (!fs.statSync(original, { throwIfNoEntry: false })?.isFile()) return false;
  const current = fs.readFileSync(original);
  if (current.equals(content)) return true;
  // V1 recorded paths but not hashes. Only normalize checkout line endings
  // for UTF-8 text; V2 ownership remains based on the exact recorded bytes.
  return previous.version === undefined &&
    !current.includes(0) && !content.includes(0) && isUtf8(current) && isUtf8(content) &&
    current.toString("utf8").replaceAll("\r\n", "\n") === content.toString("utf8").replaceAll("\r\n", "\n");
}

const projectConfigs = ["opencode.json", "opencode.jsonc", ".opencode/opencode.json", ".opencode/opencode.jsonc"];

function previousConfig(previous) {
  if (!previous.configFile) return undefined;
  const file = previous.version === 3 ? previous.configFile : `.opencode/${previous.configFile}`;
  if (!projectConfigs.includes(file) || (previous.version !== 3 && !file.startsWith(".opencode/"))) {
    throw new Error("Unexpected configuration path in install state");
  }
  return file;
}

function configName(previousFile) {
  const candidates = projectConfigs.filter((name) => stat(target(name, project)));
  if (candidates.length > 1) throw new Error(`Multiple project configurations exist (${candidates.join(", ")}); consolidate them first`);
  return candidates[0] || previousFile || ".opencode/opencode.jsonc";
}

function setConfig(rel, old, value) {
  if (old) {
    backup(rel.replace(/^\.opencode\//, ""), old);
    const sidecar = target(`${rel}.bak`, project);
    if (!stat(sidecar)) {
      try {
        fs.writeFileSync(sidecar, old, backupFileOptions);
      } catch (error) {
        if (error.code !== "EEXIST") throw error;
      }
    }
  }
  if (value === undefined) fs.unlinkSync(target(rel, project));
  else write(rel, json(value), undefined, project);
}

function requireKnownConfig(configFile, previousFile, original, previous) {
  if (previousFile && configFile !== previousFile && original && hash(original) !== previous.configSha256) {
    throw new Error(`Cannot verify ${configFile} as the original ${previousFile}; restore its original name and location, then retry`);
  }
}

function install() {
  requireOutsideCheckout();
  const { previous, paths, hasState } = loadInstall();
  const previousFile = previousConfig(previous);
  const configFile = configName(previousFile);
  const original = read(configFile, project);
  if (hasState) requireKnownConfig(configFile, previousFile, original, previous);
  const config = parseConfig(original?.toString("utf8") ?? "{}");
  const before = JSON.stringify(config);
  const legacy = !hasState && [config.plugin, config.plugins].some(
    (items) => Array.isArray(items) && items.some((item) => legacyPluginItem(item, root)),
  );
  const v1 = hasState && previous.version === undefined;
  const configState = hasState ? previous : {};
  const template = parseConfig(fs.readFileSync(path.join(source, "opencode.jsonc"), "utf8"));
  for (const rel of Object.keys(knownV1).filter((name) => name.startsWith("plugins/"))) {
    const existing = read(rel);
    if (!existing) continue;
    const from = path.join(source, rel);
    if (rel !== stopSummary && fs.readFileSync(from).equals(existing)) continue;
    const verified = ownedFile(previous, paths, rel, existing) || (legacy && knownV1File(rel, existing));
    if (!verified && (v1 || legacy)) {
      throw new Error(`Cannot verify the legacy file ${rel}; back it up and move it out of ${root} before upgrading`);
    }
  }
  const localInstructions = read("AGENTS.md");
  const userInstructions = ["AGENTS.md", "CLAUDE.md"].some((name) => fs.existsSync(path.join(project, name)));
  const instructions = !userInstructions && (!localInstructions || ownedFile(previous, paths, "AGENTS.md", localInstructions))
    ? ".opencode/AGENTS.md" : undefined;
  const ownership = mergeConfig(config, template, root, configState, legacy, instructions, warn);
  const fileHashes = Object.create(null);
  const agentsTargets = [];
  const managedPaths = [];
  const configCreated = !original || (configState.configCreated && hash(original) === configState.configSha256);

  function copy(src, dest = src) {
    const from = path.join(source, src);
    const contents = fs.readFileSync(from);
    const existing = read(dest);
    if (dest === memory && existing) return true;
    const owned = existing && (ownedFile(previous, paths, dest, existing) ||
      (legacy && dest.startsWith("plugins/") && knownV1File(dest, existing)));
    const identical = existing?.equals(contents);
    if (existing && !owned && !identical) {
      warn(`Keeping existing file: ${dest}`);
      return false;
    }
    if (!identical) {
      if (existing) backup(dest, existing);
      write(dest, contents, fs.statSync(from).mode);
    }
    if (dest !== memory && (!existing || owned || (legacy && identical))) {
      managedPaths.push(dest);
      fileHashes[dest] = hash(contents);
    }
    return true;
  }

  for (const rel of ["AGENTS.md", "AGENTS.zh-CN.md"]) {
    const existing = read(rel);
    const dest = existing && !ownedFile(previous, paths, rel, existing)
      ? rel.replace(/\.md$/, ".scholar.md") : rel;
    if (copy(rel, dest)) agentsTargets.push(dest);
  }
  for (const component of components) {
    if (stat(path.join(source, component))?.isDirectory()) {
      for (const rel of collect(component)) copy(rel);
    }
  }
  const oldStop = read(stopSummary);
  if (oldStop && (paths.has(stopSummary) || legacy) && knownV1File(stopSummary, oldStop)) {
    backup(stopSummary, oldStop);
    fs.unlinkSync(target(stopSummary));
  }
  if (!original || before !== JSON.stringify(config)) setConfig(configFile, original, config);
  managedPaths.sort();
  write(manifest, managedPaths.length ? managedPaths.join("\n") + "\n" : "");
  write(stateFile, json({
    version: 3, configFile, configCreated, configSha256: hash(read(configFile, project)),
    sourceDir: source, managedPaths, agentsTargets, fileHashes, config: ownership,
  }));
  info(`Installed OpenCode Scholar for ${project}. Open that project in OpenCode, or use /reload.`);
}

function uninstall() {
  const { previous, paths, hasState } = loadInstall();
  if (!hasState || ![2, 3].includes(previous.version)) throw new Error("Scholar install state not found; refusing to guess ownership");
  const previousFile = previousConfig(previous);
  const configFile = configName(previousFile);
  const original = read(configFile, project);
  if (original) {
    requireKnownConfig(configFile, previousFile, original, previous);
    const unchanged = hash(original) === previous.configSha256;
    const config = parseConfig(original.toString("utf8"));
    if (previous.configCreated && unchanged) setConfig(configFile, original);
    else {
      const before = JSON.stringify(config);
      removeOwned(config, previous.config || {}, warn);
      if (before !== JSON.stringify(config)) setConfig(configFile, original, config);
    }
  }
  for (const rel of paths) {
    if (rel === memory) continue;
    try {
      const content = read(rel);
      if (!content) continue;
      if (!previous.fileHashes?.[rel] || !ownedFile(previous, paths, rel, content)) {
        warn(`Keeping changed or unverified file: ${rel}`);
        continue;
      }
      fs.unlinkSync(target(rel));
    } catch (error) {
      warn(`Keeping ${rel}: ${error.message}`);
    }
  }
  fs.unlinkSync(target(manifest));
  fs.unlinkSync(target(stateFile));
  info(`Removed verified Scholar files from ${root}. User writing memory and backups were kept.`);
}

try {
  const [operation, directory, ...extra] = process.argv.slice(2);
  if (!["install", "uninstall"].includes(operation) || !directory?.trim() || extra.length) {
    throw new Error("Usage: node scripts/install.cjs install|uninstall <project-directory>");
  }
  selectProject(directory);
  if (operation === "install") install();
  else uninstall();
} catch (error) {
  console.error(`[ERROR] ${error.message}`);
  process.exitCode = 1;
}
