#!/usr/bin/env node
/**
 * SessionStart Hook: 显示项目状态（跨平台版本）
 *
 * 事件: SessionStart
 * 功能: 在会话开始时显示项目状态、Git信息、待办事项、插件和命令
 */

const path = require('path');
const os = require('os');
const fs = require('fs');

// 导入共享函数库
const common = require('./hook-common');

// 导入包管理器检测
const { getPackageManager, getSelectionPrompt } = require('../scripts/lib/package-manager');

// 读取 stdin 输入
let input = {};
try {
  const stdinData = require('fs').readFileSync(0, 'utf8');
  if (stdinData.trim()) {
    input = JSON.parse(stdinData);
  }
} catch {
  // 使用默认空对象
}

const cwd = input.cwd || process.cwd();
const projectName = path.basename(cwd);
const homeDir = os.homedir();

// 构建输出
let output = '';

// 会话启动信息
output += `🚀 ${projectName} 会话已启动\n`;
output += `▸ 时间: ${common.formatDateTime()}\n`;
output += `▸ 目录: ${cwd}\n\n`;

// Git 状态
const gitInfo = common.getGitInfo(cwd);

if (gitInfo.is_repo) {
  output += `▸ Git 分支: ${gitInfo.branch}\n\n`;

  if (gitInfo.has_changes) {
    output += `⚠️  未提交变更 (${gitInfo.changes_count} 个文件):\n`;

    // 显示变更列表（最多 10 个）
    const statusIcons = {
      'M': '📝',  // Modified
      'A': '➕',  // Added
      'D': '❌',  // Deleted
      'R': '🔄',  // Renamed
      '??': '❓'  // Untracked
    };

    for (let i = 0; i < Math.min(gitInfo.changes.length, 10); i++) {
      const change = gitInfo.changes[i];
      const status = change.substring(0, 2).trim();
      const file = change.substring(3).trim();

      const icon = statusIcons[status] || '•';
      output += `  ${icon} ${file}\n`;
    }

    if (gitInfo.changes_count > 10) {
      output += `  ... (还有 ${gitInfo.changes_count - 10} 个文件)\n`;
    }
  } else {
    output += `✅ 工作区干净\n`;
  }
  output += '\n';
} else {
  output += `▸ Git: 非仓库\n\n`;
}

// 包管理器检测
try {
  const pm = getPackageManager();
  output += `📦 包管理器: ${pm.name} (${pm.source})\n`;

  // 如果是通过 fallback 检测的，提示设置
  if (pm.source === 'fallback' || pm.source === 'default') {
    output += `💡 运行 /setup-pm 配置首选包管理器\n`;
  }
} catch (err) {
  // 包管理器检测失败，静默忽略
}

output += '\n';

// 待办事项
output += `📋 待办事项:\n`;
const todoInfo = common.getTodoInfo(cwd);

if (todoInfo.found) {
  output += `  - ${todoInfo.pending} 未完成 / ${todoInfo.done} 已完成\n`;

  // 显示前 5 个未完成事项
  if (fs.existsSync(todoInfo.path)) {
    try {
      const content = fs.readFileSync(todoInfo.path, 'utf8');
      const pendingItems = content.match(/^[\-\*] \[ \].+$/gm) || [];

      if (pendingItems.length > 0) {
        output += `\n  最近待办:\n`;
        for (let i = 0; i < Math.min(5, pendingItems.length); i++) {
          const item = pendingItems[i].replace(/^[\-\*] \[ \]\s*/, '').substring(0, 60);
          output += `  - ${item}\n`;
        }
      }
    } catch {
      // 忽略错误
    }
  }
} else {
  output += `  未找到待办事项文件 (TODO.md, docs/todo.md 等)\n`;
}

output += '\n';

// 已启用的插件
output += `🔌 已启用插件:\n`;
const enabledPlugins = common.getEnabledPlugins(homeDir);

if (enabledPlugins.length > 0) {
  for (const plugin of enabledPlugins) {
    output += `  - ${plugin.name}\n`;
  }
} else {
  output += `  无\n`;
}

output += '\n';

// 可用命令
output += `💡 可用命令:\n`;
const availableCommands = common.getAvailableCommands(homeDir);

if (availableCommands.length > 0) {
  for (const cmd of availableCommands.slice(0, 20)) {
    const description = common.getCommandDescription(cmd.path) || `${cmd.plugin} 命令`;
    const truncatedDesc = description.length > 40 ? description.substring(0, 40) + '...' : description;
    output += `  /${cmd.name.padEnd(20)} ${truncatedDesc}\n`;
  }

  if (availableCommands.length > 20) {
    output += `  ... (还有 ${availableCommands.length - 20} 个命令)\n`;
  }
} else {
  output += `  未找到可用命令\n`;
}

// 输出 JSON
const result = {
  continue: true,
  systemMessage: output
};

console.log(JSON.stringify(result));

process.exit(0);
