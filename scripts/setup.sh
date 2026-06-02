#!/usr/bin/env bash
# ============================================================
# Claude Scholar — Kimi Code CLI Installer
# ============================================================
# Usage: bash scripts/setup.sh
# Supports fresh install and safer incremental updates.

set -uo pipefail

KIMI_HOME="${KIMI_HOME:-$HOME/.kimi}"
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
CONFIG_SHA256=""
MANAGED_PATHS=()
AGENTS_TARGETS=()
CONFIG_META_FILE="$(mktemp)"
LEGACY_INSTALL_DETECTED=0

# --- State flags ---
SKIP_PROVIDER=false
SKIP_AUTH=false
PERSIST_AUTH=false
ENV_AUTH_DETECTED=0
PROVIDER_NAME=""
PROVIDER_URL=""
MODEL=""
AUTH_ENV_VAR_NAME="OPENAI_API_KEY"
API_KEY=""
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
  debug "state: SKIP_PROVIDER=$SKIP_PROVIDER SKIP_AUTH=$SKIP_AUTH PERSIST_AUTH=$PERSIST_AUTH ENV_AUTH_DETECTED=$ENV_AUTH_DETECTED"
  debug "state: PROVIDER_NAME=${PROVIDER_NAME:-<empty>} MODEL=${MODEL:-<empty>}"
  debug "state: config_exists=$([ -f "$KIMI_HOME/config.toml" ] && printf yes || printf no) auth_exists=$([ -f "$KIMI_HOME/auth.json" ] && printf yes || printf no) manifest_exists=$([ -f "$MANIFEST_FILE" ] && printf yes || printf no)"
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

