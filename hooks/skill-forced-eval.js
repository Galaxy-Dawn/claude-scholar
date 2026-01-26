#!/usr/bin/env node
/**
 * UserPromptSubmit Hook: 强制技能激活流程（跨平台版本）
 *
 * 事件: UserPromptSubmit
 * 功能: 强制 AI 评估可用技能并在激活后开始实现
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
  // 区分命令和路径：
  // - 命令：/commit, /update-github (斜杠后不包含第二个斜杠)
  // - 路径：/Users/xxx, /path/to/file (包含路径分隔符)
  const rest = userPrompt.substring(1);
  if (rest.includes('/')) {
    // 这是路径，继续进行 skill 扫描
  } else {
    // 这是命令，跳过 skill 评估
    console.log(JSON.stringify({ continue: true }));
    process.exit(0);
  }
}

const homeDir = os.homedir();

// 动态收集技能列表
function collectSkills() {
  const skills = [];
  const skillsDir = path.join(homeDir, '.claude', 'skills');

  // 1. 收集本地技能
  if (fs.existsSync(skillsDir)) {
    const skillDirs = fs.readdirSync(skillsDir, { withFileTypes: true })
      .filter(d => d.isDirectory())
      .map(d => d.name);

    for (const skillName of skillDirs) {
      skills.push(skillName);
    }
  }

  // 2. 收集插件技能
  const pluginsCache = path.join(homeDir, '.claude', 'plugins', 'cache');

  if (fs.existsSync(pluginsCache)) {
    const marketplaces = fs.readdirSync(pluginsCache, { withFileTypes: true })
      .filter(d => d.isDirectory())
      .map(d => d.name);

    for (const marketplace of marketplaces) {
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

        if (versions.length > 0) {
          const latestVersion = versions[0];
          const skillsDirPath = path.join(pluginPath, latestVersion, 'skills');

          if (fs.existsSync(skillsDirPath)) {
            const skillDirs = fs.readdirSync(skillsDirPath, { withFileTypes: true })
              .filter(d => d.isDirectory())
              .map(d => d.name);

            for (const skillName of skillDirs) {
              skills.push(`${plugin}:${skillName}`);
            }
          }
        }
      }
    }
  }

  // 去重
  return [...new Set(skills)].sort();
}

// 生成技能列表
const SKILL_LIST = collectSkills();

// 生成输出
const output = `## 指令：强制技能激活流程（必须执行）

### 步骤 1 - 评估技能
针对以下每个技能，陈述：[技能名] - 是/否 - [理由]

可用技能列表：
${SKILL_LIST.map(skill => `- ${skill}`).join('\n')}
### 步骤 2 - 激活
如果任何技能为"是" → 立即使用 Skill(技能) 工具激活
如果所有技能为"否" → 说明"不需要技能"并继续

### 步骤 3 - 实现
只有在步骤 2 完成后，才能开始实现。

**关键规划**：
1.你必须在步骤2调用Skill()工具，不要跳过直接实现；
2.首先评估步骤1的所有技能，不要跳过任何一个技能；
3.多个技能相关时，全部激活；
4.判断仅包含是或否：是 = 明确相关且必需，否 = 不相关或非必需，去掉"可能"选项；
5.只有完成上述步骤之后才开始实现。
`;

console.log(output);

process.exit(0);
