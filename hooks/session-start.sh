#!/bin/bash
# Session Start Hook for Kimi CLI (upgraded version)
# Event: SessionStart
# Purpose: Display project status, Git info, todos, skills, and Obsidian KB status

set -euo pipefail

JSON_INPUT=""
if [ -t 0 ]; then
    JSON_INPUT="{}"
else
    JSON_INPUT=$(cat)
fi

source=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('source','startup'))" 2>/dev/null || echo "startup")
cwd=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "$(pwd)")

project_name=$(basename "$cwd")

output=""
output+="🚀 $project_name Session started\n"
output+="▸ Time: $(date '+%Y-%m-%d %H:%M:%S')\n"
output+="▸ Directory: $cwd\n\n"

# Git status with detailed changes
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    output+="▸ Git branch: $branch\n"

    changes=$(git -C "$cwd" status --short 2>/dev/null || echo "")
    if [ -n "$changes" ]; then
        change_count=$(echo "$changes" | wc -l | tr -d ' ')
        output+="⚠️  Uncommitted changes ($change_count files):\n"
        echo "$changes" | head -5 | while read line; do
            status="${line:0:2}"
            file="${line:3}"
            case "$status" in
                *M*) icon="📝" ;;
                *A*) icon="➕" ;;
                *D*) icon="❌" ;;
                *R*) icon="🔄" ;;
                \?\?*) icon="❓" ;;
                *) icon="•" ;;
            esac
            output+="  $icon $file\n"
        done
        total_changes=$(echo "$changes" | wc -l | tr -d ' ')
        if [ "$total_changes" -gt 5 ]; then
            output+="  ... ($(($total_changes - 5)) more files)\n"
        fi
    else
        output+="✅ Working directory clean\n"
    fi
    output+="\n"
else
    output+="▸ Git: Not a repository\n\n"
fi

# Obsidian KB status
if [ -f "$cwd/.kimi-code/project-memory/registry.yaml" ]; then
    output+="🧠 Obsidian project KB: bound\n"
    output+="  - Suggested: kb-status, kb-sync, kb-lint skills\n\n"
elif [ -d "$cwd/.git" ] && ([ -f "$cwd/README.md" ] || [ -d "$cwd/src" ] || [ -f "$cwd/pyproject.toml" ]); then
    output+="🧠 Obsidian project KB: research repo candidate\n"
    output+="  - Suggested: kb-init skill\n\n"
fi

# Todos
todo_files=("$cwd/TODO.md" "$cwd/todo.md" "$cwd/docs/TODO.md" "$cwd/docs/todo.md")
todo_found=""
for todo_file in "${todo_files[@]}"; do
    if [ -f "$todo_file" ]; then
        todo_found="$todo_file"
        break
    fi
done

output+="📋 Todos:\n"
if [ -n "$todo_found" ]; then
    pending=$(grep -cE '^\s*[-*]\s*\[\s*\]' "$todo_found" 2>/dev/null || echo "0")
    completed=$(grep -cE '^\s*[-*]\s*\[[xX]\]' "$todo_found" 2>/dev/null || echo "0")
    output+="  - $pending pending / $completed completed\n"

    # Show top 5 pending items
    pending_items=$(grep -E '^\s*[-*]\s*\[\s*\]' "$todo_found" 2>/dev/null | head -5 | sed 's/^\s*[-*]\s*\[\s*\]\s*//')
    if [ -n "$pending_items" ]; then
        output+="\n  Recent todos:\n"
        echo "$pending_items" | while read item; do
            truncated="${item:0:60}"
            output+="  - $truncated\n"
        done
    fi
else
    output+="  No todo file found (TODO.md, docs/todo.md etc)\n"
fi
output+="\n"

# Skills list
output+="🔧 Loaded skills ($(ls ~/.kimi-code/skills/ 2>/dev/null | wc -l | tr -d ' ')):\n"
skills=$(ls ~/.kimi-code/skills/ 2>/dev/null | head -8 | tr '\n' ', ' | sed 's/, $//')
output+="  $skills"
remaining=$(ls ~/.kimi-code/skills/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$remaining" -gt 8 ]; then
    output+=", ... ($(($remaining - 8)) more)"
fi
output+="\n\n"

# For startup source, print full info
if [ "$source" = "startup" ]; then
    echo -e "$output"
fi

exit 0
