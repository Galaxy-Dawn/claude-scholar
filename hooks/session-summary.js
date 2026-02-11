#!/usr/bin/env node
/**
 * SessionEnd Hook: Work Log + Smart Suggestions (Cross-platform)
 *
 * Event: SessionEnd
 * Purpose: Create work log, record changes and generate smart suggestions
 */

const path = require('path');
const fs = require('fs');
const os = require('os');
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
const sessionId = input.session_id || 'unknown';
const transcriptPath = input.transcript_path || '';

// Create work log directory
const logDir = path.join(cwd, '.claude', 'logs');
fs.mkdirSync(logDir, { recursive: true });

// Generate log filename
const now = new Date();
const dateStr = now.toISOString().split('T')[0].replace(/-/g, '');
const logFile = path.join(logDir, `session-${dateStr}-${sessionId.substring(0, 8)}.md`);

// Get project info
const projectName = path.basename(cwd);

// Build log content
let logContent = '';

logContent += `# 📝 Work Log - ${projectName}\n`;
logContent += `\n`;
logContent += `**Session ID**: ${sessionId}\n`;
logContent += `**Time**: ${common.formatDateTime(now)}\n`;
logContent += `**Directory**: ${cwd}\n`;
logContent += `\n`;

// Git change statistics
logContent += `## 📊 Session Changes\n`;
const gitInfo = common.getGitInfo(cwd);
const changesDetails = gitInfo.is_repo ? common.getChangesDetails(cwd) : { added: 0, modified: 0, deleted: 0 };

if (gitInfo.is_repo) {
  logContent += `**Branch**: ${gitInfo.branch}\n`;
  logContent += `\n`;
  logContent += '```\n';

  if (gitInfo.has_changes) {
    for (const change of gitInfo.changes) {
      logContent += `${change}\n`;
    }
  } else {
    logContent += 'No changes\n';
  }

  logContent += '```\n';

  // Change statistics
  logContent += `\n`;
  logContent += '| Type | Count |\n';
  logContent += '|------|------|\n';
  logContent += `| Added | ${changesDetails.added} |\n`;
  logContent += `| Modified | ${changesDetails.modified} |\n`;
  logContent += `| Deleted | ${changesDetails.deleted} |\n`;
} else {
  logContent += 'Not a Git repository\n';
}

logContent += `\n`;

// Smart suggestions
if (gitInfo.has_changes) {
  logContent += `## 💡 Suggested Actions\n`;
  logContent += `\n`;

  const typeAnalysis = common.analyzeChangesByType(cwd);

  if (changesDetails.modified > 0 || changesDetails.added > 0) {
    logContent += '- Review changes with code review tools\n';
  }
  if (typeAnalysis.test_files > 0) {
    logContent += '- Test files changed, remember to run test suite\n';
  }
  if (typeAnalysis.docs_files > 0) {
    logContent += '- Documentation updated, ensure sync with code\n';
  }
  if (typeAnalysis.sql_files > 0) {
    logContent += '- SQL files changed, ensure all database scripts are updated\n';
  }
  if (typeAnalysis.service_files > 0) {
    logContent += '- New Service/Controller added, remember to update API docs\n';
  }
  if (typeAnalysis.config_files > 0) {
    logContent += '- Config files modified, check if environment variables need updating\n';
  }

  logContent += `\n`;
}

// Read transcript to extract key operations (if available)
if (transcriptPath && fs.existsSync(transcriptPath)) {
  try {
    const transcript = fs.readFileSync(transcriptPath, 'utf8');
    const toolMatches = transcript.match(/Tool used: [A-Z][a-z]*/g) || [];

    if (toolMatches.length > 0) {
      // Count tool usage
      const toolCounts = {};
      for (const match of toolMatches) {
        const tool = match.replace('Tool used: ', '');
        toolCounts[tool] = (toolCounts[tool] || 0) + 1;
      }

      // Sort and take top 10
      const sortedTools = Object.entries(toolCounts)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10);

      if (sortedTools.length > 0) {
        logContent += `## 🔧 Key Operations\n`;
        logContent += `\n`;

        for (const [tool, count] of sortedTools) {
          logContent += `| ${tool} | ${count} times |\n`;
        }

        logContent += `\n`;
      }
    }
  } catch {
    // Ignore errors
  }
}

// Next steps
logContent += `## 🎯 Next Steps\n`;
logContent += `\n`;

// Git commit suggestions
if (gitInfo.has_changes) {
  logContent += '- ⚠️ Uncommitted changes detected, consider committing first:\n';
  logContent += '  ```bash\n';
  logContent += '  git add . && git commit -m "feat: xxx"\n';
  logContent += '  ```\n';
} else {
  logContent += '- ✅ Working directory clean, ready for new tasks\n';
}

// Todo reminders
const todoInfo = common.getTodoInfo(cwd);
if (todoInfo.found) {
  logContent += `- Update todos: ${todoInfo.file} (${todoInfo.pending} pending)\n`;
}

// CLAUDE.md memory update check
const homeDir = os.homedir();
const claudeMdCheck = common.checkClaudeMdUpdate(homeDir);

if (claudeMdCheck.needsUpdate) {
  logContent += `- ⚠️ **CLAUDE.md memory needs updating** (${claudeMdCheck.changedFiles.length} source files changed)\n`;
  logContent += `  Run "/update-memory" to sync latest memory\n`;

  // Record change details to log
  logContent += `\n`;
  logContent += `### CLAUDE.md Change Details\n`;
  logContent += `\n`;
  logContent += `| Type | File | Modified |\n`;
  logContent += `|------|------|----------|\n`;
  for (const file of claudeMdCheck.changedFiles.slice(0, 10)) {
    logContent += `| ${file.type} | ${file.relativePath} | ${file.mtime} |\n`;
  }
  if (claudeMdCheck.changedFiles.length > 10) {
    logContent += `| ... | ${claudeMdCheck.changedFiles.length - 10} more files | ... |\n`;
  }
} else {
  logContent += `- ✅ CLAUDE.md memory is up to date\n`;
}

logContent += '- View context snapshot: `cat .claude/session-context-*.md`\n';
logContent += `\n`;

// Write log file
fs.writeFileSync(logFile, logContent, 'utf8');

// Build message to display to user
let displayMsg = '\n---\n';
displayMsg += '✅ **Session ended** | Work log saved\n\n';
displayMsg += '**Changes**: ';

if (gitInfo.is_repo) {
  if (gitInfo.has_changes) {
    displayMsg += `${gitInfo.changes_count} files\n\n`;
    displayMsg += '**Suggested actions**:\n';
    displayMsg += `- View log: cat .claude/logs/${path.basename(logFile)}\n`;
    displayMsg += '- Commit code: git add . && git commit -m "feat: xxx"\n';
  } else {
    displayMsg += 'None\n\nWorking directory clean ✅\n';
  }
} else {
  displayMsg += 'Not a Git repository\n';
}

// Add CLAUDE.md update reminder to display message
if (claudeMdCheck.needsUpdate) {
  displayMsg += '\n**⚠️ CLAUDE.md memory needs updating**\n';
  displayMsg += `- ${claudeMdCheck.changedFiles.length} source files changed\n`;
  displayMsg += '- Run `/update-memory` to sync latest memory\n';
}

displayMsg += '\n---';

const result = {
  continue: true,
  systemMessage: displayMsg
};

console.log(JSON.stringify(result));

process.exit(0);
