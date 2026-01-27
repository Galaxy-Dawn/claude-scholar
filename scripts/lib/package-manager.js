/**
 * 包管理器检测系统
 * 智能检测并管理 npm、pnpm、yarn、bun 等包管理器
 *
 * @module package-manager
 */

const fs = require('fs');
const path = require('path');
const { commandExists, readJSON, getProjectRoot, getClaudeConfigDir, isWindows } = require('./utils');

// 包管理器配置
const PACKAGE_MANAGERS = {
  npm: {
    name: 'npm',
    lockFile: 'package-lock.json',
    installCmd: 'npm install',
    runCmd: 'npm run',
    execCmd: 'npx',
    globalFlag: '--global'
  },
  pnpm: {
    name: 'pnpm',
    lockFile: 'pnpm-lock.yaml',
    installCmd: 'pnpm install',
    runCmd: 'pnpm',
    execCmd: 'pnpm dlx',
    globalFlag: '--global'
  },
  yarn: {
    name: 'yarn',
    lockFile: 'yarn.lock',
    installCmd: 'yarn install',
    runCmd: 'yarn',
    execCmd: 'yarn dlx',
    globalFlag: 'global'
  },
  bun: {
    name: 'bun',
    lockFile: 'bun.lockb',
    installCmd: 'bun install',
    runCmd: 'bun run',
    execCmd: 'bun x',
    globalFlag: '--global'
  }
};

// 检测优先级
const DETECTION_PRIORITY = ['pnpm', 'bun', 'yarn', 'npm'];

/**
 * 获取项目配置文件路径
 * @returns {string} 配置文件路径
 */
function getProjectConfigPath() {
  const projectRoot = getProjectRoot();
  if (projectRoot) {
    return path.join(projectRoot, '.claude', 'package-manager.json');
  }
  return null;
}

/**
 * 获取全局配置文件路径
 * @returns {string} 配置文件路径
 */
function getGlobalConfigPath() {
  return path.join(getClaudeConfigDir(), 'package-manager.json');
}

/**
 * 从环境变量检测包管理器
 * @returns {string|null} 包管理器名称或 null
 */
function detectFromEnvironment() {
  const envPm = process.env.CLAUDE_PACKAGE_MANAGER;
  if (envPm && PACKAGE_MANAGERS[envPm]) {
    return envPm;
  }
  return null;
}

/**
 * 从项目配置检测包管理器
 * @returns {string|null} 包管理器名称或 null
 */
function detectFromProjectConfig() {
  const configPath = getProjectConfigPath();
  if (configPath && fs.existsSync(configPath)) {
    const config = readJSON(configPath);
    if (config && config.packageManager && PACKAGE_MANAGERS[config.packageManager]) {
      return config.packageManager;
    }
  }
  return null;
}

/**
 * 从全局配置检测包管理器
 * @returns {string|null} 包管理器名称或 null
 */
function detectFromGlobalConfig() {
  const configPath = getGlobalConfigPath();
  if (configPath && fs.existsSync(configPath)) {
    const config = readJSON(configPath);
    if (config && config.packageManager && PACKAGE_MANAGERS[config.packageManager]) {
      return config.packageManager;
    }
  }
  return null;
}

/**
 * 从 package.json 检测包管理器
 * @returns {string|null} 包管理器名称或 null
 */
function detectFromPackageJson() {
  const projectRoot = getProjectRoot();
  if (!projectRoot) {
    return null;
  }

  const packageJsonPath = path.join(projectRoot, 'package.json');
  if (!fs.existsSync(packageJsonPath)) {
    return null;
  }

  const packageJson = readJSON(packageJsonPath);
  if (!packageJson) {
    return null;
  }

  // 检查 packageManager 字段
  if (packageJson.packageManager) {
    // 格式: "npm@8.0.0" 或 "pnpm@7.0.0"
    const match = packageJson.packageManager.match(/^([a-zA-Z]+)@/);
    if (match && PACKAGE_MANAGERS[match[1]]) {
      return match[1];
    }
  }

  return null;
}

/**
 * 从锁文件检测包管理器
 * @returns {string|null} 包管理器名称或 null
 */
function detectFromLockFile() {
  const projectRoot = getProjectRoot();
  if (!projectRoot) {
    return null;
  }

  // 按优先级检查锁文件
  for (const pm of DETECTION_PRIORITY) {
    const lockFile = path.join(projectRoot, PACKAGE_MANAGERS[pm].lockFile);
    if (fs.existsSync(lockFile)) {
      return pm;
    }
  }

  return null;
}

/**
 * 从可用命令检测包管理器
 * @returns {string|null} 包管理器名称或 null
 */
function detectFromAvailableCommands() {
  for (const pm of DETECTION_PRIORITY) {
    if (commandExists(pm)) {
      return pm;
    }
  }
  // npm 始终可用（Node.js 自带）
  return 'npm';
}

