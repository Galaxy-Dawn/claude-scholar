#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SETUP_SH="$REPO_ROOT/scripts/setup.sh"
UNINSTALL_SH="$REPO_ROOT/scripts/uninstall.sh"

pass() {
  echo "[PASS] $1"
}

make_home() {
  mktemp -d /tmp/claude-scholar-test.XXXXXX
}

run_setup() {
  HOME="$1" bash "$SETUP_SH" >/dev/null
}

run_uninstall() {
  HOME="$1" bash "$UNINSTALL_SH" >/dev/null
}

test_roundtrip_empty_home() {
  local home
  home="$(make_home)"
  run_setup "$home"

  test -f "$home/.gemini/config/plugins/claude-scholar/.claude-scholar-manifest.txt"
  test -f "$home/.gemini/config/plugins/claude-scholar/.claude-scholar-install-state"
  test -f "$home/.gemini/config/plugins/claude-scholar/CLAUDE.md"

  run_uninstall "$home"

  test ! -f "$home/.gemini/config/plugins/claude-scholar/.claude-scholar-manifest.txt"
  test ! -f "$home/.gemini/config/plugins/claude-scholar/.claude-scholar-install-state"
  test ! -f "$home/.gemini/config/mcp_config.json"
  if [ -d "$home/.gemini/config/plugins/claude-scholar" ]; then
    ! find "$home/.gemini/config/plugins/claude-scholar"/{skills,commands,agents,rules,hooks,scripts} -type f 2>/dev/null | grep -q .
  fi
  pass "roundtrip on empty home"
}

test_preserve_preexisting_settings_keys() {
  local home
  home="$(make_home)"
  mkdir -p "$home/.gemini/config"
  python3 - "$home/.gemini/config/mcp_config.json" <<'PY'
import json, sys
path = sys.argv[1]
data = {
    "mcpServers": {
        "zotero": {
            "command": "custom-zotero"
        }
    }
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

  run_setup "$home"
  run_uninstall "$home"

  python3 - "$home/.gemini/config/mcp_config.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["mcpServers"]["zotero"]["command"] == "custom-zotero"
assert "args" not in data["mcpServers"]["zotero"]
assert "env" not in data["mcpServers"]["zotero"]
PY
  pass "preserve pre-existing settings entries with overlapping keys"
}

test_manifest_missing_fails_safe() {
  local home
  home="$(make_home)"
  run_setup "$home"

  rm -f "$home/.gemini/config/plugins/claude-scholar/.claude-scholar-manifest.txt"
  if HOME="$home" bash "$UNINSTALL_SH" >/tmp/claude-scholar-uninstall-fail.log 2>&1; then
    echo "[FAIL] manifest missing should fail"
    cat /tmp/claude-scholar-uninstall-fail.log
    exit 1
  fi

  test -f "$home/.gemini/config/plugins/claude-scholar/CLAUDE.md"
  test -f "$home/.gemini/config/plugins/claude-scholar/.claude-scholar-install-state"
  pass "manifest missing fails safely"
}

test_state_records_direct_claude_targets() {
  local home
  home="$(make_home)"
  run_setup "$home"

  python3 - "$home/.gemini/config/plugins/claude-scholar/.claude-scholar-install-state" <<'PY'
import json, sys
state = json.load(open(sys.argv[1], encoding="utf-8"))
targets = set(state["claudeTargets"])
assert "CLAUDE.md" in targets, targets
assert "CLAUDE.zh-CN.md" in targets, targets
PY

  run_uninstall "$home"
  test ! -f "$home/.gemini/config/plugins/claude-scholar/CLAUDE.md"
  test ! -f "$home/.gemini/config/plugins/claude-scholar/CLAUDE.zh-CN.md"
  pass "state records direct CLAUDE targets"
}

test_identical_preexisting_file_is_not_owned() {
  local home
  home="$(make_home)"
  mkdir -p "$home/.gemini/config/plugins/claude-scholar/hooks"
  cp "$REPO_ROOT/hooks/security-guard.js" "$home/.gemini/config/plugins/claude-scholar/hooks/security-guard.js"

  run_setup "$home"
  run_uninstall "$home"

  test -f "$home/.gemini/config/plugins/claude-scholar/hooks/security-guard.js"
  pass "identical pre-existing file is not treated as owned"
}

test_reinstall_keeps_owned_files_owned() {
  local home
  home="$(make_home)"
  run_setup "$home"
  run_setup "$home"
  run_uninstall "$home"

  test ! -f "$home/.gemini/config/plugins/claude-scholar/hooks/security-guard.js"
  test ! -f "$home/.gemini/config/plugins/claude-scholar/CLAUDE.md"
  pass "reinstall preserves ownership of previously installed files"
}

test_legacy_install_upgrade_adopts_existing_files() {
  local home
  home="$(make_home)"
  mkdir -p "$home/.gemini/config/plugins/claude-scholar/hooks"
  cp "$REPO_ROOT/CLAUDE.md" "$home/.gemini/config/plugins/claude-scholar/CLAUDE.md"
  cp "$REPO_ROOT/hooks/security-guard.js" "$home/.gemini/config/plugins/claude-scholar/hooks/security-guard.js"
  python3 - "$home/.gemini/config/plugins/claude-scholar/settings.json" <<'PY'
import json, sys
data = {
    "mcpServers": {
        "streamable-mcp-server": {
            "type": "streamable-http",
            "url": "http://127.0.0.1:12306/mcp"
        }
    },
    "hooks": {
        "PreToolUse": [
            {
                "matcher": "Bash|Write|Edit",
                "hooks": [
                    {
                        "type": "command",
                        "command": "node -e \"const p=require('path'),h=require('os').homedir();require('child_process').execSync('node '+p.join(h,'.claude/hooks/security-guard.js'),{stdio:'inherit'})\"",
                        "timeout": 5
                    }
                ]
            }
        ]
    }
}
with open(sys.argv[1], "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

  run_setup "$home"
  run_uninstall "$home"

  test ! -f "$home/.gemini/config/plugins/claude-scholar/CLAUDE.md"
  test ! -f "$home/.gemini/config/plugins/claude-scholar/hooks/security-guard.js"
  pass "legacy install upgrade adopts existing managed files"
}

test_overlapping_mcp_keys_do_not_trigger_legacy_adoption() {
  local home
  home="$(make_home)"
  mkdir -p "$home/.gemini/config/plugins/claude-scholar/hooks"
  cp "$REPO_ROOT/hooks/security-guard.js" "$home/.gemini/config/plugins/claude-scholar/hooks/security-guard.js"
  python3 - "$home/.gemini/config/plugins/claude-scholar/settings.json" <<'PY'
import json, sys
data = {
    "mcpServers": {
        "zotero": {
            "command": "custom-zotero"
        }
    },
    "enabledPlugins": {
        "superpowers@claude-plugins-official": False
    }
}
with open(sys.argv[1], "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

  run_setup "$home"
  run_uninstall "$home"

  test -f "$home/.gemini/config/plugins/claude-scholar/hooks/security-guard.js"
  pass "overlapping MCP keys alone do not trigger legacy adoption"
}

main() {
  bash -n "$SETUP_SH"
  bash -n "$UNINSTALL_SH"
  test_roundtrip_empty_home
  test_preserve_preexisting_settings_keys
  test_manifest_missing_fails_safe
  test_state_records_direct_claude_targets
  test_identical_preexisting_file_is_not_owned
  test_reinstall_keeps_owned_files_owned
  test_legacy_install_upgrade_adopts_existing_files
  test_overlapping_mcp_keys_do_not_trigger_legacy_adoption
}

main "$@"
