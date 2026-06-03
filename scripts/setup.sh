#!/usr/bin/env bash
# ============================================================
# Claude Scholar — Kimi Code CLI Installer
# ============================================================
# Usage: bash scripts/setup.sh [--dry-run] [--debug] [--yes]
#
# Supports fresh install and incremental updates.
# Respects existing user configuration — never overwrites without consent.
#
# Options:
#   --dry-run, -n   Preview changes without modifying anything.
#   --yes, -y       Auto-confirm all prompts (non-interactive).
#   --debug, -d     Enable verbose debug logging.
#   --help, -h      Show this help message.
# ============================================================

set -uo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
KIMI_HOME="${KIMI_HOME:-$HOME/.kimi-code}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_MD_SIDECAR="AGENTS.scholar.md"
AGENTS_ZH_MD_SIDECAR="AGENTS.zh-CN.scholar.md"
BACKUP_ROOT="$KIMI_HOME/.kimi-scholar-backups"
MANIFEST_FILE="$KIMI_HOME/.kimi-scholar-manifest.txt"
STATE_FILE="$KIMI_HOME/.kimi-scholar-install-state"

BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)-$$-${RANDOM}"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_STAMP"

# Runtime state
BACKUP_READY=0
BACKUP_COUNT=0
UPDATED_COUNT=0
SKIPPED_COUNT=0
CONFIG_CREATED=0
DRY_RUN=0
AUTO_YES=0
SCHOLAR_DEBUG="${SCHOLAR_DEBUG:-0}"
SKIP_HOOKS_COPY=0
INSTALL_STEP=""

# Arrays
MANAGED_PATHS=()
AGENTS_TARGETS=()

# Temporary files
PREVIOUS_MANAGED_PATHS_FILE="$(mktemp)"
CONFIG_META_FILE="$(mktemp)"
MCP_STATE_FILE="$(mktemp)"
# Track Python script temps for cleanup on signal/interrupt
_SCHOLAR_TEMP_SCRIPTS=()

trap cleanup EXIT

# ---------------------------------------------------------------------------
# UI helpers
# ---------------------------------------------------------------------------
info()   { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()   { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error()  { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; exit 1; }
die()    { printf "\033[1;31m[FATAL]\033[0m %s\n" "$*"; exit 1; }

bold()   { printf "\033[1m%s\033[0m" "$1"; }
green()  { printf "\033[32m%s\033[0m" "$1"; }
red()    { printf "\033[31m%s\033[0m" "$1"; }
yellow() { printf "\033[33m%s\033[0m" "$1"; }

debug() {
  [ "$SCHOLAR_DEBUG" = "1" ] || return 0
  printf '[DEBUG] %s\n' "$*" >&2
}

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------
cleanup() {
  local rc=$?
  rm -f "$PREVIOUS_MANAGED_PATHS_FILE" "$CONFIG_META_FILE" "$MCP_STATE_FILE"
  for tmp_script in "${_SCHOLAR_TEMP_SCRIPTS[@]}"; do
    rm -f "$tmp_script"
  done
  if [ "$SCHOLAR_DEBUG" = "1" ]; then
    debug "exit: rc=$rc step=${INSTALL_STEP:-none}"
    debug "summary: updated=$UPDATED_COUNT skipped=$SKIPPED_COUNT backups=$BACKUP_COUNT"
  fi
}

run_step() {
  local step_name="$1"
  shift
  INSTALL_STEP="$step_name"
  debug "step:start $step_name"
  "$@"
  local rc=$?
  debug "step:done $step_name rc=$rc"
  INSTALL_STEP=""
  return $rc
}

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run|-n)
        DRY_RUN=1
        info "Dry-run mode: no files will be modified."
        shift
        ;;
      --yes|-y)
        AUTO_YES=1
        shift
        ;;
      --debug|-d)
        SCHOLAR_DEBUG=1
        shift
        ;;
      --help|-h)
        cat <<'EOF'
Usage: bash scripts/setup.sh [OPTIONS]

Claude Scholar installer for Kimi Code CLI.

Options:
  --dry-run, -n   Preview changes without modifying anything.
  --yes, -y       Auto-confirm all prompts (non-interactive mode).
  --debug, -d     Enable verbose phase/state logging.
  --help, -h      Show this help message.

Environment:
  KIMI_HOME       Target directory (default: ~/.kimi-code).
  SCHOLAR_DEBUG=1 Enable debug logging.

Examples:
  bash scripts/setup.sh              # Interactive install
  bash scripts/setup.sh --dry-run    # Preview only
  bash scripts/setup.sh --yes        # Non-interactive install
EOF
        exit 0
        ;;
      *)
        error "Unknown argument: $1 (use --help for usage)"
        ;;
    esac
  done
}

# ---------------------------------------------------------------------------
# Prompt helpers (respect --yes and non-TTY)
# ---------------------------------------------------------------------------
_prompt() {
  local msg="$1"
  local default="${2:-}"
  if [ "$AUTO_YES" = "1" ]; then
    echo "$default"
    return 0
  fi
  if [ ! -t 0 ]; then
    echo ""
    return 0
  fi
  local answer
  read -rp "$msg" answer
  echo "${answer:-$default}"
}

