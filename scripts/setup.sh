#!/usr/bin/env bash
# ============================================================
# Claude Scholar — OpenCode Installer
# ============================================================
# Usage: bash scripts/setup.sh
# Supports fresh install and safe incremental updates.

set -euo pipefail

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPONENTS=(skills commands plugins scripts utils templates)
AGENTS_MD_SIDECAR="AGENTS.scholar.md"
AGENTS_ZH_MD_SIDECAR="AGENTS.zh-CN.scholar.md"
BACKUP_ROOT="$OPENCODE_DIR/.opencode-scholar-backups"
MANIFEST_FILE="$OPENCODE_DIR/.opencode-scholar-manifest.txt"
STATE_FILE="$OPENCODE_DIR/.opencode-scholar-install-state"
PREVIOUS_MANAGED_PATHS_FILE="$(mktemp)"
CONFIG_META_FILE="$(mktemp)"
BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_STAMP"
BACKUP_READY=0
BACKUP_COUNT=0
UPDATED_COUNT=0
SKIPPED_COUNT=0
CONFIG_CREATED=0
CONFIG_SHA256=""
LEGACY_INSTALL_DETECTED=0
MANAGED_PATHS=()
AGENTS_TARGETS=()

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; exit 1; }

cleanup_temp_files() {
  rm -f "$PREVIOUS_MANAGED_PATHS_FILE" "$CONFIG_META_FILE"
}
trap cleanup_temp_files EXIT

check_deps() {
  command -v git  >/dev/null || error "Git is required. Install it first."
  command -v node >/dev/null || error "Node.js is required. Install it first."
  if ! command -v opencode >/dev/null 2>&1; then
    warn "OpenCode CLI was not found in PATH. Install or update OpenCode before using the installed workflow."
  fi
}

load_previous_manifest() {
  if [ -f "$MANIFEST_FILE" ]; then
    cp "$MANIFEST_FILE" "$PREVIOUS_MANAGED_PATHS_FILE"
  else
    : > "$PREVIOUS_MANAGED_PATHS_FILE"
  fi
}

detect_legacy_install() {
  local config="$OPENCODE_DIR/opencode.jsonc"
  [ -f "$MANIFEST_FILE" ] && return 0
  [ -f "$config" ] || return 0

  if grep -q "$OPENCODE_DIR/plugins/\|file://.*/plugins/" "$config" 2>/dev/null; then
    LEGACY_INSTALL_DETECTED=1
  fi
}

record_managed_path() {
  local target="$1"
  local rel="${target#$OPENCODE_DIR/}"
  [ "$rel" = "$target" ] && return 0
  [ -z "$rel" ] && return 0
  MANAGED_PATHS+=("$rel")
}

record_agents_target() {
  local target="$1"
  local rel="${target#$OPENCODE_DIR/}"
  [ "$rel" = "$target" ] && return 0
  [ -z "$rel" ] && return 0
  AGENTS_TARGETS+=("$rel")
}

was_previously_managed() {
  local target="$1"
  local rel="${target#$OPENCODE_DIR/}"
  [ "$rel" = "$target" ] && return 1
  grep -Fxq "$rel" "$PREVIOUS_MANAGED_PATHS_FILE"
}

should_adopt_existing_path() {
  local target="$1"
  if was_previously_managed "$target"; then
    return 0
  fi
  [ "$LEGACY_INSTALL_DETECTED" -eq 1 ]
}

file_sha256() {
  local target="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$target" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target" | awk '{print $1}'
  else
    printf ''
  fi
}

