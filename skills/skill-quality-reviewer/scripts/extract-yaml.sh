#!/bin/bash
# extract-yaml.sh - Extract YAML frontmatter from SKILL.md files
# Part of skill-quality-reviewer

# Usage: ./extract-yaml.sh <path-to-skill>
# Example: ./extract-yaml.sh ~/.claude/skills/git-workflow

set -euo pipefail

# Check if path provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-skill>"
    echo "Example: $0 ~/.claude/skills/git-workflow"
    exit 1
fi

SKILL_PATH="$1"
SKILL_FILE="${SKILL_PATH}/SKILL.md"

# Check if SKILL.md exists
if [ ! -f "$SKILL_FILE" ]; then
    echo "Error: SKILL.md not found at ${SKILL_FILE}"
    exit 1
fi

# Extract YAML frontmatter (between --- lines)
# Using sed to extract content between first and second ---
sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$SKILL_FILE"
