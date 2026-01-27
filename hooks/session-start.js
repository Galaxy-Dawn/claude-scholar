#!/usr/bin/env node
/**
 * SessionStart Hook: Display project status (cross-platform version)
 *
 * Event: SessionStart
 * Purpose: Show project status, Git info, todos, plugins, and commands on session start
 */

const path = require('path');
const os = require('os');
const fs = require('fs');

// Import shared functions
const common = require('./hook-common');

// Import package manager detection
const { getPackageManager, getSelectionPrompt } = require('../scripts/lib/package-manager');

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
const projectName = path.basename(cwd);
const homeDir = os.homedir();

// Build output
let output = '';

// Session startup info
output += `🚀 ${projectName} session started\n`;
output += `▸ Time: ${common.formatDateTime()}\n`;
output += `▸ Directory: ${cwd}\n\n`;

// Git status
const gitInfo = common.getGitInfo(cwd);

if (gitInfo.is_repo) {
  output += `▸ Git branch: ${gitInfo.branch}\n\n`;

  if (gitInfo.has_changes) {
    output += `⚠️  Uncommitted changes (${gitInfo.changes_count} files):\n`;

    // Show change list (max 10)
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
      output += `  ... (${gitInfo.changes_count - 10} more files)\n`;
    }
  } else {
    output += `✅ Working directory clean\n`;
  }
  output += '\n';
} else {
  output += `▸ Git: not a repository\n\n`;
}

// Package manager detection
try {
  const pm = getPackageManager();
  output += `📦 Package manager: ${pm.name} (${pm.source})\n`;

  // If detected by fallback, prompt to configure
  if (pm.source === 'fallback' || pm.source === 'default') {
    output += `💡 Run /setup-pm to configure preferred package manager\n`;
  }
} catch (err) {
  // Package manager detection failed, silently ignore
}

output += '\n';

// Todos
output += `📋 Todos:\n`;
const todoInfo = common.getTodoInfo(cwd);

if (todoInfo.found) {
  output += `  - ${todoInfo.pending} pending / ${todoInfo.done} completed\n`;

  // Show first 5 pending items
  if (fs.existsSync(todoInfo.path)) {
    try {
      const content = fs.readFileSync(todoInfo.path, 'utf8');
      const pendingItems = content.match(/^[\-\*] \[ \].+$/gm) || [];

      if (pendingItems.length > 0) {
        output += `\n  Recent todos:\n`;
        for (let i = 0; i < Math.min(5, pendingItems.length); i++) {
          const item = pendingItems[i].replace(/^[\-\*] \[ \]\s*/, '').substring(0, 60);
          output += `  - ${item}\n`;
        }
      }
    } catch {
      // Ignore errors
    }
  }
} else {
  output += `  No todo file found (TODO.md, docs/todo.md, etc.)\n`;
}

output += '\n';

// Enabled plugins
output += `🔌 Enabled plugins:\n`;
const enabledPlugins = common.getEnabledPlugins(homeDir);

if (enabledPlugins.length > 0) {
  for (const plugin of enabledPlugins) {
    output += `  - ${plugin.name}\n`;
  }
} else {
  output += `  None\n`;
}

output += '\n';

// Available commands
output += `💡 Available commands:\n`;
const availableCommands = common.getAvailableCommands(homeDir);

if (availableCommands.length > 0) {
  for (const cmd of availableCommands.slice(0, 20)) {
    const description = common.getCommandDescription(cmd.path) || `${cmd.plugin} command`;
    const truncatedDesc = description.length > 40 ? description.substring(0, 40) + '...' : description;
    output += `  /${cmd.name.padEnd(20)} ${truncatedDesc}\n`;
  }

  if (availableCommands.length > 20) {
    output += `  ... (${availableCommands.length - 20} more commands)\n`;
  }
} else {
  output += `  No commands found\n`;
}

// Output JSON
const result = {
  continue: true,
  systemMessage: output
};

console.log(JSON.stringify(result));

process.exit(0);