write_install_state() {
  mkdir -p "$OPENCODE_DIR"
  if [ "${#MANAGED_PATHS[@]}" -gt 0 ]; then
    printf "%s\n" "${MANAGED_PATHS[@]}" | LC_ALL=C sort -u > "$MANIFEST_FILE"
  else
    : > "$MANIFEST_FILE"
  fi

  local managed_paths_file agents_targets_file
  managed_paths_file="$(mktemp)"
  agents_targets_file="$(mktemp)"

  if [ "${#MANAGED_PATHS[@]}" -gt 0 ]; then
    printf "%s\n" "${MANAGED_PATHS[@]}" | LC_ALL=C sort -u > "$managed_paths_file"
  else
    : > "$managed_paths_file"
  fi

  if [ "${#AGENTS_TARGETS[@]}" -gt 0 ]; then
    printf "%s\n" "${AGENTS_TARGETS[@]}" | LC_ALL=C sort -u > "$agents_targets_file"
  else
    : > "$agents_targets_file"
  fi

  OPENCODE_STATE_FILE="$STATE_FILE" \
  OPENCODE_CONFIG_META_FILE="$CONFIG_META_FILE" \
  OPENCODE_MANAGED_PATHS_FILE="$managed_paths_file" \
  OPENCODE_AGENTS_TARGETS_FILE="$agents_targets_file" \
  OPENCODE_INSTALLED_AT="$BACKUP_STAMP" \
  OPENCODE_SOURCE_DIR="$SRC_DIR" \
  OPENCODE_CONFIG_CREATED="$CONFIG_CREATED" \
  OPENCODE_CONFIG_SHA256="$CONFIG_SHA256" \
  OPENCODE_BACKUP_DIR="$BACKUP_DIR" \
  OPENCODE_BACKUP_READY="$BACKUP_READY" \
  node <<'NODE'
const fs = require('fs');

function readLines(path) {
  if (!path || !fs.existsSync(path)) return [];
  return fs.readFileSync(path, 'utf8').split('\n').map((line) => line.trim()).filter(Boolean);
}

function readJson(path) {
  if (!path || !fs.existsSync(path)) return {};
  return JSON.parse(fs.readFileSync(path, 'utf8'));
}

const state = {
  installedAt: process.env.OPENCODE_INSTALLED_AT,
  sourceDir: process.env.OPENCODE_SOURCE_DIR,
  configCreated: process.env.OPENCODE_CONFIG_CREATED === '1',
  configSha256: process.env.OPENCODE_CONFIG_SHA256 || '',
  backupDir: process.env.OPENCODE_BACKUP_READY === '1' ? process.env.OPENCODE_BACKUP_DIR : '',
  managedPaths: readLines(process.env.OPENCODE_MANAGED_PATHS_FILE),
  agentsTargets: readLines(process.env.OPENCODE_AGENTS_TARGETS_FILE),
  config: readJson(process.env.OPENCODE_CONFIG_META_FILE),
};

fs.writeFileSync(process.env.OPENCODE_STATE_FILE, JSON.stringify(state, null, 2) + '\n');
NODE

  rm -f "$managed_paths_file" "$agents_targets_file"
}

ensure_backup_dir() {
  if [ "$BACKUP_READY" -eq 0 ]; then
    mkdir -p "$BACKUP_DIR"
    BACKUP_READY=1
    info "Backup directory: $BACKUP_DIR"
  fi
}

backup_path() {
  local target="$1"
  [ -e "$target" ] || return 0

  ensure_backup_dir

  local rel="${target#$OPENCODE_DIR/}"
  if [ "$rel" = "$target" ]; then
    rel="$(basename "$target")"
  fi

  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  if [ -d "$target" ]; then
    cp -R "$target" "$BACKUP_DIR/$rel"
  else
    cp -p "$target" "$BACKUP_DIR/$rel"
  fi
  BACKUP_COUNT=$((BACKUP_COUNT + 1))
}

ensure_parent_dir() {
  local target_path="$1"
  local parent_dir
  parent_dir="$(dirname "$target_path")"

  if [ -e "$parent_dir" ] && [ ! -d "$parent_dir" ]; then
    backup_path "$parent_dir"
    rm -rf "$parent_dir"
  fi

  mkdir -p "$parent_dir"
}

copy_file_safely() {
  local src_file="$1"
  local target_file="$2"

  ensure_parent_dir "$target_file"

  # Mined writing knowledge is user data, not an installer-managed skill file.
  if [ "$target_file" = "$OPENCODE_DIR/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md" ]; then
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
      [ -f "$target_file" ] || [ -L "$target_file" ] || error "Writing memory path is not a file: $target_file"
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      return 0
    fi
    cp -p "$src_file" "$target_file"
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
    return 0
  fi

  if [ -f "$target_file" ] && [ ! -L "$target_file" ] && cmp -s "$src_file" "$target_file"; then
    if should_adopt_existing_path "$target_file"; then
      record_managed_path "$target_file"
    fi
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 0
  fi

  if [ -e "$target_file" ]; then
    backup_path "$target_file"
    rm -rf "$target_file"
  fi

  cp -p "$src_file" "$target_file"
  record_managed_path "$target_file"
  UPDATED_COUNT=$((UPDATED_COUNT + 1))
}

copy_dir_safely() {
  local src_dir="$1"
  local target_dir="$2"

  if [ -L "$target_dir" ] || { [ -e "$target_dir" ] && [ ! -d "$target_dir" ]; }; then
    backup_path "$target_dir"
    rm -rf "$target_dir"
  fi
  ensure_parent_dir "$target_dir/.dir"
  mkdir -p "$target_dir"

  while IFS= read -r -d '' src_file; do
    local rel="${src_file#$src_dir/}"
    local target_file="$target_dir/$rel"
    copy_file_safely "$src_file" "$target_file"
  done < <(find "$src_dir" -type f -print0)
}

