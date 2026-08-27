#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SETUP="$REPO_DIR/scripts/setup.sh"
UNINSTALL="$REPO_DIR/scripts/uninstall.sh"
TEST_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() { echo "[FAIL] $*" >&2; exit 1; }
pass() { echo "[PASS] $*"; }

run_setup() {
  local home="$1"
  OPENCODE_DIR="$home" bash "$SETUP" >/dev/null
}

run_uninstall() {
  local home="$1"
  OPENCODE_DIR="$home" bash "$UNINSTALL" >/dev/null
}

json_query() {
  node -e "const fs=require('fs'); const data=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); console.log(JSON.stringify(($2), null, 0));" "$1"
}

assert_file_exists() { [ -e "$1" ] || fail "Expected file to exist: $1"; }
assert_file_missing() { [ ! -e "$1" ] || fail "Expected file to be missing: $1"; }
assert_contains() { grep -q "$2" "$1" || fail "Expected $1 to contain $2"; }
assert_not_contains() { ! grep -q "$2" "$1" || fail "Expected $1 not to contain $2"; }

test_created_config_roundtrip() {
  local home="$TEST_ROOT/created-config"
  mkdir -p "$home"

  run_setup "$home"
  assert_file_exists "$home/opencode.jsonc"
  assert_file_exists "$home/.opencode-scholar-manifest.txt"
  assert_file_exists "$home/.opencode-scholar-install-state"
  assert_file_exists "$home/skills/research-ideation/references/research-contract.md"
  assert_file_exists "$home/skills/post-acceptance/references/xquik-promotion.md"
  assert_file_exists "$home/commands/promote.md"
  assert_not_contains "$home/commands/promote.md" "generate-promotion.py"
  grep -Fxq "skills/research-ideation/references/research-contract.md" "$home/.opencode-scholar-manifest.txt" || fail "research contract missing from manifest"
  grep -Fxq "skills/post-acceptance/references/xquik-promotion.md" "$home/.opencode-scholar-manifest.txt" || fail "Xquik promotion reference missing from manifest"
  grep -Fxq "commands/promote.md" "$home/.opencode-scholar-manifest.txt" || fail "promote command missing from manifest"

  run_uninstall "$home"
  assert_file_missing "$home/opencode.jsonc"
  assert_file_missing "$home/.opencode-scholar-manifest.txt"
  assert_file_missing "$home/.opencode-scholar-install-state"
  pass "created opencode.jsonc is removed when unchanged"
}

test_existing_config_preserves_user_entries() {
  local home="$TEST_ROOT/existing-config"
  mkdir -p "$home"
  cat > "$home/opencode.jsonc" <<'JSON'
{
  "$schema": "https://opencode.ai/schema.json",
  "agent": {
    "custom-agent": { "description": "mine", "tools": { "read": true }, "prompt": "keep" }
  },
  "mcp": {
    "zotero": { "enabled": false }
  },
  "permission": {
    "read": "allow"
  },
  "plugin": ["file:///user/plugin.ts"]
}
JSON

  run_setup "$home"
  node - "$home/opencode.jsonc" <<'NODE'
const fs = require('fs');
const data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
if (!data.agent['code-reviewer']) throw new Error('missing injected agent');
if (!data.agent['custom-agent']) throw new Error('lost custom agent');
if (data.mcp.zotero.enabled !== false) throw new Error('overwrote existing zotero.enabled');
if (!data.mcp.zotero.command) throw new Error('missing nested zotero.command');
if (!data.plugin.includes('file:///user/plugin.ts')) throw new Error('lost user plugin');
NODE

  run_uninstall "$home"
  node - "$home/opencode.jsonc" <<'NODE'
const fs = require('fs');
const data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
if (data.agent && data.agent['code-reviewer']) throw new Error('injected agent remained');
if (!data.agent['custom-agent']) throw new Error('lost custom agent');
if (data.mcp.zotero.enabled !== false) throw new Error('lost user zotero.enabled');
if ('command' in data.mcp.zotero) throw new Error('injected zotero.command remained');
if (!data.plugin.includes('file:///user/plugin.ts')) throw new Error('lost user plugin');
NODE
  pass "existing opencode.jsonc keeps user entries and removes only recorded additions"
}

