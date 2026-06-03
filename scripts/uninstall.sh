#!/usr/bin/env bash
set -euo pipefail

KIMI_HOME="${KIMI_HOME:-$HOME/.kimi-code}"
MANIFEST_FILE="$KIMI_HOME/.kimi-scholar-manifest.txt"
STATE_FILE="$KIMI_HOME/.kimi-scholar-install-state"
BACKUP_ROOT="$KIMI_HOME/.kimi-scholar-backups"
UNINSTALL_STAMP="$(date +%Y%m%d-%H%M%S)-$$-${RANDOM}"
UNINSTALL_BACKUP_DIR="$BACKUP_ROOT/uninstall-$UNINSTALL_STAMP"
COMPONENT_DIRS=(skills templates agents hooks scripts utils)
REMOVED_COUNT=0
SKIPPED_COUNT=0
DRY_RUN=0
AUTO_YES=0

info()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: bash scripts/uninstall.sh [OPTIONS]

Removes Kimi Scholar managed files from ~/.kimi-code without touching unrelated user files.
- Uses ~/.kimi-code/.kimi-scholar-manifest.txt for managed file ownership.
- Refuses to guess ownership when install metadata is missing.

Options:
  --dry-run     Preview what would be removed without deleting anything.
  --yes, -y     Skip confirmation prompt (non-interactive mode).
  -h, --help    Show this help message.
EOF
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --yes|-y) AUTO_YES=1 ;;
      -h|--help) usage; exit 0 ;;
      *) error "Unknown argument: $1" ;;
    esac
    shift
  done
}

require_install_metadata() {
  [ -f "$MANIFEST_FILE" ] || {
    if [ -f "$STATE_FILE" ]; then
      warn "Missing $MANIFEST_FILE. Scholar-managed files cannot be identified."
      warn "To force cleanup, manually remove: $KIMI_HOME/skills, $KIMI_HOME/hooks, etc."
    else
      warn "Neither $MANIFEST_FILE nor $STATE_FILE found."
      warn "Claude Scholar does not appear to be installed, or was already uninstalled."
    fi
    exit 0
  }
  [ -f "$STATE_FILE" ] || warn "Missing $STATE_FILE. Config cleanup will use conservative detection."
}

validate_install_state() {
  [ -f "$STATE_FILE" ] || return 0
  python3 - "$STATE_FILE" <<'PY'
import json, pathlib, sys

state_path = pathlib.Path(sys.argv[1])
try:
    state = json.loads(state_path.read_text())
except Exception as e:
    print(f"ERROR: Failed to parse install state: {e}", file=sys.stderr)
    sys.exit(1)

if not isinstance(state, dict):
    print("ERROR: install state must be a JSON object", file=sys.stderr)
    sys.exit(1)

mcp_state = state.get("mcpServers", {})
if not isinstance(mcp_state, dict):
    print("ERROR: install state mcpServers must be a JSON object", file=sys.stderr)
    sys.exit(1)

for name, meta in mcp_state.items():
    if not isinstance(meta, dict):
        print(f"ERROR: install state mcpServers.{name} must be a JSON object", file=sys.stderr)
        sys.exit(1)
PY
}

backup_target() {
  local target="$1"
  [ -e "$target" ] || return 0
  [ "$DRY_RUN" -eq 1 ] && return 0
  local rel="${target#$KIMI_HOME/}"
  [ "$rel" = "$target" ] && rel="$(basename "$target")"
  mkdir -p "$UNINSTALL_BACKUP_DIR/$(dirname "$rel")"
  if [ -d "$target" ]; then
    cp -R "$target" "$UNINSTALL_BACKUP_DIR/$rel" || return 1
  else
    cp -p "$target" "$UNINSTALL_BACKUP_DIR/$rel" || return 1
  fi
}

collect_manifest_paths() {
  cat "$MANIFEST_FILE"
}

remove_managed_files() {
  local rel
  while IFS= read -r rel; do
    local target="$KIMI_HOME/$rel"
    if ! backup_target "$target"; then
      warn "Failed to back up $target — skipping removal"
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      continue
    fi
    if [ "$DRY_RUN" -eq 0 ]; then
      if [ -L "$target" ]; then
        rm -f "$target"
      elif [ -d "$target" ]; then
        rm -rf "$target"
      else
        rm -f "$target"
      fi
    fi
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  done < <(collect_targets_to_remove)
}