install_agents_md() {
  local src_file="$1"
  local target_file="$OPENCODE_DIR/AGENTS.md"
  local sidecar_file="$OPENCODE_DIR/$AGENTS_MD_SIDECAR"

  if [ -f "$target_file" ] && should_adopt_existing_path "$target_file"; then
    copy_file_safely "$src_file" "$target_file"
    record_agents_target "$target_file"
    return 0
  fi

  if [ -f "$target_file" ]; then
    warn "Preserving existing AGENTS.md"
    copy_file_safely "$src_file" "$sidecar_file"
    record_agents_target "$sidecar_file"
    info "Installed repository AGENTS.md as $AGENTS_MD_SIDECAR"
    return 0
  fi

  copy_file_safely "$src_file" "$target_file"
  record_agents_target "$target_file"
}

install_agents_zh_md() {
  local src_file="$1"
  local target_file="$OPENCODE_DIR/AGENTS.zh-CN.md"
  local sidecar_file="$OPENCODE_DIR/$AGENTS_ZH_MD_SIDECAR"

  if [ -f "$target_file" ] && should_adopt_existing_path "$target_file"; then
    copy_file_safely "$src_file" "$target_file"
    record_agents_target "$target_file"
    return 0
  fi

  if [ -f "$target_file" ]; then
    warn "Preserving existing AGENTS.zh-CN.md"
    copy_file_safely "$src_file" "$sidecar_file"
    record_agents_target "$sidecar_file"
    info "Installed repository AGENTS.zh-CN.md as $AGENTS_ZH_MD_SIDECAR"
    return 0
  fi

  copy_file_safely "$src_file" "$target_file"
  record_agents_target "$target_file"
}

copy_components() {
  local src="$1"

  if [ -f "$src/AGENTS.md" ]; then
    install_agents_md "$src/AGENTS.md"
  fi
  if [ -f "$src/AGENTS.zh-CN.md" ]; then
    install_agents_zh_md "$src/AGENTS.zh-CN.md"
  fi

  for comp in "${COMPONENTS[@]}"; do
    if [ -e "$src/$comp" ]; then
      if [ -d "$src/$comp" ]; then
        copy_dir_safely "$src/$comp" "$OPENCODE_DIR/$comp"
      else
        copy_file_safely "$src/$comp" "$OPENCODE_DIR/$comp"
      fi
    fi
  done
  info "Updated components: ${COMPONENTS[*]}"
}

# Merge agent, mcp, permission, and plugin entries from opencode.jsonc.
# The merge records exactly which config keys/items were added, so uninstall can
# remove only installer-owned entries and preserve user-owned config.
merge_opencode_config() {
  local template="$1/opencode.jsonc"
  local target="$OPENCODE_DIR/opencode.jsonc"

  [ -f "$template" ] || return 0

  if [ -f "$target" ]; then
    backup_path "$target"
    cp "$target" "${target}.bak"
    info "Backed up opencode.jsonc → opencode.jsonc.bak"
  fi

  OPENCODE_TARGET="$target" \
  OPENCODE_TEMPLATE="$template" \
  OPENCODE_HOME="$OPENCODE_DIR" \
  OPENCODE_CONFIG_META_FILE="$CONFIG_META_FILE" \
  node <<'NODE'
const fs = require('fs');
const path = require('path');
const { pathToFileURL } = require('url');

const targetPath = process.env.OPENCODE_TARGET;
const templatePath = process.env.OPENCODE_TEMPLATE;
const opencodeHome = process.env.OPENCODE_HOME;
const metaPath = process.env.OPENCODE_CONFIG_META_FILE;

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function readJson(pathName, fallback) {
  if (!fs.existsSync(pathName)) return fallback;
  return JSON.parse(fs.readFileSync(pathName, 'utf8'));
}

function setNested(target, segments, value) {
  let cur = target;
  for (let i = 0; i < segments.length - 1; i++) {
    const key = segments[i];
    if (!cur[key] || Array.isArray(cur[key]) || typeof cur[key] !== 'object') cur[key] = {};
    cur = cur[key];
  }
  cur[segments[segments.length - 1]] = clone(value);
}

function mergeMissing(target, template, prefix, addedFields) {
  if (!template || Array.isArray(template) || typeof template !== 'object') return clone(target ?? template);
  const output = target && !Array.isArray(target) && typeof target === 'object' ? clone(target) : {};
  for (const [key, value] of Object.entries(template)) {
    const nextPath = [...prefix, key];
    if (!(key in output)) {
      output[key] = clone(value);
      addedFields.push(nextPath.join('.'));
      continue;
    }
    if (
      output[key] && value &&
      !Array.isArray(output[key]) && !Array.isArray(value) &&
      typeof output[key] === 'object' && typeof value === 'object'
    ) {
      output[key] = mergeMissing(output[key], value, nextPath, addedFields);
    }
  }
  return output;
}

const existed = fs.existsSync(targetPath);
const existing = readJson(targetPath, {});
const template = readJson(templatePath, {});
const merged = clone(existing);
const meta = {
  configCreated: !existed,
  addedAgentKeys: [],
  addedMcpKeys: [],
  addedMcpFields: [],
  addedPermissionKeys: [],
  addedPermissionFields: [],
  addedPluginItems: [],
};

if (template.$schema && !merged.$schema) merged.$schema = template.$schema;

merged.agent = merged.agent && typeof merged.agent === 'object' && !Array.isArray(merged.agent) ? merged.agent : {};
for (const [key, value] of Object.entries(template.agent || {})) {
  if (!(key in (existing.agent || {}))) {
    meta.addedAgentKeys.push(key);
  }
  merged.agent[key] = clone(value);
}

merged.permission = merged.permission && typeof merged.permission === 'object' && !Array.isArray(merged.permission) ? merged.permission : {};
for (const [key, value] of Object.entries(template.permission || {})) {
  if (!(key in (existing.permission || {}))) {
    meta.addedPermissionKeys.push(key);
    merged.permission[key] = clone(value);
    continue;
  }
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    const fields = [];
    merged.permission[key] = mergeMissing(merged.permission[key], value, [key], fields);
    meta.addedPermissionFields.push(...fields.map((field) => ({ key, field: field.split('.').slice(1).join('.') })));
  }
}

