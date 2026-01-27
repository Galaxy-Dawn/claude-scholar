/**
 * Cross-platform Hook Shared Functions Library
 * Provides cross-platform compatible shared functions for Claude Code Hooks
 *
 * @module hook-common
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

/**
 * Get Git status information
 * @param {string} cwd - Current working directory
 * @returns {Object} Git information object
 */
function getGitInfo(cwd) {
  try {
    // Check if it's a Git repository
    execSync('git rev-parse --git-dir', {
      cwd,
      stdio: 'pipe'
    });

    // Get branch name
    let branch = 'unknown';
    try {
      branch = execSync('git branch --show-current', {
        cwd,
        encoding: 'utf8',
        stdio: 'pipe'
      }).trim();
    } catch {
      branch = 'unknown';
    }

    // Get changed files
    let changes = '';
    try {
      changes = execSync('git status --porcelain', {
        cwd,
        encoding: 'utf8',
        stdio: 'pipe'
      });
    } catch {
      changes = '';
    }

    const changeList = changes.trim().split('\n').filter(Boolean);
    const hasChanges = changeList.length > 0;

    return {
      is_repo: true,
      branch,
      changes_count: changeList.length,
      has_changes: hasChanges,
      changes: changeList
    };
  } catch {
    return {
      is_repo: false,
      branch: 'unknown',
      changes_count: 0,
      has_changes: false,
      changes: []
    };
  }
}

/**
 * Get todo information
 * @param {string} cwd - Current working directory
 * @returns {Object} Todo information
 */
function getTodoInfo(cwd) {
  const todoFiles = [
    path.join(cwd, 'docs', 'todo.md'),
    path.join(cwd, 'TODO.md'),
    path.join(cwd, '.claude', 'todos.md'),
    path.join(cwd, 'TODO'),
    path.join(cwd, 'notes', 'todo.md')
  ];

  for (const file of todoFiles) {
    if (fs.existsSync(file)) {
      try {
        const content = fs.readFileSync(file, 'utf8');
        const totalMatches = content.match(/^[\-\*] \[[ x]\]/gi) || [];
        const total = totalMatches.length;

        const doneMatches = content.match(/^[\-\*] \[x\]/gi) || [];
        const done = doneMatches.length;

        const pending = total - done;

        return {
          found: true,
          file: path.basename(file),
          path: file,
          total,
          done,
          pending
        };
      } catch {
        continue;
      }
    }
  }

  return {
    found: false,
    file: null,
    path: null,
    total: 0,
    done: 0,
    pending: 0
  };
}

/**
 * Get Git change details
 * @param {string} cwd - Current working directory
 * @returns {Object} Change statistics
 */
function getChangesDetails(cwd) {
  try {
    const added = execSync('git diff --name-only --diff-filter=A', {
      cwd,
      encoding: 'utf8',
      stdio: 'pipe'
    }).trim().split('\n').filter(Boolean).length;

    const modified = execSync('git diff --name-only --diff-filter=M', {
      cwd,
      encoding: 'utf8',
      stdio: 'pipe'
    }).trim().split('\n').filter(Boolean).length;

    const deleted = execSync('git diff --name-only --diff-filter=D', {
      cwd,
      encoding: 'utf8',
      stdio: 'pipe'
    }).trim().split('\n').filter(Boolean).length;

    return { added, modified, deleted };
  } catch {
    return { added: 0, modified: 0, deleted: 0 };
  }
}

/**
 * Analyze changes by file type
 * @param {string} cwd - Current working directory
 * @returns {Object} File type statistics
 */
function analyzeChangesByType(cwd) {
  const gitInfo = getGitInfo(cwd);

  if (!gitInfo.is_repo || !gitInfo.has_changes) {
    return {
      test_files: 0,
      docs_files: 0,
      sql_files: 0,
      config_files: 0,
      service_files: 0
    };
  }

  const changes = gitInfo.changes.join('\n');

  const testFiles = (changes.match(/test/gi) || []).length;
  const docsFiles = (changes.match(/\.(md|txt|rst)$/gi) || []).length;
  const sqlFiles = (changes.match(/\.sql$/gi) || []).length;
  const configFiles = (changes.match(/\.(json|yaml|yml|toml|ini|conf)$/gi) || []).length;
  const serviceFiles = (changes.match(/(service|controller)/gi) || []).length;

  return {
    test_files: testFiles,
    docs_files: docsFiles,
    sql_files: sqlFiles,
    config_files: configFiles,
    service_files: serviceFiles
  };
}

/**
 * Detect temporary files
 * @param {string} cwd - Current working directory
 * @returns {Object} Temporary file information
 */
