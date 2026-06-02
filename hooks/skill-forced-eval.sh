#!/bin/bash
# UserPromptSubmit Hook for Kimi CLI (upgraded version)
# Event: UserPromptSubmit
# Purpose: Scan actual skills directory and inject relevant skill evaluation prompts

set -uo pipefail

JSON_INPUT=""
if [ -t 0 ]; then
    JSON_INPUT="{}"
else
    JSON_INPUT=$(cat)
fi

prompt=$(echo "$JSON_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('prompt',''))" 2>/dev/null || echo "")

# Skip if prompt is empty or too short
if [ -z "$prompt" ] || [ "${#prompt}" -lt 10 ]; then
    exit 0
fi

# Skip if it's a slash command (but not a path)
if echo "$prompt" | grep -qE '^/[^/[:space:]]+$'; then
    exit 0
fi

# Skip simple greetings
SIMPLE_GREETINGS='^(hi|hello|hey|你好|嗨|help|\?)[[:space:]]*$'
if echo "$prompt" | grep -qiE "$SIMPLE_GREETINGS"; then
    exit 0
fi

# Collect actual skills from ~/.kimi-code/skills/
all_skills=""
for dir in ~/.kimi-code/skills; do
    if [ -d "$dir" ]; then
        for skill in "$dir"/*; do
            if [ -d "$skill" ] && [ -f "$skill/SKILL.md" ]; then
                name=$(basename "$skill")
                # Skip hidden and special directories
                if [[ "$name" != .* && "$name" != "backup" && "$name" != ".DS_Store" ]]; then
                    all_skills="$all_skills $name"
                fi
            fi
        done
    fi
done

# Remove duplicates and sort
all_skills=$(echo "$all_skills" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/^ *//;s/ *$//')

