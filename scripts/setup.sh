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
  # We merge by:
  # 1. Keeping user's existing [providers], [models], [services]
  # 2. Adding/merging [[hooks]] from template
  # 3. Setting default_model and merge_all_available_skills if not present

  python3 - "$target" "$template" "$BACKUP_STAMP" <<'PY'
import pathlib
import sys
import tomllib
import tomli_w

target_path = pathlib.Path(sys.argv[1])
template_path = pathlib.Path(sys.argv[2])

# Read template
template_text = template_path.read_text()

try:
    template = tomllib.loads(template_text)
except Exception:
    template = {}

# Read existing target if present
if target_path.exists():
    try:
        existing = tomllib.loads(target_path.read_text())
    except Exception:
        existing = {}
else:
    existing = {}

# Start with existing config
merged = dict(existing)

# Set top-level defaults if not present
if "default_model" not in merged and "default_model" in template:
    merged["default_model"] = template["default_model"]
if "default_thinking" not in merged and "default_thinking" in template:
    merged["default_thinking"] = template["default_thinking"]
if "merge_all_available_skills" not in merged and "merge_all_available_skills" in template:
    merged["merge_all_available_skills"] = template["merge_all_available_skills"]
if "telemetry" not in merged and "telemetry" in template:
    merged["telemetry"] = template["telemetry"]

# Merge hooks: template hooks overwrite any existing hooks with same event+matcher
existing_hooks = merged.get("hooks", [])
if not isinstance(existing_hooks, list):
    existing_hooks = [existing_hooks]

template_hooks = template.get("hooks", [])
if not isinstance(template_hooks, list):
    template_hooks = [template_hooks]

# Build a key map for existing hooks
hook_keys = {}
for i, h in enumerate(existing_hooks):
    key = (h.get("event", ""), h.get("matcher", ""))
    hook_keys[key] = i

for th in template_hooks:
    key = (th.get("event", ""), th.get("matcher", ""))
    if key in hook_keys:
        existing_hooks[hook_keys[key]] = th
    else:
        existing_hooks.append(th)

if existing_hooks:
    merged["hooks"] = existing_hooks

# Write merged config
# Use tomli_w for proper TOML writing
try:
    import tomli_w
    target_path.write_text(tomli_w.dumps(merged))
except ImportError:
    # Fallback: just copy template if tomli_w not available
    if target_path.exists():
        target_path.write_text(template_text)
    else:
        target_path.write_text(template_text)
PY
  local py_rc=$?
  if [ "$py_rc" -ne 0 ]; then
    # Fallback: simple merge
    if [ -f "$target" ]; then
      # Append hooks from template to existing config
      local tmp_config
      tmp_config="$(mktemp)"
      cp "$target" "$tmp_config"
      # Extract hooks from template and append
      awk '/^\[\[hooks\]\]/{flag=1} flag{print} /^\[\[hooks\]\]$/{flag=1}' "$template" >> "$tmp_config"
      mv "$tmp_config" "$target"
    else
      cp "$template" "$target"
    fi
    CONFIG_CREATED=1
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
  if [ "$enable_zotero" = "y" ] || [ "$enable_zotero" = "Y" ]; then
    if ! command -v zotero-mcp >/dev/null 2>&1; then
      warn "zotero-mcp not found. Install with: uv tool install git+https://github.com/Galaxy-Dawn/zotero-mcp.git"
    fi
    info "Zotero MCP configured in mcp.json"
  fi
}

check_deps() {
  command -v git >/dev/null || error "Git is required."
  command -v python3 >/dev/null || error "Python 3 is required."
  select_find_cmd
  if ! command -v kimi-code >/dev/null 2>&1 && ! command -v kimi >/dev/null 2>&1; then
    warn "Kimi Code CLI not detected. Make sure it is installed and on PATH."
  fi
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
  run_step "load_previous_manifest" load_previous_manifest

  info "Source: $SRC_DIR"
  info "Target: $KIMI_HOME"
  mkdir -p "$KIMI_HOME" || error "Failed to create KIMI_HOME at $KIMI_HOME"

  run_step "merge_kimi_config" merge_kimi_config
  run_step "merge_mcp_config" merge_mcp_config
  run_step "configure_zotero_mcp" configure_zotero_mcp
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
