#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SETUP_SH="$REPO_ROOT/scripts/setup.sh"
UNINSTALL_SH="$REPO_ROOT/scripts/uninstall.sh"

pass() {
  echo "[PASS] $1"
}

make_home() {
  mktemp -d /tmp/kimi-scholar-test.XXXXXX
}

write_base_config() {
  local home="$1"
  mkdir -p "$home/.kimi"
  cat > "$home/.kimi/config.toml" <<'TOML'
model = "gpt-5.4"
model_provider = "openai"

[model_providers.openai]
name = "openai"
base_url = "https://api.openai.com/v1"
wire_api = "responses"
requires_openai_auth = true
TOML
}

run_setup() {
  KIMI_HOME="$1/.kimi" bash "$SETUP_SH" --yes >/dev/null
}

run_uninstall() {
  KIMI_HOME="$1/.kimi" bash "$UNINSTALL_SH" --yes >/dev/null
}

test_roundtrip_existing_config() {
  local home
  home="$(make_home)"
  write_base_config "$home"

  run_setup "$home"
  test -f "$home/.kimi/.kimi-scholar-manifest.txt"
  test -f "$home/.kimi/.kimi-scholar-install-state"
  test -f "$home/.kimi/AGENTS.md"
  test -f "$home/.kimi/skills/research-ideation/references/research-contract.md"
  grep -Fxq "skills/research-ideation/references/research-contract.md" "$home/.kimi/.kimi-scholar-manifest.txt"

  run_uninstall "$home"
  test ! -f "$home/.kimi/.kimi-scholar-manifest.txt"
  test ! -f "$home/.kimi/.kimi-scholar-install-state"
  test -f "$home/.kimi/config.toml"
  ! grep -q '\[agents\.' "$home/.kimi/config.toml"
  ! grep -q '\[mcp_servers\.zotero' "$home/.kimi/config.toml"
  pass "roundtrip with existing config"
}

test_preserve_existing_mcp_section() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  cat >> "$home/.kimi/config.toml" <<'TOML'

[mcp_servers.zotero]
command = "custom-zotero"
enabled = true
TOML

  run_setup "$home"
  run_uninstall "$home"

  grep -q '\[mcp_servers\.zotero\]' "$home/.kimi/config.toml"
  grep -q 'command = "custom-zotero"' "$home/.kimi/config.toml"
  ! grep -q '\[mcp_servers\.zotero\.env\]' "$home/.kimi/config.toml"
  pass "preserve existing mcp server while removing injected env section"
}

test_manifest_missing_skips_safely() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  run_setup "$home"

  rm -f "$home/.kimi/.kimi-scholar-manifest.txt"
  KIMI_HOME="$home/.kimi" bash "$UNINSTALL_SH" --yes >/tmp/kimi-scholar-uninstall-missing-manifest.log 2>&1

  test -f "$home/.kimi/AGENTS.md"
  test -f "$home/.kimi/.kimi-scholar-install-state"
  grep -q "Scholar-managed files cannot be identified" /tmp/kimi-scholar-uninstall-missing-manifest.log
  pass "manifest missing skips safely"
}

test_identical_preexisting_file_is_not_owned() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  mkdir -p "$home/.kimi/scripts"
  cp "$REPO_ROOT/scripts/setup-package-manager.js" "$home/.kimi/scripts/setup-package-manager.js"

  run_setup "$home"
  run_uninstall "$home"

  test -f "$home/.kimi/scripts/setup-package-manager.js"
  pass "identical pre-existing file is not treated as owned"
}

test_reinstall_keeps_owned_files_owned() {
  local home
  home="$(make_home)"
  write_base_config "$home"

  run_setup "$home"
  run_setup "$home"
  run_uninstall "$home"

  test ! -f "$home/.kimi/AGENTS.md"
  pass "reinstall preserves ownership of installed files"
}

test_existing_agents_file_is_preserved_as_user_owned() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  mkdir -p "$home/.kimi/scripts"
  cp "$REPO_ROOT/AGENTS.md" "$home/.kimi/AGENTS.md"
  cp "$REPO_ROOT/scripts/setup-package-manager.js" "$home/.kimi/scripts/setup-package-manager.js"
  cat >> "$home/.kimi/config.toml" <<'TOML'