# Match skills using a keyword-based approach with simple variables
match_skill() {
    local skill="$1"
    local prompt_lower="$2"
    local matched=""

    case "$skill" in
        nature-writing)
            echo "$prompt_lower" | grep -qiE 'paper|write|draft|manuscript|abstract|introduction|method|experiment' && matched="$skill"
            ;;
        nature-polishing)
            echo "$prompt_lower" | grep -qiE 'polish|refine|edit|revise|grammar|style|phrase' && matched="$skill"
            ;;
        nature-response)
            echo "$prompt_lower" | grep -qiE 'rebuttal|reviewer|response|revision|revise|minor|major' && matched="$skill"
            ;;
        nature-data)
            echo "$prompt_lower" | grep -qiE 'data|repository|fair|dataset|identifier' && matched="$skill"
            ;;
        ml-paper-writing)
            echo "$prompt_lower" | grep -qiE 'paper|writing|conference|neurips|icml|iclr|submission' && matched="$skill"
            ;;
        research-ideation)
            echo "$prompt_lower" | grep -qiE 'research|idea|ideation|literature|survey|gap' && matched="$skill"
            ;;
        results-analysis)
            echo "$prompt_lower" | grep -qiE 'analysis|statistic|figure|plot|chart|benchmark|ablation' && matched="$skill"
            ;;
        results-report)
            echo "$prompt_lower" | grep -qiE 'report|summary|experiment|result|post-experiment' && matched="$skill"
            ;;
        citation-verification)
            echo "$prompt_lower" | grep -qiE 'citation|reference|verify|bibliography' && matched="$skill"
            ;;
        daily-paper-generator)
            echo "$prompt_lower" | grep -qiE 'paper|daily|arxiv|track' && matched="$skill"
            ;;
        code-review-excellence)
            echo "$prompt_lower" | grep -qiE 'code|review|quality|security|maintainability' && matched="$skill"
            ;;
        bug-detective)
            echo "$prompt_lower" | grep -qiE 'bug|debug|error|investigate|trace' && matched="$skill"
            ;;
        architecture-design)
            echo "$prompt_lower" | grep -qiE 'architecture|design|pattern|structure|module' && matched="$skill"
            ;;
        verification-loop)
            echo "$prompt_lower" | grep -qiE 'verify|test|check|validate|confirm' && matched="$skill"
            ;;
        planning-with-files)
            echo "$prompt_lower" | grep -qiE 'plan|todo|task|plan\.md|task_plan' && matched="$skill"
            ;;
        git-workflow)
            echo "$prompt_lower" | grep -qiE 'git|commit|branch|merge|rebase|push|pull' && matched="$skill"
            ;;
        uv-package-manager)
            echo "$prompt_lower" | grep -qiE 'uv|pip|package|install|dependency' && matched="$skill"
            ;;
        daily-coding)
            echo "$prompt_lower" | grep -qiE 'coding|code|checklist' && matched="$skill"
            ;;
        kaggle-learner)
            echo "$prompt_lower" | grep -qiE 'kaggle|competition|leaderboard|submission' && matched="$skill"
            ;;
        obsidian-project-kb-core)
            echo "$prompt_lower" | grep -qiE 'obsidian|kb|knowledge|vault|note' && matched="$skill"
            ;;
        obsidian-source-ingestion)
            echo "$prompt_lower" | grep -qiE 'ingest|source|paper|web|interview' && matched="$skill"
            ;;
        obsidian-literature-workflow)
            echo "$prompt_lower" | grep -qiE 'literature|paper|note|canvas' && matched="$skill"
            ;;
        zotero-obsidian-bridge)
            echo "$prompt_lower" | grep -qiE 'zotero|collection|paper|import' && matched="$skill"
            ;;
        publication-chart-skill)
            echo "$prompt_lower" | grep -qiE 'figure|chart|table|plot|pubfig' && matched="$skill"
            ;;
        expression-skill)
            echo "$prompt_lower" | grep -qiE 'expression|communication|style|wording' && matched="$skill"
            ;;
        writing-anti-ai)
            echo "$prompt_lower" | grep -qiE 'anti-ai|natural|rewrite|humanize' && matched="$skill"
            ;;
        paper-self-review)
            echo "$prompt_lower" | grep -qiE 'self-review|review|checklist|quality' && matched="$skill"
            ;;
        review-response)
            echo "$prompt_lower" | grep -qiE 'response|rebuttal|reviewer' && matched="$skill"
            ;;
        post-acceptance)
            echo "$prompt_lower" | grep -qiE 'poster|presentation|promotion' && matched="$skill"
            ;;
        skill-development)
            echo "$prompt_lower" | grep -qiE 'skill|create|develop' && matched="$skill"
            ;;
        mcp-integration)
            echo "$prompt_lower" | grep -qiE 'mcp|server|integration' && matched="$skill"
            ;;
        hook-development)
            echo "$prompt_lower" | grep -qiE 'hook|event|trigger' && matched="$skill"
            ;;
        command-development)
            echo "$prompt_lower" | grep -qiE 'command|slash' && matched="$skill"
            ;;
        plugin-structure)
            echo "$prompt_lower" | grep -qiE 'plugin|structure' && matched="$skill"
            ;;
        *)
            # Fallback: match skill name itself
            if echo "$prompt_lower" | grep -qi "$skill"; then
                matched="$skill"
            fi
            ;;
    esac

    echo "$matched"
}

# Build matched skills list
matched_skills=""
prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

for skill in $all_skills; do
    result=$(match_skill "$skill" "$prompt_lower")
    if [ -n "$result" ]; then
        if ! echo "$matched_skills" | grep -qw "$result"; then
            matched_skills="$matched_skills $result"
        fi
    fi
done

# Build output
output=""
output+="\n\n[Skill Evaluation]\n"
output+="Before responding, evaluate whether any loaded Skill is relevant to this request.\n"
output+="If a Skill matches, read its SKILL.md and follow its guidance.\n"
output+="If multiple Skills match, evaluate them in parallel where possible.\n"

if [ -n "$matched_skills" ]; then
    output+="\n🎯 Potentially relevant skills (based on your request):\n"
    for skill in $matched_skills; do
        output+="  - $skill\n"
    done
fi

output+="\n📚 All available skills:\n"
output+="  $all_skills\n"

echo -e "$output"
exit 0