normalize_host_path() {
  local path_value="$1"
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -m "$path_value"
  else
    printf '%s' "$path_value"
  fi
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

read_prompt() {
  local __var="$1"
  local prompt="$2"
  local default_value="${3:-}"
  local silent="${4:-0}"
  local value=""

  if [ "$silent" = "1" ]; then
    if read -rsp "$prompt" value; then
      echo ""
    else
      echo ""
      value="$default_value"
    fi
  else
    if ! read -rp "$prompt" value; then
      value="$default_value"
    fi
  fi

  if [ -z "$value" ]; then
    value="$default_value"
  fi

  printf -v "$__var" '%s' "$value"
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

# --- Presets ---
declare -a PRESET_NAMES=("openai" "custom")
declare -a PRESET_LABELS=("OpenAI (official)" "Custom provider")
declare -a PRESET_URLS=("https://api.openai.com/v1" "")
declare -a PRESET_MODELS=("gpt-5.4" "")

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

detect_legacy_install() {
  local config="$KIMI_HOME/config.toml"
  [ -f "$MANIFEST_FILE" ] && return 0
  [ -f "$config" ] || return 0

  if grep -q 'config_file = "~/.kimi-code/agents/' "$config" 2>/dev/null; then
    LEGACY_INSTALL_DETECTED=1
  fi
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

was_previously_managed() {
  local target="$1"
  local rel="${target#$KIMI_HOME/}"
  [ "$rel" = "$target" ] && return 1
  grep -Fxq "$rel" "$PREVIOUS_MANAGED_PATHS_FILE"
}

should_adopt_existing_path() {
  local target="$1"
  if was_previously_managed "$target"; then
    return 0
  fi
  if is_existing_scholar_agents_file "$target"; then
    return 0
  fi
  [ "$LEGACY_INSTALL_DETECTED" -eq 1 ]
}

is_existing_scholar_agents_file() {
  local target="$1"
  local rel="${target#$KIMI_HOME/}"
  [ "$rel" = "$target" ] && return 1

  case "$rel" in
    AGENTS.md|AGENTS.zh-CN.md) ;;
    *) return 1 ;;
  esac

  [ -f "$target" ] || return 1

  # Older Kimi Scholar installs may predate the install manifest. In that case
  # the global AGENTS files are still installer-owned and should be updated in
  # place. Keep the marker strict so genuinely custom user AGENTS files are
  # still preserved via AGENTS.scholar.md sidecars.
  head -n 40 "$target" | grep -Eq '^# (Kimi Scholar|Claude Scholar) (Core Instructions|核心指令)$'
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

write_config_meta() {
  local config_created="$1"
  local sections_csv="$2"
  local created_json="false"
  local first=1
  local section=""

  if [ "$config_created" = "true" ]; then
    created_json="true"
  fi

  {
    printf '{\n'
    printf '  "configCreated": %s,\n' "$created_json"
    printf '  "addedSections": ['
    local IFS=','
    for section in $sections_csv; do
      [ -n "$section" ] || continue
      if [ "$first" -eq 1 ]; then
        first=0
      else
        printf ', '
      fi
      printf '"%s"' "$section"
    done
    printf ']\n'
    printf '}\n'
  } > "$CONFIG_META_FILE" || error "Failed to write config metadata"
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

join_lines_csv() {
  awk 'BEGIN { first = 1 } NF { if (!first) printf ","; printf "%s", $0; first = 0 }'
}

write_install_state() {
  mkdir -p "$KIMI_HOME" || error "Failed to create KIMI_HOME at $KIMI_HOME"
  write_unique_lines "$MANIFEST_FILE" "${MANAGED_PATHS[@]}" || error "Failed to write install manifest"

  local managed_paths_file agents_targets_file
  managed_paths_file="$(mktemp)"
  agents_targets_file="$(mktemp)"

  write_unique_lines "$managed_paths_file" "${MANAGED_PATHS[@]}" || error "Failed to write managed paths temp file"

  write_unique_lines "$agents_targets_file" "${AGENTS_TARGETS[@]}" || error "Failed to write agents targets temp file"

  KIMI_STATE_FILE="$(normalize_host_path "$STATE_FILE")" \
  KIMI_CONFIG_META_FILE="$(normalize_host_path "$CONFIG_META_FILE")" \
  KIMI_MANAGED_PATHS_FILE="$(normalize_host_path "$managed_paths_file")" \
  KIMI_AGENTS_TARGETS_FILE="$(normalize_host_path "$agents_targets_file")" \
  KIMI_INSTALLED_AT="$BACKUP_STAMP" \
  KIMI_SOURCE_DIR="$(normalize_host_path "$SRC_DIR")" \
  KIMI_CONFIG_CREATED="$CONFIG_CREATED" \
  KIMI_CONFIG_SHA256="$CONFIG_SHA256" \
  KIMI_BACKUP_DIR="$(normalize_host_path "$BACKUP_DIR")" \
  KIMI_BACKUP_READY="$BACKUP_READY" \
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
  installedAt: process.env.KIMI_INSTALLED_AT,
  sourceDir: process.env.KIMI_SOURCE_DIR,
  configCreated: process.env.KIMI_CONFIG_CREATED === '1',
  configSha256: process.env.KIMI_CONFIG_SHA256 || '',
  backupDir: process.env.KIMI_BACKUP_READY === '1' ? process.env.KIMI_BACKUP_DIR : '',
  managedPaths: readLines(process.env.KIMI_MANAGED_PATHS_FILE),
  agentsTargets: readLines(process.env.KIMI_AGENTS_TARGETS_FILE),
  config: readJson(process.env.KIMI_CONFIG_META_FILE),
};

fs.writeFileSync(process.env.KIMI_STATE_FILE, JSON.stringify(state, null, 2) + '\n');
NODE
  local node_rc=$?
  rm -f "$managed_paths_file" "$agents_targets_file"
  [ "$node_rc" -eq 0 ] || error "Failed to write install state"
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
    if should_adopt_existing_path "$target_file"; then
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
  local target_file="$KIMI_HOME/AGENTS.zh-CN.md"
  local sidecar_file="$KIMI_HOME/$AGENTS_ZH_MD_SIDECAR"

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

# --- Auth/provider helpers ---
validate_env_var_name() {
  local name="$1"
  [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || error "Invalid env var name: $name"
}

read_auth_entry() {
  local file="$1"
  [ -f "$file" ] || return 0

  python3 - "$(normalize_host_path "$file")" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text())
except Exception:
    sys.exit(0)

for key, value in data.items():
    if isinstance(value, str) and value:
        print(f"{key}\t{value}")
        break
PY
}

normalize_env_prefix() {
  local raw="$1"
  printf '%s' "$raw" \
    | tr '[:lower:]-./' '[:upper:]___' \
    | sed 's/[^A-Z0-9_]/_/g; s/__*/_/g; s/^_//; s/_$//'
}

collect_api_key_candidates() {
  local provider="$1"
  local normalized_provider=""
  local -a candidates=()

  if [ -n "$provider" ]; then
    normalized_provider=$(normalize_env_prefix "$provider")
    if [ -n "$normalized_provider" ]; then
      candidates+=("${normalized_provider}_API_KEY")
    fi
  fi

  candidates+=(
    "OPENAI_API_KEY"
    "ANTHROPIC_API_KEY"
    "OPENROUTER_API_KEY"
    "GEMINI_API_KEY"
    "GOOGLE_API_KEY"
    "DEEPSEEK_API_KEY"
    "DASHSCOPE_API_KEY"
    "SILICONFLOW_API_KEY"
    "XAI_API_KEY"
    "GROQ_API_KEY"
    "MISTRAL_API_KEY"
    "COHERE_API_KEY"
    "TOGETHER_API_KEY"
    "FIREWORKS_API_KEY"
    "MOONSHOT_API_KEY"
    "ZHIPU_API_KEY"
  )

  printf '%s\n' "${candidates[@]}" | awk '!seen[$0]++'
}

detect_existing_env_auth() {
  local provider="$1"
  local candidate=""
  local value=""

  ENV_AUTH_DETECTED=0

  while IFS= read -r candidate; do
    [ -n "$candidate" ] || continue
    value="${!candidate:-}"
    if [ -n "$value" ]; then
      AUTH_ENV_VAR_NAME="$candidate"
      API_KEY="$value"
      PERSIST_AUTH=true
      ENV_AUTH_DETECTED=1
      info "No auth.json found; detected an API key in the environment and will persist it for Kimi compatibility"
      return 0
    fi
  done < <(collect_api_key_candidates "$provider") || true

  return 0
}

check_deps() {
  command -v git >/dev/null || error "Git is required."
  command -v python3 >/dev/null || error "Python 3 is required."
  select_find_cmd
  if ! command -v kimi >/dev/null; then
    warn "Kimi Code CLI not found. Install: npm i -g @openai/kimi"
  fi
}

detect_existing() {
  echo ""
  if [ -f "$KIMI_HOME/config.toml" ]; then
    info "Existing config.toml found at $KIMI_HOME/config.toml"
    local cur_model cur_provider
    cur_model=$(grep '^model ' "$KIMI_HOME/config.toml" 2>/dev/null | head -1 | sed 's/.*= *"//;s/".*//' || true)
    cur_provider=$(grep '^model_provider ' "$KIMI_HOME/config.toml" 2>/dev/null | head -1 | sed 's/.*= *"//;s/".*//' || true)
    PROVIDER_NAME="$cur_provider"
    [ -n "$cur_model" ] && info "  Current model: $cur_model"
    [ -n "$cur_provider" ] && info "  Current provider: $cur_provider"
    SKIP_PROVIDER=true
    info "Detected existing provider/model configuration; keeping it without prompting"
  fi

  if [ -f "$KIMI_HOME/auth.json" ]; then
    local auth_entry existing_key_name existing_key_value
    auth_entry=$(read_auth_entry "$KIMI_HOME/auth.json")
    if [ -n "$auth_entry" ]; then
      IFS=$'\t' read -r existing_key_name existing_key_value <<< "$auth_entry"
      AUTH_ENV_VAR_NAME="$existing_key_name"
      info "Existing auth.json credential found; leaving it untouched"
    else
      info "Existing auth.json found; leaving it untouched"
    fi
    SKIP_AUTH=true
    info "Detected existing authentication configuration; keeping it without prompting"
  elif [ "$SKIP_PROVIDER" = true ]; then
    SKIP_AUTH=true
    detect_existing_env_auth "$PROVIDER_NAME"
    if [ "$ENV_AUTH_DETECTED" -ne 1 ]; then
      info "Existing Kimi config detected; installer will not prompt for credentials or overwrite your current auth flow"
    fi
  fi
  debug "detect_existing: complete"
}

choose_provider() {
  if [ "$SKIP_PROVIDER" = true ]; then
    return
  fi

  echo ""
  bold "Select API provider:"
  echo ""
  for i in "${!PRESET_LABELS[@]}"; do
    echo "  $((i+1))) ${PRESET_LABELS[$i]}"
  done
  echo ""

  local choice
  read_prompt choice "Enter choice [1-2] (default: 1): " "1"

  case "$choice" in
    ''|*[!0-9]*)
      warn "Invalid provider choice '$choice'; using default: 1"
      choice="1"
      ;;
  esac

  local idx=$((choice - 1))
  if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#PRESET_NAMES[@]}" ]; then
    warn "Invalid provider choice '$choice'; using default: 1"
    idx=0
  fi

  PROVIDER_NAME="${PRESET_NAMES[$idx]}"
  PROVIDER_URL="${PRESET_URLS[$idx]}"
  MODEL="${PRESET_MODELS[$idx]}"

  if [ "$PROVIDER_NAME" = "custom" ]; then
    read_prompt PROVIDER_NAME "Provider name: " ""
    read_prompt PROVIDER_URL "Base URL: " ""
    read_prompt MODEL "Model name: " ""
    [ -n "$PROVIDER_NAME" ] || error "Provider name is required for custom provider."
    [ -n "$PROVIDER_URL" ] || error "Base URL is required for custom provider."
    [ -n "$MODEL" ] || error "Model name is required for custom provider."
  else
    echo ""
    read_prompt input_model "Model name (default: $MODEL): " "$MODEL"
    MODEL="$input_model"
  fi

  info "Provider: $PROVIDER_NAME | URL: $PROVIDER_URL | Model: $MODEL"
}

configure_api_key() {
  if [ "$SKIP_AUTH" = true ]; then
    return
  fi

  echo ""
  read_prompt input_env_name "API key env var name (default: $AUTH_ENV_VAR_NAME): " "$AUTH_ENV_VAR_NAME"
  AUTH_ENV_VAR_NAME="$input_env_name"
  validate_env_var_name "$AUTH_ENV_VAR_NAME"

  local env_value="${!AUTH_ENV_VAR_NAME:-}"
  if [ -n "$env_value" ]; then
    API_KEY="$env_value"
    PERSIST_AUTH=true
    info "Detected $AUTH_ENV_VAR_NAME in current environment; will reuse it without prompting for the key again"
    return
  fi

  read_prompt API_KEY "Enter API key for $AUTH_ENV_VAR_NAME (or press Enter to skip): " "" "1"
  if [ -z "$API_KEY" ]; then
    warn "No API key set. Make sure $AUTH_ENV_VAR_NAME is available in your environment."
    SKIP_AUTH=true
    return
  fi

  PERSIST_AUTH=true
}

generate_fresh_config() {
  local template="$1"
  local target="$2"
  local sections=""

  sed -e "s|__MODEL__|$MODEL|g" \
      -e "s|__PROVIDER_NAME__|$PROVIDER_NAME|g" \
      -e "s|__PROVIDER_URL__|$PROVIDER_URL|g" \
      "$template" > "$target" || error "Failed to render config.toml from template"
  CONFIG_CREATED=1
  CONFIG_SHA256="$(file_sha256 "$target")"
  sections="$(
    awk '
      {
        line = $0
        sub(/\r$/, "", line)
        if (line ~ /^\[[^]]+\]$/) {
          print substr(line, 2, length(line) - 2)
        }
      }
    ' "$target" | join_lines_csv
  )" || error "Failed to collect config metadata"
  write_config_meta true "$sections"
  info "Generated config.toml (model=$MODEL, provider=$PROVIDER_NAME)"
}

