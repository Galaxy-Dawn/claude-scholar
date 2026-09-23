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
  test -f "$home/.codex/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md"
  for agent in paper-miner literature-reviewer kaggle-miner code-reviewer rebuttal-writer tdd-guide; do
    test -f "$home/.codex/agents/$agent.toml"
    test ! -f "$home/.codex/agents/$agent/config.toml"
  done
  grep -Fxq "skills/research-ideation/references/research-contract.md" "$home/.codex/.codex-scholar-manifest.txt"
  grep -Fxq "skills/post-acceptance/references/xquik-promotion.md" "$home/.codex/.codex-scholar-manifest.txt"

  run_uninstall "$home"
  test ! -f "$home/.codex/.codex-scholar-manifest.txt"
  test ! -f "$home/.codex/.codex-scholar-install-state"
  test -f "$home/.codex/config.toml"
  test -f "$home/.codex/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md"
  ! grep -q '\[agents\.' "$home/.codex/config.toml"
  ! grep -q '\[mcp_servers\.zotero' "$home/.codex/config.toml"
  pass "roundtrip with existing config"
}

test_writing_memory_survives_update_and_legacy_uninstall() {
  local home memory
  home="$(make_home)"
  write_base_config "$home"
  run_setup "$home"
  memory="$home/.codex/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md"
  printf '\n### Kept example\n**Source:** Test paper\n' >> "$memory"

  run_setup "$home"
  grep -Fq '### Kept example' "$memory"
  ! grep -Fxq 'skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md' "$home/.codex/.codex-scholar-manifest.txt"

  # Older manifests may still claim ownership of the file.
  printf '%s\n' 'skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md' >> "$home/.codex/.codex-scholar-manifest.txt"
  run_uninstall "$home"
  grep -Fq '### Kept example' "$memory"
  pass "mined writing memory survives update and legacy uninstall"
}

test_agent_discovery_files() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  run_setup "$home"
  python3 - "$home/.codex/agents" <<'PY'
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
expected = {"paper-miner", "literature-reviewer", "kaggle-miner", "code-reviewer", "rebuttal-writer", "tdd-guide"}
for name in expected:
    data = tomllib.loads((root / f"{name}.toml").read_text())
    assert data["name"] == name
    assert data["description"].strip()
    assert data["developer_instructions"].strip()
    assert (root / name / "AGENTS.md").is_file()
PY
  pass "standalone Codex agent files have required discovery fields"
}

test_fresh_openai_config_uses_builtin_provider() {
  local home
  home="$(make_home)"
  printf '1\n\n\n\n' | CODEX_HOME="$home/.codex" bash "$SETUP_SH" >/dev/null
  grep -Fxq 'model_provider = "openai"' "$home/.codex/config.toml"
  ! grep -Fq '[model_providers.openai]' "$home/.codex/config.toml"
  if command -v codex >/dev/null 2>&1; then
    CODEX_HOME="$home/.codex" codex debug prompt-input 'Use paper-miner' >/dev/null
  fi
  pass "fresh OpenAI config uses Codex built-in provider"
}

test_legacy_agent_config_migrates_without_duplicates() {
  local home
  home="$(make_home)"
  write_base_config "$home"
  run_setup "$home"
  mkdir -p "$home/.codex/agents/paper-miner"
  cp "$REPO_ROOT/agents/paper-miner/config.toml" "$home/.codex/agents/paper-miner/config.toml"
  printf '%s\n' 'agents/paper-miner/config.toml' >> "$home/.codex/.codex-scholar-manifest.txt"
  cat >> "$home/.codex/config.toml" <<'TOML'

[agents.paper-miner]
description = "Extract writing knowledge from successful papers"
config_file = "~/.codex/agents/paper-miner/config.toml"
TOML

  run_setup "$home"
  test ! -f "$home/.codex/agents/paper-miner/config.toml"
  ! grep -Fq '[agents.paper-miner]' "$home/.codex/config.toml"
  test -f "$home/.codex/agents/paper-miner.toml"
  if command -v codex >/dev/null 2>&1; then
    CODEX_HOME="$home/.codex" codex debug prompt-input 'Use paper-miner' >/dev/null
  fi
  pass "legacy agent registration migrates without duplicate role"
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
  test_writing_memory_survives_update_and_legacy_uninstall
  test_agent_discovery_files
  test_fresh_openai_config_uses_builtin_provider
  test_legacy_agent_config_migrates_without_duplicates
  test_preserve_existing_mcp_section
  test_manifest_missing_fails_safe
  test_identical_preexisting_file_is_not_owned
  test_reinstall_keeps_owned_files_owned
  test_legacy_install_upgrade_adopts_existing_files
}

main "$@"
