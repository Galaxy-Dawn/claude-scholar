#!/usr/bin/env node
/**
 * Stop Hook: 显示基础状态 + AI 总结提示（跨平台版本）
 *
 * 事件: Stop
 * 功能: 在会话停止时显示 Git 状态、变更统计和临时文件
 */

const common = require('./hook-common');

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
const reason = input.reason || 'task_complete';

// 构建消息
function buildMessage() {
  let msg = '\n---\n';
  msg += '✅ 会话结束\n\n';

  // Git 信息
  const gitInfo = common.getGitInfo(cwd);

  if (gitInfo.is_repo) {
    msg += '📁 Git 仓库\n';
    msg += `  分支: ${gitInfo.branch}\n`;

    if (gitInfo.has_changes) {
      const changesDetails = common.getChangesDetails(cwd);
      const total = changesDetails.added + changesDetails.modified + changesDetails.deleted;

      msg += `  变更: ${total} 个文件`;
      if (changesDetails.added > 0) msg += ` (+${changesDetails.added})`;
      if (changesDetails.modified > 0) msg += ` (~${changesDetails.modified})`;
      if (changesDetails.deleted > 0) msg += ` (-${changesDetails.deleted})`;
      msg += '\n';
    } else {
      msg += '  状态: 干净\n';
    }
  } else {
    msg += '📁 非Git 仓库目录\n';
  }

  msg += '\n';

  // 临时文件检测
  const tempInfo = common.detectTempFiles(cwd);

  if (tempInfo.count > 0) {
    msg += `🧹 临时文件: ${tempInfo.count} 个\n`;
    for (const file of tempInfo.files) {
      msg += `  • ${file}\n`;
    }
  } else {
    msg += '✅ 无临时文件\n';
  }

  msg += '---';

  return msg;
}

// 构建并返回
const systemMessage = buildMessage();

const result = {
  continue: true,
  systemMessage: systemMessage
};

console.log(JSON.stringify(result));

process.exit(0);
