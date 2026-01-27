#!/usr/bin/env bash
# platform.sh - 跨平台兼容性函数库
#
# 提供 macOS/Linux/Windows Git Bash 的跨平台兼容函数

# 跨平台获取文件修改时间（Unix 时间戳）
# 用法: stat_mtime <file>
# 返回: Unix 时间戳（秒）
stat_mtime() {
    local file="$1"

    # macOS/BSD stat
    if stat -f "%m" "$file" >/dev/null 2>&1; then
        stat -f "%m" "$file"
        return 0
    fi

    # Linux/GNU stat
    if stat -c "%Y" "$file" >/dev/null 2>&1; then
        stat -c "%Y" "$file"
        return 0
    fi

    # Windows Git Bash - 使用 date 命令
    if date -r "$file" +%s >/dev/null 2>&1; then
        date -r "$file" +%s
        return 0
    fi

    # 最后的后备方案
    echo "0"
    return 1
}

# 跨平台临时文件创建（mktemp 后备）
# 用法: mktemp_file [prefix]
# 返回: 临时文件路径
mktemp_file() {
    local prefix="${1:-tmp}"
    local tmpdir="${TMP:-/tmp}"

    # 尝试使用 mktemp
    if command -v mktemp >/dev/null 2>&1; then
        mktemp "${tmpdir}/${prefix}.XXXXXX"
        return 0
    fi

    # 后备方案：使用 $$ 和 RANDOM
    local random_suffix="${RANDOM:-$(date +%s%N)}"
    echo "${tmpdir}/${prefix}.$$.${random_suffix}"
    return 0
}

# 检测命令是否存在
# 用法: command_exists <command>
# 返回: 0=存在, 1=不存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}
