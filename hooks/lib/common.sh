#!/usr/bin/env bash
# 共享函数库 - 供其他 hooks 使用

# 获取 Git 状态信息
# 返回: JSON 格式的 Git 信息
get_git_info() {
  local cwd="$1"

  if ! git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    echo '{"is_repo":false}'
    return
  fi

  local branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "unknown")
  local changes=$(git -C "$cwd" status --porcelain 2>/dev/null || true)
  local count=$(echo "$changes" | wc -l | tr -d ' ')

  echo "{\"is_repo\":true,\"branch\":\"$branch\",\"changes_count\":\"$count\",\"has_changes\":$([ -n "$changes" ] && echo "true" || echo "false")}"
}

# 获取待办事项
# 参数: $1 - 项目目录
# 返回: JSON 格式的待办信息
get_todo_info() {
  local cwd="$1"
  local todo_files=(
    "$cwd/docs/todo.md"
    "$cwd/TODO.md"
    "$cwd/.claude/todos.md"
    "$cwd/TODO"
    "$cwd/notes/todo.md"
  )

  for file in "${todo_files[@]}"; do
    if [ -f "$file" ]; then
      local total=$(grep -c '^- \[[ x]\]' "$file" 2>/dev/null || echo "0")
      local done=$(grep -c '^- \[x\]' "$file" 2>/dev/null || echo "0")
      local pending=$((total - done))
      local found_file=$(basename "$file")

      echo "{\"found\":true,\"file\":\"$found_file\",\"total\":\"$total\",\"done\":\"$done\",\"pending\":\"$pending\"}"
      return
    fi
  done

  echo '{"found":false}'
}

# 获取 Git 变更详情
# 参数: $1 - 项目目录
# 返回: 变更统计 JSON
get_changes_details() {
  local cwd="$1"

  if ! git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    echo '{"added":0,"modified":0,"deleted":0}'
    return
  fi

  local added=$(git -C "$cwd" diff --name-only --diff-filter=A 2>/dev/null | wc -l | tr -d ' ')
  local modified=$(git -C "$cwd" diff --name-only --diff-filter=M 2>/dev/null | wc -l | tr -d ' ')
  local deleted=$(git -C "$cwd" diff --name-only --diff-filter=D 2>/dev/null | wc -l | tr -d ' ')

  echo "{\"added\":\"$added\",\"modified\":\"$modified\",\"deleted\":\"$deleted\"}"
}

# 按文件类型分析变更
# 参数: $1 - 项目目录
# 返回: 文件类型统计 JSON
analyze_changes_by_type() {
  local cwd="$1"
  local changes=""

  if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    changes=$(git -C "$cwd" status --porcelain 2>/dev/null || true)
  fi

  if [ -z "$changes" ]; then
    echo '{"test_files":0,"docs_files":0,"sql_files":0,"config_files":0,"service_files":0}'
    return
  fi

  local test_files=$(echo "$changes" | grep -i "test" | wc -l | tr -d ' ')
  local docs_files=$(echo "$changes" | grep -E "\.(md|txt|rst)$" | wc -l | tr -d ' ')
  local sql_files=$(echo "$changes" | grep -E "\.sql$" | wc -l | tr -d ' ')
  local config_files=$(echo "$changes" | grep -E "\.(json|yaml|yml|toml|ini|conf)$" | wc -l | tr -d ' ')
  local service_files=$(echo "$changes" | grep -iE "(service|controller)" | wc -l | tr -d ' ')

  echo "{\"test_files\":\"$test_files\",\"docs_files\":\"$docs_files\",\"sql_files\":\"$sql_files\",\"config_files\":\"$config_files\",\"service_files\":\"$service_files\"}"
}

# 检测临时文件
# 参数: $1 - 项目目录
# 返回: 临时文件列表 JSON
detect_temp_files() {
  local cwd="$1"
  local temp_files=()

  # Git 未跟踪的临时文件（按模式匹配）
  if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    while IFS= read -r file; do
      [ -n "$file" ] && temp_files+=("$file")
    done < <(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | grep -E "(plan|draft|tmp|temp|scratch)" || true)
  fi

  # 已知临时目录
  for dir in "plan" "docs/plans" ".claude/temp" "tmp" "temp"; do
    if [ -d "$cwd/$dir" ]; then
      while IFS= read -r file; do
        [ -n "$file" ] && temp_files+=("$file")
      done < <(find "$cwd/$dir" -type f 2>/dev/null || true)
    fi
  done

  # 构建 JSON 数组
  if [ ${#temp_files[@]} -eq 0 ]; then
    echo '{"files":[],"count":0}'
    return
  fi

  local json="{\"files\":["
  local first=true
  for file in "${temp_files[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      json+=","
    fi
    # 获取相对路径
    local rel_path="${file#$cwd/}"
    json+="\"$rel_path\""
  done
  json+="],\"count\":${#temp_files[@]}}"
  echo "$json"
}

# 生成智能推荐
# 参数: $1 - 项目目录, $2 - 变更详情 JSON, $3 - 类型分析 JSON, $4 - is_repo, $5 - has_changes
# 返回: 推荐列表（每行一个）
generate_recommendations() {
  local cwd="$1"
  local changes_details="$2"
  local type_analysis="$3"
  local is_repo="$4"
  local has_changes="$5"

  local recommendations=()

  # Git 仓库且有变更时的建议
  if [ "$is_repo" = "true" ] && [ "$has_changes" = "true" ]; then
    # Git 提交建议
    local added=$(echo "$changes_details" | jq -r '.added')
    local modified=$(echo "$changes_details" | jq -r '.modified')

    if [ "$added" != "0" ] || [ "$modified" != "0" ]; then
      recommendations+=("git add . && git commit -m \"feat: xxx\"")
    fi

    # 按类型推荐
    local test_files=$(echo "$type_analysis" | jq -r '.test_files')
    local docs_files=$(echo "$type_analysis" | jq -r '.docs_files')
    local sql_files=$(echo "$type_analysis" | jq -r '.sql_files')
    local config_files=$(echo "$type_analysis" | jq -r '.config_files')
    local service_files=$(echo "$type_analysis" | jq -r '.service_files')

    [ "$test_files" != "0" ] && recommendations+=("运行测试套件验证修改")
    [ "$docs_files" != "0" ] && recommendations+=("检查文档与代码同步")
    [ "$sql_files" != "0" ] && recommendations+=("更新所有相关数据库脚本")
    [ "$config_files" != "0" ] && recommendations+=("检查是否需要更新环境变量")
    [ "$service_files" != "0" ] && recommendations+=("更新 API 文档")
  fi

  # 通用建议（无论是否在 git 仓库）
  # 检查是否有待办事项文件
  local todo_info=$(get_todo_info "$cwd")
  local todo_found=$(echo "$todo_info" | jq -r '.found')
  if [ "$todo_found" = "true" ]; then
    local todo_pending=$(echo "$todo_info" | jq -r '.pending')
    local todo_file=$(echo "$todo_info" | jq -r '.file')
    if [ "$todo_pending" != "0" ]; then
      recommendations+=("查看待办事项: $todo_file (还有 $todo_pending 项未完成)")
    fi
  fi

  # 检查是否有最近修改的文件（可能需要备份）
  if [ "$is_repo" = "false" ]; then
    # 非仓库环境，提醒备份重要文件
    recommendations+=("记得备份重要文件到 git 仓库或云存储")
  fi

  # 输出推荐列表
  if [ ${#recommendations[@]} -eq 0 ]; then
    echo ""  # 返回空而不是"无特别建议"
  else
    printf '%s\n' "${recommendations[@]}"
  fi
}
