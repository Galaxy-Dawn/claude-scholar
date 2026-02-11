#!/usr/bin/env node
/**
 * PreToolUse Hook: Security guard layer (cross-platform version)
 *
 * Event: PreToolUse
 * Function: Detect dangerous commands and sensitive file operations, provide security protection
 */

const path = require('path');

// Read stdin input
let input = {};
try {
  const stdinData = require('fs').readFileSync(0, 'utf8');
  if (stdinData.trim()) {
    input = JSON.parse(stdinData);
  }
} catch {
  // Use default empty object
}

const toolName = input.tool_name || '';
const cwd = input.cwd || process.cwd();

let decision = 'allow';
let reason = '';
let systemMessage = '';

// === Bash command security check ===
if (toolName === 'Bash') {
  const command = input.tool_input?.command || '';

  // Dangerous command blacklist detection
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

  // Warning pattern detection
  function checkWarning(cmd) {
    const warningPatterns = [
      { pattern: /rm\s+-[rf]/, label: 'rm -' },
      { pattern: /\bmv\s/, label: 'mv' },
      { pattern: /\bcp\s/, label: 'cp' },
      { pattern: /chmod\s+777/, label: 'chmod 777' },
      { pattern: /chown\s/, label: 'chown' },
      { pattern: /(wget|curl)\s/, label: 'Network download' },
      { pattern: /(pip|npm|yarn|bun|brew|apt-get|yum)\s+install/, label: 'Software install' },
      { pattern: /sudo\s+(apt-get|yum)/, label: 'sudo install' }
    ];

    for (const { pattern, label } of warningPatterns) {
      if (pattern.test(cmd)) {
        return label;
      }
    }

    return null;
  }

  // Check dangerous commands
  if (isDangerous(command)) {
    decision = 'deny';
    reason = 'Dangerous command detected';
  }

  // Warning level check
  if (decision === 'allow') {
    const warningPattern = checkWarning(command);
    if (warningPattern) {
      systemMessage = `⚠️ Security notice: Executing sensitive operation (${warningPattern})`;
    }
  }

// === File write security check ===
} else if (toolName === 'Write' || toolName === 'Edit') {
  const filePath = input.tool_input?.file_path || '';

  // Sensitive path blacklist
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
      reason = `Writing to system path denied: ${sensitivePath}`;
      break;
    }
  }

  // Check sensitive files
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
        systemMessage = `⚠️ Security notice: Modifying sensitive file (${sensitiveFile})`;
        break;
      }
    }
  }

  // Check path traversal attack
  if (filePath.includes('..')) {
    decision = 'deny';
    reason = 'Path traversal attack detected';
  }

  // Check absolute path injection
  if (filePath.includes('~/') && !filePath.startsWith(cwd)) {
    systemMessage = '⚠️ Path notice: File path is outside project directory';
  }
}

// === Build output ===
if (decision === 'deny') {
  // Block execution
  const errorOutput = {
    hookSpecificOutput: {
      permissionDecision: 'deny'
    },
    systemMessage: `🛑 Security blocked: ${reason}\n\nTo perform this operation, run it manually in the terminal.`
  };

  console.error(JSON.stringify(errorOutput));
  process.exit(2);
} else {
  // Allow execution (with optional warning message)
  const result = {
    continue: true
  };

  if (systemMessage) {
    result.systemMessage = systemMessage;
  }

  console.log(JSON.stringify(result));
  process.exit(0);
}
