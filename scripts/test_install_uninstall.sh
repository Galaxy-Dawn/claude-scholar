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

  test -f "$home/.claude/.claude-scholar-manifest.txt"
  test -f "$home/.claude/.claude-scholar-install-state"
  test -f "$home/.claude/CLAUDE.md"
  node "$REPO_ROOT/scripts/test_settings_hooks.js" "$home/.claude/settings.json"
  test -f "$home/.claude/commands/promote.md"
  test -f "$home/.claude/skills/post-acceptance/references/xquik-promotion.md"
  test -f "$home/.claude/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md"
  ! grep -q 'generate-promotion.py' "$home/.claude/commands/promote.md"

  run_uninstall "$home"

  test ! -f "$home/.claude/.claude-scholar-manifest.txt"
  test ! -f "$home/.claude/.claude-scholar-install-state"
  test ! -f "$home/.claude/settings.json"
  test -f "$home/.claude/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md"
  if [ -d "$home/.claude" ]; then
    ! find "$home/.claude"/{skills,commands,agents,rules,hooks,scripts} -type f ! -path "$home/.claude/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md" 2>/dev/null | grep -q .
  fi
  pass "roundtrip on empty home"
}

test_writing_memory_survives_update_and_legacy_uninstall() {
  local home memory
  home="$(make_home)"
  run_setup "$home"
  memory="$home/.claude/skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md"
  printf '\n### Kept example\n**Source:** Test paper\n' >> "$memory"

  run_setup "$home"
  grep -Fq '### Kept example' "$memory"
  ! grep -Fxq 'skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md' "$home/.claude/.claude-scholar-manifest.txt"

  # Older manifests may still claim ownership of the file.
  printf '%s\n' 'skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md' >> "$home/.claude/.claude-scholar-manifest.txt"
  run_uninstall "$home"
  grep -Fq '### Kept example' "$memory"
  pass "mined writing memory survives update and legacy uninstall"
}

