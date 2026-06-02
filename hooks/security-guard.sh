#!/bin/bash
# Security Guard Hook for Kimi CLI
# Event: PreToolUse
# Purpose: Block catastrophic commands, flag dangerous operations

set -euo pipefail

# Read JSON from stdin
JSON_INPUT=""
if [ -t 0 ]; then
    JSON_INPUT="{}"
else
    JSON_INPUT=$(cat)
fi

# Extract fields using Python (more reliable than jq for nested paths)
tool_name=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")
tool_input=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('tool_input',{})))" 2>/dev/null || echo "{}")
cwd=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "$(pwd)")

DECISION="allow"
REASON=""
CONFIRM_LABEL=""

# === Bash command security check ===
if [ "$tool_name" = "Shell" ] || [ "$tool_name" = "Bash" ]; then
    command=$(echo "$tool_input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('command',''))" 2>/dev/null || echo "")

    # Tier 1: Block — catastrophic commands
    BLOCK_PATTERNS=(
        'rm\s+-rf\s+/($|[[:space:]])'
        'rm\s+--no-preserve-root'
        'dd\s+if=/dev/(zero|random)'
        'mkfs\.'
        'rm\s+-[rf]?\s+/(etc|usr|bin|sbin)(/|[[:space:]]|$)'
        'rm\s+-rf\s+/home/[^/[:space:]]*/?([[:space:]]|$)'
        'rm\s+-rf\s+/Users/[^/[:space:]]*/?([[:space:]]|$)'
    )

    for pattern in "${BLOCK_PATTERNS[@]}"; do
        if echo "$command" | grep -qE "$pattern" 2>/dev/null; then
            DECISION="deny"
            REASON="Catastrophic command detected"
            break
        fi
    done

    # Tier 2: Confirm — dangerous but sometimes legitimate
    if [ "$DECISION" = "allow" ]; then
        if echo "$command" | grep -qE 'git\s+push\s+.*(-f|--force)' 2>/dev/null; then
            CONFIRM_LABEL="git push --force (overwrites remote history)"
        elif echo "$command" | grep -qE 'git\s+reset\s+--hard' 2>/dev/null; then
            CONFIRM_LABEL="git reset --hard (discards all uncommitted changes)"
        elif echo "$command" | grep -qE 'git\s+clean\s+-[a-z]*f' 2>/dev/null; then
            CONFIRM_LABEL="git clean -f (permanently deletes untracked files)"
        elif echo "$command" | grep -qE 'git\s+(checkout|restore)\s+\.' 2>/dev/null; then
            CONFIRM_LABEL="git checkout/restore . (discards all working tree changes)"
        elif echo "$command" | grep -qE 'rm\s+-[rf]' 2>/dev/null; then
            CONFIRM_LABEL="rm -rf (recursive/force delete)"
        elif echo "$command" | grep -qE 'chmod\s+(-R\s+)?777' 2>/dev/null; then
            CONFIRM_LABEL="chmod 777 (world-writable permissions)"
        elif echo "$command" | grep -qE 'npm\s+publish' 2>/dev/null; then
            CONFIRM_LABEL="npm publish (publishes package to registry)"
        elif echo "$command" | grep -qE 'pip\s+upload|twine\s+upload' 2>/dev/null; then
            CONFIRM_LABEL="pip/twine upload (publishes package to PyPI)"
        elif echo "$command" | grep -qE 'docker\s+system\s+prune' 2>/dev/null; then
            CONFIRM_LABEL="docker system prune (removes all unused resources)"
        elif echo "$command" | grep -qiE 'DROP\s+(DATABASE|TABLE)' 2>/dev/null; then
            CONFIRM_LABEL="SQL DROP (destroys database/table)"
        elif echo "$command" | grep -qiE 'DELETE\s+FROM\s+(?!.*WHERE)' 2>/dev/null; then
            CONFIRM_LABEL="DELETE without WHERE (deletes all rows)"
        elif echo "$command" | grep -qiE 'UPDATE\s+\S+\s+SET\s+(?!.*WHERE)' 2>/dev/null; then
            CONFIRM_LABEL="UPDATE without WHERE (updates all rows)"
        elif echo "$command" | grep -qiE 'TRUNCATE\s+TABLE' 2>/dev/null; then
            CONFIRM_LABEL="SQL TRUNCATE (empties entire table)"
        fi
    fi

# === File write security check ===
elif [ "$tool_name" = "WriteFile" ] || [ "$tool_name" = "StrReplaceFile" ]; then
    file_path=$(echo "$tool_input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))" 2>/dev/null || echo "")

    # Tier 1: Block — system paths
    if echo "$file_path" | grep -qE '^/(etc/|usr/bin/|usr/sbin/|bin/|sbin/|System/|dev/|proc/|sys/)' 2>/dev/null; then
        DECISION="deny"
        REASON="Writing to system path denied: $file_path"
    fi

    # Block — outside repo and home
    if [ "$DECISION" = "allow" ]; then
        resolved=$(cd "$cwd" 2>/dev/null && realpath -m "$file_path" 2>/dev/null || echo "$cwd/$file_path")
        home_dir="$HOME"

        # Find git repo root
        repo_root="$cwd"
        if git -C "$cwd" rev-parse --show-toplevel 2>/dev/null; then
            repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
        fi

        inside_repo=false
        inside_home=false

        if echo "$resolved" | grep -q "^$repo_root" 2>/dev/null; then
            inside_repo=true
        fi
        if echo "$resolved" | grep -q "^$home_dir" 2>/dev/null; then
            inside_home=true
        fi

        if [ "$inside_repo" = "false" ] && [ "$inside_home" = "false" ]; then
            DECISION="deny"
            REASON="Path traversal attack detected: resolved path is outside the repository and home directory"
        elif [ "$inside_repo" = "false" ] && [ "$inside_home" = "true" ]; then
            rel_path="${resolved#$home_dir/}"
            CONFIRM_LABEL="home directory path outside repo (~/$rel_path)"
        fi
    fi

    # Tier 2: Confirm — sensitive files
    if [ "$DECISION" = "allow" ]; then
        file_name=$(basename "$file_path")

        if echo "$file_name" | grep -qE '^\.env' 2>/dev/null; then
            CONFIRM_LABEL=".env file ($file_name)"
        elif [ "$file_name" = "credentials.json" ] || [ "$file_name" = "key.pem" ] || [ "$file_name" = "key.json" ] || [ "$file_name" = "id_rsa" ]; then
            CONFIRM_LABEL="sensitive file ($file_name)"
        elif echo "$file_path" | grep -qE '\.aws/credentials|\.npmrc' 2>/dev/null; then
            CONFIRM_LABEL="sensitive path ($file_path)"
        fi
    fi
fi

# === Output decision ===
if [ "$DECISION" = "deny" ]; then
    echo "Error: $REASON" >&2
    exit 2
fi

if [ -n "$CONFIRM_LABEL" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"confirm","permissionDecisionReason":"'"$CONFIRM_LABEL"'"}}'
    exit 0
fi

exit 0