[agents.code-reviewer]
description = "Expert code review"
config_file = "~/.kimi/agents/code-reviewer/config.toml"
TOML

  run_setup "$home"
  test -f "$home/.kimi/AGENTS.scholar.md"
  run_uninstall "$home"

  test -f "$home/.kimi/AGENTS.md"
  test ! -f "$home/.kimi/AGENTS.scholar.md"
  test -f "$home/.kimi/scripts/setup-package-manager.js"
  pass "existing AGENTS.md is preserved as user-owned"
}

test_user_hook_is_not_duplicated() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  cat >> "$home/.kimi/config.toml" <<'TOML'

[[hooks]]
event = "CustomEvent"
command = "bash ~/.local/bin/custom-hook.sh"
timeout = 3
TOML

  run_setup "$home"

  local count
  count="$(grep -c 'command = "bash ~/.local/bin/custom-hook.sh"' "$home/.kimi/config.toml")"
  test "$count" -eq 1
  pass "user hook is not duplicated during install"
}

test_user_hooks_path_is_not_removed() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  cat >> "$home/.kimi/config.toml" <<'TOML'

[[hooks]]
event = "PreToolUse"
command = "bash ~/.local/hooks/my-pretool-hook.sh"
timeout = 3
TOML

  run_setup "$home"
  run_uninstall "$home"

  grep -q 'command = "bash ~/.local/hooks/my-pretool-hook.sh"' "$home/.kimi/config.toml"
  ! grep -q 'command = "bash ~/.kimi-code/hooks/security-guard.sh"' "$home/.kimi/config.toml"
  pass "user /hooks/ path is not removed during uninstall"
}

test_non_tty_cancel_keeps_existing_scholar_hook() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  cat >> "$home/.kimi/config.toml" <<'TOML'

[[hooks]]
event = "PreToolUse"
matcher = "Shell|WriteFile|StrReplaceFile"
command = "bash ~/.kimi-code/hooks/security-guard.sh"
timeout = 5
TOML

  printf 'n\n' | KIMI_HOME="$home/.kimi" bash "$SETUP_SH" >/dev/null

  grep -q 'command = "bash ~/.kimi-code/hooks/security-guard.sh"' "$home/.kimi/config.toml"
  ! grep -q 'command = "bash ~/.kimi-code/hooks/session-start.sh"' "$home/.kimi/config.toml"
  pass "non-tty cancel keeps existing Scholar hook"
}

test_yes_adds_new_without_removing_existing_scholar_hook() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  cat >> "$home/.kimi/config.toml" <<'TOML'

[[hooks]]
event = "PreToolUse"
matcher = "Shell|WriteFile|StrReplaceFile"
command = "bash ~/.kimi-code/hooks/security-guard.sh"
timeout = 5
TOML

  KIMI_HOME="$home/.kimi" bash "$SETUP_SH" --yes >/dev/null

  grep -q 'command = "bash ~/.kimi-code/hooks/security-guard.sh"' "$home/.kimi/config.toml"
  grep -q 'command = "bash ~/.kimi-code/hooks/session-start.sh"' "$home/.kimi/config.toml"
  pass "yes adds new hooks without removing existing Scholar hook"
}

test_existing_mcp_json_is_preserved_on_uninstall() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  cat > "$home/.kimi/mcp.json" <<'JSON'
{
  "mcpServers": {
    "custom": {
      "command": "custom-mcp",
      "args": ["--keep"]
    }
  }
}
JSON

  run_setup "$home"
  grep -q 'custom-mcp' "$home/.kimi/mcp.json"
  grep -q 'zotero-mcp' "$home/.kimi/mcp.json"
  ! grep -Fxq 'mcp.json' "$home/.kimi/.kimi-scholar-manifest.txt"

  run_uninstall "$home"

  test -f "$home/.kimi/mcp.json"
  grep -q 'custom-mcp' "$home/.kimi/mcp.json"
  ! grep -q 'zotero-mcp' "$home/.kimi/mcp.json"
  pass "existing mcp.json is preserved on uninstall"
}