/**
 * 智能检测包管理器
 * @param {Object} options - 检测选项
 * @returns {{name: string, source: string, config: Object}} 检测结果
 */
function getPackageManager(options = {}) {
  const {
    skipEnvironment = false,
    skipProjectConfig = false,
    skipGlobalConfig = false,
    skipPackageJson = false,
    skipLockFile = false,
    skipAvailable = false
  } = options;

  // 按优先级检测
  const detectors = [
    !skipEnvironment && { detector: detectFromEnvironment, source: 'environment' },
    !skipProjectConfig && { detector: detectFromProjectConfig, source: 'project-config' },
    !skipPackageJson && { detector: detectFromPackageJson, source: 'package.json' },
    !skipLockFile && { detector: detectFromLockFile, source: 'lock-file' },
    !skipGlobalConfig && { detector: detectFromGlobalConfig, source: 'global-config' },
    !skipAvailable && { detector: detectFromAvailableCommands, source: 'available' }
  ].filter(Boolean);

  for (const { detector, source } of detectors) {
    const pm = detector();
    if (pm && PACKAGE_MANAGERS[pm]) {
      return {
        name: pm,
        source,
        config: PACKAGE_MANAGERS[pm]
      };
    }
  }

  // 默认回退到 npm
  return {
    name: 'npm',
    source: 'default',
    config: PACKAGE_MANAGERS.npm
  };
}

/**
 * 设置项目包管理器
 * @param {string} packageManager - 包管理器名称
 * @returns {boolean} 是否成功
 */
function setProjectPackageManager(packageManager) {
  if (!PACKAGE_MANAGERS[packageManager]) {
    console.error(`不支持的包管理器: ${packageManager}`);
    return false;
  }

  const configPath = getProjectConfigPath();
  if (!configPath) {
    console.error('无法找到项目根目录');
    return false;
  }

  const configDir = path.dirname(configPath);
  if (!fs.existsSync(configDir)) {
    fs.mkdirSync(configDir, { recursive: true });
  }

  try {
    fs.writeFileSync(
      configPath,
      JSON.stringify({ packageManager }, null, 2),
      'utf8'
    );
    return true;
  } catch (err) {
    console.error(`写入配置失败: ${err.message}`);
    return false;
  }
}

/**
 * 设置全局包管理器
 * @param {string} packageManager - 包管理器名称
 * @returns {boolean} 是否成功
 */
function setGlobalPackageManager(packageManager) {
  if (!PACKAGE_MANAGERS[packageManager]) {
    console.error(`不支持的包管理器: ${packageManager}`);
    return false;
  }

  const configPath = getGlobalConfigPath();
  const configDir = path.dirname(configPath);

  if (!fs.existsSync(configDir)) {
    fs.mkdirSync(configDir, { recursive: true });
  }

  try {
    fs.writeFileSync(
      configPath,
      JSON.stringify({ packageManager }, null, 2),
      'utf8'
    );
    return true;
  } catch (err) {
    console.error(`写入配置失败: ${err.message}`);
    return false;
  }
}

/**
 * 构建包管理器命令
 * @param {string} commandType - 命令类型 (install, run, exec)
 * @param {Object} options - 选项
 * @returns {string} 完整命令
 */
function buildCommand(commandType, options = {}) {
  const pm = getPackageManager();
  const config = pm.config;

  switch (commandType) {
    case 'install':
      return config.installCmd;
    case 'run':
      return `${config.runCmd} ${options.script || ''}`;
    case 'exec':
      return `${config.execCmd} ${options.package || ''}`;
    default:
      return config.installCmd;
  }
}

/**
 * 获取所有可用的包管理器
 * @returns {Array<{name: string, available: boolean}>} 可用包管理器列表
 */
function getAvailablePackageManagers() {
  return Object.keys(PACKAGE_MANAGERS).map(name => ({
    name,
    available: commandExists(name)
  }));
}

/**
 * 打印包管理器信息
 */
function printPackageManagerInfo() {
  const pm = getPackageManager();
  console.log(`当前包管理器: ${pm.name} (来源: ${pm.source})`);
  console.log(`配置:`);
  console.log(`  安装命令: ${pm.config.installCmd}`);
  console.log(`  运行命令: ${pm.config.runCmd}`);
  console.log(`  执行命令: ${pm.config.execCmd}`);
}

// 导出所有函数
module.exports = {
  PACKAGE_MANAGERS,
  DETECTION_PRIORITY,
  getPackageManager,
  setProjectPackageManager,
  setGlobalPackageManager,
  buildCommand,
  getAvailablePackageManagers,
  printPackageManagerInfo,
  getProjectConfigPath,
  getGlobalConfigPath,
  // 为 setup-package-manager.js 添加的导出
  setPreferredPackageManager: setGlobalPackageManager,
  detectFromLockFile,
  detectFromPackageJson,
  getSelectionPrompt: () => {
    return '\n💡 运行 /setup-pm 配置首选包管理器\n';
  }
};
