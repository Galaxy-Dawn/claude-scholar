#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.gemini/config/plugins/claude-scholar"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPONENTS=(skills commands agents rules hooks scripts templates)
CLAUDE_MD_SIDECAR="CLAUDE.scholar.md"
CLAUDE_ZH_MD_SIDECAR="CLAUDE.zh-CN.scholar.md"
BACKUP_ROOT="$CLAUDE_DIR/.claude-scholar-backups"
MANIFEST_FILE="$CLAUDE_DIR/.claude-scholar-manifest.txt"
STATE_FILE="$CLAUDE_DIR/.claude-scholar-install-state"
PREVIOUS_MANAGED_PATHS_FILE="$(mktemp)"
BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_STAMP"
BACKUP_READY=0
BACKUP_COUNT=0
UPDATED_COUNT=0
SKIPPED_COUNT=0
SETTINGS_CREATED=0
MANAGED_PATHS=()
CLAUDE_TARGETS=()
SETTINGS_META_FILE="$(mktemp)"
LEGACY_INSTALL_DETECTED=0

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; exit 1; }

cleanup_temp_files() {
  rm -f "$SETTINGS_META_FILE" "$PREVIOUS_MANAGED_PATHS_FILE"
}

trap cleanup_temp_files EXIT

check_deps() {
  command -v git  >/dev/null || error "Git is required. Install it first."
  command -v node >/dev/null || error "Node.js is required (hooks depend on it). Install it first."
}

load_previous_manifest() {
  if [ -f "$MANIFEST_FILE" ]; then
    cp "$MANIFEST_FILE" "$PREVIOUS_MANAGED_PATHS_FILE"
  else
    : > "$PREVIOUS_MANAGED_PATHS_FILE"
  fi
}

detect_legacy_install() {
  local settings="$CLAUDE_DIR/settings.json"
  [ -f "$MANIFEST_FILE" ] && return 0
  [ -f "$settings" ] || return 0

  if CLAUDE_SETTINGS_TARGET="$settings" node <<'NODE'
const fs = require('fs');
const settings = JSON.parse(fs.readFileSync(process.env.CLAUDE_SETTINGS_TARGET, 'utf8'));
const hookNeedles = [
  '.claude/hooks/security-guard.js',
  '.claude/hooks/session-summary.js',
  '.claude/hooks/session-start.js',
  '.claude/hooks/stop-summary.js',
  '.claude/hooks/skill-forced-eval.js',
];
let detected = false;

for (const matchers of Object.values(settings.hooks || {})) {
  if (!Array.isArray(matchers)) continue;
  for (const matcher of matchers) {
    for (const hook of matcher.hooks || []) {
      if (typeof hook.command === 'string' && hookNeedles.some((needle) => hook.command.includes(needle))) {
        detected = true;
      }
    }
  }
}

process.exit(detected ? 0 : 1);
NODE
  then
    LEGACY_INSTALL_DETECTED=1
  fi
}

record_managed_path() {
  local target="$1"
  local rel="${target#$CLAUDE_DIR/}"
  [ "$rel" = "$target" ] && return 0
  [ -z "$rel" ] && return 0
  MANAGED_PATHS+=("$rel")
}

record_claude_target() {
  local target="$1"
  local rel="${target#$CLAUDE_DIR/}"
  [ "$rel" = "$target" ] && return 0
  [ -z "$rel" ] && return 0
  CLAUDE_TARGETS+=("$rel")
}

