#!/bin/bash
# Stop Hook for Kimi CLI
# Event: Stop
# Purpose: Quick status check and temp file detection

set -euo pipefail

JSON_INPUT=""
if [ -t 0 ]; then
    JSON_INPUT="{}"
else
    JSON_INPUT=$(cat)
fi

cwd=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "$(pwd)")

output=""
output+="\n---\n"
output+="✅ Session ended\n\n"

# Git status
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    changed_count=$(git -C "$cwd" diff --name-only 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    staged_count=$(git -C "$cwd" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ' || echo "0")

    if [ "$changed_count" -gt 0 ] || [ "$staged_count" -gt 0 ]; then
        output+="📁 Git: $changed_count modified, $staged_count staged\n"
    else
        output+="📁 Git: clean\n"
    fi
fi

# Temp files check
temp_dirs=("$cwd/plan" "$cwd/temp" "$cwd/tmp" "$cwd/.kimi-code/temp")
temp_count=0
for dir in "${temp_dirs[@]}"; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
        temp_count=$((temp_count + count))
    fi
done

if [ "$temp_count" -gt 0 ]; then
    output+="🗑️  Temp files: $temp_count in /plan, /temp, /tmp, /.kimi-code/temp\n"
fi

# Obsidian KB reminder
if [ -f "$cwd/.kimi-code/project-memory/registry.yaml" ]; then
    output+="📚 Obsidian KB: Remember to update daily note and project memory\n"
fi

output+="\n"

echo -e "$output"
exit 0
