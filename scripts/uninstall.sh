#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.gemini/config/plugins/claude-scholar"
MANIFEST_FILE="$CLAUDE_DIR/.claude-scholar-manifest.txt"
STATE_FILE="$CLAUDE_DIR/.claude-scholar-install-state"
BACKUP_ROOT="$CLAUDE_DIR/.claude-scholar-backups"
UNINSTALL_STAMP="$(date +%Y%m%d-%H%M%S)"
UNINSTALL_BACKUP_DIR="$BACKUP_ROOT/uninstall-$UNINSTALL_STAMP"
COMPONENT_DIRS=(skills commands agents rules hooks scripts templates)
LEGACY_MANAGED_PATHS=(
  "skills/planning-with-files/SKILL.md"
  "skills/planning-with-files/examples.md"
  "skills/planning-with-files/reference.md"
)
REMOVED_COUNT=0
SKIPPED_COUNT=0
DRY_RUN=0

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: bash scripts/uninstall.sh [--dry-run]

Removes Claude Scholar managed files from ~/.claude without touching unrelated user files.
- Uses ~/.claude/.claude-scholar-manifest.txt when available.
- Falls back to the current repo checkout when run from a repo working tree.
- Cleans Claude Scholar hook / MCP / plugin entries from ~/.claude/settings.json.
EOF
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "Unknown argument: $1"
        ;;
    esac
    shift
  done
}

require_install_metadata() {
  [ -f "$MANIFEST_FILE" ] || error "Missing $MANIFEST_FILE. Refusing to guess ownership."
  [ -f "$STATE_FILE" ] || error "Missing $STATE_FILE. Refusing to guess settings ownership."
}

backup_target() {
  local target="$1"
  [ -e "$target" ] || return 0
  local rel="${target#$CLAUDE_DIR/}"
  [ "$rel" = "$target" ] && rel="$(basename "$target")"
  mkdir -p "$UNINSTALL_BACKUP_DIR/$(dirname "$rel")"
  if [ "$DRY_RUN" -eq 0 ]; then
    if [ -d "$target" ]; then
      cp -R "$target" "$UNINSTALL_BACKUP_DIR/$rel"
    else
      cp -p "$target" "$UNINSTALL_BACKUP_DIR/$rel"
    fi
  fi
}

append_path() {
  local path="$1"
  [ -n "$path" ] || return 0
  printf "%s\n" "$path"
}

collect_manifest_paths() {
  cat "$MANIFEST_FILE"
  printf "%s\n" "${LEGACY_MANAGED_PATHS[@]}"
}

remove_managed_files() {
  local rel
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      .*|*..*|/*) continue ;;
    esac
    local target="$CLAUDE_DIR/$rel"
    if [ ! -e "$target" ]; then
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      continue
    fi
    backup_target "$target"
    if [ "$DRY_RUN" -eq 0 ]; then
      rm -rf "$target"
    fi
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  done < <(collect_manifest_paths | LC_ALL=C sort -u)
}

cleanup_empty_dirs() {
  local comp
  for comp in "${COMPONENT_DIRS[@]}"; do
    if [ -d "$CLAUDE_DIR/$comp" ] && [ "$DRY_RUN" -eq 0 ]; then
      find "$CLAUDE_DIR/$comp" -depth -type d -empty -delete
    fi
  done
}

cleanup_settings() {
  local settings="$HOME/.gemini/config/mcp_config.json"
  [ -f "$settings" ] || return 0

  backup_target "$settings"
  if [ "$DRY_RUN" -eq 1 ]; then
    info "Would clean Claude Scholar entries from $settings"
    return 0
  fi

  SETTINGS_PATH="$settings" STATE_PATH="$STATE_FILE" node <<'NODE'
const fs = require('fs');

const settingsPath = process.env.SETTINGS_PATH;
const statePath = process.env.STATE_PATH;
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
const settingsCreated = Boolean(state.settingsCreated);
const addedMcpServers = new Set(Array.isArray(state.settings?.addedMcpServers) ? state.settings.addedMcpServers : []);
const addedMcpServerFields = state.settings?.addedMcpServerFields && typeof state.settings.addedMcpServerFields === 'object'
  ? state.settings.addedMcpServerFields
  : {};

function pruneEmptyContainers(root, parts) {
  for (let i = parts.length - 1; i > 0; i -= 1) {
    const parent = parts.slice(0, i - 1).reduce((acc, key) => (acc && typeof acc === 'object') ? acc[key] : undefined, root);
    const key = parts[i - 1];
    if (!parent || typeof parent !== 'object') return;
    const value = parent[key];
    if (value && typeof value === 'object' && !Array.isArray(value) && Object.keys(value).length === 0) {
      delete parent[key];
      continue;
    }
    return;
  }
}

function removeNestedPath(root, dottedPath) {
  if (!root || typeof root !== 'object' || !dottedPath) return;
  const parts = dottedPath.split('.').filter(Boolean);
  if (parts.length === 0) return;
  let current = root;
  for (let i = 0; i < parts.length - 1; i += 1) {
    current = current?.[parts[i]];
    if (!current || typeof current !== 'object') return;
  }
  delete current[parts[parts.length - 1]];
  pruneEmptyContainers(root, parts);
}

if (settings.mcpServers && typeof settings.mcpServers === 'object') {
  for (const key of addedMcpServers) {
    delete settings.mcpServers[key];
  }
  for (const [key, paths] of Object.entries(addedMcpServerFields)) {
    if (!(key in settings.mcpServers) || !Array.isArray(paths)) continue;
    for (const dottedPath of paths) {
      removeNestedPath(settings.mcpServers[key], dottedPath);
    }
    if (
      settings.mcpServers[key] &&
      typeof settings.mcpServers[key] === 'object' &&
      !Array.isArray(settings.mcpServers[key]) &&
      Object.keys(settings.mcpServers[key]).length === 0
    ) {
      delete settings.mcpServers[key];
    }
  }
  if (Object.keys(settings.mcpServers).length === 0) delete settings.mcpServers;
}

const onlyEmptyRemainder =
  settingsCreated &&
  Object.keys(settings).length === 1 &&
  settings.mcpServers &&
  Object.keys(settings.mcpServers).length === 0;

if (onlyEmptyRemainder) {
  fs.unlinkSync(settingsPath);
} else {
  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
}
NODE
}

remove_metadata_files() {
  local path
  for path in "$MANIFEST_FILE" "$STATE_FILE"; do
    [ -e "$path" ] || continue
    backup_target "$path"
    if [ "$DRY_RUN" -eq 0 ]; then
      rm -f "$path"
    fi
  done
}

main() {
  parse_args "$@"
  require_install_metadata

  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║      Claude Scholar Uninstaller      ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  remove_managed_files
  cleanup_empty_dirs
  cleanup_settings
  remove_metadata_files

  if [ "$DRY_RUN" -eq 1 ]; then
    info "Dry run complete. Files that would be removed: $REMOVED_COUNT | Missing/skipped: $SKIPPED_COUNT"
    exit 0
  fi

  info "Removed files: $REMOVED_COUNT | Missing/skipped: $SKIPPED_COUNT"
  info "Uninstall backup: $UNINSTALL_BACKUP_DIR"
  info "Done."
}

main "$@"
