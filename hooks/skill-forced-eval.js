#!/usr/bin/env node
/**
 * UserPromptSubmit Hook: Force skill activation flow (cross-platform version)
 *
 * Event: UserPromptSubmit
 * Purpose: Force AI to evaluate available skills and activate before implementation
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

const userPrompt = input.user_prompt || '';

// Check if it's a slash command (escape)
if (userPrompt.startsWith('/')) {
  // Distinguish command from path:
  // - Command: /commit, /update-github (no second slash after)
  // - Path: /Users/xxx, /path/to/file (contains path separator)
  const rest = userPrompt.substring(1);
  if (rest.includes('/')) {
    // This is a path, continue with skill scanning
  } else {
    // This is a command, skip skill evaluation
    console.log(JSON.stringify({ continue: true }));
    process.exit(0);
  }
}

const homeDir = os.homedir();

// Dynamically collect skill list
function collectSkills() {
  const skills = [];
  const skillsDir = path.join(homeDir, '.claude', 'skills');

  // 1. Collect local skills
  if (fs.existsSync(skillsDir)) {
    const skillDirs = fs.readdirSync(skillsDir, { withFileTypes: true })
      .filter(d => d.isDirectory())
      .map(d => d.name);

    for (const skillName of skillDirs) {
      skills.push(skillName);
    }
  }

  // 2. Collect plugin skills
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

  // Deduplicate
  return [...new Set(skills)].sort();
}

// Generate skill list
const SKILL_LIST = collectSkills();

// Generate output
const output = `## Instruction: Force Skill Activation (Must Execute)

### Step 1 - Evaluate Skills
For each skill below, state: [Skill Name] - Yes/No - [Reason]

Available skills:
${SKILL_LIST.map(skill => `- ${skill}`).join('\n')}

### Step 2 - Activate
If any skill is "Yes" → Immediately use Skill(skill) tool to activate
If all skills are "No" → State "No skills needed" and continue

### Step 3 - Implement
Only after Step 2 is complete, begin implementation.

**Critical rules**:
1. You MUST call Skill() tool in Step 2, do not skip to implementation
2. Evaluate ALL skills in Step 1, do not skip any skill
3. When multiple skills are relevant, activate ALL of them
4. Judgment is Yes/No only: Yes = clearly relevant and required, No = not relevant or not required
5. Only begin implementation after completing the above steps
`;

console.log(output);

process.exit(0);