_confirm() {
  local msg="$1"
  local default="${2:-y}"
  local answer
  if [ "$AUTO_YES" = "1" ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    return 1
  fi
  answer="$(_prompt "$msg" "$default")"
  case "$answer" in
    [Yy]|"" ) return 0 ;;
    * ) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# Managed-path bookkeeping
# ---------------------------------------------------------------------------
load_previous_manifest() {
  if [ -f "$MANIFEST_FILE" ]; then
    cp "$MANIFEST_FILE" "$PREVIOUS_MANAGED_PATHS_FILE" \
      || error "Failed to copy previous install manifest"
  else
    : > "$PREVIOUS_MANAGED_PATHS_FILE" \
      || error "Failed to initialize previous manifest cache"
  fi
}

validate_install_metadata_targets() {
  local path
  for path in "$MANIFEST_FILE" "$STATE_FILE"; do
    if [ -e "$path" ] && [ ! -f "$path" ]; then
      error "Install metadata path is not a regular file: $path"
    fi
  done
}

load_previous_mcp_state() {
  : > "$MCP_STATE_FILE" || error "Failed to initialize MCP state cache"
  [ -f "$STATE_FILE" ] || return 0
  python3 - "$STATE_FILE" "$MCP_STATE_FILE" <<'PY' || error "Failed to load previous MCP state"
import json, pathlib, sys

state_path = pathlib.Path(sys.argv[1])
mcp_state_path = pathlib.Path(sys.argv[2])
try:
    state = json.loads(state_path.read_text())
except Exception as e:
    print(f"ERROR: Failed to parse existing install state: {e}", file=sys.stderr)
    sys.exit(1)

if not isinstance(state, dict):
    print("ERROR: existing install state must be a JSON object", file=sys.stderr)
    sys.exit(1)

mcp_state = state.get("mcpServers", {})
if not isinstance(mcp_state, dict):
    print("ERROR: existing install state mcpServers must be a JSON object", file=sys.stderr)
    sys.exit(1)

for name, meta in mcp_state.items():
    if not isinstance(meta, dict):
        print(f"ERROR: existing install state mcpServers.{name} must be a JSON object", file=sys.stderr)
        sys.exit(1)

mcp_state_path.write_text(json.dumps(mcp_state, indent=2) + "\n")
PY
}

validate_mcp_config_schema() {
  local target="$KIMI_HOME/mcp.json"
  [ -f "$target" ] || return 0
  python3 - "$target" <<'PY' || error "Invalid existing mcp.json schema"
import json, pathlib, sys

path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text())
except Exception as e:
    print(f"ERROR: Failed to parse existing mcp.json: {e}", file=sys.stderr)
    sys.exit(1)

if not isinstance(data, dict):
    print("ERROR: existing mcp.json must be a JSON object", file=sys.stderr)
    sys.exit(1)

servers = data.get("mcpServers", {})
if not isinstance(servers, dict):
    print("ERROR: existing mcp.json mcpServers must be a JSON object", file=sys.stderr)
    sys.exit(1)

for name, cfg in servers.items():
    if not isinstance(cfg, dict):
        print(f"ERROR: existing mcp.json mcpServers.{name} must be a JSON object", file=sys.stderr)
        sys.exit(1)
PY
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
  # Also record in MANAGED_PATHS so was_previously_managed works
  MANAGED_PATHS+=("$rel")
}

record_mcp_state_before_merge() {
  local target="$1"
  local template="$2"
  local after_merge="$3"

  [ "$DRY_RUN" = "1" ] && return 0
  python3 - "$MCP_STATE_FILE" "$target" "$template" "$after_merge" <<'PY'
import hashlib, json, pathlib, sys

state_path = pathlib.Path(sys.argv[1])
target_path = pathlib.Path(sys.argv[2])
template_path = pathlib.Path(sys.argv[3])
after_merge = sys.argv[4] == "1"

def canonical_sha(value):
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(payload.encode()).hexdigest()

try:
    state = json.loads(state_path.read_text() or "{}")
except Exception:
    state = {}

existing = json.loads(target_path.read_text()) if target_path.exists() else {}
template = json.loads(template_path.read_text())
existing_servers = existing.get("mcpServers", {})
template_servers = template.get("mcpServers", {})

for name, cfg in template_servers.items():
    previous = state.get(name, {})
    if name in existing_servers:
        before = existing_servers[name]
        if before == cfg:
            if (
                isinstance(previous, dict)
                and previous.get("action") in {"created", "added", "replaced"}
                and previous.get("afterSha256") == canonical_sha(before)
            ):
                entry = dict(previous)
                entry["template"] = cfg
                if after_merge:
                    entry["afterSha256"] = canonical_sha(cfg)
                state[name] = entry
                continue
            else:
                action = "unchanged"
        else:
            action = "replaced"
    else:
        before = None
        action = "added"

    entry = {
        "action": action,
        "before": before,
        "template": cfg,
    }
    if after_merge:
        entry["afterSha256"] = canonical_sha(cfg)
    state[name] = entry

state_path.write_text(json.dumps(state, indent=2) + "\n")
PY
}

