#!/bin/bash
#
# Shell 脚本调试流程示例
# 展示常见的 Bash 脚本错误和调试方法
#

# ============================================
# 调试设置
# ============================================

# 取消注释以启用调试模式
# set -x   # 打印每个命令
# set -e   # 错误时退出
# set -u   # 未定义变量报错
# set -o pipefail  # 管道中任何命令失败则失败

# 或组合使用
# set -xeuo pipefail  # 严格模式


# ============================================
# 错误处理函数
# ============================================

# 错误退出函数
die() {
    local message="$1"
    local exit_code="${2:-1}"
    echo "Error: $message" >&2
    exit "$exit_code"
}

# 记录函数
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >&2
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }


# ============================================
# 问题 1：未引用的变量
# ============================================

# 错误示例：变量未引用
demo_unquoted_variable() {
    echo "=== 问题 1：未引用的变量 ==="
    
    local name="John Doe"
    
    # 错误：变量未引用，空值会导致语法错误
    # if [ $name = "John Doe" ]; then
    #     echo "Match"
    # fi
    
    # 正确：始终引用变量
    if [ "$name" = "John Doe" ]; then
        log_info "变量匹配: $name"
    fi
}


# ============================================
# 问题 2：命令失败继续执行
# ============================================

demo_command_failure() {
    echo "=== 问题 2：命令失败继续执行 ==="
    
    # 错误：cd 失败后继续执行
    # cd /nonexistent_directory
    # rm -rf file.txt  # 会删除当前目录的文件！
    
    # 正确：检查命令是否成功
    cd /tmp || die "无法切换到 /tmp 目录"
    log_info "成功切换到目录: $(pwd)"
    
    cd - > /dev/null || true
}


# ============================================
# 问题 3：循环中的变量作用域（管道问题）
# ============================================

demo_pipeline_scope() {
    echo "=== 问题 3：管道中的变量作用域 ==="
    
    local count=0
    
    # 错误：管道创建子 shell，外部变量不改变
    # echo -e "1\n2\n3" | while read line; do
    #     count=$((count + 1))
    # done
    # echo "Count: $count"  # 输出 0
    
    # 正确：使用重定向
    while read line; do
        count=$((count + 1))
    done < <(echo -e "1\n2\n3")
    log_info "计数结果: $count"
}


# ============================================
# 问题 4：数组操作
# ============================================

demo_array_operations() {
    echo "=== 问题 4：数组操作 ==="
    
    local fruits=("apple" "banana" "cherry")
    
    # 错误的数组访问
    # echo $fruits[1]  # 输出 apple[1]
    
    # 正确的数组访问
    log_info "第一个元素: ${fruits[0]}"
    log_info "第二个元素: ${fruits[1]}"
    log_info "所有元素: ${fruits[@]}"
    log_info "数组长度: ${#fruits[@]}"
    
    # 遍历数组
    for fruit in "${fruits[@]}"; do
        log_info "水果: $fruit"
    done
}


# ============================================
# 问题 5：字符串比较
# ============================================

demo_string_comparison() {
    echo "=== 问题 5：字符串比较 ==="
    
    local name="John"
    
    # 错误：数字比较使用 =
    # if [ $age = 18 ]; then
    
    # 正确：字符串比较
    if [[ "$name" == "John" ]]; then
        log_info "字符串匹配"
    fi
    
    # 正确：数字比较
    local age=18
    if [ "$age" -eq 18 ]; then
        log_info "数字匹配"
    fi
}


# ============================================
# 问题 6：算术运算
# ============================================

demo_arithmetic() {
    echo "=== 问题 6：算术运算 ==="
    
    local a=10
    local b=5
    
    # 错误：使用 let 或 $(())
    # result = a + b  # 这是命令调用
    
    # 正确的算术运算
    local result=$((a + b))
    log_info "加法: $a + $b = $result"
    
    result=$((a - b))
    log_info "减法: $a - $b = $result"
    
    result=$((a * b))
    log_info "乘法: $a * $b = $result"
    
    result=$((a / b))
    log_info "除法: $a / $b = $result"
    
    # 使用 let
    let result=a+b
    log_info "let 加法: $result"
}