test_existing_zotero_mcp_server_is_restored_on_uninstall() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  cat > "$home/.kimi/mcp.json" <<'JSON'
{
  "mcpServers": {
    "zotero": {
      "command": "custom-zotero",
      "args": ["--user-owned"]
    },
    "custom": {
      "command": "custom-mcp",
      "args": ["--keep"]
    }
  }
}
JSON

  run_setup "$home"
  run_setup "$home"
  ! grep -q 'custom-zotero' "$home/.kimi/mcp.json"
  grep -q 'zotero-mcp' "$home/.kimi/mcp.json"
  grep -q '"action": "replaced"' "$home/.kimi/.kimi-scholar-install-state"
  grep -q '"afterSha256"' "$home/.kimi/.kimi-scholar-install-state"
  ! grep -q '"after":' "$home/.kimi/.kimi-scholar-install-state"

  run_uninstall "$home"

  test -f "$home/.kimi/mcp.json"
  grep -q 'custom-zotero' "$home/.kimi/mcp.json"
  grep -q 'custom-mcp' "$home/.kimi/mcp.json"
  ! grep -q 'zotero-mcp' "$home/.kimi/mcp.json"
  pass "existing zotero MCP server is restored on uninstall"
}

test_fresh_mcp_json_keeps_user_added_server_on_uninstall() {
  local home
  home="$(make_home)"
  write_base_config "$home"

  run_setup "$home"
  python3 - "$home/.kimi/mcp.json" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data.setdefault("mcpServers", {})["custom"] = {
    "command": "custom-mcp",
    "args": ["--keep"],
}
path.write_text(json.dumps(data, indent=2) + "\n")
PY

  run_uninstall "$home"

  test -f "$home/.kimi/mcp.json"
  grep -q 'custom-mcp' "$home/.kimi/mcp.json"
  ! grep -q 'zotero-mcp' "$home/.kimi/mcp.json"
  pass "fresh mcp.json keeps user-added server on uninstall"
}

test_fresh_mcp_json_is_removed_when_empty_on_uninstall() {
  local home
  home="$(make_home)"
  write_base_config "$home"

  run_setup "$home"
  test -f "$home/.kimi/mcp.json"

  run_uninstall "$home"

  test ! -f "$home/.kimi/mcp.json"
  pass "fresh mcp.json is removed when no user entries remain"
}

test_mcp_state_does_not_store_configured_secrets() {
  local home
  home="$(make_home)"
  write_base_config "$home"

  run_setup "$home"
  python3 - "$home/.kimi/mcp.json" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
env = data["mcpServers"]["zotero"].setdefault("env", {})
env["ZOTERO_API_KEY"] = "secret-api-key"
path.write_text(json.dumps(data, indent=2) + "\n")
PY
  KIMI_HOME="$home/.kimi" bash "$SETUP_SH" --yes >/dev/null

  ! grep -q 'secret-api-key' "$home/.kimi/.kimi-scholar-install-state"
  grep -q '"afterSha256"' "$home/.kimi/.kimi-scholar-install-state"
  pass "mcp install state does not store configured secrets"
}

test_invalid_existing_mcp_json_fails_safely() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-invalid-mcp.log"
  write_base_config "$home"
  printf '{ invalid json\n' > "$home/.kimi/mcp.json"

  if KIMI_HOME="$home/.kimi" bash "$SETUP_SH" --yes >"$log" 2>&1; then
    echo "[FAIL] invalid existing mcp.json should fail setup"
    cat "$log"
    exit 1
  fi

  grep -q "Failed to parse existing mcp.json" "$log"
  test ! -f "$home/.kimi/.kimi-scholar-manifest.txt"
  grep -q '{ invalid json' "$home/.kimi/mcp.json"
  pass "invalid existing mcp.json fails safely"
}

test_invalid_existing_mcp_schema_fails_before_install() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-invalid-mcp-schema.log"
  write_base_config "$home"
  cat > "$home/.kimi/mcp.json" <<'JSON'
{
  "mcpServers": []
}
JSON

  if KIMI_HOME="$home/.kimi" bash "$SETUP_SH" --yes >"$log" 2>&1; then
    echo "[FAIL] invalid existing mcp.json schema should fail setup"
    cat "$log"
    exit 1
  fi

  grep -q "Invalid existing mcp.json schema" "$log"
  ! grep -q 'bash ~/.kimi-code/hooks' "$home/.kimi/config.toml"
  test ! -f "$home/.kimi/.kimi-scholar-manifest.txt"
  test ! -f "$home/.kimi/.kimi-scholar-install-state"
  pass "invalid existing mcp.json schema fails before install"
}

