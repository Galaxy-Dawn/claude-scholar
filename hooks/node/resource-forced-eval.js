#!/usr/bin/env node
/**
 * UserPromptSubmit Hook: 资源可用性检查（跨平台版本）
 *
 * 事件: UserPromptSubmit
 * 功能: 为 LLM 提供可用的 plugins、skills、agents 资源信息
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

const userPrompt = input.user_prompt || '';

// 检查是否是斜杠命令（转义）
if (userPrompt.startsWith('/')) {
  process.exit(0);
}

const homeDir = os.homedir();

// 收集本地 Skills
function collectLocalSkills() {
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

    if (description) {
      skills.push(`${skillName} - ${description}`);
    } else {
      skills.push(skillName);
    }
  }

  return skills;
}

// 收集插件 Skills
function collectPluginSkills() {
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
          skills.push(`${plugin}:${skillName}`);
        }
      }
    }
  }

  return skills;
}

// 收集本地 Commands
function collectLocalCommands() {
  const commands = [];
  const localCommandsDir = path.join(homeDir, '.claude', 'commands');

  if (!fs.existsSync(localCommandsDir)) {
    return commands;
  }

  const commandFiles = fs.readdirSync(localCommandsDir)
    .filter(f => f.endsWith('.md'));

  for (const cmdFile of commandFiles) {
    const commandName = cmdFile.replace('.md', '');
    commands.push(commandName);
  }

  return commands.sort();
}

// 收集插件 Commands
function collectPluginCommands() {
  const commands = [];
  const pluginsCache = path.join(homeDir, '.claude', 'plugins', 'cache');

  if (!fs.existsSync(pluginsCache)) {
    return commands;
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
      const commandsDir = path.join(pluginRoot, 'commands');

      if (fs.existsSync(commandsDir) && fs.statSync(commandsDir).isDirectory()) {
        const commandFiles = fs.readdirSync(commandsDir)
          .filter(f => f.endsWith('.md'));

        for (const cmdFile of commandFiles) {
          const commandName = cmdFile.replace('.md', '');
          commands.push(`${plugin}:${commandName}`);
        }
      }
    }
  }

  // 去重
  return [...new Set(commands)].sort();
}

// 收集 AI Research Skills
function collectAIResearchPlugins() {
  const plugins = [];
  const aiMarketplace = path.join(homeDir, '.claude', 'plugins', 'cache', 'ai-research-skills');

  if (!fs.existsSync(aiMarketplace)) {
    return plugins;
  }

  const pluginDirs = fs.readdirSync(aiMarketplace, { withFileTypes: true })
    .filter(d => d.isDirectory() && !d.name.startsWith('.'))
    .map(d => d.name);

  for (const pluginName of pluginDirs) {
    plugins.push(pluginName);
  }

  return plugins;
}

// 格式化列表
function formatList(list) {
  if (!list || list.length === 0) {
    return '（无）';
  }

  return list.map(item => `- ${item}`).join('\n');
}

// 收集资源
const LOCAL_SKILLS = collectLocalSkills();
const LOCAL_COMMANDS = collectLocalCommands();
// const PLUGIN_SKILLS = collectPluginSkills();
// const PLUGIN_COMMANDS = collectPluginCommands();
// const AI_RESEARCH_PLUGINS = collectAIResearchPlugins();

// 生成输出
const output = `## 指令：资源可用性检查

你当前环境中有以下可用的资源，可以帮助你完成任务：

### 📚 本地 Skills (~/.claude/skills/)
${formatList(LOCAL_SKILLS)}

### 🔧 本地 Commands (~/.claude/commands/)
${formatList(LOCAL_COMMANDS)}

### 🔌 插件 Skills (plugins/*/skills/)
（已禁用）

### 🔌 插件 Commands (plugins/*/commands/)
（已禁用）

### 🧠 AI Research Skills (ai-research-skills)
（已禁用）

---

**使用指南**：
- 对于本地 skills，直接使用技能名称（如：agent-identifier）
- 对于本地 commands，直接使用命令名称（如：/plan）
- 插件资源已暂时禁用
`;

console.log(output);

process.exit(0);
