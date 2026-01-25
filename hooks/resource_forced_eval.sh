#!/usr/bin/env bash
set -euo pipefail

# Hook triggered on UserPromptSubmit event
# 为 LLM 提供可用的 plugins、skills、agents 资源信息

# 检查 jq 是否可用
if ! command -v jq >/dev/null 2>&1; then
    # jq 不可用，跳过资源评估
    echo '{"continue": true}'
    exit 0
fi

# 加载跨平台兼容函数
SCRIPT_DIR="$(dirname "$0")"
if [ -f "$SCRIPT_DIR/lib/platform.sh" ]; then
    source "$SCRIPT_DIR/lib/platform.sh"
fi

# Read JSON from stdin and extract user_prompt
input=$(cat)
user_prompt=$(echo "$input" | jq -r '.user_prompt // ""')

# Check if the input is a slash command (escape hatch)
if [[ "$user_prompt" =~ ^/ ]]; then
    # Skip resource evaluation for slash commands
    exit 0
fi

# ========== 资源收集函数 ==========

# 收集本地 Skills
collect_local_skills() {
    local tmp_file=$(mktemp_file "claude-local-skills")
    local skills_dir="$HOME/.claude/skills"

    if [ -d "$skills_dir" ]; then
        for skill_dir in "$skills_dir"/*/; do
            if [ -d "$skill_dir" ]; then
                local skill_name=$(basename "$skill_dir")
                # 尝试读取 skill.md 的第一行描述
                local skill_file="$skill_dir/skill.md"
                local description=""
                if [ -f "$skill_file" ]; then
                    description=$(head -3 "$skill_file" 2>/dev/null | grep -i "description" | sed 's/description:*//i' | xargs || echo "")
                fi
                if [ -n "$description" ]; then
                    echo "$skill_name - $description" >> "$tmp_file"
                else
                    echo "$skill_name" >> "$tmp_file"
                fi
            fi
        done
    fi

    cat "$tmp_file" 2>/dev/null
    rm -f "$tmp_file"
}

# 收集插件 Skills（传统结构：plugins/*/skills/）
collect_plugin_skills() {
    local tmp_file=$(mktemp_file "claude-plugin-skills")

    local plugins_cache="$HOME/.claude/plugins/cache"
    if [ -d "$plugins_cache" ]; then
        # 遍历所有 marketplace
        for marketplace_dir in "$plugins_cache"/*/; do
            if [ -d "$marketplace_dir" ]; then
                # 跳过 ai-research-skills（单独处理）
                local marketplace_name=$(basename "$marketplace_dir")
                if [ "$marketplace_name" = "ai-research-skills" ]; then
                    continue
                fi

                # 遍历每个插件
                for plugin_dir in "$marketplace_dir"/*/; do
                    if [ -d "$plugin_dir" ]; then
                        local plugin_name=$(basename "$plugin_dir")
                        # 跳过非插件目录
                        case "$plugin_name" in .*) continue;; esac

                        # 找到最新版本的插件目录
                        local latest_version=$(ls -t "$plugin_dir" 2>/dev/null | head -1)
                        if [ -n "$latest_version" ]; then
                            local plugin_root="$plugin_dir/$latest_version"

                            # 收集 Skills
                            local skills_dir="$plugin_root/skills"
                            if [ -d "$skills_dir" ]; then
                                for skill_dir in "$skills_dir"/*/; do
                                    if [ -d "$skill_dir" ]; then
                                        local skill_name=$(basename "$skill_dir")
                                        echo "$plugin_name:$skill_name" >> "$tmp_file"
                                    fi
                                done
                            fi
                        fi
                    fi
                done
            fi
        done
    fi

    cat "$tmp_file" 2>/dev/null
    rm -f "$tmp_file"
}

# 收集 AI Research Skills 插件（无 skills 子目录结构）
collect_ai_research_plugins() {
    local tmp_file=$(mktemp_file "claude-ai-research")
    local ai_marketplace="$HOME/.claude/plugins/cache/ai-research-skills"

    if [ -d "$ai_marketplace" ]; then
        for plugin_dir in "$ai_marketplace"/*/; do
            if [ -d "$plugin_dir" ]; then
                local plugin_name=$(basename "$plugin_dir")
                case "$plugin_name" in .*) continue;; esac
                echo "$plugin_name" >> "$tmp_file"
            fi
        done
    fi

    cat "$tmp_file" 2>/dev/null
    rm -f "$tmp_file"
}