test_preserve_preexisting_settings_keys() {
  local home
  home="$(make_home)"
  mkdir -p "$home/.claude"
  python3 - "$home/.claude/settings.json" "$REPO_ROOT/scripts/test-fixtures/manual-hooks-v1.json" <<'PY'
import json, sys
path = sys.argv[1]
legacy = json.load(open(sys.argv[2], encoding="utf-8"))["PreToolUse"][0]
data = {
    "mcpServers": {
        "zotero": {
            "command": "custom-zotero"
        }
    },
    "enabledPlugins": {
        "superpowers@claude-plugins-official": False
    },
    "hooks": {
        "PreToolUse": [{**legacy, "matcher": "Read"}],
        "Stop": [
            {
                "matcher": "*",
                "hooks": [
                    {
                        "type": "command",
                        "command": "echo .claude/hooks/stop-summary.js",
                        "timeout": 3
                    }
                ]
            }
        ]
    }
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

  run_setup "$home"
  python3 - "$home/.claude/settings.json" <<'PY'
import json, sys
hooks = json.load(open(sys.argv[1], encoding="utf-8"))["hooks"]
stop = hooks["Stop"][0]["hooks"]
assert len(stop) == 2 and stop[0]["command"] == "echo .claude/hooks/stop-summary.js", stop
assert [m["matcher"] for m in hooks["PreToolUse"]] == ["Read", "Bash|Write|Edit"]
PY
  run_uninstall "$home"

  python3 - "$home/.claude/settings.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["mcpServers"]["zotero"]["command"] == "custom-zotero"
assert "args" not in data["mcpServers"]["zotero"]
assert "env" not in data["mcpServers"]["zotero"]
assert data["enabledPlugins"]["superpowers@claude-plugins-official"] is False
hooks = data["hooks"]["Stop"][0]["hooks"]
assert len(hooks) == 1 and hooks[0]["command"] == "echo .claude/hooks/stop-summary.js"
assert "PreToolUse" not in data["hooks"]
PY
  pass "preserve pre-existing settings entries with overlapping keys"
}

test_stock_manual_hooks_migrate_on_upgrade() {
  local home warnings
  home="$(make_home)"
  mkdir -p "$home/.claude"

  python3 - "$REPO_ROOT" "$home/.claude/settings.json" <<'PY'
import json, sys
from pathlib import Path

root, target = map(Path, sys.argv[1:])
legacy = json.loads((root / "scripts/test-fixtures/manual-hooks-v1.json").read_text())
current = json.loads((root / "settings.json.template").read_text())["hooks"]
legacy["SessionEnd"].append(current["SessionEnd"][0])
legacy["SessionStart"][0]["hooks"][0]["async"] = True
read_hook = {**legacy["PreToolUse"][0]["hooks"][0], "statusMessage": "Reading"}
legacy["PreToolUse"].append({"matcher": "Read", "hooks": [read_hook]})
stop = legacy["Stop"][0]["hooks"][0]
legacy["Stop"][0]["hooks"].extend([{**stop, "timeout": 33}, {**stop, "async": False, "statusMessage": "Saving"}])
current_stop = current["Stop"][0]["hooks"][0]
same_options = {"statusMessage": "Saving", "async": False, **current_stop}
legacy["Stop"].append({"matcher": "*", "hooks": [current_stop, same_options]})
target.write_text(json.dumps({"hooks": legacy, "model": "user-model"}))
PY

  cp "$home/.claude/settings.json" "$home/settings-before-upgrade.json"
  printf '%s' '{"settings":' > "$home/.claude/.claude-scholar-install-state"
  warnings="$(run_setup "$home" 2>&1)"
  [[ "$warnings" == *"Ignoring unreadable previous Claude Scholar install state"* ]]
  test -f "$home/.claude/settings.json.bak"
  cp "$home/.claude/settings.json" "$home/settings-after-upgrade.json"
  run_setup "$home"
  cmp "$home/settings-after-upgrade.json" "$home/.claude/settings.json"
  python3 - "$REPO_ROOT" "$home/.claude" <<'PY'
import json, sys
from pathlib import Path

root, config_dir = map(Path, sys.argv[1:])
settings = json.loads((config_dir / "settings.json").read_text())
state = json.loads((config_dir / ".claude-scholar-install-state").read_text())
current = json.loads((root / "settings.json.template").read_text())["hooks"]
assert settings["model"] == "user-model"
stop = current["Stop"][0]["hooks"][0]
current["Stop"][0]["hooks"] = [{**stop, "timeout": 33}, {**stop, "async": False, "statusMessage": "Saving"}]
current["SessionStart"][0]["hooks"][0]["async"] = True
original = json.loads((config_dir.parent / "settings-before-upgrade.json").read_text())
current["PreToolUse"].append(original["hooks"]["PreToolUse"][-1])
assert settings["hooks"] == current, settings["hooks"]
owned = state["settings"]["addedHooks"]
assert sorted((h["event"], h["matcher"]) for h in owned) == [
    ("PreToolUse", "Bash|Write|Edit"), ("UserPromptSubmit", "*")
]
PY

  run_uninstall "$home"
  python3 - "$home/.claude/settings.json" <<'PY'
import json, sys
from pathlib import Path

settings_path = Path(sys.argv[1])
settings = json.loads(settings_path.read_text())
assert settings["model"] == "user-model"
assert "hooks" not in settings, settings["hooks"]
backup, = (settings_path.parent / ".claude-scholar-backups").glob("uninstall-*/settings.json")
assert backup.read_bytes() == (settings_path.parent.parent / "settings-after-upgrade.json").read_bytes()
PY
  pass "upgrade migrates stock Hooks and uninstall backs up their customizations"
}

test_customized_installed_hooks_are_backed_up() {
  local home reinstall
  for reinstall in no yes; do
    home="$(make_home)"
    run_setup "$home"
    python3 - "$home/.claude/settings.json" <<'PY'
import json, sys
from pathlib import Path

settings = Path(sys.argv[1])
data = json.loads(settings.read_text())
data["hooks"]["SessionStart"][0]["hooks"][0]["async"] = True
data["hooks"]["Stop"][0]["hooks"][0]["timeout"] = 41
data["hooks"]["Stop"][0]["hooks"].append({"type": "command", "command": "echo .claude/hooks/stop-summary.js"})
settings.write_text(json.dumps(data))
PY

    if [ "$reinstall" = yes ]; then
      run_setup "$home"
      python3 - "$home/.claude/.claude-scholar-install-state" <<'PY'
import json, sys

state = json.load(open(sys.argv[1], encoding="utf-8"))
assert all(hook["event"] not in {"SessionStart", "Stop"} for hook in state["settings"]["addedHooks"])
PY
    fi

    cp "$home/.claude/settings.json" "$home/settings-before-uninstall.json"
    run_uninstall "$home"
    test ! -e "$home/.claude/hooks/session-start.js"
    test ! -e "$home/.claude/hooks/stop-summary.js"
    python3 - "$home/.claude/settings.json" <<'PY'
import json, sys
from pathlib import Path

settings_path = Path(sys.argv[1])
assert json.loads(settings_path.read_text())["hooks"] == {
    "Stop": [{"matcher": "*", "hooks": [{"type": "command", "command": "echo .claude/hooks/stop-summary.js"}]}],
}
backup, = (settings_path.parent / ".claude-scholar-backups").glob("uninstall-*/settings.json")
assert backup.read_bytes() == (settings_path.parent.parent / "settings-before-uninstall.json").read_bytes()
PY
  done
  pass "uninstall backs up customized Scholar Hooks with or without reinstall"
}

test_manifest_missing_fails_safe() {
  local home
  home="$(make_home)"
  run_setup "$home"

  rm -f "$home/.claude/.claude-scholar-manifest.txt"
  if HOME="$home" bash "$UNINSTALL_SH" >/tmp/claude-scholar-uninstall-fail.log 2>&1; then
    echo "[FAIL] manifest missing should fail"
    cat /tmp/claude-scholar-uninstall-fail.log
    exit 1
  fi

  test -f "$home/.claude/CLAUDE.md"
  test -f "$home/.claude/.claude-scholar-install-state"
  pass "manifest missing fails safely"
}

test_state_records_direct_claude_targets() {
  local home
  home="$(make_home)"
  run_setup "$home"

  python3 - "$home/.claude/.claude-scholar-install-state" <<'PY'
import json, sys
state = json.load(open(sys.argv[1], encoding="utf-8"))
targets = set(state["claudeTargets"])
assert "CLAUDE.md" in targets, targets
assert "CLAUDE.zh-CN.md" in targets, targets
PY

  run_uninstall "$home"
  test ! -f "$home/.claude/CLAUDE.md"
  test ! -f "$home/.claude/CLAUDE.zh-CN.md"
  pass "state records direct CLAUDE targets"
}

test_identical_preexisting_file_is_not_owned() {
  local home
  home="$(make_home)"
  mkdir -p "$home/.claude/hooks"
  cp "$REPO_ROOT/hooks/security-guard.js" "$home/.claude/hooks/security-guard.js"

  run_setup "$home"
  run_uninstall "$home"

  test -f "$home/.claude/hooks/security-guard.js"
  pass "identical pre-existing file is not treated as owned"
}

test_reinstall_keeps_owned_files_owned() {
  local home
  home="$(make_home)"
  run_setup "$home"
  run_setup "$home"
  run_uninstall "$home"

  test ! -f "$home/.claude/hooks/security-guard.js"
  test ! -f "$home/.claude/CLAUDE.md"
  pass "reinstall preserves ownership of previously installed files"
}

test_legacy_install_upgrade_adopts_existing_files() {
  local home
  home="$(make_home)"
  mkdir -p "$home/.claude/hooks"
  cp "$REPO_ROOT/CLAUDE.md" "$home/.claude/CLAUDE.md"
  cp "$REPO_ROOT/hooks/security-guard.js" "$home/.claude/hooks/security-guard.js"
  python3 - "$home/.claude/settings.json" <<'PY'
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

  test ! -f "$home/.claude/CLAUDE.md"
  test ! -f "$home/.claude/hooks/security-guard.js"
  pass "legacy install upgrade adopts existing managed files"
}

test_overlapping_mcp_keys_do_not_trigger_legacy_adoption() {
  local home preexisting_common
  for preexisting_common in no yes; do
    home="$(make_home)"
    mkdir -p "$home/.claude/hooks"
    cp "$REPO_ROOT/hooks/security-guard.js" "$home/.claude/hooks/"
    if [ "$preexisting_common" = yes ]; then
      cp "$REPO_ROOT/hooks/hook-common.js" "$home/.claude/hooks/"
    fi
    python3 - "$home/.claude/settings.json" <<'PY'
import json, sys
from pathlib import Path

Path(sys.argv[1]).write_text(json.dumps({
    "mcpServers": {"zotero": {"command": "custom-zotero"}},
    "enabledPlugins": {"superpowers@claude-plugins-official": False},
}))
PY

    run_setup "$home"
    python3 - "$home/.claude/settings.json" <<'PY'
import json, sys
from pathlib import Path

settings = Path(sys.argv[1])
data = json.loads(settings.read_text())
matcher = data["hooks"]["PreToolUse"][0]
data["hooks"]["PreToolUse"].append({**matcher, "matcher": "Read"})
settings.write_text(json.dumps(data))
PY
    run_uninstall "$home"

    test -f "$home/.claude/hooks/security-guard.js"
    python3 - "$home/.claude/settings.json" "$preexisting_common" <<'PY'
import json, sys
from pathlib import Path

settings = Path(sys.argv[1])
hooks = json.loads(settings.read_text()).get("hooks", {})
matchers = [matcher["matcher"] for matcher in hooks.get("PreToolUse", [])]
common = settings.parent / "hooks/hook-common.js"
if sys.argv[2] == "yes":
    assert common.is_file()
    assert matchers == ["Read"], hooks
else:
    assert not common.exists()
    assert not matchers, hooks
PY
  done
  pass "uninstall preserves existing hook scripts and cleans launchers missing their shared helper"
}

main() {
  bash -n "$SETUP_SH"
  bash -n "$UNINSTALL_SH"
  test_roundtrip_empty_home
  test_writing_memory_survives_update_and_legacy_uninstall
  test_preserve_preexisting_settings_keys
  test_stock_manual_hooks_migrate_on_upgrade
  test_customized_installed_hooks_are_backed_up
  test_manifest_missing_fails_safe
  test_state_records_direct_claude_targets
  test_identical_preexisting_file_is_not_owned
  test_reinstall_keeps_owned_files_owned
  test_legacy_install_upgrade_adopts_existing_files
  test_overlapping_mcp_keys_do_not_trigger_legacy_adoption
}

main "$@"
