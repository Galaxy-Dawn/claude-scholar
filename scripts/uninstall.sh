#!/usr/bin/env bash
set -euo pipefail

KIMI_HOME="${KIMI_HOME:-$HOME/.kimi-code}"
MANIFEST_FILE="$KIMI_HOME/.kimi-scholar-manifest.txt"
STATE_FILE="$KIMI_HOME/.kimi-scholar-install-state"
BACKUP_ROOT="$KIMI_HOME/.kimi-scholar-backups"
UNINSTALL_STAMP="$(date +%Y%m%d-%H%M%S)"
UNINSTALL_BACKUP_DIR="$BACKUP_ROOT/uninstall-$UNINSTALL_STAMP"
COMPONENT_DIRS=(skills templates agents scripts utils)
REMOVED_COUNT=0
SKIPPED_COUNT=0
DRY_RUN=0

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: bash scripts/uninstall.sh [--dry-run]

Removes Kimi Scholar managed files from ~/.kimi-code without touching unrelated user files.
- Uses ~/.kimi-code/.kimi-scholar-manifest.txt for managed file ownership.
- Uses ~/.kimi-code/.kimi-scholar-install-state for safe config.toml cleanup.
- Refuses to guess ownership when install metadata is missing.
EOF
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      -h|--help) usage; exit 0 ;;
      *) error "Unknown argument: $1" ;;
    esac
    shift
  done
}

require_install_metadata() {
  [ -f "$MANIFEST_FILE" ] || error "Missing $MANIFEST_FILE. Refusing to guess ownership."
  [ -f "$STATE_FILE" ] || error "Missing $STATE_FILE. Refusing to guess config ownership."
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

backup_target() {
  local target="$1"
  [ -e "$target" ] || return 0
  local rel="${target#$KIMI_HOME/}"
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

collect_manifest_paths() {
  cat "$MANIFEST_FILE"
}

remove_managed_files() {
  local rel
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      .*|*..*|/*) continue ;;
    esac
    local target="$KIMI_HOME/$rel"
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
    if [ -d "$KIMI_HOME/$comp" ] && [ "$DRY_RUN" -eq 0 ]; then
      find "$KIMI_HOME/$comp" -depth -type d -empty -delete
    fi
  done
}

cleanup_config() {
  local config="$KIMI_HOME/config.toml"
  [ -f "$config" ] || return 0
  backup_target "$config"

  if [ "$DRY_RUN" -eq 1 ]; then
    info "Would clean Kimi Scholar entries from $config"
    return 0
  fi

  CONFIG_PATH="$config" STATE_PATH="$STATE_FILE" CURRENT_SHA="$(file_sha256 "$config")" python3 <<'PY'
import json
import os
import pathlib
import re

config_path = pathlib.Path(os.environ["CONFIG_PATH"])
state = json.loads(pathlib.Path(os.environ["STATE_PATH"]).read_text())
text = config_path.read_text()
current_sha = os.environ.get("CURRENT_SHA", "")

if state.get("configCreated") and current_sha and current_sha == state.get("configSha256", ""):
    config_path.unlink()
    raise SystemExit(0)

if state.get("configCreated"):
    # The user changed the installer-created config after install; preserve it.
    raise SystemExit(0)

sections = state.get("config", {}).get("addedSections", [])
if not sections:
    raise SystemExit(0)

for section in sorted(set(sections), key=len, reverse=True):
    pattern = rf"(^\[{re.escape(section)}\]\n(?:.*\n)*?)(?=^\[|\Z)"
    text = re.sub(pattern, "", text, flags=re.M)

text = re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"
config_path.write_text(text)
PY
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
  echo "║   Claude Scholar Uninstaller (Kimi) ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  remove_managed_files
  cleanup_empty_dirs
  cleanup_config
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