test_manifest_missing_fails_safely() {
  local home="$TEST_ROOT/no-manifest"
  mkdir -p "$home"
  cat > "$home/opencode.jsonc" <<'JSON'
{ "plugin": ["file:///user/plugin.ts"] }
JSON
  if OPENCODE_DIR="$home" bash "$UNINSTALL" >/dev/null 2>&1; then
    fail "uninstall should fail without manifest/state"
  fi
  assert_contains "$home/opencode.jsonc" "user/plugin"
  pass "uninstall refuses to guess ownership without manifest/state"
}

test_identical_preexisting_file_not_owned() {
  local home="$TEST_ROOT/preexisting-identical"
  mkdir -p "$home/skills/daily-coding"
  cp "$REPO_DIR/skills/daily-coding/SKILL.md" "$home/skills/daily-coding/SKILL.md"

  run_setup "$home"
  assert_file_exists "$home/skills/daily-coding/SKILL.md"
  if grep -Fxq "skills/daily-coding/SKILL.md" "$home/.opencode-scholar-manifest.txt"; then
    fail "identical pre-existing file was incorrectly owned"
  fi

  run_uninstall "$home"
  assert_file_exists "$home/skills/daily-coding/SKILL.md"
  pass "identical pre-existing files are not removed unless previously owned"
}

test_reinstall_preserves_ownership() {
  local home="$TEST_ROOT/reinstall"
  mkdir -p "$home"

  run_setup "$home"
  run_setup "$home"
  assert_file_exists "$home/skills/results-analysis/SKILL.md"
  grep -Fxq "skills/results-analysis/SKILL.md" "$home/.opencode-scholar-manifest.txt" || fail "managed file missing from manifest after reinstall"

  run_uninstall "$home"
  assert_file_missing "$home/skills/results-analysis/SKILL.md"
  pass "reinstall preserves ownership for unchanged managed files"
}

test_legacy_install_adopts_existing_files() {
  local home="$TEST_ROOT/legacy"
  mkdir -p "$home/skills/daily-coding"
  cp "$REPO_DIR/skills/daily-coding/SKILL.md" "$home/skills/daily-coding/SKILL.md"
  cat > "$home/opencode.jsonc" <<JSON
{ "plugin": ["file://$home/plugins/session-summary.ts"] }
JSON

  run_setup "$home"
  grep -Fxq "skills/daily-coding/SKILL.md" "$home/.opencode-scholar-manifest.txt" || fail "legacy identical file was not adopted"
  run_uninstall "$home"
  assert_file_missing "$home/skills/daily-coding/SKILL.md"
  pass "legacy installs can be adopted into manifest-based ownership"
}

test_created_config_changed_is_preserved() {
  local home="$TEST_ROOT/changed-created-config"
  mkdir -p "$home"

  run_setup "$home"
  node - "$home/opencode.jsonc" <<'NODE'
const fs = require('fs');
const path = process.argv[2];
const data = JSON.parse(fs.readFileSync(path, 'utf8'));
data.userOwned = true;
fs.writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
NODE
  run_uninstall "$home"
  assert_file_exists "$home/opencode.jsonc"
  assert_contains "$home/opencode.jsonc" "userOwned"
  pass "installer-created opencode.jsonc is preserved if user changed it"
}

main() {
  bash -n "$SETUP"
  bash -n "$UNINSTALL"
  test_created_config_roundtrip
  test_existing_config_preserves_user_entries
  test_manifest_missing_fails_safely
  test_identical_preexisting_file_not_owned
  test_reinstall_preserves_ownership
  test_legacy_install_adopts_existing_files
  test_created_config_changed_is_preserved
  echo "All installer uninstall smoke tests passed."
}

main "$@"
