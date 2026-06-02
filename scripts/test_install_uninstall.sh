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
  printf 'n\n' | KIMI_HOME="$1/.kimi" bash "$SETUP_SH" >/dev/null
}

run_uninstall() {
  KIMI_HOME="$1/.kimi" bash "$UNINSTALL_SH" >/dev/null
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

test_manifest_missing_fails_safe() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  run_setup "$home"

  rm -f "$home/.kimi/.kimi-scholar-manifest.txt"
  if KIMI_HOME="$home/.kimi" bash "$UNINSTALL_SH" >/tmp/kimi-scholar-uninstall-fail.log 2>&1; then
    echo "[FAIL] manifest missing should fail"
    cat /tmp/kimi-scholar-uninstall-fail.log
    exit 1
  fi

  test -f "$home/.kimi/AGENTS.md"
  test -f "$home/.kimi/.kimi-scholar-install-state"
  pass "manifest missing fails safely"
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

test_legacy_install_upgrade_adopts_existing_files() {
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
  run_uninstall "$home"

  test ! -f "$home/.kimi/AGENTS.md"
  test ! -f "$home/.kimi/scripts/setup-package-manager.js"
  pass "legacy install upgrade adopts existing managed files"
}

main() {
  bash -n "$SETUP_SH"
  bash -n "$UNINSTALL_SH"
  test_roundtrip_existing_config
  test_preserve_existing_mcp_section
  test_manifest_missing_fails_safe
  test_identical_preexisting_file_is_not_owned
  test_reinstall_keeps_owned_files_owned
  test_legacy_install_upgrade_adopts_existing_files
}

main "$@"