test_invalid_existing_config_fails_before_install() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-invalid-config.log"
  mkdir -p "$home/.kimi"
  printf 'invalid toml = [\n' > "$home/.kimi/config.toml"

  if KIMI_HOME="$home/.kimi" bash "$SETUP_SH" --yes >"$log" 2>&1; then
    echo "[FAIL] invalid existing config.toml should fail setup"
    cat "$log"
    exit 1
  fi

  grep -q "Invalid existing config.toml" "$log"
  test ! -f "$home/.kimi/.kimi-scholar-manifest.txt"
  test ! -f "$home/.kimi/.kimi-scholar-install-state"
  test ! -f "$home/.kimi/mcp.json"
  test ! -f "$home/.kimi/AGENTS.md"
  grep -q 'invalid toml' "$home/.kimi/config.toml"
  pass "invalid existing config.toml fails before install"
}

test_install_state_write_failure_fails_install() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-state-write-failure.log"
  write_base_config "$home"
  mkdir -p "$home/.kimi/.kimi-scholar-install-state"

  if KIMI_HOME="$home/.kimi" bash "$SETUP_SH" --yes >"$log" 2>&1; then
    echo "[FAIL] install state write failure should fail setup"
    cat "$log"
    exit 1
  fi

  test ! -f "$home/.kimi/.kimi-scholar-manifest.txt"
  test -d "$home/.kimi/.kimi-scholar-install-state"
  grep -q "Install metadata path is not a regular file" "$log"
  pass "install state write failure fails install"
}

test_invalid_existing_install_state_blocks_setup() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-invalid-state-setup.log"
  write_base_config "$home"
  cat > "$home/.kimi/mcp.json" <<'JSON'
{
  "mcpServers": {
    "zotero": {
      "command": "custom-zotero",
      "args": ["--user-owned"]
    },
    "custom": {
      "command": "custom-mcp",
      "args": ["--keep"]
    }
  }
}
JSON

  run_setup "$home"
  printf '{ invalid state\n' > "$home/.kimi/.kimi-scholar-install-state"

  if KIMI_HOME="$home/.kimi" bash "$SETUP_SH" --yes >"$log" 2>&1; then
    echo "[FAIL] invalid existing install state should block setup"
    cat "$log"
    exit 1
  fi

  grep -q "Failed to parse existing install state" "$log"
  grep -q '{ invalid state' "$home/.kimi/.kimi-scholar-install-state"
  grep -q 'zotero-mcp' "$home/.kimi/mcp.json"
  grep -q 'custom-mcp' "$home/.kimi/mcp.json"
  pass "invalid existing install state blocks setup"
}

test_invalid_install_state_mcp_schema_blocks_setup() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-invalid-state-mcp-schema-setup.log"
  write_base_config "$home"
  run_setup "$home"
  python3 - "$home/.kimi/.kimi-scholar-install-state" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["mcpServers"] = "bad-type"
path.write_text(json.dumps(data, indent=2) + "\n")
PY

  if KIMI_HOME="$home/.kimi" bash "$SETUP_SH" --yes >"$log" 2>&1; then
    echo "[FAIL] invalid install state mcpServers schema should block setup"
    cat "$log"
    exit 1
  fi

  grep -q "mcpServers must be a JSON object" "$log"
  grep -q '"mcpServers": "bad-type"' "$home/.kimi/.kimi-scholar-install-state"
  pass "invalid install state mcpServers schema blocks setup"
}

test_invalid_install_state_mcp_entry_blocks_uninstall() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-invalid-state-mcp-entry-uninstall.log"
  write_base_config "$home"
  run_setup "$home"
  python3 - "$home/.kimi/.kimi-scholar-install-state" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["mcpServers"] = {"zotero": "bad-entry"}
path.write_text(json.dumps(data, indent=2) + "\n")
PY

  if KIMI_HOME="$home/.kimi" bash "$UNINSTALL_SH" --yes >"$log" 2>&1; then
    echo "[FAIL] invalid install state mcp entry should block uninstall"
    cat "$log"
    exit 1
  fi

  grep -q "mcpServers.zotero must be a JSON object" "$log"
  test -f "$home/.kimi/.kimi-scholar-manifest.txt"
  test -f "$home/.kimi/.kimi-scholar-install-state"
  test -f "$home/.kimi/mcp.json"
  grep -q 'zotero-mcp' "$home/.kimi/mcp.json"
  pass "invalid install state mcp entry blocks uninstall"
}

