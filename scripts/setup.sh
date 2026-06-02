#!/usr/bin/env bash
# ============================================================
# Claude Scholar — Kimi Code CLI Installer
# ============================================================
# Usage: bash scripts/setup.sh
# Supports fresh install and incremental updates.

set -uo pipefail

KIMI_HOME="${KIMI_HOME:-$HOME/.kimi-code}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_MD_SIDECAR="AGENTS.scholar.md"
AGENTS_ZH_MD_SIDECAR="AGENTS.zh-CN.scholar.md"
BACKUP_ROOT="$KIMI_HOME/.kimi-scholar-backups"
MANIFEST_FILE="$KIMI_HOME/.kimi-scholar-manifest.txt"
STATE_FILE="$KIMI_HOME/.kimi-scholar-install-state"
PREVIOUS_MANAGED_PATHS_FILE="$(mktemp)"
BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_STAMP"
BACKUP_READY=0
BACKUP_COUNT=0
UPDATED_COUNT=0
SKIPPED_COUNT=0
CONFIG_CREATED=0
MANAGED_PATHS=()
AGENTS_TARGETS=()
CONFIG_META_FILE="$(mktemp)"
SCHOLAR_DEBUG="${SCHOLAR_DEBUG:-0}"
INSTALL_STEP=""
FIND_CMD=""

# --- Colors ---
green()  { printf "\033[32m%s\033[0m" "$1"; }
red()    { printf "\033[31m%s\033[0m" "$1"; }
yellow() { printf "\033[33m%s\033[0m" "$1"; }
bold()   { printf "\033[1m%s\033[0m" "$1"; }
info()   { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()   { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error()  {
  echo -e "\033[1;31m[ERROR]\033[0m $*"
  if [ "$SCHOLAR_DEBUG" = "1" ]; then
    debug "error: step=${INSTALL_STEP:-none} line=${BASH_LINENO[0]:-unknown}"
  fi
  exit 1
}

debug() {
  [ "$SCHOLAR_DEBUG" = "1" ] || return 0
  printf '[DEBUG] %s\n' "$*" >&2
}

debug_state() {
  [ "$SCHOLAR_DEBUG" = "1" ] || return 0
  debug "state: KIMI_HOME=$KIMI_HOME"
  debug "state: SRC_DIR=$SRC_DIR"
}

run_step() {
  local step_name="$1"
  shift
  INSTALL_STEP="$step_name"
  debug "step:start $step_name"
  debug_state
  "$@"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    error "Step failed: $step_name (exit=$rc)"
  fi
  debug "step:done $step_name"
  INSTALL_STEP=""
}

select_find_cmd() {
  if [ -x /usr/bin/find ]; then
    FIND_CMD="/usr/bin/find"
  elif command -v gfind >/dev/null 2>&1; then
    FIND_CMD="$(command -v gfind)"
  elif find . -maxdepth 0 -print0 >/dev/null 2>&1; then
    FIND_CMD="$(command -v find)"
  else
    error "A Unix-compatible find command is required."
  fi
  debug "using find command: $FIND_CMD"
}

cleanup_temp_files() {
  rm -f "$CONFIG_META_FILE" "$PREVIOUS_MANAGED_PATHS_FILE"
}

on_exit() {
  local rc=$?
  if [ "$SCHOLAR_DEBUG" = "1" ]; then
    debug "exit: rc=$rc step=${INSTALL_STEP:-none} line=${LINENO}"
    debug "summary: updated=$UPDATED_COUNT skipped=$SKIPPED_COUNT backups=$BACKUP_COUNT"
  fi
  cleanup_temp_files
}

trap on_exit EXIT

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --debug|-d)
        SCHOLAR_DEBUG=1
        shift
        ;;
      --help|-h)
        cat <<'EOF'
Usage: bash scripts/setup.sh [--debug]

Options:
  --debug, -d   Enable verbose phase/state logging.
  --help, -h    Show this help.

You can also enable debug with:
  SCHOLAR_DEBUG=1 bash scripts/setup.sh
EOF
        exit 0
        ;;
      *)
        error "Unknown argument: $1"
        ;;
    esac
  done
}

