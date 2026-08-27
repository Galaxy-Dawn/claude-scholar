#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SETUP_SH="$REPO_ROOT/scripts/setup.sh"
UNINSTALL_SH="$REPO_ROOT/scripts/uninstall.sh"

pass() {
  echo "[PASS] $1"
}

make_home() {
  mktemp -d /tmp/codex-scholar-test.XXXXXX
}

write_base_config() {
  local home="$1"
  mkdir -p "$home/.codex"
  cat > "$home/.codex/config.toml" <<'TOML'
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
  printf 'n\n' | CODEX_HOME="$1/.codex" bash "$SETUP_SH" >/dev/null
}

run_uninstall() {
  CODEX_HOME="$1/.codex" bash "$UNINSTALL_SH" >/dev/null
}

test_roundtrip_existing_config() {
  local home
  home="$(make_home)"
  write_base_config "$home"

  run_setup "$home"
  test -f "$home/.codex/.codex-scholar-manifest.txt"
  test -f "$home/.codex/.codex-scholar-install-state"
  test -f "$home/.codex/AGENTS.md"
  test -f "$home/.codex/skills/research-ideation/references/research-contract.md"
  test -f "$home/.codex/skills/post-acceptance/references/xquik-promotion.md"
  grep -Fxq "skills/research-ideation/references/research-contract.md" "$home/.codex/.codex-scholar-manifest.txt"
  grep -Fxq "skills/post-acceptance/references/xquik-promotion.md" "$home/.codex/.codex-scholar-manifest.txt"

  run_uninstall "$home"
  test ! -f "$home/.codex/.codex-scholar-manifest.txt"
  test ! -f "$home/.codex/.codex-scholar-install-state"
  test -f "$home/.codex/config.toml"
  ! grep -q '\[agents\.' "$home/.codex/config.toml"
  ! grep -q '\[mcp_servers\.zotero' "$home/.codex/config.toml"
  pass "roundtrip with existing config"
}

test_preserve_existing_mcp_section() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  cat >> "$home/.codex/config.toml" <<'TOML'

[mcp_servers.zotero]
command = "custom-zotero"
enabled = true
TOML

  run_setup "$home"
  run_uninstall "$home"

  grep -q '\[mcp_servers\.zotero\]' "$home/.codex/config.toml"
  grep -q 'command = "custom-zotero"' "$home/.codex/config.toml"
  ! grep -q '\[mcp_servers\.zotero\.env\]' "$home/.codex/config.toml"
  pass "preserve existing mcp server while removing injected env section"
}

test_manifest_missing_fails_safe() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  run_setup "$home"

  rm -f "$home/.codex/.codex-scholar-manifest.txt"
  if CODEX_HOME="$home/.codex" bash "$UNINSTALL_SH" >/tmp/codex-scholar-uninstall-fail.log 2>&1; then
    echo "[FAIL] manifest missing should fail"
    cat /tmp/codex-scholar-uninstall-fail.log
    exit 1
  fi

  test -f "$home/.codex/AGENTS.md"
  test -f "$home/.codex/.codex-scholar-install-state"
  pass "manifest missing fails safely"
}

test_identical_preexisting_file_is_not_owned() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  mkdir -p "$home/.codex/scripts"
  cp "$REPO_ROOT/scripts/setup-package-manager.js" "$home/.codex/scripts/setup-package-manager.js"

  run_setup "$home"
  run_uninstall "$home"

  test -f "$home/.codex/scripts/setup-package-manager.js"
  pass "identical pre-existing file is not treated as owned"
}

test_reinstall_keeps_owned_files_owned() {
  local home
  home="$(make_home)"
  write_base_config "$home"

  run_setup "$home"
  run_setup "$home"
  run_uninstall "$home"

  test ! -f "$home/.codex/AGENTS.md"
  pass "reinstall preserves ownership of installed files"
}

test_legacy_install_upgrade_adopts_existing_files() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  mkdir -p "$home/.codex/scripts"
  cp "$REPO_ROOT/AGENTS.md" "$home/.codex/AGENTS.md"
  cp "$REPO_ROOT/scripts/setup-package-manager.js" "$home/.codex/scripts/setup-package-manager.js"
  cat >> "$home/.codex/config.toml" <<'TOML'

[agents.code-reviewer]
description = "Expert code review"
config_file = "~/.codex/agents/code-reviewer/config.toml"
TOML

  run_setup "$home"
  run_uninstall "$home"

  test ! -f "$home/.codex/AGENTS.md"
  test ! -f "$home/.codex/scripts/setup-package-manager.js"
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