cleanup_empty_dirs() {
  local comp
  for comp in "${COMPONENT_DIRS[@]}"; do
    if [ -d "$KIMI_HOME/$comp" ] && [ "$DRY_RUN" -eq 0 ]; then
      find "$KIMI_HOME/$comp" -depth -type d -empty -delete 2>/dev/null || true
    fi
  done
}

cleanup_config() {
  local config="$KIMI_HOME/config.toml"
  [ -f "$config" ] || return 0

  if [ "$DRY_RUN" -eq 1 ]; then
    info "Would clean Kimi Scholar entries from $config"
    return 0
  fi

  # Run Python script to detect and remove Scholar hooks.
  # If it fails, do not delete the config file.
  local py_rc=0
  backup_target "$config" || {
    warn "Failed to back up $config — preserving config"
    return 1
  }
  python3 - "$config" <<'PY' || py_rc=$?
import pathlib, sys, re, tempfile, os

config_path = pathlib.Path(sys.argv[1])
try:
    text = config_path.read_text()
except Exception as e:
    print(f"ERROR: Failed to read config: {e}", file=sys.stderr)
    sys.exit(1)

# Identify Scholar-managed hooks by exact command path. Do not guess from event
# name or a generic "/hooks/" substring because users may define their own hooks.
scholar_events = {
    "PreToolUse", "SessionStart", "UserPromptSubmit",
    "SessionEnd", "Stop"
}
scholar_commands = {
    "bash ~/.kimi-code/hooks/security-guard.sh",
    "bash ~/.kimi-code/hooks/session-start.sh",
    "bash ~/.kimi-code/hooks/skill-forced-eval.sh",
    "bash ~/.kimi-code/hooks/session-summary.sh",
    "bash ~/.kimi-code/hooks/stop-summary.sh",
}

lines = text.split("\n")
new_lines = []
i = 0
removed_any = False

while i < len(lines):
    line = lines[i]
    if line.strip() == "# --- Claude Scholar defaults ---":
        i += 1
        while i < len(lines) and lines[i].strip() and not lines[i].strip().startswith("["):
            i += 1
        while new_lines and new_lines[-1].strip() == "":
            new_lines.pop()
        removed_any = True
        continue

    if line.strip() == "[[hooks]]":
        hook_block = [line]
        i += 1
        while i < len(lines) and not lines[i].strip().startswith("["):
            hook_block.append(lines[i])
            i += 1

        hook_event = ""
        hook_command = ""
        for hl in hook_block:
            stripped = hl.strip()
            if stripped.startswith("event = "):
                hook_event = stripped.split("=", 1)[1].strip().strip('"').strip("'")
            elif stripped.startswith("command = "):
                hook_command = stripped.split("=", 1)[1].strip().strip('"').strip("'")

        is_scholar = False
        if hook_event in scholar_events and hook_command in scholar_commands:
            is_scholar = True

        if is_scholar:
            # Remove any Scholar comment markers before this hook block
            while new_lines and new_lines[-1].strip().startswith("# ---"):
                new_lines.pop()
            while new_lines and new_lines[-1].strip() == "":
                new_lines.pop()
            removed_any = True
            continue

        new_lines.extend(hook_block)
        continue

    new_lines.append(line)
    i += 1

while new_lines and new_lines[-1].strip() == "":
    new_lines.pop()

if removed_any:
    text = "\n".join(new_lines) + "\n"
    text = re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"
    # Atomic write
    fd, tmp_name = tempfile.mkstemp(
        dir=str(config_path.parent),
        prefix=config_path.name + ".",
        suffix=".tmp"
    )
    try:
        with os.fdopen(fd, 'w') as f:
            f.write(text)
        os.replace(tmp_name, config_path)
    except Exception:
        os.unlink(tmp_name)
        raise
PY
  if [ "$py_rc" -ne 0 ]; then
    warn "Config cleanup failed — preserving $config"
    return 1
  fi
}

