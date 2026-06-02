#!/bin/bash
# SessionEnd Hook for Kimi CLI (upgraded version)
# Event: SessionEnd
# Purpose: Create detailed work log, detect AGENTS.md changes, and generate smart suggestions

set -euo pipefail

JSON_INPUT=""
if [ -t 0 ]; then
    JSON_INPUT="{}"
else
    JSON_INPUT=$(cat)
fi

cwd=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "$(pwd)")
reason=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('reason',''))" 2>/dev/null || echo "")

project_name=$(basename "$cwd")
date_str=$(date '+%Y%m%d')
log_dir="$cwd/.kimi/logs"

mkdir -p "$log_dir" 2>/dev/null || true

# Smart suggestion output
suggestions=""
suggestions+="\n📊 Session Summary\n"

# Git statistics
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    added=$(git -C "$cwd" diff --name-only --diff-filter=A 2>/dev/null | wc -l | tr -d ' ')
    modified=$(git -C "$cwd" diff --name-only --diff-filter=M 2>/dev/null | wc -l | tr -d ' ')
    deleted=$(git -C "$cwd" diff --name-only --diff-filter=D 2>/dev/null | wc -l | tr -d ' ')
    staged=$(git -C "$cwd" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

    if [ "$((added + modified + deleted + staged))" -gt 0 ]; then
        suggestions+="Changes: $added added, $modified modified, $deleted deleted, $added staged\n"
    else
        suggestions+="No file changes in this session\n"
    fi
fi

# Detect AGENTS.md changes
agents_changed=""
for file in "$cwd/AGENTS.md" "$cwd/.kimi/AGENTS.md"; do
    if [ -f "$file" ]; then
        # Check if modified in last 10 minutes (session duration proxy)
        if find "$file" -mmin -10 2>/dev/null | grep -q .; then
            agents_changed="$(basename "$file")"
            break
        fi
    fi
done

if [ -n "$agents_changed" ]; then
    suggestions+="⚠️  $agents_changed was modified during this session\n"
    suggestions+="   Consider committing the change if it's intentional\n"
fi

# Check for temp files
temp_count=0
temp_dirs=("$cwd/plan" "$cwd/temp" "$cwd/tmp" "$cwd/.kimi/temp" "$cwd/.kimi/temp")
for dir in "${temp_dirs[@]}"; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
        temp_count=$((temp_count + count))
    fi
done

if [ "$temp_count" -gt 0 ]; then
    suggestions+="🗑️  Temp files: $temp_count (consider cleaning /plan, /temp when done)\n"
fi

# Check for uncommitted changes
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    uncommitted=$(git -C "$cwd" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    if [ "$uncommitted" -gt 0 ]; then
        suggestions+="💡 $uncommitted uncommitted files. Consider: /commit\n"
    fi
fi

# Obsidian KB reminder
if [ -f "$cwd/.kimi/project-memory/registry.yaml" ]; then
    suggestions+="📚 Obsidian KB: Update daily note and project memory if substantial work was done\n"
fi

suggestions+="\n"
echo -e "$suggestions" >&2

# Write log file
log_file="$log_dir/session-${date_str}.md"
if [ ! -f "$log_file" ]; then
    echo "# 📝 Work Log - $project_name" > "$log_file"
    echo "" >> "$log_file"
fi

log_entry="- $(date '+%H:%M') — Session ended (${reason:-completed})"
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    changed_files=$(git -C "$cwd" diff --name-only 2>/dev/null | head -5 | tr '\n' ', ' | sed 's/, $//')
    if [ -n "$changed_files" ]; then
        log_entry+=" | Modified: $changed_files"
    fi
fi
echo "$log_entry" >> "$log_file"

exit 0