function detectTempFiles(cwd) {
  const tempFiles = [];
  const gitInfo = getGitInfo(cwd);

  // Find from Git untracked files
  if (gitInfo.is_repo) {
    for (const change of gitInfo.changes) {
      if (change.startsWith('??')) {
        const file = change.substring(3).trim();
        if (/plan|draft|tmp|temp|scratch/i.test(file)) {
          tempFiles.push(file);
        }
      }
    }
  }

  // Check known temp directories
  const tempDirs = ['plan', 'docs/plans', '.claude/temp', 'tmp', 'temp'];
  for (const dir of tempDirs) {
    const dirPath = path.join(cwd, dir);
    if (fs.existsSync(dirPath)) {
      try {
        const files = getAllFiles(dirPath);
        for (const file of files) {
          tempFiles.push(path.relative(cwd, file));
        }
      } catch {
        // Ignore errors
      }
    }
  }

  return {
    files: tempFiles,
    count: tempFiles.length
  };
}

/**
 * Recursively get all files in a directory
 * @param {string} dirPath - Directory path
 * @returns {Array<string>} List of file paths
 */
function getAllFiles(dirPath) {
  const files = [];
  const items = fs.readdirSync(dirPath);

  for (const item of items) {
    const fullPath = path.join(dirPath, item);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      files.push(...getAllFiles(fullPath));
    } else {
      files.push(fullPath);
    }
  }

  return files;
}

/**
 * Generate smart recommendations
 * @param {string} cwd - Current working directory
 * @param {Object} gitInfo - Git information
 * @returns {Array<string>} Recommendation list
 */
function generateRecommendations(cwd, gitInfo) {
  const recommendations = [];

  if (gitInfo.is_repo && gitInfo.has_changes) {
    const changesDetails = getChangesDetails(cwd);
    const typeAnalysis = analyzeChangesByType(cwd);

    if (changesDetails.added > 0 || changesDetails.modified > 0) {
      recommendations.push('git add . && git commit -m "feat: xxx"');
    }

    if (typeAnalysis.test_files > 0) {
      recommendations.push('Run test suite to verify changes');
    }
    if (typeAnalysis.docs_files > 0) {
      recommendations.push('Check documentation sync with code');
    }
    if (typeAnalysis.sql_files > 0) {
      recommendations.push('Update all related database scripts');
    }
    if (typeAnalysis.config_files > 0) {
      recommendations.push('Check if environment variables need update');
    }
    if (typeAnalysis.service_files > 0) {
      recommendations.push('Update API documentation');
    }
  }

  // Todo reminder
  const todoInfo = getTodoInfo(cwd);
  if (todoInfo.found && todoInfo.pending > 0) {
    recommendations.push(`Check todos: ${todoInfo.file} (${todoInfo.pending} remaining)`);
  }

  // Non-repo environment reminder
  if (!gitInfo.is_repo) {
    recommendations.push('Remember to backup important files to git repository or cloud storage');
  }

  return recommendations;
}

/**
 * Get enabled plugins list
 * @param {string} homeDir - User home directory
 * @returns {Array<Object>} Plugin list
 */
function getEnabledPlugins(homeDir) {
  const settingsFile = path.join(homeDir, '.claude', 'settings.json');

  if (!fs.existsSync(settingsFile)) {
    return [];
  }

  try {
    const settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
    const enabledPlugins = settings.enabledPlugins || {};

    const plugins = [];
    for (const [pluginId, enabled] of Object.entries(enabledPlugins)) {
      if (enabled) {
        const pluginName = pluginId.split('@')[0];
        plugins.push({
          id: pluginId,
          name: pluginName
        });
      }
    }

    return plugins;
  } catch {
    return [];
  }
}

/**
 * Get available commands list
 * @param {string} homeDir - User home directory
 * @returns {Array<Object>} Command list
 */
function getAvailableCommands(homeDir) {
  const commands = [];

  // Only collect local commands, not plugin commands
  const localCommandsDir = path.join(homeDir, '.claude', 'commands');
  if (fs.existsSync(localCommandsDir)) {
    const commandFiles = fs.readdirSync(localCommandsDir)
      .filter(f => f.endsWith('.md'));

    for (const cmdFile of commandFiles) {
      const cmdName = cmdFile.replace('.md', '');
      commands.push({
        plugin: 'local',
        name: cmdName,
        path: path.join(localCommandsDir, cmdFile)
      });
    }
  }

  return commands;
}

/**
 * Get command description
 * @param {string} cmdPath - Command file path
 * @returns {string} Command description
 */