cleanup_mcp_config() {
  local mcp_file="$KIMI_HOME/mcp.json"
  [ -f "$mcp_file" ] || return 0
  [ -f "$STATE_FILE" ] || {
    warn "Missing install state — preserving MCP config"
    return 0
  }

  if [ "$DRY_RUN" -eq 1 ]; then
    info "Would clean or restore Kimi Scholar MCP entries from $mcp_file according to install state"
    return 0
  fi

  local py_rc=0
  backup_target "$mcp_file" || {
    warn "Failed to back up $mcp_file — preserving MCP config"
    return 1
  }
  python3 - "$mcp_file" "$STATE_FILE" <<'PY' || py_rc=$?
import hashlib, json, os, pathlib, sys, tempfile

mcp_path = pathlib.Path(sys.argv[1])
state_path = pathlib.Path(sys.argv[2])

def canonical_sha(value):
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(payload.encode()).hexdigest()

try:
    data = json.loads(mcp_path.read_text())
except Exception as e:
    print(f"ERROR: Failed to parse mcp.json: {e}", file=sys.stderr)
    sys.exit(1)

try:
    state = json.loads(state_path.read_text())
except Exception as e:
    print(f"ERROR: Failed to parse install state: {e}", file=sys.stderr)
    sys.exit(1)

mcp_state = state.get("mcpServers", {})
if not isinstance(mcp_state, dict) or not mcp_state:
    sys.exit(0)

servers = data.get("mcpServers")
if not isinstance(servers, dict):
    sys.exit(0)

changed = False
for name, meta in mcp_state.items():
    if not isinstance(meta, dict):
        continue
    action = meta.get("action")
    after_sha = meta.get("afterSha256")
    current = servers.get(name)

    if after_sha and canonical_sha(current) != after_sha:
        print(
            f"WARN: Preserving mcpServers.{name}; current value differs from install state",
            file=sys.stderr,
        )
        continue
    if not after_sha and current != meta.get("after"):
        print(
            f"WARN: Preserving mcpServers.{name}; current value differs from legacy install state",
            file=sys.stderr,
        )
        continue

    if action in {"created", "added"}:
        del servers[name]
        changed = True
    elif action == "replaced":
        before = meta.get("before")
        if before is None:
            del servers[name]
        else:
            servers[name] = before
        changed = True
    elif action == "unchanged":
        continue

if not changed:
    sys.exit(0)

if not servers:
    data.pop("mcpServers", None)

if not data:
    mcp_path.unlink()
    sys.exit(0)

text = json.dumps(data, indent=2) + "\n"
fd, tmp_name = tempfile.mkstemp(
    dir=str(mcp_path.parent),
    prefix=mcp_path.name + ".",
    suffix=".tmp",
)
try:
    with os.fdopen(fd, "w") as f:
        f.write(text)
    os.replace(tmp_name, mcp_path)
except Exception:
    os.unlink(tmp_name)
    raise
PY
  if [ "$py_rc" -ne 0 ]; then
    warn "MCP cleanup failed — preserving $mcp_file"
    return 1
  fi
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

collect_targets_to_remove() {
  # Prints one target per line to stdout (for pipe-based collection)
  local rel
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      .*|*..*|/*|*\\*|*\$*|*~*) continue ;;
    esac
    local target="$KIMI_HOME/$rel"
    [ -e "$target" ] || continue
    printf '%s\n' "$rel"
  done < <(collect_manifest_paths | LC_ALL=C sort -u)
}

preview_uninstall() {
  local -a to_remove=()
  while IFS= read -r rel; do
    to_remove+=("$rel")
  done < <(collect_targets_to_remove)

  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║   Uninstall Preview                  ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  if [ ${#to_remove[@]} -gt 0 ]; then
    echo "  Files to be removed: (${#to_remove[@]})"
    local count=0
    for f in "${to_remove[@]}"; do
      echo "    - $f"
      count=$((count + 1))
      if [ "$count" -ge 15 ] && [ ${#to_remove[@]} -gt 15 ]; then
        echo "    ... and $(( ${#to_remove[@]} - 15 )) more"
        break
      fi
    done
  else
    echo "  No managed files found to remove."
  fi

  local config="$KIMI_HOME/config.toml"
  if [ -f "$config" ]; then
    echo ""
    echo "  Config: Scholar hooks will be removed from $config"
  fi

  echo ""
  echo "  Backup directory: $UNINSTALL_BACKUP_DIR"
  echo ""

  if [ "$DRY_RUN" = "1" ]; then
    return 0
  fi

  if [ "$AUTO_YES" = "1" ]; then
    return 0
  fi

  if [ ! -t 0 ]; then
    warn "Non-interactive mode detected. Use --yes to confirm uninstall."
    info "Uninstall cancelled."
    exit 0
  fi

  local answer
  read -rp "Proceed with uninstall? [y/N]: " answer
  case "$answer" in
    [Yy]) return 0 ;;
    *) info "Uninstall cancelled."; exit 0 ;;
  esac
}

main() {
  parse_args "$@"
  require_install_metadata
  validate_install_state || error "Invalid install state. Refusing to uninstall."

  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║   Claude Scholar Uninstaller (Kimi) ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  preview_uninstall

  remove_managed_files
  cleanup_empty_dirs
  cleanup_config
  cleanup_mcp_config
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