sync_mcp_state_after_merge() {
  local target="$1"
  local template="$2"

  [ "$DRY_RUN" = "1" ] && return 0
  python3 - "$MCP_STATE_FILE" "$target" "$template" <<'PY'
import hashlib, json, pathlib, sys

state_path = pathlib.Path(sys.argv[1])
target_path = pathlib.Path(sys.argv[2])
template_path = pathlib.Path(sys.argv[3])

def canonical_sha(value):
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(payload.encode()).hexdigest()

try:
    state = json.loads(state_path.read_text() or "{}")
except Exception:
    state = {}

target = json.loads(target_path.read_text())
template = json.loads(template_path.read_text())
servers = target.get("mcpServers", {})

for name in template.get("mcpServers", {}):
    if name in state:
        state[name]["afterSha256"] = canonical_sha(servers.get(name))
        state[name].pop("after", None)

state_path.write_text(json.dumps(state, indent=2) + "\n")
PY
}

record_created_mcp_state() {
  local target="$1"
  local template="$2"

  [ "$DRY_RUN" = "1" ] && return 0
  python3 - "$MCP_STATE_FILE" "$target" "$template" <<'PY'
import hashlib, json, pathlib, sys

state_path = pathlib.Path(sys.argv[1])
target_path = pathlib.Path(sys.argv[2])
template_path = pathlib.Path(sys.argv[3])

def canonical_sha(value):
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(payload.encode()).hexdigest()

target = json.loads(target_path.read_text())
template = json.loads(template_path.read_text())
servers = target.get("mcpServers", {})
state = {}
for name, cfg in template.get("mcpServers", {}).items():
    state[name] = {
        "action": "created",
        "before": None,
        "template": cfg,
        "afterSha256": canonical_sha(servers.get(name)),
    }
state_path.write_text(json.dumps(state, indent=2) + "\n")
PY
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
  [ "$DRY_RUN" = "1" ] && return 0
  mkdir -p "$KIMI_HOME" || error "Failed to create KIMI_HOME at $KIMI_HOME"
  validate_install_metadata_targets

  local managed_tmp agents_tmp manifest_tmp state_tmp py_rc
  managed_tmp="$(mktemp)"
  agents_tmp="$(mktemp)"
  manifest_tmp="$(mktemp "$KIMI_HOME/.kimi-scholar-manifest.txt.XXXXXX")" \
    || error "Failed to create temporary install manifest"
  state_tmp="$(mktemp "$KIMI_HOME/.kimi-scholar-install-state.XXXXXX")" \
    || error "Failed to create temporary install state"
  write_unique_lines "$managed_tmp" "${MANAGED_PATHS[@]}" \
    || error "Failed to write managed paths temp file"
  write_unique_lines "$agents_tmp" "${AGENTS_TARGETS[@]}" \
    || error "Failed to write agents targets temp file"
  cp "$managed_tmp" "$manifest_tmp" \
    || error "Failed to write temporary install manifest"

  py_rc=0
  python3 - "$state_tmp" "$managed_tmp" "$agents_tmp" "$MCP_STATE_FILE" "$BACKUP_STAMP" "$SRC_DIR" <<'PY' || py_rc=$?
import json, pathlib, sys
state_path = pathlib.Path(sys.argv[1])
managed_file = pathlib.Path(sys.argv[2])
agents_file = pathlib.Path(sys.argv[3])
mcp_state_file = pathlib.Path(sys.argv[4])
try:
    mcp_servers = json.loads(mcp_state_file.read_text() or "{}")
except Exception:
    mcp_servers = {}

state = {
    "installedAt": sys.argv[5],
    "sourceDir": sys.argv[6],
    "managedPaths": [l for l in managed_file.read_text().split('\n') if l.strip()],
    "agentsTargets": [l for l in agents_file.read_text().split('\n') if l.strip()],
    "mcpServers": mcp_servers,
}
state_path.write_text(json.dumps(state, indent=2) + '\n')
PY
  if [ "$py_rc" -ne 0 ]; then
    rm -f "$managed_tmp" "$agents_tmp" "$manifest_tmp" "$state_tmp"
    return "$py_rc"
  fi
  mv "$manifest_tmp" "$MANIFEST_FILE" \
    || {
      rm -f "$managed_tmp" "$agents_tmp" "$manifest_tmp" "$state_tmp"
      return 1
    }
  mv "$state_tmp" "$STATE_FILE" \
    || {
      rm -f "$managed_tmp" "$agents_tmp" "$state_tmp"
      return 1
    }
  rm -f "$managed_tmp" "$agents_tmp"
}

