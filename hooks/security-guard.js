#!/usr/bin/env node
/**
 * PreToolUse Hook: 安全防护层（跨平台版本）
 *
 * 事件: PreToolUse
 * 功能: 检测危险命令和敏感文件操作，提供安全保护
 */

const path = require('path');

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

const toolName = input.tool_name || '';
const cwd = input.cwd || process.cwd();

let decision = 'allow';
let reason = '';
let systemMessage = '';

// === Bash 命令安全检查 ===
if (toolName === 'Bash') {
  const command = input.tool_input?.command || '';

  // 危险命令黑名单检测
  function isDangerous(cmd) {
    const dangerousPatterns = [
      /rm\s+-rf\s+\//,                    // rm -rf /
      /rm\s+--no-preserve-root\s+-rf/,   // rm --no-preserve-root -rf
      /dd\s+if=\/dev\/(zero|random)/,    // dd from /dev/zero or /dev/random
      />\s*\/dev\/sd/,                    // Write to disk devices
      />\s*\/dev\/nvme/,                  // Write to NVMe devices
      />\s*\/dev\/vda/,                   // Write to VDA devices
      /mkfs\./,                           // Format filesystem
      /format\s/,                         // Format command
      /DROP\s+(DATABASE|TABLE)/i,        // SQL DROP
      /DELETE\s+FROM/i,                   // SQL DELETE
      /TRUNCATE\s+TABLE/i,                // SQL TRUNCATE
      /rm\s+-rf?\s+\/(etc|usr|bin|sbin)/, // Remove system dirs
      /rm\s+-rf\s+\/home\//,              // Remove home dirs
      /rm\s+-rf\s+\/Users\//              // Remove macOS user dirs
    ];

    return dangerousPatterns.some(pattern => pattern.test(cmd));
  }

  // 警告模式检测
  function checkWarning(cmd) {
    const warningPatterns = [
      { pattern: /rm\s+-[rf]/, label: 'rm -' },
      { pattern: /\bmv\s/, label: 'mv' },
      { pattern: /\bcp\s/, label: 'cp' },
      { pattern: /chmod\s+777/, label: 'chmod 777' },
      { pattern: /chown\s/, label: 'chown' },
      { pattern: /(wget|curl)\s/, label: '网络下载' },
      { pattern: /(pip|npm|yarn|bun|brew|apt-get|yum)\s+install/, label: '软件安装' },
      { pattern: /sudo\s+(apt-get|yum)/, label: 'sudo 安装' }
    ];

    for (const { pattern, label } of warningPatterns) {
      if (pattern.test(cmd)) {
        return label;
      }
    }

    return null;
  }

  // 检查危险命令
  if (isDangerous(command)) {
    decision = 'deny';
    reason = '检测到危险命令';
  }

  // 警告级别检查
  if (decision === 'allow') {
    const warningPattern = checkWarning(command);
    if (warningPattern) {
      systemMessage = `⚠️ 安全提醒: 正在执行敏感操作 (${warningPattern})`;
    }
  }

// === 文件写入安全检查 ===
} else if (toolName === 'Write' || toolName === 'Edit') {
  const filePath = input.tool_input?.file_path || '';

  // 敏感路径黑名单
  const sensitivePaths = [
    '/etc/',
    '/usr/bin/',
    '/usr/sbin/',
    '/bin/',
    '/sbin/',
    '/System/',
    '/dev/',
    '/proc/',
    '/sys/'
  ];

  for (const sensitivePath of sensitivePaths) {
    if (filePath.startsWith(sensitivePath)) {
      decision = 'deny';
      reason = `禁止写入系统路径: ${sensitivePath}`;
      break;
    }
  }

  // 检查敏感文件
  const sensitiveFiles = [
    '.env',
    '.env.local',
    '.env.production',
    'credentials.json',
    'key.pem',
    'key.json',
    'id_rsa',
    '.aws/credentials',
    '.npmrc'
  ];

  if (decision === 'allow') {
    const fileName = path.basename(filePath);
    for (const sensitiveFile of sensitiveFiles) {
      if (fileName === sensitiveFile) {
        systemMessage = `⚠️ 安全提醒: 正在修改敏感文件 (${sensitiveFile})`;
        break;
      }
    }
  }

  // 检查路径遍历攻击
  if (filePath.includes('..')) {
    decision = 'deny';
    reason = '检测到路径遍历攻击';
  }

  // 检查绝对路径注入
  if (filePath.includes('~/') && !filePath.startsWith(cwd)) {
    systemMessage = '⚠️ 路径提醒: 文件路径不在项目目录内';
  }
}

// === 构建输出 ===
if (decision === 'deny') {
  // 阻止执行
  const errorOutput = {
    hookSpecificOutput: {
      permissionDecision: 'deny'
    },
    systemMessage: `🛑 安全拦截: ${reason}\n\n如需执行此操作，请手动在终端运行。`
  };

  console.error(JSON.stringify(errorOutput));
  process.exit(2);
} else {
  // 允许执行（可选警告消息）
  const result = {
    continue: true
  };

  if (systemMessage) {
    result.systemMessage = systemMessage;
  }

  console.log(JSON.stringify(result));
  process.exit(0);
}