# 收集插件 Commands（传统结构：plugins/*/commands/）
collect_plugin_commands() {
    local tmp_file=$(mktemp_file "claude-plugin-commands")

    local plugins_cache="$HOME/.claude/plugins/cache"
    if [ -d "$plugins_cache" ]; then
        # 遍历所有 marketplace
        for marketplace_dir in "$plugins_cache"/*/; do
            if [ -d "$marketplace_dir" ]; then
                # 跳过 ai-research-skills
                local marketplace_name=$(basename "$marketplace_dir")
                if [ "$marketplace_name" = "ai-research-skills" ]; then
                    continue
                fi

                # 遍历每个插件
                for plugin_dir in "$marketplace_dir"/*/; do
                    if [ -d "$plugin_dir" ]; then
                        local plugin_name=$(basename "$plugin_dir")
                        case "$plugin_name" in .*) continue;; esac

                        # 找到最新版本的插件目录
                        local latest_version=$(ls -t "$plugin_dir" 2>/dev/null | head -1)
                        if [ -n "$latest_version" ]; then
                            local plugin_root="$plugin_dir/$latest_version"

                            # 收集 Commands
                            local commands_dir="$plugin_root/commands"
                            if [ -d "$commands_dir" ]; then
                                for command_file in "$commands_dir"/*.md; do
                                    if [ -f "$command_file" ]; then
                                        local command_name=$(basename "$command_file" .md)
                                        echo "$plugin_name:$command_name" >> "$tmp_file"
                                    fi
                                done
                            fi
                        fi
                    fi
                done
            fi
        done
    fi

    cat "$tmp_file" 2>/dev/null
    rm -f "$tmp_file"
}

# ========== 主逻辑 ==========

# 收集资源
LOCAL_SKILLS=$(collect_local_skills)
PLUGIN_SKILLS=$(collect_plugin_skills)
PLUGIN_COMMANDS=$(collect_plugin_commands)
AI_RESEARCH_PLUGINS=$(collect_ai_research_plugins)

# 格式化输出
format_list() {
    local list="$1"
    if [ -z "$list" ]; then
        echo "（无）"
    else
        echo "$list" | tr '|' '\n' | sed 's/^/- /'
    fi
}

format_simple_list() {
    local list="$1"
    if [ -z "$list" ]; then
        echo "（无）"
    else
        while IFS= read -r item; do
            echo "- $item"
        done <<< "$list"
    fi
}

# 生成输出
cat <<EOF
## 指令：资源可用性检查

你当前环境中有以下可用的资源，可以帮助你完成任务：

### 📚 本地 Skills (～/.claude/skills/)
$(format_simple_list "$LOCAL_SKILLS")

### 🔌 插件 Skills (plugins/*/skills/)
$(format_simple_list "$PLUGIN_SKILLS")

### 🔧 插件 Commands (plugins/*/commands/)
$(format_simple_list "$PLUGIN_COMMANDS")

### 🧠 AI Research Skills (ai-research-skills)
$(format_simple_list "$AI_RESEARCH_PLUGINS")

---

**使用指南**：
- 对于本地 skills，直接使用技能名称（如：agent-identifier）
- 对于插件资源，使用完整路径（如：document-skills:pdf）
- Commands 可用 /plugin-name:command-name 方式调用
- AI Research Skills 可作为知识库参考，包含模型架构、微调、数据处理等主题
EOF

# 成功退出
exit 0