# ---------------------------------------------------------------------------
# Backup
# ---------------------------------------------------------------------------
ensure_backup_dir() {
  [ "$DRY_RUN" = "1" ] && return 0
  if [ "$BACKUP_READY" -eq 0 ] || [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || error "Failed to create backup directory $BACKUP_DIR"
    BACKUP_READY=1
    info "Backup directory: $BACKUP_DIR"
  fi
}

backup_path() {
  local target="$1"
  [ -e "$target" ] || return 0
  [ "$DRY_RUN" = "1" ] && return 0

  ensure_backup_dir

  local rel="${target#$KIMI_HOME/}"
  [ "$rel" = "$target" ] && rel="$(basename "$target")"

  mkdir -p "$BACKUP_DIR/$(dirname "$rel")" \
    || error "Failed to create backup parent for $rel"

  if [ -d "$target" ]; then
    cp -R "$target" "$BACKUP_DIR/$rel" \
      || error "Failed to back up directory $target"
  else
    cp -p "$target" "$BACKUP_DIR/$rel" \
      || error "Failed to back up file $target"
  fi
  debug "backup: ${target#$KIMI_HOME/} -> $BACKUP_DIR/$rel"
  BACKUP_COUNT=$((BACKUP_COUNT + 1))
}

# ---------------------------------------------------------------------------
# Safe file operations
# ---------------------------------------------------------------------------
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

  # Unchanged + previously managed → just re-record, skip copy
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

  if [ "$DRY_RUN" = "1" ]; then
    record_managed_path "$target_file"
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
    return 0
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
  done < <(find "$src_dir" -type f -print0)
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

# ---------------------------------------------------------------------------
# Kimi Code CLI specific: config.toml
# ---------------------------------------------------------------------------
merge_kimi_config() {
  local template="$SRC_DIR/config.toml"
  local target="$KIMI_HOME/config.toml"

  [ -f "$template" ] || {
    warn "Template config.toml not found at $template — skipping"
    return 0
  }

  # If existing config exists, compute diff without modifying anything yet
  local action=""
  local _SCHOLAR_TMP_1="$(mktemp)"
  _SCHOLAR_TEMP_SCRIPTS+=("$_SCHOLAR_TMP_1")
  cat > "$_SCHOLAR_TMP_1" <<'PY'
import pathlib, sys, tomllib

def _do_merge(target_path, template, existing, scholar_hooks_to_add, replace_events):
    existing_text = target_path.read_text()

    # 1. Remove Scholar-managed hooks from raw text
    #    We identify Scholar hooks by exact command from the template.
    scholar_commands = {
        h.get("command", "")
        for h in template.get("hooks", [])
        if h.get("command", "")
    }
    replace_events = set(replace_events)

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

            # Determine if this hook block is a Scholar-managed hook. Do not
            # guess by event name or generic "/hooks/" path, because users may
            # have their own hooks for the same event.
            hook_event = ""
            hook_command = ""
            for hl in hook_block:
                stripped = hl.strip()
                if stripped.startswith("event = "):
                    hook_event = stripped.split("=", 1)[1].strip().strip('"').strip("'")
                elif stripped.startswith("command = "):
                    hook_command = stripped.split("=", 1)[1].strip().strip('"').strip("'")

            is_scholar = hook_event in replace_events and hook_command in scholar_commands

            if is_scholar:
                # Remove any Scholar comment markers before this hook block
                while new_lines and new_lines[-1].strip().startswith("# ---"):
                    new_lines.pop()
                while new_lines and new_lines[-1].strip() == "":
                    new_lines.pop()
                continue

            # Not a Scholar hook — keep it
            new_lines.extend(hook_block)
            continue

        new_lines.append(line)
        i += 1

    while new_lines and new_lines[-1].strip() == "":
        new_lines.pop()

    text = "\n".join(new_lines) + "\n"

    # 2. Detect missing top-level defaults from template
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

    # 3. Existing non-Scholar hooks are already preserved in raw text above.
    #    Only append selected Scholar hooks here; otherwise user hooks would be
    #    duplicated and could run twice.
    final_hooks = list(scholar_hooks_to_add)

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

    # Atomic write: write to uniquely-named temp, then rename
    import tempfile, os
    fd, tmp_name = tempfile.mkstemp(
        dir=str(target_path.parent),
        prefix=target_path.name + ".",
        suffix=".tmp"
    )
    try:
        with os.fdopen(fd, 'w') as f:
            f.write(text)
        os.replace(tmp_name, target_path)
    except Exception:
        os.unlink(tmp_name)
        raise


target_path = pathlib.Path(sys.argv[1])
template_path = pathlib.Path(sys.argv[2])
dry_run = sys.argv[3] == "1"
auto_yes = sys.argv[4] == "1"

template_text = template_path.read_text()
try:
    template = tomllib.loads(template_text)
except Exception as e:
    print(f"INVALID_TEMPLATE:{e}")
    raise SystemExit(1)

template_hooks = template.get("hooks", [])
if not isinstance(template_hooks, list):
    template_hooks = [template_hooks]

scholar_events = {h.get("event", "") for h in template_hooks}

# Fresh install
if not target_path.exists():
    if dry_run:
        print("DRY_FRESH")
    else:
        target_path.write_text(template_text)
        print("FRESH_INSTALL")
    raise SystemExit(0)

# Existing config — parse and analyze
existing_text = target_path.read_text()
try:
    existing = tomllib.loads(existing_text)
except Exception as e:
    print(f"INVALID_EXISTING_CONFIG:{e}")
    raise SystemExit(1)

existing_hooks = existing.get("hooks", [])
if not isinstance(existing_hooks, list):
    existing_hooks = [existing_hooks]

existing_event_map = {}
for i, h in enumerate(existing_hooks):
    ev = h.get("event", "")
    if ev:
        existing_event_map[ev] = i

# Categorize hooks
conflicts = []
new_hooks = []
for th in template_hooks:
    ev = th.get("event", "")
    if ev in existing_event_map:
        conflicts.append({
            "event": ev,
            "existing": existing_hooks[existing_event_map[ev]],
            "scholar": th,
        })
    else:
        new_hooks.append(th)

# If no conflicts and no new hooks, nothing to do
if not conflicts and not new_hooks:
    print("NOOP")
    raise SystemExit(0)

# Dry-run: just report
if dry_run:
    print("DRY_CONFLICTS")
    raise SystemExit(0)

# Non-interactive or no conflicts: merge directly
if not conflicts:
    _do_merge(target_path, template, existing, new_hooks, [])
    print("MERGED_OK")
    raise SystemExit(0)

if auto_yes:
    scholar_hooks_to_add = list(template_hooks)
    _do_merge(target_path, template, existing, scholar_hooks_to_add, scholar_events)
    print("MERGED_OK")
    raise SystemExit(0)

# Interactive: show diff and ask
print("", file=sys.stderr)
print("╔════════════════════════════════════════════════════════════╗", file=sys.stderr)
print("║   Hook changes detected in config.toml                     ║", file=sys.stderr)
print("╚════════════════════════════════════════════════════════════╝", file=sys.stderr)
print("", file=sys.stderr)

if conflicts:
    print(f"  {len(conflicts)} hook(s) conflict with existing configuration:\n", file=sys.stderr)
    for c in conflicts:
        ev = c["event"]
        old_cmd = c["existing"].get("command", "")
        new_cmd = c["scholar"].get("command", "")
        print(f"  [{ev}]", file=sys.stderr)
        if old_cmd != new_cmd:
            print(f"    - command = \"{old_cmd}\"", file=sys.stderr)
            print(f"    + command = \"{new_cmd}\"", file=sys.stderr)
        else:
            print(f"    (same command path)", file=sys.stderr)
        for k in sorted(c["scholar"].keys()):
            if k in ("event", "command"):
                continue
            old_val = c["existing"].get(k)
            new_val = c["scholar"][k]
            if old_val != new_val:
                print(f"    - {k} = {repr(old_val)}", file=sys.stderr)
                print(f"    + {k} = {repr(new_val)}", file=sys.stderr)
        print("", file=sys.stderr)

if new_hooks:
    print(f"  {len(new_hooks)} new hook(s) will be added:\n", file=sys.stderr)
    for h in new_hooks:
        print(f"  [{h.get('event', '')}] (new)", file=sys.stderr)
        for k, v in sorted(h.items()):
            if k == "event":
                continue
            print(f"    + {k} = {repr(v)}", file=sys.stderr)
print("", file=sys.stderr)

print("How would you like to proceed?", file=sys.stderr)
print("  (y) Refresh Scholar hooks and add new ones while preserving user hooks", file=sys.stderr)
print("  (k) Keep existing hooks, add only new hooks", file=sys.stderr)
print("  (s) Select individually", file=sys.stderr)
print("  (n) Skip all hook changes", file=sys.stderr)
print("", file=sys.stderr)

while True:
    try:
        print("Choice [y/k/s/n]: ", end="", file=sys.stderr)
        choice = input().strip().lower()
    except EOFError:
        choice = ""
    if choice in ("y", "k", "s", "n", ""):
        break

choice = choice or "y"

if choice == "n":
    # Keep all existing hooks and add nothing.
    print("SKIPPED")
    raise SystemExit(42)

if choice == "k":
    # Keep existing, add only new hooks
    _do_merge(target_path, template, existing, new_hooks, [])
    print("MERGED_KEEP")
    raise SystemExit(0)

if choice == "y":
    # Refresh Scholar hooks + add new, while keeping user hooks intact.
    scholar_hooks_to_add = list(template_hooks)
    _do_merge(target_path, template, existing, scholar_hooks_to_add, scholar_events)
    print("MERGED_OK")
    raise SystemExit(0)

# Individual selection
scholar_hooks_to_add = []
replace_events = set()
for th in template_hooks:
    ev = th.get("event", "")
    is_conflict = any(c["event"] == ev for c in conflicts)
    is_new = any(h.get("event", "") == ev for h in new_hooks)

    if not is_conflict and not is_new:
        continue

    if is_new:
        prompt = f"Add new hook [{ev}]? [Y/n]: "
    else:
        prompt = f"Overwrite existing hook [{ev}]? [Y/n]: "

    while True:
        try:
            print(prompt, end="", file=sys.stderr)
            individual = input().strip().lower()
        except EOFError:
            individual = "y"
        if individual in ("y", "n", ""):
            break

    if individual == "y" or individual == "":
        scholar_hooks_to_add.append(th)
        if is_conflict:
            replace_events.add(ev)

_do_merge(target_path, template, existing, scholar_hooks_to_add, replace_events)
print("MERGED_SELECT")
raise SystemExit(0)


PY
  if [ "$DRY_RUN" != "1" ] && [ -f "$target" ]; then
    backup_path "$target"
  fi

  local merge_rc=0
  action="$(python3 "$_SCHOLAR_TMP_1" "$target" "$template" "$DRY_RUN" "$AUTO_YES")" || merge_rc=$?
  action="${action%%[$'\n\r']}"  # strip trailing newline from Python print
  rm -f "$_SCHOLAR_TMP_1"
  if [ "$merge_rc" -ne 0 ] && [ "$action" != "SKIPPED" ]; then
    case "$action" in
      INVALID_EXISTING_CONFIG:*)
        warn "Invalid existing config.toml: ${action#INVALID_EXISTING_CONFIG:}"
        ;;
      INVALID_TEMPLATE:*)
        warn "Invalid template config.toml: ${action#INVALID_TEMPLATE:}"
        ;;
      *)
        warn "Failed to analyze or merge config.toml"
        ;;
    esac
    return "$merge_rc"
  fi

  case "$action" in
    FRESH_INSTALL)
      CONFIG_CREATED=1
      info "Created config.toml (fresh install)"
      ;;
    DRY_FRESH)
      CONFIG_CREATED=1
      info "Would create config.toml (dry-run)"
      ;;
    MERGED_OK|MERGED_KEEP|MERGED_SELECT)
      info "Merged hooks into config.toml"
      ;;
    DRY_CONFLICTS)
      info "Would merge hooks into config.toml (dry-run)"
      ;;
    NOOP)
      info "config.toml already up to date"
      ;;
    SKIPPED)
      SKIP_HOOKS_COPY=1
      info "Skipped hook changes (user chose to keep existing)"
      ;;
    INVALID_TEMPLATE:*)
      warn "Invalid template config.toml: ${action#INVALID_TEMPLATE:}"
      ;;
    *)
      warn "Unexpected result from config merge: $action"
      ;;
  esac

}