# ============================================
# 参数验证
# ============================================

validate_arguments() {
    echo "=== 参数验证 ==="
    
    # 检查参数数量
    if [ $# -lt 2 ]; then
        die "用法: $0 <文件> <目录>" 2
    fi
    
    local file="$1"
    local dir="$2"
    
    # 检查文件存在
    if [ ! -f "$file" ]; then
        die "文件不存在: $file" 3
    fi
    
    # 检查目录存在
    if [ ! -d "$dir" ]; then
        die "目录不存在: $dir" 4
    fi
    
    log_info "参数验证通过"
    log_info "文件: $file"
    log_info "目录: $dir"
}


# ============================================
# 使用 trap 进行清理
# ============================================

demo_trap() {
    echo "=== 使用 trap 进行清理 ==="
    
    # 设置清理函数
    cleanup() {
        log_info "执行清理操作..."
        # 这里可以执行清理操作
    }
    
    # 捕获退出信号
    trap cleanup EXIT
    
    # 捕获错误信号
    trap 'log_error "发生错误，行号: $LINENO"' ERR
    
    # 捕获中断信号
    trap 'log_warn "脚本被中断"; cleanup; exit 130' INT
    
    log_info "执行一些操作..."
    # 模拟操作
    sleep 1
}


# ============================================
# 调试技巧示例
# ============================================

demo_debugging() {
    echo "=== 调试技巧 ==="
    
    # 1. 使用 echo 调试
    local value="test"
    echo "[DEBUG] value = $value" >&2
    
    # 2. 使用 printf 格式化输出
    printf "[DEBUG] Count: %d, Name: %s\n" 42 "John" >&2
    
    # 3. 检查变量是否设置
    if [ -z "${unset_var+x}" ]; then
        log_warn "变量 unset_var 未设置"
    fi
    
    # 4. 显示调用栈
    log_info "调用栈:"
    local i=0
    while caller $i; do
        ((i++))
    done 2>/dev/null || true
}


# ============================================
# 文件操作错误处理
# ============================================

demo_file_operations() {
    echo "=== 文件操作错误处理 ==="
    
    local tmpfile=$(mktemp) || die "无法创建临时文件"
    
    # 确保文件被删除
    trap "rm -f '$tmpfile'" EXIT
    
    # 写入文件
    echo "Test content" > "$tmpfile" || die "无法写入文件: $tmpfile"
    
    # 读取文件
    local content
    content=$(cat "$tmpfile") || die "无法读取文件: $tmpfile"
    
    log_info "文件内容: $content"
    
    # trap 会自动清理
}


# ============================================
# 带重试的操作
# ============================================

demo_retry() {
    echo "=== 带重试的操作 ==="
    
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "尝试 $attempt/$max_attempts..."
        
        # 模拟可能失败的操作
        if [ $attempt -eq 2 ]; then
            log_info "成功！"
            return 0
        fi
        
        log_warn "失败，重试..."
        ((attempt++))
        sleep 1
    done
    
    log_error "所有尝试都失败了"
    return 1
}


# ============================================
# 检查依赖
# ============================================

check_dependencies() {
    echo "=== 检查依赖 ==="
    
    local required_commands=("curl" "jq" "git")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "缺少依赖: $cmd"
            return 1
        fi
        log_info "✓ $cmd 可用"
    done
    
    log_info "所有依赖都已满足"
}


# ============================================
# 主函数
# ============================================

main() {
    echo "============================================"
    echo "Shell 脚本调试示例"
    echo "============================================"
    
    # 运行各个示例
    demo_unquoted_variable
    echo ""
    
    demo_command_failure
    echo ""
    
    demo_pipeline_scope
    echo ""
    
    demo_array_operations
    echo ""
    
    demo_string_comparison
    echo ""
    
    demo_arithmetic
    echo ""
    
    demo_trap
    echo ""
    
    demo_debugging
    echo ""
    
    demo_file_operations
    echo ""
    
    demo_retry
    echo ""
    
    check_dependencies
    echo ""
    
    log_info "所有示例执行完成"
}

# 运行主函数
main "$@"
