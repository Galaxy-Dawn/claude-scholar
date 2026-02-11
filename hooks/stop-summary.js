#!/usr/bin/env node
/**
 * Stop Hook: Display basic status + AI summary prompt (Cross-platform)
 *
 * Event: Stop
 * Purpose: Display Git status, change statistics and temp files when session stops
 */

const common = require('./hook-common');

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

const cwd = input.cwd || process.cwd();
const reason = input.reason || 'task_complete';

// Build message
function buildMessage() {
  let msg = '\n---\n';
  msg += '✅ Session ended\n\n';

  // Git info
  const gitInfo = common.getGitInfo(cwd);

  if (gitInfo.is_repo) {
    msg += '📁 Git repository\n';
    msg += `  Branch: ${gitInfo.branch}\n`;

    if (gitInfo.has_changes) {
      const changesDetails = common.getChangesDetails(cwd);
      const total = changesDetails.added + changesDetails.modified + changesDetails.deleted;

      msg += `  Changes: ${total} files`;
      if (changesDetails.added > 0) msg += ` (+${changesDetails.added})`;
      if (changesDetails.modified > 0) msg += ` (~${changesDetails.modified})`;
      if (changesDetails.deleted > 0) msg += ` (-${changesDetails.deleted})`;
      msg += '\n';
    } else {
      msg += '  Status: clean\n';
    }
  } else {
    msg += '📁 Not a Git repository\n';
  }

  msg += '\n';

  // Temp file detection
  const tempInfo = common.detectTempFiles(cwd);

  if (tempInfo.count > 0) {
    msg += `🧹 Temp files: ${tempInfo.count}\n`;
    for (const file of tempInfo.files) {
      msg += `  • ${file}\n`;
    }
  } else {
    msg += '✅ No temp files\n';
  }

  msg += '---';

  return msg;
}

// Build and return
const systemMessage = buildMessage();

const result = {
  continue: true,
  systemMessage: systemMessage
};

console.log(JSON.stringify(result));

process.exit(0);