# ---------------------------------------------------------------------------
# Kimi Code CLI specific: mcp.json
# ---------------------------------------------------------------------------
merge_mcp_config() {
  local template="$SRC_DIR/mcp.json"
  local target="$KIMI_HOME/mcp.json"

  [ -f "$template" ] || {
    debug "Template mcp.json not found at $template — skipping"
    return 0
  }

  if [ -f "$target" ]; then
    # Preview what would change
    local preview=""
    local _SCHOLAR_TMP_2="$(mktemp)"
    _SCHOLAR_TEMP_SCRIPTS+=("$_SCHOLAR_TMP_2")
    cat > "$_SCHOLAR_TMP_2" <<'PY'
import json, pathlib, sys

target_path = pathlib.Path(sys.argv[1])
template_path = pathlib.Path(sys.argv[2])

existing = json.loads(target_path.read_text())
template = json.loads(template_path.read_text())

changes = []
if "mcpServers" in template:
    for name, config in template["mcpServers"].items():
        if name not in existing.get("mcpServers", {}):
            changes.append(f"+ {name} (new)")
        elif existing["mcpServers"][name] != config:
            changes.append(f"~ {name} (modified)")

if changes:
    print("CHANGES:\n" + "\n".join(changes))
else:
    print("NOOP")
PY
    if ! preview="$(python3 "$_SCHOLAR_TMP_2" "$target" "$template")"; then
      rm -f "$_SCHOLAR_TMP_2"
      warn "Failed to parse existing mcp.json — skipping MCP config merge"
      return 1
    fi
    preview="${preview%%[$'\n\r']}"  # strip trailing newline from Python print
    rm -f "$_SCHOLAR_TMP_2"
    case "$preview" in
      NOOP)
        info "mcp.json already up to date"
        return 0
        ;;
      CHANGES:*)
        echo ""
        echo "  MCP servers to be added/modified:"
        echo "${preview#CHANGES:}"
        echo ""
        if ! _confirm "Proceed with MCP config merge? [Y/n]: "; then
          info "Skipping MCP config merge"
          return 0
        fi
        ;;
    esac

    backup_path "$target"

    if [ "$DRY_RUN" = "1" ]; then
      info "Would merge MCP config (dry-run)"
      return 0
    fi

    record_mcp_state_before_merge "$target" "$template" "0" \
      || return 1

    if ! python3 - "$target" "$template" <<'PY'