merge_scholar_config() {
  local target="$1"
  local template="$2"
  local added_file
  added_file="$(mktemp)"

  append_template_section() {
    local header="$1"
    local block=""

    if grep -Fq "[$header]" "$target"; then
      return 0
    fi

    block="$(
      awk -v wanted="[$header]" '
        {
          line = $0
          sub(/\r$/, "", line)
        }
        line == wanted {
          capture = 1
          print line
          next
        }
        capture && line ~ /^\[/ {
          exit
        }
        capture {
          print line
        }
      ' "$template"
    )"

    if [ -n "$block" ]; then
      printf '\n\n%s\n' "$block" >> "$target" || return 1
      printf '%s\n' "$header" >> "$added_file" || return 1
    fi
  }

  append_template_section "features" || return 1
  append_template_section "mcp_servers.zotero" || return 1
  append_template_section "mcp_servers.zotero.env" || return 1

  while IFS= read -r header; do
    [ -n "$header" ] || continue
    append_template_section "$header" || return 1
  done < <(
    awk '
      {
        line = $0
        sub(/\r$/, "", line)
        if (line ~ /^\[agents\.[^]]+\]$/) {
          print substr(line, 2, length(line) - 2)
        }
      }
    ' "$template"
  )

  if [ -s "$added_file" ]; then
    join_lines_csv < "$added_file"
  fi
  rm -f "$added_file"
}

