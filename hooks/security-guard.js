#!/usr/bin/env node
/**
 * PreToolUse Hook: Security guard layer (cross-platform version)
 *
 * Event: PreToolUse
 * Two-tier security: Block (exit 2) | Confirm (exit 0 + ask user)
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
let confirmLabel = '';

// === Bash command security check ===
if (toolName === 'Bash') {
  const command = input.tool_input?.command || '';

  // Tier 1: Block — catastrophic, no recovery
  const blockPatterns = [
    /rm\s+-rf\s+\/(\s|$)/,                       // rm -rf /
    /rm\s+--no-preserve-root/,                    // rm --no-preserve-root
    /dd\s+if=\/dev\/(zero|random)/,               // dd from /dev/zero or /dev/random
    />\s*\/dev\/(sd|nvme|vda)/,                   // Write to block devices
    /mkfs\./,                                      // Format filesystem
    /rm\s+-rf?\s+\/(etc|usr|bin|sbin)(\/|\s|$)/,  // Remove system dirs
    /rm\s+-rf\s+\/home\/[^\/\s]*\/?(\s|$)/,       // Remove user home dir
    /rm\s+-rf\s+\/Users\/[^\/\s]*\/?(\s|$)/,      // Remove macOS user dir
  ];

  for (const pattern of blockPatterns) {
    if (pattern.test(command)) {
      decision = 'deny';
      reason = 'Catastrophic command detected';
      break;
    }
  }

  // Tier 2: Confirm — dangerous but sometimes legitimate
  if (decision === 'allow') {
    const confirmPatterns = [
      { pattern: /git\s+push\s+.*(-f|--force)/, label: 'git push --force (overwrites remote history)' },
      { pattern: /git\s+reset\s+--hard/, label: 'git reset --hard (discards all uncommitted changes)' },
      { pattern: /git\s+clean\s+-[a-z]*f/, label: 'git clean -f (permanently deletes untracked files)' },
      { pattern: /git\s+(checkout|restore)\s+\./, label: 'git checkout/restore . (discards all working tree changes)' },
      { pattern: /rm\s+-[rf]/, label: 'rm -rf (recursive/force delete)' },
      { pattern: /chmod\s+(-R\s+)?777/, label: 'chmod 777 (world-writable permissions)' },
      { pattern: /npm\s+publish/, label: 'npm publish (publishes package to registry)' },
      { pattern: /pip\s+upload|twine\s+upload/, label: 'pip/twine upload (publishes package to PyPI)' },
      { pattern: /docker\s+system\s+prune/, label: 'docker system prune (removes all unused resources)' },
      { pattern: /DROP\s+(DATABASE|TABLE)/i, label: 'SQL DROP (destroys database/table)' },
      { pattern: /DELETE\s+FROM\s+(?!.*WHERE)/i, label: 'DELETE without WHERE (deletes all rows)' },
      { pattern: /UPDATE\s+\S+\s+SET\s+(?!.*WHERE)/i, label: 'UPDATE without WHERE (updates all rows)' },
      { pattern: /TRUNCATE\s+TABLE/i, label: 'SQL TRUNCATE (empties entire table)' },
    ];

    for (const { pattern, label } of confirmPatterns) {
      if (pattern.test(command)) {
        confirmLabel = label;
        break;
      }
    }
  }

// === File write security check ===
} else if (toolName === 'Write' || toolName === 'Edit') {
  const filePath = input.tool_input?.file_path || '';

  // Tier 1: Block — system paths
  const sensitivePaths = [
    '/etc/', '/usr/bin/', '/usr/sbin/',
    '/bin/', '/sbin/', '/System/',
    '/dev/', '/proc/', '/sys/'
  ];

  for (const sp of sensitivePaths) {
    if (filePath.startsWith(sp)) {
      decision = 'deny';
      reason = `Writing to system path denied: ${sp}`;
      break;
    }
  }

  // Block — path traversal
  if (decision === 'allow') {
    const homedir = require('os').homedir();
    const resolved = path.resolve(cwd, filePath);
    if (!resolved.startsWith(cwd) && !resolved.startsWith(homedir)) {
      decision = 'deny';
      reason = 'Path traversal attack detected: resolved path is outside allowed directories';
    }
  }

  // Tier 2: Confirm — sensitive files
  if (decision === 'allow') {
    const fileName = path.basename(filePath);

    if (fileName.startsWith('.env')) {
      confirmLabel = `.env file (${fileName})`;
    }

    if (!confirmLabel) {
      const sensitiveFiles = ['credentials.json', 'key.pem', 'key.json', 'id_rsa'];
      for (const sf of sensitiveFiles) {
        if (fileName === sf) {
          confirmLabel = `sensitive file (${sf})`;
          break;
        }
      }
    }

    if (!confirmLabel) {
      const sensitivePathPatterns = ['.aws/credentials', '.npmrc'];
      for (const sp of sensitivePathPatterns) {
        if (filePath.includes(sp)) {
          confirmLabel = `sensitive path (${sp})`;
          break;
        }
      }
    }
  }
}

// === Build output ===
if (decision === 'deny') {
  const errorOutput = {
    hookSpecificOutput: { permissionDecision: 'deny' },
    systemMessage: `🛑 Blocked: ${reason}\n\nTo perform this operation, run it manually in the terminal.`
  };
  console.error(JSON.stringify(errorOutput));
  process.exit(2);
} else {
  const result = { continue: true };

  if (confirmLabel) {
    result.systemMessage = `⚠️ CONFIRM REQUIRED: ${confirmLabel}\n\nYou MUST ask the user for explicit confirmation before executing this operation. Do NOT proceed without user approval.`;
  }

  console.log(JSON.stringify(result));
  process.exit(0);
}
