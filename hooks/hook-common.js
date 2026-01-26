/**
 * 跨平台 Hook 共享函数库
 * 为 Claude Code Hooks 提供跨平台兼容的共享函数
 *
 * @module hook-common
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

/**
 * 获取 Git 状态信息
 * @param {string} cwd - 当前工作目录
 * @returns {Object} Git 信息对象
 */
function getGitInfo(cwd) {
  try {
    // 检查是否是 Git 仓库
    execSync('git rev-parse --git-dir', {
      cwd,
      stdio: 'pipe'
    });

    // 获取分支名
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

    // 获取变更文件
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
 * 获取待办事项信息
 * @param {string} cwd - 当前工作目录
 * @returns {Object} 待办事项信息
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
 * 获取 Git 变更详情
 * @param {string} cwd - 当前工作目录
 * @returns {Object} 变更统计
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
 * 按文件类型分析变更
 * @param {string} cwd - 当前工作目录
 * @returns {Object} 文件类型统计
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
 * 检测临时文件
 * @param {string} cwd - 当前工作目录
 * @returns {Object} 临时文件信息
 */
function detectTempFiles(cwd) {
  const tempFiles = [];
  const gitInfo = getGitInfo(cwd);

  // 从 Git 未跟踪文件中查找
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

  // 检查已知临时目录
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
        // 忽略错误
      }
    }
  }

  return {
    files: tempFiles,
    count: tempFiles.length
  };
}

/**
 * 递归获取目录下所有文件
 * @param {string} dirPath - 目录路径
 * @returns {Array<string>} 文件路径列表
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
 * 生成智能推荐
 * @param {string} cwd - 当前工作目录
 * @param {Object} gitInfo - Git 信息
 * @returns {Array<string>} 推荐列表
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
      recommendations.push('运行测试套件验证修改');
    }
    if (typeAnalysis.docs_files > 0) {
      recommendations.push('检查文档与代码同步');
    }
    if (typeAnalysis.sql_files > 0) {
      recommendations.push('更新所有相关数据库脚本');
    }
    if (typeAnalysis.config_files > 0) {
      recommendations.push('检查是否需要更新环境变量');
    }
    if (typeAnalysis.service_files > 0) {
      recommendations.push('更新 API 文档');
    }
  }

  // 待办事项提醒
  const todoInfo = getTodoInfo(cwd);
  if (todoInfo.found && todoInfo.pending > 0) {
    recommendations.push(`查看待办事项: ${todoInfo.file} (还有 ${todoInfo.pending} 项未完成)`);
  }

  // 非仓库环境提醒
  if (!gitInfo.is_repo) {
    recommendations.push('记得备份重要文件到 git 仓库或云存储');
  }

  return recommendations;
}

/**
 * 获取已启用的插件列表
 * @param {string} homeDir - 用户主目录
 * @returns {Array<Object>} 插件列表
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
 * 获取可用命令列表
 * @param {string} homeDir - 用户主目录
 * @returns {Array<Object>} 命令列表
 */
function getAvailableCommands(homeDir) {
  const commands = [];

  // 只收集本地命令，不收集插件命令
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
 * 获取命令描述
 * @param {string} cmdPath - 命令文件路径
 * @returns {string} 命令描述
 */
function getCommandDescription(cmdPath) {
  try {
    const content = fs.readFileSync(cmdPath, 'utf8');
    const lines = content.split('\n');

    // 尝试从 frontmatter 获取 description
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

    // 尝试从标题获取
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
 * 收集本地技能
 * @param {string} homeDir - 用户主目录
 * @returns {Array<Object>} 技能列表
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
        // 忽略
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
 * 收集插件技能
 * @param {string} homeDir - 用户主目录
 * @returns {Array<Object>} 技能列表
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
    // 跳过 ai-research-skills
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
 * 格式化日期时间
 * @param {Date} date - 日期对象
 * @returns {string} 格式化的日期时间字符串
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
 * 创建临时文件
 * @param {string} prefix - 文件名前缀
 * @returns {string} 临时文件路径
 */
function createTempFile(prefix = 'claude-temp') {
  const os = require('os');
  const tmpDir = os.tmpdir();
  const randomSuffix = Math.random().toString(36).substring(2, 8);
  return path.join(tmpDir, `${prefix}-${randomSuffix}.tmp`);
}

// 导出所有函数
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