generate_config() {
  local template="$SRC_DIR/config.toml"
  local target="$KIMI_HOME/config.toml"

  [ -f "$template" ] || error "Template config.toml not found at $template"

  if [ -f "$target" ]; then
    backup_path "$target"
    cp "$target" "${target}.bak" || error "Failed to write config.toml.bak"
    info "Backed up config.toml → config.toml.bak"
  fi

  if [ "$SKIP_PROVIDER" = true ]; then
    local added
    added=$(merge_scholar_config "$target" "$template") || error "Failed to merge Scholar config sections"
    write_config_meta false "$added"
    CONFIG_SHA256="$(file_sha256 "$target")"
    if [ -n "$added" ]; then
      info "Merged Scholar sections into existing config.toml: $added"
    else
      info "Config already had the required Scholar sections"
    fi
  else
    generate_fresh_config "$template" "$target"
  fi
}

write_auth() {
  if [ "$PERSIST_AUTH" != true ]; then
    return
  fi

  local target="$KIMI_HOME/auth.json"
  if [ -f "$target" ]; then
    backup_path "$target"
    cp "$target" "${target}.bak" || error "Failed to write auth.json.bak"
    info "Backed up auth.json → auth.json.bak"
  fi
  python3 - "$(normalize_host_path "$target")" "$AUTH_ENV_VAR_NAME" "$API_KEY" <<'PY'
import json
import pathlib
import sys

target = pathlib.Path(sys.argv[1])
env_name = sys.argv[2]
api_key = sys.argv[3]

payload = {env_name: api_key}
if env_name != "OPENAI_API_KEY":
    payload["OPENAI_API_KEY"] = api_key

target.write_text(json.dumps(payload, indent=2) + "\n")
PY
  [ "$?" -eq 0 ] || error "Failed to write auth.json"
  chmod 600 "$target" || error "Failed to set auth.json permissions"
  if [ "$AUTH_ENV_VAR_NAME" = "OPENAI_API_KEY" ]; then
    info "Wrote auth.json (permissions: 600)"
  else
    info "Wrote auth.json with $AUTH_ENV_VAR_NAME and OPENAI_API_KEY for Kimi compatibility (permissions: 600)"
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
  if [ -f "$SRC_DIR/AGENTS.md" ]; then
    install_agents_md "$SRC_DIR/AGENTS.md"
  fi
  if [ -f "$SRC_DIR/AGENTS.zh-CN.md" ]; then
    install_agents_zh_md "$SRC_DIR/AGENTS.zh-CN.md"
  fi
  if [ -d "$SRC_DIR/scripts" ]; then
    copy_dir_safely "$SRC_DIR/scripts" "$KIMI_HOME/scripts"
  fi
  if [ -d "$SRC_DIR/utils" ]; then
    copy_dir_safely "$SRC_DIR/utils" "$KIMI_HOME/utils"
  fi

  info "Synced repo-managed Kimi components"
}