import json, pathlib, sys

target_path = pathlib.Path(sys.argv[1])
template_path = pathlib.Path(sys.argv[2])

existing = json.loads(target_path.read_text())
template = json.loads(template_path.read_text())

if "mcpServers" in template:
    if "mcpServers" not in existing:
        existing["mcpServers"] = {}
    for name, config in template["mcpServers"].items():
        # Only overwrite if config actually differs
        if existing["mcpServers"].get(name) != config:
            existing["mcpServers"][name] = config

# Atomic write
import tempfile, os
text = json.dumps(existing, indent=2) + '\n'
fd, tmp_name = tempfile.mkstemp(
    dir=str(target_path.parent),
    prefix=target_path.name + ".",
    suffix=".tmp"
)
try:
    with os.fdopen(fd, 'w') as f:
        f.write(text)
    os.replace(tmp_name, target_path)
except Exception:
    os.unlink(tmp_name)
    raise
PY
    then
      warn "Failed to merge MCP config into mcp.json"
      return 1
	    fi
	    info "Merged MCP config into mcp.json"
	    sync_mcp_state_after_merge "$target" "$template" \
	      || return 1
	  else
	    if [ "$DRY_RUN" = "1" ]; then
      info "Would create mcp.json (dry-run)"
    else
      record_created_mcp_state "$template" "$template" \
        || return 1
      cp "$template" "$target"
      sync_mcp_state_after_merge "$target" "$template" \
        || return 1
      info "Created mcp.json"
	    fi
	  fi
}

