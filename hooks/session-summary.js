#!/usr/bin/env node
/**
 * SessionEnd Hook: 工作日志 + 智能建议（跨平台版本）
 *
 * 事件: SessionEnd
 * 功能: 创建工作日志，记录变更并生成智能建议
 */

const path = require('path');
const fs = require('fs');
const os = require('os');
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
const sessionId = input.session_id || 'unknown';
const transcriptPath = input.transcript_path || '';

// 创建工作日志目录
const logDir = path.join(cwd, '.claude', 'logs');
fs.mkdirSync(logDir, { recursive: true });

// 生成日志文件名
const now = new Date();
const dateStr = now.toISOString().split('T')[0].replace(/-/g, '');
const logFile = path.join(logDir, `session-${dateStr}-${sessionId.substring(0, 8)}.md`);

// 获取项目信息
const projectName = path.basename(cwd);

// 构建日志内容
let logContent = '';

logContent += `# 📝 工作日志 - ${projectName}\n`;
logContent += `\n`;
logContent += `**会话 ID**: ${sessionId}\n`;
logContent += `**时间**: ${common.formatDateTime(now)}\n`;
logContent += `**目录**: ${cwd}\n`;
logContent += `\n`;

// Git 变更统计
logContent += `## 📊 本次会话变更\n`;
const gitInfo = common.getGitInfo(cwd);
const changesDetails = gitInfo.is_repo ? common.getChangesDetails(cwd) : { added: 0, modified: 0, deleted: 0 };

if (gitInfo.is_repo) {
  logContent += `**分支**: ${gitInfo.branch}\n`;
  logContent += `\n`;
  logContent += '```\n';

  if (gitInfo.has_changes) {
    for (const change of gitInfo.changes) {
      logContent += `${change}\n`;
    }
  } else {
    logContent += '无变更\n';
  }

  logContent += '```\n';

  // 变更统计
  logContent += `\n`;
  logContent += '| 类型 | 数量 |\n';
  logContent += '|------|------|\n';
  logContent += `| 新增 | ${changesDetails.added} |\n`;
  logContent += `| 修改 | ${changesDetails.modified} |\n`;
  logContent += `| 删除 | ${changesDetails.deleted} |\n`;
} else {
  logContent += '非 Git 仓库\n';
}

logContent += `\n`;

// 智能建议
if (gitInfo.has_changes) {
  logContent += `## 💡 建议操作\n`;
  logContent += `\n`;

  const typeAnalysis = common.analyzeChangesByType(cwd);

  if (changesDetails.modified > 0 || changesDetails.added > 0) {
    logContent += '- 使用代码审查工具检查修改\n';
  }
  if (typeAnalysis.test_files > 0) {
    logContent += '- 有测试文件变更，记得运行测试套件\n';
  }
  if (typeAnalysis.docs_files > 0) {
    logContent += '- 文档已更新，确保与代码同步\n';
  }
  if (typeAnalysis.sql_files > 0) {
    logContent += '- SQL 文件有变更，确保更新所有数据库脚本\n';
  }
  if (typeAnalysis.service_files > 0) {
    logContent += '- 新增了 Service/Controller，记得更新 API 文档\n';
  }
  if (typeAnalysis.config_files > 0) {
    logContent += '- 配置文件已修改，检查是否需要更新环境变量\n';
  }

  logContent += `\n`;
}

// 读取 transcript 提取关键操作（如果可用）
if (transcriptPath && fs.existsSync(transcriptPath)) {
  try {
    const transcript = fs.readFileSync(transcriptPath, 'utf8');
    const toolMatches = transcript.match(/Tool used: [A-Z][a-z]*/g) || [];

    if (toolMatches.length > 0) {
      // 统计工具使用次数
      const toolCounts = {};
      for (const match of toolMatches) {
        const tool = match.replace('Tool used: ', '');
        toolCounts[tool] = (toolCounts[tool] || 0) + 1;
      }

      // 排序并取前 10
      const sortedTools = Object.entries(toolCounts)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10);

      if (sortedTools.length > 0) {
        logContent += `## 🔧 主要操作\n`;
        logContent += `\n`;

        for (const [tool, count] of sortedTools) {
          logContent += `| ${tool} | ${count} 次 |\n`;
        }

        logContent += `\n`;
      }
    }
  } catch {
    // 忽略错误
  }
}

// 下次继续建议
logContent += `## 🎯 下次继续\n`;
logContent += `\n`;

// Git 提交建议
if (gitInfo.has_changes) {
  logContent += '- ⚠️ 有未提交变更，建议先提交代码：\n';
  logContent += '  ```bash\n';
  logContent += '  git add . && git commit -m "feat: xxx"\n';
  logContent += '  ```\n';
} else {
  logContent += '- ✅ 工作区干净，可以开始新任务\n';
}

// 待办事项提醒
const todoInfo = common.getTodoInfo(cwd);
if (todoInfo.found) {
  logContent += `- 更新待办事项: ${todoInfo.file} (${todoInfo.pending} 个未完成)\n`;
}

logContent += '- 查看上下文快照: `cat .claude/session-context-*.md`\n';
logContent += `\n`;

// 写入日志文件
fs.writeFileSync(logFile, logContent, 'utf8');

// 构建显示给用户的消息
let displayMsg = '\n---\n';
displayMsg += '✅ **会话结束** | 工作日志已保存\n\n';
displayMsg += '**本次变更**: ';

if (gitInfo.is_repo) {
  if (gitInfo.has_changes) {
    displayMsg += `${gitInfo.changes_count} 个文件\n\n`;
    displayMsg += '**建议操作**:\n';
    displayMsg += `- 查看日志: cat .claude/logs/${path.basename(logFile)}\n`;
    displayMsg += '- 提交代码: git add . && git commit -m "feat: xxx"\n';
  } else {
    displayMsg += '无\n\n工作区干净 ✅\n';
  }
} else {
  displayMsg += '非 Git 仓库\n';
}

displayMsg += '\n---';

const result = {
  continue: true,
  systemMessage: displayMsg
};

console.log(JSON.stringify(result));

process.exit(0);