configure_mcp() {
  if ! grep -q '\[mcp_servers\.zotero\]' "$KIMI_HOME/config.toml" 2>/dev/null; then
    return
  fi

  if awk '/\[mcp_servers\.zotero\]/{flag=1;next}/^\[/{flag=0}flag && /enabled = true/{found=1}END{exit(found?0:1)}' "$KIMI_HOME/config.toml"; then
    info "Zotero MCP already enabled"
    return
  fi

  echo ""
  local enable_zotero=""
  read_prompt enable_zotero "Enable Zotero MCP server? [y/N]: " ""
  if [ -z "$enable_zotero" ] && [ ! -t 0 ]; then
    info "Zotero MCP is available but installer is running non-interactively; leaving it disabled"
  fi
  if [ "$enable_zotero" = "y" ] || [ "$enable_zotero" = "Y" ]; then
    local tmp_config
    tmp_config="$(mktemp)"
    awk '
      {
        line = $0
        clean = line
        sub(/\r$/, "", clean)
        if (clean ~ /^\[/) {
          in_zotero = (clean == "[mcp_servers.zotero]")
        }
        if (in_zotero && clean ~ /^enabled[[:space:]]*=[[:space:]]*false[[:space:]]*$/) {
          sub(/false/, "true", line)
          changed = 1
        }
        print line
      }
      END {
        if (!changed) {
          exit 1
        }
      }
    ' "$KIMI_HOME/config.toml" > "$tmp_config" || {
      rm -f "$tmp_config"
      error "Failed to enable Zotero MCP"
    }
    mv "$tmp_config" "$KIMI_HOME/config.toml" || error "Failed to replace config.toml after enabling Zotero MCP"
    info "Zotero MCP enabled"
    if ! command -v zotero-mcp >/dev/null 2>&1; then
      warn "zotero-mcp not found. Install latest with: uv tool install --reinstall git+https://github.com/Galaxy-Dawn/zotero-mcp.git"
    fi
  fi
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
  run_step "detect_legacy_install" detect_legacy_install

  info "Source: $SRC_DIR"
  info "Target: $KIMI_HOME"
  mkdir -p "$KIMI_HOME" || error "Failed to create KIMI_HOME at $KIMI_HOME"

  run_step "detect_existing" detect_existing
  run_step "choose_provider" choose_provider
  run_step "configure_api_key" configure_api_key
  run_step "generate_config" generate_config
  run_step "write_auth" write_auth
  run_step "copy_components" copy_components
  run_step "configure_mcp" configure_mcp
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
  echo "  Config:  $KIMI_HOME/config.toml"
  echo "  Auth:    $KIMI_HOME/auth.json"
  echo "  Skills:  $KIMI_HOME/skills/"
  echo "  Templates: $KIMI_HOME/templates/"
  echo "  Agents:  $KIMI_HOME/agents/"
  echo ""
  info "Existing model/provider/API key settings are preserved when you choose the incremental update path."
  echo "  Run $(bold 'kimi') to start."
  echo "============================================================"
}

main "$@"