# ---------------------------------------------------------------------------
# Zotero MCP interactive configuration
# ---------------------------------------------------------------------------
configure_zotero_mcp() {
  [ "$DRY_RUN" = "1" ] && return 0

  local mcp_file="$KIMI_HOME/mcp.json"
  [ -f "$mcp_file" ] || return 0

  # Check if zotero is in the merged config
  if ! python3 -c "import json; d=json.load(open('$mcp_file')); exit(0 if 'zotero' in d.get('mcpServers', {}) else 1)" 2>/dev/null; then
    return 0
  fi

  # Non-interactive: skip with warning
  if [ ! -t 0 ] || [ "$AUTO_YES" = "1" ]; then
    warn "Zotero MCP configuration skipped in non-interactive mode."
    warn "Run interactively or manually edit $KIMI_HOME/mcp.json to configure."
    return 0
  fi

  echo ""
  if ! _confirm "Enable Zotero MCP server? [y/N]: " "n"; then
    return 0
  fi

  if ! command -v zotero-mcp >/dev/null 2>&1; then
    warn "zotero-mcp not found."
    warn "Install with: uv tool install git+https://github.com/Galaxy-Dawn/zotero-mcp.git"
  fi

  echo ""
  echo "  Zotero MCP configuration (all fields optional — press Enter to skip):"
  echo ""

  local zotero_api_key=""
  local zotero_library_id=""
  local unpaywall_email=""

  read -srp "    ZOTERO_API_KEY (for Web API write access): " zotero_api_key; echo ""
  read -rp "    ZOTERO_LIBRARY_ID (your numeric User ID):  " zotero_library_id
  read -rp "    UNPAYWALL_EMAIL (for PDF lookup):          " unpaywall_email

  ZOTERO_API_KEY="$zotero_api_key" ZOTERO_LIBRARY_ID="$zotero_library_id" ZOTERO_UNPAYWALL_EMAIL="$unpaywall_email" \
  python3 - "$mcp_file" <<'PY'
import json, pathlib, sys, os

mcp_path = pathlib.Path(sys.argv[1])
api_key = os.environ.get("ZOTERO_API_KEY", "")
library_id = os.environ.get("ZOTERO_LIBRARY_ID", "")
email = os.environ.get("ZOTERO_UNPAYWALL_EMAIL", "")

data = json.loads(mcp_path.read_text())

if "zotero" in data.get("mcpServers", {}):
    env = data["mcpServers"]["zotero"].setdefault("env", {})
    if api_key:
        env["ZOTERO_API_KEY"] = api_key
    if library_id:
        env["ZOTERO_LIBRARY_ID"] = library_id
    if email:
        env["UNPAYWALL_EMAIL"] = email
    env.setdefault("ZOTERO_LIBRARY_TYPE", "user")
    env.setdefault("UNSAFE_OPERATIONS", "all")
    env.setdefault("NO_PROXY", "localhost,127.0.0.1")
    env.setdefault("ZOTERO_LOCAL", "true")

mcp_path.write_text(json.dumps(data, indent=2) + '\n')
PY

  sync_mcp_state_after_merge "$mcp_file" "$SRC_DIR/mcp.json" \
    || warn "Failed to update MCP state after Zotero configuration"
  info "Zotero MCP configured in mcp.json"
}

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
check_deps() {
  command -v git >/dev/null || error "Git is required."
  command -v python3 >/dev/null || error "Python 3 is required."

  # Warn if Kimi CLI not detected, but don't fail — user might install later
  if ! command -v kimi-code >/dev/null 2>&1 && ! command -v kimi >/dev/null 2>&1; then
    warn "Kimi Code CLI not detected on PATH."
    warn "Install from: https://www.kimi.com/code"
    echo ""
  fi
}

check_kimi_login() {
  local oauth_file="$KIMI_HOME/oauth/kimi-code"
  local creds_file="$KIMI_HOME/credentials/kimi-code.json"

  if [ -f "$oauth_file" ] || [ -f "$creds_file" ]; then
    info "Kimi login detected"
    return 0
  fi

  # Non-interactive: warn and continue
  if [ ! -t 0 ] || [ "$AUTO_YES" = "1" ]; then
    warn "Kimi login not detected. Continuing in non-interactive mode."
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

  if ! _confirm "Continue installation anyway? [y/N]: " "n"; then
    info "Installation aborted. Run 'kimi login' and try again."
    exit 0
  fi
}

# ---------------------------------------------------------------------------
# Preview (runs BEFORE any modifications)
# ---------------------------------------------------------------------------
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

  # MCP changes — check if actual changes are needed
  local mcp_template="$SRC_DIR/mcp.json"
  local mcp_target="$KIMI_HOME/mcp.json"
  if [ -f "$mcp_template" ]; then
    if [ ! -f "$mcp_target" ]; then
      new_files+=("mcp.json")
    elif ! cmp -s "$mcp_template" "$mcp_target"; then
      # Template and target differ — check if mcpServers actually changed
      local mcp_diff=""
      if ! mcp_diff="$(python3 - "$mcp_target" "$mcp_template" <<'PY'
import json, sys
existing = json.load(open(sys.argv[1]))
template = json.load(open(sys.argv[2]))
changes = []
for name, cfg in template.get("mcpServers", {}).items():
    if name not in existing.get("mcpServers", {}):
        changes.append(name)
    elif existing["mcpServers"][name] != cfg:
        changes.append(name)