test_invalid_install_state_blocks_uninstall_before_removal() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-invalid-state-uninstall.log"
  mkdir -p "$home/.kimi"
  cat > "$home/.kimi/.kimi-scholar-manifest.txt" <<'EOF'
AGENTS.md
EOF
  printf '{ invalid state\n' > "$home/.kimi/.kimi-scholar-install-state"
  touch "$home/.kimi/AGENTS.md"

  if KIMI_HOME="$home/.kimi" bash "$UNINSTALL_SH" --yes >"$log" 2>&1; then
    echo "[FAIL] invalid install state should block uninstall"
    cat "$log"
    exit 1
  fi

  test -f "$home/.kimi/AGENTS.md"
  test -f "$home/.kimi/.kimi-scholar-manifest.txt"
  grep -q "Invalid install state" "$log"
  pass "invalid install state blocks uninstall before removal"
}

test_non_tty_setup_requires_yes() {
  local home log
  home="$(make_home)"
  log="/tmp/kimi-scholar-non-tty-setup.log"
  write_base_config "$home"

  printf 'n\n' | KIMI_HOME="$home/.kimi" bash "$SETUP_SH" >"$log" 2>&1

  grep -q "Installation cancelled" "$log"
  ! grep -q 'bash ~/.kimi-code/hooks' "$home/.kimi/config.toml"
  test ! -f "$home/.kimi/.kimi-scholar-manifest.txt"
  pass "non-tty setup requires explicit yes"
}

test_setup_dry_run_does_not_create_target_dir() {
  local home target log
  home="$(make_home)"
  target="$home/new-kimi"
  log="/tmp/kimi-scholar-setup-dry-run.log"

  KIMI_HOME="$target" bash "$SETUP_SH" --dry-run --yes >"$log" 2>&1

  grep -q "Dry run complete" "$log"
  test ! -e "$target"
  pass "setup dry-run does not create target directory"
}

test_uninstall_dry_run_does_not_create_backup_dir() {
  local home backup_dir log
  home="$(make_home)"
  log="/tmp/kimi-scholar-uninstall-dry-run.log"
  write_base_config "$home"
  run_setup "$home"

  KIMI_HOME="$home/.kimi" bash "$UNINSTALL_SH" --dry-run --yes >"$log" 2>&1

  grep -q "Dry run complete" "$log"
  backup_dir="$(sed -n 's/^  Backup directory: //p' "$log" | tail -n 1)"
  test -n "$backup_dir"
  test ! -e "$backup_dir"
  test -f "$home/.kimi/.kimi-scholar-manifest.txt"
  pass "uninstall dry-run does not create backup directory"
}

main() {
  bash -n "$SETUP_SH"
  bash -n "$UNINSTALL_SH"
  test_roundtrip_existing_config
  test_preserve_existing_mcp_section
  test_manifest_missing_skips_safely
  test_identical_preexisting_file_is_not_owned
  test_reinstall_keeps_owned_files_owned
  test_existing_agents_file_is_preserved_as_user_owned
  test_user_hook_is_not_duplicated
  test_user_hooks_path_is_not_removed
  test_non_tty_cancel_keeps_existing_scholar_hook
  test_yes_adds_new_without_removing_existing_scholar_hook
  test_existing_mcp_json_is_preserved_on_uninstall
  test_existing_zotero_mcp_server_is_restored_on_uninstall
  test_fresh_mcp_json_keeps_user_added_server_on_uninstall
  test_fresh_mcp_json_is_removed_when_empty_on_uninstall
  test_mcp_state_does_not_store_configured_secrets
  test_invalid_existing_mcp_json_fails_safely
  test_invalid_existing_mcp_schema_fails_before_install
  test_invalid_existing_config_fails_before_install
  test_install_state_write_failure_fails_install
  test_invalid_existing_install_state_blocks_setup
  test_invalid_install_state_mcp_schema_blocks_setup
  test_invalid_install_state_mcp_entry_blocks_uninstall
  test_invalid_install_state_blocks_uninstall_before_removal
  test_non_tty_setup_requires_yes
  test_setup_dry_run_does_not_create_target_dir
  test_uninstall_dry_run_does_not_create_backup_dir
}

main "$@"