merged.mcp = merged.mcp && typeof merged.mcp === 'object' && !Array.isArray(merged.mcp) ? merged.mcp : {};
for (const [key, value] of Object.entries(template.mcp || {})) {
  if (!(key in (existing.mcp || {}))) {
    meta.addedMcpKeys.push(key);
    merged.mcp[key] = clone(value);
    continue;
  }
  const fields = [];
  merged.mcp[key] = mergeMissing(merged.mcp[key], value, [key], fields);
  meta.addedMcpFields.push(...fields.map((field) => ({ key, field: field.split('.').slice(1).join('.') })));
}

const plugin = Array.isArray(existing.plugin) ? clone(existing.plugin) : [];
const seen = new Set(plugin.map((item) => JSON.stringify(item)));
const pluginCandidates = [...(template.plugin || [])];
const repoManagedPlugins = [
  'session-summary.ts',
  'session-start.ts',
  'security-guard.ts',
  'skill-eval.ts',
  'stop-summary.ts',
]
  .map((name) => path.join(opencodeHome, 'plugins', name))
  .filter((pluginPath) => fs.existsSync(pluginPath))
  .map((pluginPath) => pathToFileURL(pluginPath).href);
pluginCandidates.push(...repoManagedPlugins);

for (const item of pluginCandidates) {
  const sig = JSON.stringify(item);
  if (!seen.has(sig)) {
    plugin.push(clone(item));
    meta.addedPluginItems.push(clone(item));
    seen.add(sig);
  }
}
merged.plugin = plugin;

fs.writeFileSync(targetPath, JSON.stringify(merged, null, 2) + '\n');
fs.writeFileSync(metaPath, JSON.stringify(meta, null, 2) + '\n');
NODE

  local merge_status=$?
  if [ "$merge_status" -ne 0 ]; then
    warn "Auto-merge failed. Please manually copy settings from opencode.jsonc."
    return 0
  fi

  if grep -q '"configCreated": true' "$CONFIG_META_FILE"; then
    CONFIG_CREATED=1
  fi
  CONFIG_SHA256="$(file_sha256 "$target")"
  info "Merged agent/mcp/permission/plugin into opencode.jsonc without touching env/model/API key/provider/auth fields."
}

main() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║   Claude Scholar Installer (OpenCode)║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  check_deps
  mkdir -p "$OPENCODE_DIR"
  load_previous_manifest
  detect_legacy_install

  info "Installing from: $SRC_DIR"
  info "Target: $OPENCODE_DIR"
  copy_components "$SRC_DIR"
  merge_opencode_config "$SRC_DIR"
  write_install_state

  info "Your existing env/model/API key/provider/auth settings are preserved."
  info "Install manifest: $MANIFEST_FILE"
  info "Install state: $STATE_FILE"
  info "Updated files: $UPDATED_COUNT | Unchanged files skipped: $SKIPPED_COUNT | Backups created: $BACKUP_COUNT"
  if [ "$BACKUP_READY" -eq 1 ]; then
    info "Recover previous files from: $BACKUP_DIR"
  fi

  echo ""
  info "Done! Restart OpenCode CLI to activate."
  echo ""
}

main "$@"