load_previous_manifest() {
  if [ -f "$MANIFEST_FILE" ]; then
    cp "$MANIFEST_FILE" "$PREVIOUS_MANAGED_PATHS_FILE" || error "Failed to copy previous install manifest"
  else
    : > "$PREVIOUS_MANAGED_PATHS_FILE" || error "Failed to initialize previous manifest cache"
  fi
}

was_previously_managed() {
  local target="$1"
  local rel="${target#$KIMI_HOME/}"
  [ "$rel" = "$target" ] && return 1
  grep -Fxq "$rel" "$PREVIOUS_MANAGED_PATHS_FILE"
}

record_managed_path() {
  local target="$1"
  local rel="${target#$KIMI_HOME/}"
  [ "$rel" = "$target" ] && return 0
  [ -z "$rel" ] && return 0
  MANAGED_PATHS+=("$rel")
}

record_agents_target() {
  local target="$1"
  local rel="${target#$KIMI_HOME/}"
  [ "$rel" = "$target" ] && return 0
  [ -z "$rel" ] && return 0
  AGENTS_TARGETS+=("$rel")
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

write_unique_lines() {
  local target="$1"
  shift
  if [ "$#" -gt 0 ]; then
    printf "%s\n" "$@" | awk 'NF && !seen[$0]++' > "$target" || return 1
  else
    : > "$target" || return 1
  fi
}

write_install_state() {
  mkdir -p "$KIMI_HOME" || error "Failed to create KIMI_HOME at $KIMI_HOME"
  write_unique_lines "$MANIFEST_FILE" "${MANAGED_PATHS[@]}" || error "Failed to write install manifest"

  local managed_paths_file agents_targets_file
  managed_paths_file="$(mktemp)"
  agents_targets_file="$(mktemp)"

  write_unique_lines "$managed_paths_file" "${MANAGED_PATHS[@]}" || error "Failed to write managed paths temp file"
  write_unique_lines "$agents_targets_file" "${AGENTS_TARGETS[@]}" || error "Failed to write agents targets temp file"

  python3 - "$STATE_FILE" "$managed_paths_file" "$agents_targets_file" "$BACKUP_STAMP" "$SRC_DIR" <<'PY'
import json
import os
import pathlib
import sys

state_path = pathlib.Path(sys.argv[1])
managed_file = pathlib.Path(sys.argv[2])
agents_file = pathlib.Path(sys.argv[3])

state = {
    "installedAt": sys.argv[4],
    "sourceDir": sys.argv[5],
    "managedPaths": [l for l in managed_file.read_text().split('\n') if l.strip()],
    "agentsTargets": [l for l in agents_file.read_text().split('\n') if l.strip()],
}

state_path.write_text(json.dumps(state, indent=2) + '\n')
PY
  local py_rc=$?
  rm -f "$managed_paths_file" "$agents_targets_file"
  [ "$py_rc" -eq 0 ] || error "Failed to write install state"
}

ensure_backup_dir() {
  if [ "$BACKUP_READY" -eq 0 ]; then
    mkdir -p "$BACKUP_DIR" || error "Failed to create backup directory $BACKUP_DIR"
    BACKUP_READY=1
    info "Backup directory: $BACKUP_DIR"
  fi
}

backup_path() {
  local target="$1"
  [ -e "$target" ] || return 0

  ensure_backup_dir

  local rel="${target#$KIMI_HOME/}"
  if [ "$rel" = "$target" ]; then
    rel="$(basename "$target")"
  fi

  mkdir -p "$BACKUP_DIR/$(dirname "$rel")" || error "Failed to create backup parent for $rel"
  if [ -d "$target" ]; then
    cp -R "$target" "$BACKUP_DIR/$rel" || error "Failed to back up directory $target"
  else
    cp -p "$target" "$BACKUP_DIR/$rel" || error "Failed to back up file $target"
  fi
  debug "backup: ${target#$KIMI_HOME/} -> $BACKUP_DIR/$rel"
  BACKUP_COUNT=$((BACKUP_COUNT + 1))
}

ensure_parent_dir() {
  local target_path="$1"
  local parent_dir
  parent_dir="$(dirname "$target_path")"

  if [ -e "$parent_dir" ] && [ ! -d "$parent_dir" ]; then
    backup_path "$parent_dir"
    rm -f "$parent_dir" || error "Failed to remove non-directory parent $parent_dir"
  fi

  mkdir -p "$parent_dir" || error "Failed to create parent directory $parent_dir"
}

copy_file_safely() {
  local src_file="$1"
  local target_file="$2"

  ensure_parent_dir "$target_file"

  if [ -f "$target_file" ] && cmp -s "$src_file" "$target_file"; then
    if was_previously_managed "$target_file"; then
      record_managed_path "$target_file"
    fi
    debug "copy:skip unchanged ${target_file#$KIMI_HOME/}"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 0
  fi

  if [ -e "$target_file" ]; then
    backup_path "$target_file"
    if [ -d "$target_file" ]; then
      rm -rf "$target_file" || error "Failed to remove directory target $target_file"
    fi
  fi

  cp -p "$src_file" "$target_file" || error "Failed to copy $src_file to $target_file"
  debug "copy:update ${target_file#$KIMI_HOME/}"
  record_managed_path "$target_file"
  UPDATED_COUNT=$((UPDATED_COUNT + 1))
}

copy_dir_safely() {
  local src_dir="$1"
  local target_dir="$2"

  if [ -e "$target_dir" ] && [ ! -d "$target_dir" ]; then
    backup_path "$target_dir"
    rm -f "$target_dir" || error "Failed to remove non-directory target $target_dir"
  fi
  ensure_parent_dir "$target_dir/.dir"
  mkdir -p "$target_dir" || error "Failed to create target directory $target_dir"

  while IFS= read -r -d '' src_file; do
    local rel="${src_file#$src_dir/}"
    local target_file="$target_dir/$rel"
    copy_file_safely "$src_file" "$target_file"
  done < <("$FIND_CMD" "$src_dir" -type f -print0)
}

install_agents_md() {
  local src_file="$1"
  local target_file="$KIMI_HOME/AGENTS.md"
  local sidecar_file="$KIMI_HOME/$AGENTS_MD_SIDECAR"

  if [ -f "$target_file" ] && was_previously_managed "$target_file"; then
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
  local target_file="$KIMI_HOME/AGENTS.zh-CN.md"
  local sidecar_file="$KIMI_HOME/$AGENTS_ZH_MD_SIDECAR"

  if [ -f "$target_file" ] && was_previously_managed "$target_file"; then
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

# --- Kimi Code CLI specific helpers ---

merge_kimi_config() {
  local template="$SRC_DIR/config.toml"
  local target="$KIMI_HOME/config.toml"

  [ -f "$template" ] || error "Template config.toml not found at $template"

  if [ -f "$target" ]; then
    backup_path "$target"
  fi

  # Kimi Code CLI uses TOML with [providers], [models], and [[hooks]] sections.
  # Strategy:
  #   - Fresh install (no existing config): copy template as-is.
  #   - Existing config: detect hook conflicts by event name.
  #     If conflicts exist, show interactive prompt for user to decide.
  #     Never auto-overwrite user hooks without consent.

  python3 - "$target" "$template" <<'PY'
import pathlib
import sys
import tomllib

target_path = pathlib.Path(sys.argv[1])
template_path = pathlib.Path(sys.argv[2])

template_text = template_path.read_text()

try:
    template = tomllib.loads(template_text)
except Exception:
    template = {}

template_hooks = template.get("hooks", [])
if not isinstance(template_hooks, list):
    template_hooks = [template_hooks]

scholar_events = {h.get("event", "") for h in template_hooks}

# --- Fresh install ---
if not target_path.exists():
    target_path.write_text(template_text)
    print("FRESH_INSTALL")
    raise SystemExit(0)

# --- Existing config ---
existing_text = target_path.read_text()

try:
    existing = tomllib.loads(existing_text)
except Exception:
    existing = {}

existing_hooks = existing.get("hooks", [])
if not isinstance(existing_hooks, list):
    existing_hooks = [existing_hooks]

# Build event -> hook map for existing hooks
existing_event_map = {}
for i, h in enumerate(existing_hooks):
    ev = h.get("event", "")
    if ev:
        existing_event_map[ev] = i

# Find conflicts: template hooks whose event already exists
conflicts = []
for th in template_hooks:
    ev = th.get("event", "")
    if ev in existing_event_map:
        conflicts.append({
            "event": ev,
            "existing": existing_hooks[existing_event_map[ev]],
            "scholar": th,
        })

# No conflicts: merge directly
if not conflicts:
    _do_merge(target_path, template, existing, existing_hooks, template_hooks, [])
    print("MERGED_OK")
    raise SystemExit(0)

    # Show diff for each hook change
    print("")
    print("╔════════════════════════════════════════════════════════════╗")
    print("║   Hook changes in config.toml                              ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print("")

    modified = []
    new_hooks = []
    for th in template_hooks:
        ev = th.get("event", "")
        if ev in existing_event_map:
            modified.append({
                "event": ev,
                "existing": existing_hooks[existing_event_map[ev]],
                "scholar": th,
            })
        else:
            new_hooks.append(th)

    if modified:
        print(f"  {len(modified)} hook(s) will be overwritten (event already exists):\n")
        for c in modified:
            ev = c["event"]
            old_cmd = c["existing"].get("command", "")
            new_cmd = c["scholar"].get("command", "")
            print(f"  [{ev}]")
            if old_cmd != new_cmd:
                print(f"    - command = \"{old_cmd}\"")
                print(f"    + command = \"{new_cmd}\"")
            else:
                print(f"    (same command path)")
            for k in sorted(c["scholar"].keys()):
                if k == "event":
                    continue
                old_val = c["existing"].get(k)
                new_val = c["scholar"][k]
                if old_val != new_val:
                    print(f"    - {k} = {repr(old_val)}")
                    print(f"    + {k} = {repr(new_val)}")
            print()

    if new_hooks:
        print(f"  {len(new_hooks)} new hook(s) will be added:\n")
        for h in new_hooks:
            print(f"  [{h.get('event', '')}] (new)")
            for k, v in sorted(h.items()):
                if k == "event":
                    continue
                print(f"    + {k} = {repr(v)}")
            print()

    print("Accept these hook changes?")
    print("  (Y) Yes, overwrite/add all")
    print("  (n) No, keep existing hooks")
    print("  (s) Select individually")
    print()

    while True:
        try:
            choice = input("Choice [Y/n/s]: ").strip().lower()
        except EOFError:
            choice = ""
        if choice in ("y", "n", "s", ""):
            break

    if choice == "n":
        print("SKIPPED")
        raise SystemExit(0)

    # Determine which Scholar hooks to add
    scholar_hooks_to_add = []
    for th in template_hooks:
        ev = th.get("event", "")
        is_modified = any(c["event"] == ev for c in modified)
        is_new = any(h.get("event", "") == ev for h in new_hooks)

        if not is_modified and not is_new:
            continue

        if choice == "y" or choice == "":
            scholar_hooks_to_add.append(th)
        elif choice == "s":
            if is_new:
                prompt = f"Add new hook [{ev}]? [Y/n]: "
            else:
                prompt = f"Overwrite existing hook [{ev}]? [Y/n]: "
            while True:
                try:
                    individual = input(prompt).strip().lower()
                except EOFError:
                    individual = "y"
                if individual in ("y", "n", ""):
                    break
            if individual == "y" or individual == "":
                scholar_hooks_to_add.append(th)

    _do_merge(target_path, template, existing, existing_hooks, scholar_hooks_to_add)
    print("MERGED_OK")
    raise SystemExit(0)


def _do_merge(target_path, template, existing, existing_hooks, scholar_hooks_to_add):
    existing_text = target_path.read_text()

    # 1. Remove ALL existing hooks from raw text
    lines = existing_text.split("\n")
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == "[[hooks]]":
            hook_block = [line]
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("["):
                hook_block.append(lines[i])
                i += 1
            # Remove any Scholar comment markers before this hook block
            while new_lines and new_lines[-1].strip().startswith("# ---"):
                new_lines.pop()
            while new_lines and new_lines[-1].strip() == "":
                new_lines.pop()
            continue
        new_lines.append(line)
        i += 1

    while new_lines and new_lines[-1].strip() == "":
        new_lines.pop()

    text = "\n".join(new_lines) + "\n"

    # 2. Detect missing top-level defaults
    missing_top = []
    top_fields = [
        ("default_model", str),
        ("default_thinking", bool),
        ("merge_all_available_skills", bool),
        ("telemetry", bool),
    ]
    for key, val_type in top_fields:
        if key not in existing and key in template:
            val = template[key]
            if val_type is bool:
                missing_top.append(f'{key} = {str(val).lower()}')
            elif val_type is str:
                missing_top.append(f'{key} = "{val}"')
            elif val_type is int:
                missing_top.append(f'{key} = {val}')

    # 3. Build final hooks list
    final_hooks = list(scholar_hooks_to_add)
def _do_merge(target_path, template, existing, existing_hooks, scholar_hooks_to_add, conflicts, choice):
    existing_text = target_path.read_text()

    # 1. Remove ALL existing hooks from raw text
    lines = existing_text.split("\n")
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == "[[hooks]]":
            hook_block = [line]
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("["):
                hook_block.append(lines[i])
                i += 1
            # Remove any Scholar comment markers before this hook block
            while new_lines and new_lines[-1].strip().startswith("# ---"):
                new_lines.pop()
            while new_lines and new_lines[-1].strip() == "":
                new_lines.pop()
            continue
        new_lines.append(line)
        i += 1

    while new_lines and new_lines[-1].strip() == "":
        new_lines.pop()

    text = "\n".join(new_lines) + "\n"

    # 2. Detect missing top-level defaults
    missing_top = []
    top_fields = [
        ("default_model", str),
        ("default_thinking", bool),
        ("merge_all_available_skills", bool),
        ("telemetry", bool),
    ]
    for key, val_type in top_fields:
        if key not in existing and key in template:
            val = template[key]
            if val_type is bool:
                missing_top.append(f'{key} = {str(val).lower()}')
            elif val_type is str:
                missing_top.append(f'{key} = "{val}"')
            elif val_type is int:
                missing_top.append(f'{key} = {val}')

    # 3. Build final hooks list based on choice
    scholar_events = {h.get("event", "") for h in template.get("hooks", [])}

    if choice == "k":
        # Keep all existing hooks, add only non-conflicting Scholar hooks
        final_hooks = list(existing_hooks) + scholar_hooks_to_add
    else:
        # 'y', 's', or default: preserve non-Scholar user hooks + selected Scholar hooks
        non_scholar_existing = [h for h in existing_hooks if h.get("event", "") not in scholar_events]
        final_hooks = non_scholar_existing + scholar_hooks_to_add

    append_lines = []

    if missing_top:
        append_lines.append("")
        append_lines.append("# --- Claude Scholar defaults ---")
        append_lines.extend(missing_top)

    if final_hooks:
        append_lines.append("")
        append_lines.append("# --- Claude Scholar hooks ---")
        for h in final_hooks:
            append_lines.append("[[hooks]]")
            for k, v in sorted(h.items()):
                if isinstance(v, str):
                    append_lines.append(f'{k} = "{v}"')
                elif isinstance(v, int):
                    append_lines.append(f'{k} = {v}')
                elif isinstance(v, list):
                    items = ", ".join(f'"{item}"' for item in v)
                    append_lines.append(f'{k} = [{items}]')
            append_lines.append("")

    if append_lines:
        text = text.rstrip() + "\n" + "\n".join(append_lines) + "\n"

    target_path.write_text(text)
PY
  local py_rc=$?
  if [ "$py_rc" -ne 0 ]; then
    # Fallback: if Python fails, do a conservative append-only merge
    if [ -f "$target" ]; then
      # Only append hooks if user has none; otherwise leave config untouched
      if ! grep -q '^\[\[hooks\]\]' "$target" 2>/dev/null; then
        echo "" >> "$target"
        echo "# --- Claude Scholar hooks ---" >> "$target"
        awk '/^\[\[hooks\]\]/{flag=1} flag{print}' "$template" >> "$target"
        info "Appended Scholar hooks to existing config.toml"
      else
        warn "Existing config.toml already has hooks; skipping auto-merge to avoid duplicates"
        warn "Manually add hooks from the template if needed: $template"
      fi
    else
      cp "$template" "$target"
      CONFIG_CREATED=1
    fi
  fi
}

merge_mcp_config() {
  local template="$SRC_DIR/mcp.json"
  local target="$KIMI_HOME/mcp.json"

  [ -f "$template" ] || {
    warn "Template mcp.json not found at $template"
    return 0
  }

  if [ -f "$target" ]; then
    backup_path "$target"
    python3 - "$target" "$template" <<'PY'
import json
import pathlib
import sys

target_path = pathlib.Path(sys.argv[1])
template_path = pathlib.Path(sys.argv[2])

existing = json.loads(target_path.read_text())
template = json.loads(template_path.read_text())

# Merge mcpServers: add/overwrite from template
if "mcpServers" in template:
    if "mcpServers" not in existing:
        existing["mcpServers"] = {}
    for name, config in template["mcpServers"].items():
        existing["mcpServers"][name] = config

target_path.write_text(json.dumps(existing, indent=2) + '\n')
PY
    info "Merged MCP config into existing mcp.json"
  else
    cp "$template" "$target"
    record_managed_path "$target"
    info "Created mcp.json"
  fi
}

configure_zotero_mcp() {
  local mcp_file="$KIMI_HOME/mcp.json"
  [ -f "$mcp_file" ] || return 0

  if ! python3 -c "import json; d=json.load(open('$mcp_file')); exit(0 if 'zotero' in d.get('mcpServers', {}) else 1)" 2>/dev/null; then
    return 0
  fi

  echo ""
  local enable_zotero=""
  read -rp "Enable Zotero MCP server? [y/N]: " enable_zotero
  if [ "$enable_zotero" != "y" ] && [ "$enable_zotero" != "Y" ]; then
    return 0
  fi

  if ! command -v zotero-mcp >/dev/null 2>&1; then
    warn "zotero-mcp not found. Install with: uv tool install git+https://github.com/Galaxy-Dawn/zotero-mcp.git"
  fi

  # Prompt for Zotero credentials
  echo ""
  echo "  Zotero MCP configuration (all fields optional — press Enter to skip):"
  echo ""

  local zotero_api_key=""
  local zotero_library_id=""
  local unpaywall_email=""

  read -rp "    ZOTERO_API_KEY (for Web API write access): " zotero_api_key
  read -rp "    ZOTERO_LIBRARY_ID (your numeric User ID):  " zotero_library_id
  read -rp "    UNPAYWALL_EMAIL (for PDF lookup):          " unpaywall_email

  # Update mcp.json with provided values
  python3 - "$mcp_file" "$zotero_api_key" "$zotero_library_id" "$unpaywall_email" <<'PY'
import json
import pathlib
import sys

mcp_path = pathlib.Path(sys.argv[1])
api_key = sys.argv[2]
library_id = sys.argv[3]
email = sys.argv[4]

data = json.loads(mcp_path.read_text())

if "zotero" in data.get("mcpServers", {}):
    env = data["mcpServers"]["zotero"].setdefault("env", {})
    if api_key:
        env["ZOTERO_API_KEY"] = api_key
    if library_id:
        env["ZOTERO_LIBRARY_ID"] = library_id
    if email:
        env["UNPAYWALL_EMAIL"] = email
    # Always ensure these defaults
    env.setdefault("ZOTERO_LIBRARY_TYPE", "user")
    env.setdefault("UNSAFE_OPERATIONS", "all")
    env.setdefault("NO_PROXY", "localhost,127.0.0.1")
    env.setdefault("ZOTERO_LOCAL", "true")

mcp_path.write_text(json.dumps(data, indent=2) + '\n')
PY

  info "Zotero MCP configured in mcp.json"
}

check_deps() {
  command -v git >/dev/null || error "Git is required."
  command -v python3 >/dev/null || error "Python 3 is required."
  select_find_cmd
  if ! command -v kimi-code >/dev/null 2>&1 && ! command -v kimi >/dev/null 2>&1; then
    warn "Kimi Code CLI not detected. Make sure it is installed and on PATH."
  fi
}

check_kimi_login() {
  local oauth_file="$KIMI_HOME/oauth/kimi-code"
  local creds_file="$KIMI_HOME/credentials/kimi-code.json"

  if [ -f "$oauth_file" ] || [ -f "$creds_file" ]; then
    info "Kimi login detected"
    return 0
  fi

  echo ""
  warn "Kimi Code CLI login not detected."
  echo ""
  echo "  Claude Scholar requires an active Kimi login to function."
  echo "  Please run one of the following commands to authenticate:"
  echo ""
  echo "    kimi login"
  echo "    kimi-code login"
  echo ""
  echo "  After logging in, re-run this installer."
  echo ""

  local proceed=""
  read -rp "Continue installation anyway? [y/N]: " proceed
  if [ "$proceed" != "y" ] && [ "$proceed" != "Y" ]; then
    info "Installation aborted. Run 'kimi login' and try again."
    exit 0
  fi
}

collect_preview() {
  local -a new_files=()
  local -a modified_files=()
  local -a config_changes=()

  # Config changes
  if [ -f "$KIMI_HOME/config.toml" ]; then
    config_changes+=("config.toml  (merge hooks, set defaults)")
  else
    new_files+=("config.toml")
  fi

  # MCP changes
  if [ -f "$KIMI_HOME/mcp.json" ]; then
    config_changes+=("mcp.json  (merge Zotero MCP)")
  else
    new_files+=("mcp.json")
  fi

  # Component directories
  local comp src_dir target_dir
  for comp in skills agents hooks templates; do
    src_dir="$SRC_DIR/$comp"
    target_dir="$KIMI_HOME/$comp"
    [ -d "$src_dir" ] || continue

    while IFS= read -r -d '' src_file; do
      local rel="${src_file#$src_dir/}"
      local target_file="$target_dir/$rel"
      if [ ! -e "$target_file" ]; then
        new_files+=("$comp/$rel")
      elif ! cmp -s "$src_file" "$target_file"; then
        modified_files+=("$comp/$rel")
      fi
    done < <("$FIND_CMD" "$src_dir" -type f -print0)
  done

  # AGENTS.md
  if [ -f "$SRC_DIR/AGENTS.md" ]; then
    if [ ! -f "$KIMI_HOME/AGENTS.md" ]; then
      new_files+=("AGENTS.md")
    elif ! cmp -s "$SRC_DIR/AGENTS.md" "$KIMI_HOME/AGENTS.md"; then
      if was_previously_managed "$KIMI_HOME/AGENTS.md"; then
        modified_files+=("AGENTS.md")
      else
        new_files+=("AGENTS.scholar.md")
      fi
    fi
  fi

  if [ -f "$SRC_DIR/AGENTS.zh-CN.md" ]; then
    if [ ! -f "$KIMI_HOME/AGENTS.zh-CN.md" ]; then
      new_files+=("AGENTS.zh-CN.md")
    elif ! cmp -s "$SRC_DIR/AGENTS.zh-CN.md" "$KIMI_HOME/AGENTS.zh-CN.md"; then
      if was_previously_managed "$KIMI_HOME/AGENTS.zh-CN.md"; then
        modified_files+=("AGENTS.zh-CN.md")
      else
        new_files+=("AGENTS.zh-CN.scholar.md")
      fi
    fi
  fi

  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║   Installation Preview               ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  if [ ${#config_changes[@]} -gt 0 ]; then
    echo "  $(bold 'Config changes:')"
    for f in "${config_changes[@]}"; do
      echo "    • $f"
    done
    echo ""
  fi

  if [ ${#new_files[@]} -gt 0 ]; then
    echo "  $(bold 'New files to create:')" "(${#new_files[@]})"
    local count=0
    for f in "${new_files[@]}"; do
      echo "    + $f"
      count=$((count + 1))
      if [ "$count" -ge 15 ] && [ ${#new_files[@]} -gt 15 ]; then
        echo "    ... and $(( ${#new_files[@]} - 15 )) more"
        break
      fi
    done
    echo ""
  fi

  if [ ${#modified_files[@]} -gt 0 ]; then
    echo "  $(bold 'Existing files to update:')" "(${#modified_files[@]})"
    local count=0
    for f in "${modified_files[@]}"; do
      echo "    ~ $f"
      count=$((count + 1))
      if [ "$count" -ge 10 ] && [ ${#modified_files[@]} -gt 10 ]; then
        echo "    ... and $(( ${#modified_files[@]} - 10 )) more"
        break
      fi
    done
    echo ""
  fi

  if [ ${#new_files[@]} -eq 0 ] && [ ${#modified_files[@]} -eq 0 ] && [ ${#config_changes[@]} -eq 0 ]; then
    echo "  Nothing to install — everything is up to date."
    echo ""
    return 1
  fi

  echo "  Target directory: $KIMI_HOME"
  if [ -d "$BACKUP_DIR" ]; then
    echo "  Backup directory: $BACKUP_DIR"
  fi
  echo ""

  local confirm=""
  read -rp "Proceed with installation? [Y/n]: " confirm
  if [ -n "$confirm" ] && [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    info "Installation cancelled."
    exit 0
  fi

  return 0
}

copy_components() {
  if [ -d "$SRC_DIR/skills" ]; then
    copy_dir_safely "$SRC_DIR/skills" "$KIMI_HOME/skills"
  fi
  if [ -d "$SRC_DIR/templates" ]; then
    copy_dir_safely "$SRC_DIR/templates" "$KIMI_HOME/templates"
  fi
  if [ -d "$SRC_DIR/agents" ]; then
    copy_dir_safely "$SRC_DIR/agents" "$KIMI_HOME/agents"
  fi
  if [ -d "$SRC_DIR/hooks" ]; then
    copy_dir_safely "$SRC_DIR/hooks" "$KIMI_HOME/hooks"
  fi
  if [ -f "$SRC_DIR/AGENTS.md" ]; then
    install_agents_md "$SRC_DIR/AGENTS.md"
  fi
  if [ -f "$SRC_DIR/AGENTS.zh-CN.md" ]; then
    install_agents_zh_md "$SRC_DIR/AGENTS.zh-CN.md"
  fi

  info "Synced repo-managed Kimi components"
}

main() {
  parse_args "$@"
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║   Claude Scholar Installer (Kimi)   ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  run_step "check_deps" check_deps
  run_step "check_kimi_login" check_kimi_login
  run_step "load_previous_manifest" load_previous_manifest

  info "Source: $SRC_DIR"
  info "Target: $KIMI_HOME"
  mkdir -p "$KIMI_HOME" || error "Failed to create KIMI_HOME at $KIMI_HOME"

  run_step "merge_kimi_config" merge_kimi_config
  run_step "merge_mcp_config" merge_mcp_config
  run_step "configure_zotero_mcp" configure_zotero_mcp

  # Preview changes before copying files
  collect_preview || {
    info "Nothing to do."
    exit 0
  }

  run_step "copy_components" copy_components
  run_step "write_install_state" write_install_state

  echo ""
  echo "============================================================"
  info "Installation complete!"
  info "Install manifest: $MANIFEST_FILE"
  info "Updated files: $UPDATED_COUNT | Unchanged files skipped: $SKIPPED_COUNT | Backups created: $BACKUP_COUNT"
  if [ "$BACKUP_READY" -eq 1 ]; then
    info "Recover previous files from: $BACKUP_DIR"
  fi
  echo ""
  echo "  Config:    $KIMI_HOME/config.toml"
  echo "  MCP:       $KIMI_HOME/mcp.json"
  echo "  Skills:    $KIMI_HOME/skills/"
  echo "  Agents:    $KIMI_HOME/agents/"
  echo "  Hooks:     $KIMI_HOME/hooks/"
  echo "  Templates: $KIMI_HOME/templates/"
  echo ""
  echo "============================================================"
}

main "$@"