was_previously_managed() {
  local target="$1"
  local rel="${target#$CLAUDE_DIR/}"
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

write_install_state() {
  mkdir -p "$CLAUDE_DIR"
  if [ "${#MANAGED_PATHS[@]}" -gt 0 ]; then
    printf "%s\n" "${MANAGED_PATHS[@]}" | LC_ALL=C sort -u > "$MANIFEST_FILE"
  else
    : > "$MANIFEST_FILE"
  fi

  local managed_paths_file
  local claude_targets_file
  managed_paths_file="$(mktemp)"
  claude_targets_file="$(mktemp)"

  if [ "${#MANAGED_PATHS[@]}" -gt 0 ]; then
    printf "%s\n" "${MANAGED_PATHS[@]}" | LC_ALL=C sort -u > "$managed_paths_file"
  else
    : > "$managed_paths_file"
  fi

  if [ "${#CLAUDE_TARGETS[@]}" -gt 0 ]; then
    printf "%s\n" "${CLAUDE_TARGETS[@]}" | LC_ALL=C sort -u > "$claude_targets_file"
  else
    : > "$claude_targets_file"
  fi

  CLAUDE_STATE_FILE="$STATE_FILE" \
  CLAUDE_SETTINGS_META_FILE="$SETTINGS_META_FILE" \
  CLAUDE_MANAGED_PATHS_FILE="$managed_paths_file" \
  CLAUDE_TARGETS_FILE="$claude_targets_file" \
  CLAUDE_INSTALLED_AT="$BACKUP_STAMP" \
  CLAUDE_SOURCE_DIR="$SRC_DIR" \
  CLAUDE_SETTINGS_CREATED="$SETTINGS_CREATED" \
  CLAUDE_BACKUP_DIR="$BACKUP_DIR" \
  CLAUDE_BACKUP_READY="$BACKUP_READY" \
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
  installedAt: process.env.CLAUDE_INSTALLED_AT,
  sourceDir: process.env.CLAUDE_SOURCE_DIR,
  settingsCreated: process.env.CLAUDE_SETTINGS_CREATED === '1',
  backupDir: process.env.CLAUDE_BACKUP_READY === '1' ? process.env.CLAUDE_BACKUP_DIR : '',
  managedPaths: readLines(process.env.CLAUDE_MANAGED_PATHS_FILE),
  claudeTargets: readLines(process.env.CLAUDE_TARGETS_FILE),
  settings: readJson(process.env.CLAUDE_SETTINGS_META_FILE),
};

fs.writeFileSync(process.env.CLAUDE_STATE_FILE, JSON.stringify(state, null, 2) + '\n');
NODE

  rm -f "$managed_paths_file" "$claude_targets_file"
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

  local rel="${target#$CLAUDE_DIR/}"
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

# Create mcp_config.json if not present
create_settings() {
  local target="$HOME/.gemini/config/mcp_config.json"
  if [ ! -f "$target" ]; then
    mkdir -p "$(dirname "$target")"
    echo '{"mcpServers": {}}' > "$target"
    SETTINGS_CREATED=1
    info "Created empty mcp_config.json."
  fi
}

# Merge mcpServers from template into mcp_config.json
merge_settings() {
  local template="$1/settings.json.template"
  local target="$HOME/.gemini/config/mcp_config.json"

  [ -f "$template" ] || return 0
  [ -f "$target" ]   || { create_settings "$1"; }

  # Backup
  backup_path "$target"
  cp "$target" "${target}.bak"
  info "Backed up mcp_config.json → mcp_config.json.bak"

  # Merge mcpServers while preserving user configurations
  CLAUDE_SETTINGS_TARGET="$target" CLAUDE_SETTINGS_TEMPLATE="$template" CLAUDE_SETTINGS_META_FILE="$SETTINGS_META_FILE" node <<'NODE'
const fs = require('fs');

const targetPath = process.env.CLAUDE_SETTINGS_TARGET;
const templatePath = process.env.CLAUDE_SETTINGS_TEMPLATE;
const metaPath = process.env.CLAUDE_SETTINGS_META_FILE;
const existing = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
const template = JSON.parse(fs.readFileSync(templatePath, 'utf8'));
const addedMcpServers = [];
const addedMcpServerFields = {};

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function mergeMissing(existingValue, templateValue, pathParts, addedPaths) {
  if (existingValue === undefined) return clone(templateValue);
  if (templateValue === null || Array.isArray(templateValue) || typeof templateValue !== 'object') {
    return existingValue;
  }

  const output = { ...existingValue };
  for (const [key, value] of Object.entries(templateValue)) {
    if (!(key in output)) {
      output[key] = clone(value);
      addedPaths.push([...pathParts, key].join('.'));
      continue;
    }
    if (
      output[key] &&
      value &&
      !Array.isArray(output[key]) &&
      !Array.isArray(value) &&
      typeof output[key] === 'object' &&
      typeof value === 'object'
    ) {
      output[key] = mergeMissing(output[key], value, [...pathParts, key], addedPaths);
    }
  }
  return output;
}

existing.mcpServers = existing.mcpServers || {};

if (template.mcpServers) {
  for (const [key, value] of Object.entries(template.mcpServers)) {
    if (!(key in existing.mcpServers)) {
      addedMcpServers.push(key);
      existing.mcpServers[key] = clone(value);
      continue;
    }
    const addedPaths = [];
    existing.mcpServers[key] = mergeMissing(existing.mcpServers[key], value, [], addedPaths);
    if (addedPaths.length > 0) {
      addedMcpServerFields[key] = addedPaths;
    }
  }
}

fs.writeFileSync(targetPath, JSON.stringify(existing, null, 2) + '\n');
fs.writeFileSync(metaPath, JSON.stringify({
  addedHooks: [],
  addedMcpServers,
  addedMcpServerFields,
  addedEnabledPlugins: [],
}, null, 2) + '\n');
NODE

  local merge_status=$?
  if [ "$merge_status" -ne 0 ]; then
    warn "Auto-merge failed. Please manually copy mcpServers from settings.json.template."
    return 0
  fi

  info "Merged mcpServers into mcp_config.json without touching existing configurations."
}

# Copy one file with backup-aware overwrite
copy_file_safely() {
  local src_file="$1"
  local target_file="$2"

  mkdir -p "$(dirname "$target_file")"

  if [ -f "$target_file" ] && cmp -s "$src_file" "$target_file"; then
    if should_adopt_existing_path "$target_file"; then
      record_managed_path "$target_file"
    fi
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 0
  fi

  if [ -e "$target_file" ]; then
    backup_path "$target_file"
    [ -d "$target_file" ] && rm -rf "$target_file"
  fi

  cp -p "$src_file" "$target_file"
  record_managed_path "$target_file"
  UPDATED_COUNT=$((UPDATED_COUNT + 1))
}

# Copy component directories with per-file backup
copy_dir_safely() {
  local src_dir="$1"
  local target_dir="$2"

  if [ -e "$target_dir" ] && [ ! -d "$target_dir" ]; then
    backup_path "$target_dir"
    rm -f "$target_dir"
  fi
  mkdir -p "$target_dir"

  while IFS= read -r -d '' src_file; do
    local rel="${src_file#$src_dir/}"
    local target_file="$target_dir/$rel"
    copy_file_safely "$src_file" "$target_file"
  done < <(find "$src_dir" -type f -print0)
}

install_claude_md() {
  local src_file="$1"
  local target_file="$CLAUDE_DIR/CLAUDE.md"
  local sidecar_file="$CLAUDE_DIR/$CLAUDE_MD_SIDECAR"

  if [ -f "$target_file" ] && should_adopt_existing_path "$target_file"; then
    copy_file_safely "$src_file" "$target_file"
    record_claude_target "$target_file"
    return 0
  fi

  if [ -f "$target_file" ]; then
    warn "Preserving existing CLAUDE.md"
    copy_file_safely "$src_file" "$sidecar_file"
    record_claude_target "$sidecar_file"
    info "Installed repository CLAUDE.md as $CLAUDE_MD_SIDECAR"
    return 0
  fi

  copy_file_safely "$src_file" "$target_file"
  record_claude_target "$target_file"
}

install_claude_zh_md() {
  local src_file="$1"
  local target_file="$CLAUDE_DIR/CLAUDE.zh-CN.md"
  local sidecar_file="$CLAUDE_DIR/$CLAUDE_ZH_MD_SIDECAR"

  if [ -f "$target_file" ] && should_adopt_existing_path "$target_file"; then
    copy_file_safely "$src_file" "$target_file"
    record_claude_target "$target_file"
    return 0
  fi

  if [ -f "$target_file" ]; then
    warn "Preserving existing CLAUDE.zh-CN.md"
    copy_file_safely "$src_file" "$sidecar_file"
    record_claude_target "$sidecar_file"
    info "Installed repository CLAUDE.zh-CN.md as $CLAUDE_ZH_MD_SIDECAR"
    return 0
  fi

  copy_file_safely "$src_file" "$target_file"
  record_claude_target "$target_file"
}

copy_components() {
  local src="$1"

  if [ -f "$src/.claude-plugin/plugin.json" ]; then
    copy_file_safely "$src/.claude-plugin/plugin.json" "$CLAUDE_DIR/plugin.json"
    copy_file_safely "$src/.claude-plugin/plugin.json" "$CLAUDE_DIR/plugins.json"
  fi

  if [ -f "$src/CLAUDE.md" ]; then
    install_claude_md "$src/CLAUDE.md"
  fi

  if [ -f "$src/CLAUDE.zh-CN.md" ]; then
    install_claude_zh_md "$src/CLAUDE.zh-CN.md"
  fi

  for comp in "${COMPONENTS[@]}"; do
    if [ -e "$src/$comp" ]; then
      if [ -d "$src/$comp" ]; then
        copy_dir_safely "$src/$comp" "$CLAUDE_DIR/$comp"
      else
        copy_file_safely "$src/$comp" "$CLAUDE_DIR/$comp"
      fi
    fi
  done
  info "Updated components: ${COMPONENTS[*]}"
}

main() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║       Claude Scholar Installer       ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  check_deps
  load_previous_manifest
  detect_legacy_install

  info "Installing from: $SRC_DIR"
  copy_components "$SRC_DIR"
  merge_settings "$SRC_DIR"
  write_install_state
  info "Your existing env/model/API key/permissions settings are preserved."
  info "Install manifest: $MANIFEST_FILE"
  info "Updated files: $UPDATED_COUNT | Unchanged files skipped: $SKIPPED_COUNT | Backups created: $BACKUP_COUNT"
  if [ "$BACKUP_READY" -eq 1 ]; then
    info "Recover previous files from: $BACKUP_DIR"
  fi

  echo ""
  info "Done! Restart Claude Code CLI to activate."
  echo ""
}

main "$@"