print("CHANGED" if changes else "SAME")
PY
)"; then
        warn "Failed to parse existing mcp.json — cannot preview MCP config merge"
        return 2
      fi
      if [ "$mcp_diff" = "SAME" ]; then
        :  # No actual changes, skip from preview
      else
        config_changes+=("mcp.json  (merge Zotero MCP)")
      fi
    fi
  fi

  # Component directories
  local comp src_dir target_dir
  for comp in skills agents templates; do
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
    done < <(find "$src_dir" -type f -print0)
  done

  # Hooks
  if [ "$SKIP_HOOKS_COPY" != "1" ]; then
    comp="hooks"
    src_dir="$SRC_DIR/$comp"
    target_dir="$KIMI_HOME/$comp"
    if [ -d "$src_dir" ]; then
      while IFS= read -r -d '' src_file; do
        local rel="${src_file#$src_dir/}"
        local target_file="$target_dir/$rel"
        if [ ! -e "$target_file" ]; then
          new_files+=("$comp/$rel")
        elif ! cmp -s "$src_file" "$target_file"; then
          modified_files+=("$comp/$rel")
        fi
      done < <(find "$src_dir" -type f -print0)
    fi
  fi

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

  # Print preview
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
  if [ "$DRY_RUN" = "1" ]; then
    echo "  Mode: $(yellow 'DRY RUN') — no files will be modified"
  elif [ "$BACKUP_READY" -eq 1 ] || [ -d "$BACKUP_DIR" ]; then
    echo "  Backup directory: $BACKUP_DIR"
  fi
  echo ""

  if [ "$DRY_RUN" = "1" ]; then
    return 0
  fi

  if ! _confirm "Proceed with installation? [Y/n]: "; then
    info "Installation cancelled."
    exit 0
  fi

  return 0
}

# ---------------------------------------------------------------------------
# Copy components
# ---------------------------------------------------------------------------
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
  if [ "$SKIP_HOOKS_COPY" != "1" ] && [ -d "$SRC_DIR/hooks" ]; then
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

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  parse_args "$@"

  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║   Claude Scholar Installer (Kimi)    ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  run_step "check_deps" check_deps
  run_step "check_kimi_login" check_kimi_login
  run_step "load_previous_manifest" load_previous_manifest
  run_step "load_previous_mcp_state" load_previous_mcp_state

  info "Source: $SRC_DIR"
  info "Target: $KIMI_HOME"
  if [ "$DRY_RUN" != "1" ]; then
    mkdir -p "$KIMI_HOME" || error "Failed to create KIMI_HOME at $KIMI_HOME"
  fi
  run_step "validate_install_metadata_targets" validate_install_metadata_targets
  run_step "validate_mcp_config_schema" validate_mcp_config_schema

  # --- Preview phase (NO modifications yet) ---
  # We need to know SKIP_HOOKS_COPY before preview, so we do a dry analysis
  # of config.toml first. merge_kimi_config handles this internally.
  # For preview, we call merge in analysis mode only.

  # Actually: collect_preview needs SKIP_HOOKS_COPY which comes from merge_kimi_config.
  # So we call merge_kimi_config first (it can be interactive), then preview.
  # But we must NOT let merge_kimi_config modify files until after preview.
  #
  # Solution: merge_kimi_config is idempotent and respects DRY_RUN.
  # In non-dry-run mode, it modifies the file. So for preview flow:
  #   1. Run merge_kimi_config (may modify config.toml)
  #   2. Run collect_preview
  #   3. If user cancels, we need to rollback.
  #
  # Better solution: config modifications happen AFTER preview.
  # We temporarily set DRY_RUN=1 for merge_kimi_config during preview,
  # then restore and re-run after confirmation.

  local saved_dry_run="$DRY_RUN"

  # Phase 1: Dry analysis to populate SKIP_HOOKS_COPY
  DRY_RUN=1
  if ! run_step "analyze_config" merge_kimi_config; then
    DRY_RUN="$saved_dry_run"
    error "Step failed: analyze_config"
  fi
  DRY_RUN="$saved_dry_run"

  # Phase 2: Preview
  run_step "collect_preview" collect_preview
  local preview_rc=$?
  case "$preview_rc" in
    0)
      ;;
    1)
      info "Nothing to do."
      exit 0
      ;;
    *)
      error "Step failed: collect_preview"
      ;;
  esac

  # Phase 3: Actual modifications
  if [ "$DRY_RUN" != "1" ]; then
    run_step "merge_kimi_config" merge_kimi_config || error "Step failed: merge_kimi_config"
    run_step "merge_mcp_config" merge_mcp_config || error "Step failed: merge_mcp_config"
    run_step "configure_zotero_mcp" configure_zotero_mcp || true  # Zotero config is optional
    run_step "copy_components" copy_components || error "Step failed: copy_components"
    run_step "write_install_state" write_install_state || error "Step failed: write_install_state"

    # Validate resulting config.toml
    if [ -f "$KIMI_HOME/config.toml" ]; then
      if ! python3 -c "import tomllib; tomllib.load(open('$KIMI_HOME/config.toml', 'rb'))" 2>/dev/null; then
        warn "config.toml may have syntax errors. Please verify manually."
      fi
    fi
  fi

  # Summary
  echo ""
  echo "============================================================"
  if [ "$DRY_RUN" = "1" ]; then
    info "Dry run complete — no files were modified."
  else
    info "Installation complete!"
  fi
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
  if [ "$DRY_RUN" != "1" ]; then
    echo "  $(green 'Restart Kimi Code CLI to activate changes:')"
    echo "    kimi restart"
    echo "    # or start a new session"
  fi
  echo "============================================================"
}

main "$@"