function getCommandDescription(cmdPath) {
  try {
    const content = fs.readFileSync(cmdPath, 'utf8');
    const lines = content.split('\n');

    // Try to get description from frontmatter
    let inFrontmatter = false;
    for (const line of lines) {
      if (line.trim() === '---') {
        if (!inFrontmatter) {
          inFrontmatter = true;
        } else {
          break;
        }
        continue;
      }

      if (inFrontmatter && line.trim().startsWith('description:')) {
        const match = line.match(/description:\s*["']?(.+?)["']?$/);
        if (match) {
          return match[1].trim();
        }
      }
    }

    // Try to get from heading
    for (const line of lines) {
      const match = line.match(/^#+\s*(.+)$/);
      if (match) {
        return match[1].trim().substring(0, 50);
      }
    }

    return '';
  } catch {
    return '';
  }
}

/**
 * Collect local skills
 * @param {string} homeDir - User home directory
 * @returns {Array<Object>} Skill list
 */
function collectLocalSkills(homeDir) {
  const skills = [];
  const skillsDir = path.join(homeDir, '.claude', 'skills');

  if (!fs.existsSync(skillsDir)) {
    return skills;
  }

  const skillDirs = fs.readdirSync(skillsDir, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name);

  for (const skillName of skillDirs) {
    const skillFile = path.join(skillsDir, skillName, 'skill.md');
    let description = '';

    if (fs.existsSync(skillFile)) {
      try {
        const content = fs.readFileSync(skillFile, 'utf8');
        const match = content.match(/description:\s*(.+)$/im);
        if (match) {
          description = match[1].trim();
        }
      } catch {
        // Ignore
      }
    }

    skills.push({
      name: skillName,
      description,
      type: 'local'
    });
  }

  return skills;
}

/**
 * Collect plugin skills
 * @param {string} homeDir - User home directory
 * @returns {Array<Object>} Skill list
 */
function collectPluginSkills(homeDir) {
  const skills = [];
  const pluginsCache = path.join(homeDir, '.claude', 'plugins', 'cache');

  if (!fs.existsSync(pluginsCache)) {
    return skills;
  }

  const marketplaces = fs.readdirSync(pluginsCache, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name);

  for (const marketplace of marketplaces) {
    // Skip ai-research-skills
    if (marketplace === 'ai-research-skills') continue;

    const marketplacePath = path.join(pluginsCache, marketplace);
    const plugins = fs.readdirSync(marketplacePath, { withFileTypes: true })
      .filter(d => d.isDirectory() && !d.name.startsWith('.'))
      .map(d => d.name);

    for (const plugin of plugins) {
      const pluginPath = path.join(marketplacePath, plugin);
      const versions = fs.readdirSync(pluginPath, { withFileTypes: true })
        .filter(d => d.isDirectory())
        .map(d => d.name)
        .sort()
        .reverse();

      if (versions.length === 0) continue;

      const latestVersion = versions[0];
      const pluginRoot = path.join(pluginPath, latestVersion);
      const skillsDir = path.join(pluginRoot, 'skills');

      if (fs.existsSync(skillsDir)) {
        const skillDirs = fs.readdirSync(skillsDir, { withFileTypes: true })
          .filter(d => d.isDirectory())
          .map(d => d.name);

        for (const skillName of skillDirs) {
          skills.push({
            name: `${plugin}:${skillName}`,
            plugin,
            skill: skillName,
            type: 'plugin'
          });
        }
      }
    }
  }

  return skills;
}

/**
 * Format date time
 * @param {Date} date - Date object
 * @returns {string} Formatted date time string
 */
function formatDateTime(date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  const seconds = String(date.getSeconds()).padStart(2, '0');

  return `${year}/${month}/${day} ${hours}:${minutes}:${seconds}`;
}

/**
 * Create temporary file
 * @param {string} prefix - File name prefix
 * @returns {string} Temporary file path
 */
function createTempFile(prefix = 'claude-temp') {
  const os = require('os');
  const tmpDir = os.tmpdir();
  const randomSuffix = Math.random().toString(36).substring(2, 8);
  return path.join(tmpDir, `${prefix}-${randomSuffix}.tmp`);
}

// Export all functions
module.exports = {
  getGitInfo,
  getTodoInfo,
  getChangesDetails,
  analyzeChangesByType,
  detectTempFiles,
  generateRecommendations,
  getEnabledPlugins,
  getAvailableCommands,
  getCommandDescription,
  collectLocalSkills,
  collectPluginSkills,
  formatDateTime,
  createTempFile,
  getAllFiles
};
