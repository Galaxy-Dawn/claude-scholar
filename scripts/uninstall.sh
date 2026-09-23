#!/usr/bin/env bash
# ============================================================
# Claude Scholar — OpenCode Uninstaller
# ============================================================
# Usage: bash scripts/uninstall.sh
# Removes only files and opencode.jsonc entries recorded by the installer state.

set -euo pipefail

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"
MANIFEST_FILE="$OPENCODE_DIR/.opencode-scholar-manifest.txt"
STATE_FILE="$OPENCODE_DIR/.opencode-scholar-install-state"
COMPONENT_DIRS=(skills commands plugins scripts utils templates)

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; exit 1; }

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

require_state() {
  [ -f "$MANIFEST_FILE" ] || error "Install manifest not found: $MANIFEST_FILE. Refusing to guess ownership."
  [ -f "$STATE_FILE" ] || error "Install state not found: $STATE_FILE. Refusing to guess ownership."
  command -v node >/dev/null || error "Node.js is required. Install it first."
}

remove_managed_paths() {
  local removed=0
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    [ "$rel" = "skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md" ] && continue
    case "$rel" in
      /*|*..*)
        warn "Skipping suspicious manifest path: $rel"
        continue
        ;;
    esac
    local target="$OPENCODE_DIR/$rel"
    if [ -e "$target" ] || [ -L "$target" ]; then
      rm -rf "$target"
      removed=$((removed + 1))
    fi
  done < "$MANIFEST_FILE"
  info "Removed managed files/directories: $removed"
}

remove_empty_component_dirs() {
  local dir
  for dir in "${COMPONENT_DIRS[@]}"; do
    if [ -d "$OPENCODE_DIR/$dir" ]; then
      find "$OPENCODE_DIR/$dir" -type d -empty -delete 2>/dev/null || true
    fi
  done
}

clean_opencode_config() {
  local config="$OPENCODE_DIR/opencode.jsonc"
  [ -f "$config" ] || return 0

  local config_created config_sha current_sha
  config_created=$(node -e "const fs=require('fs'); const s=JSON.parse(fs.readFileSync(process.argv[1], 'utf8')); console.log(s.configCreated ? '1' : '0')" "$STATE_FILE")
  config_sha=$(node -e "const fs=require('fs'); const s=JSON.parse(fs.readFileSync(process.argv[1], 'utf8')); console.log(s.configSha256 || '')" "$STATE_FILE")

  if [ "$config_created" = "1" ]; then
    current_sha="$(file_sha256 "$config")"
    if [ -n "$config_sha" ] && [ "$current_sha" = "$config_sha" ]; then
      rm -f "$config"
      info "Removed installer-created opencode.jsonc"
      return 0
    fi
    warn "opencode.jsonc was created by installer but changed later; preserving it."
    return 0
  fi

  OPENCODE_CONFIG="$config" OPENCODE_STATE_FILE="$STATE_FILE" node <<'NODE'
const fs = require('fs');
const configPath = process.env.OPENCODE_CONFIG;
const statePath = process.env.OPENCODE_STATE_FILE;

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function sig(value) {
  return JSON.stringify(value);
}

function deleteNested(root, dottedPath) {
  if (!root || !dottedPath) return;
  const parts = dottedPath.split('.').filter(Boolean);
  let cur = root;
  for (let i = 0; i < parts.length - 1; i++) {
    cur = cur?.[parts[i]];
    if (!cur || typeof cur !== 'object' || Array.isArray(cur)) return;
  }
  delete cur[parts[parts.length - 1]];
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
const meta = state.config || {};

for (const key of meta.addedAgentKeys || []) {
  if (config.agent) delete config.agent[key];
}
for (const key of meta.addedMcpKeys || []) {
  if (config.mcp) delete config.mcp[key];
}
for (const item of meta.addedMcpFields || []) {
  if (config.mcp?.[item.key]) deleteNested(config.mcp[item.key], item.field);
}
for (const key of meta.addedPermissionKeys || []) {
  if (config.permission) delete config.permission[key];
}
for (const item of meta.addedPermissionFields || []) {
  if (config.permission?.[item.key]) deleteNested(config.permission[item.key], item.field);
}

if (Array.isArray(config.plugin)) {
  const remove = new Set((meta.addedPluginItems || []).map(sig));
  config.plugin = config.plugin.filter((item) => !remove.has(sig(item)));
}

for (const key of ['agent', 'mcp', 'permission']) {
  if (config[key] && typeof config[key] === 'object' && !Array.isArray(config[key]) && Object.keys(config[key]).length === 0) {
    delete config[key];
  }
}

fs.writeFileSync(configPath, JSON.stringify(config, null, 2) + '\n');
NODE
  info "Removed installer-owned entries from opencode.jsonc"
}

main() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║  Claude Scholar Uninstaller(OpenCode)║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  require_state
  remove_managed_paths
  remove_empty_component_dirs
  clean_opencode_config
  rm -f "$MANIFEST_FILE" "$STATE_FILE"
  info "Removed install manifest and state."
  info "Done. User-owned files and config entries were preserved."
}

main "$@"
