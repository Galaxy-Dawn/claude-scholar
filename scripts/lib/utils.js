/**
 * 跨平台工具函数库
 * 为 Claude Code 插件提供跨平台兼容性支持
 *
 * @module utils
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync, spawnSync } = require('child_process');

// 平台检测常量
const isWindows = process.platform === 'win32';
const isMacOS = process.platform === 'darwin';
const isLinux = process.platform === 'linux';

/**
 * 获取用户主目录（跨平台）
 * @returns {string} 用户主目录路径
 */
function getHomeDir() {
  return os.homedir();
}

/**
 * 确保目录存在，如不存在则创建（跨平台）
 * @param {string} dirPath - 目录路径
 * @returns {string} 目录路径
 */
function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
  return dirPath;
}

/**
 * 检查命令是否存在（跨平台）
 * @param {string} cmd - 命令名称
 * @returns {boolean} 命令是否存在
 */
function commandExists(cmd) {
  // 验证命令名称安全性
  if (!/^[a-zA-Z0-9_.-]+$/.test(cmd)) {
    return false;
  }

  try {
    if (isWindows) {
      // Windows 使用 where 命令
      const result = spawnSync('where', [cmd], { stdio: 'pipe' });
      return result.status === 0;
    } else {
      // Unix-like 系统使用 which 命令
      const result = spawnSync('which', [cmd], { stdio: 'pipe' });
      return result.status === 0;
    }
  } catch {
    return false;
  }
}

/**
 * 安全执行命令（跨平台）
 * @param {string} cmd - 要执行的命令
 * @param {Object} options - 执行选项
 * @returns {{success: boolean, output: string, error?: string}} 执行结果
 */
function runCommand(cmd, options = {}) {
  try {
    const result = execSync(cmd, {
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe'],
      ...options
    });
    return { success: true, output: result.trim() };
  } catch (err) {
    return {
      success: false,
      output: err.stdout || '',
      error: err.stderr || err.message
    };
  }
}

/**
 * 获取 Claude 配置目录（跨平台）
 * @returns {string} Claude 配置目录路径
 */
function getClaudeConfigDir() {
  const homeDir = getHomeDir();
  return path.join(homeDir, '.claude');
}

/**
 * 获取项目根目录（跨平台）
 * @param {string} startDir - 起始目录
 * @returns {string|null} 项目根目录或 null
 */
function getProjectRoot(startDir = process.cwd()) {
  let currentDir = startDir;

  while (currentDir !== path.parse(currentDir).root) {
    // 检查是否存在 .claude-plugin 目录
    const pluginDir = path.join(currentDir, '.claude-plugin');
    if (fs.existsSync(pluginDir)) {
      return currentDir;
    }

    // 检查是否存在 package.json
    const packageJson = path.join(currentDir, 'package.json');
    if (fs.existsSync(packageJson)) {
      return currentDir;
    }

    // 向上移动
    currentDir = path.dirname(currentDir);
  }

  return null;
}

/**
 * 路径拼接（跨平台）
 * @param {...string} paths - 路径片段
 * @returns {string} 拼接后的路径
 */
function joinPath(...paths) {
  return path.join(...paths);
}

/**
 * 获取绝对路径（跨平台）
 * @param {...string} paths - 路径片段
 * @returns {string} 绝对路径
 */
function resolvePath(...paths) {
  return path.resolve(...paths);
}

/**
 * 规范化路径（跨平台）
 * @param {string} filePath - 文件路径
 * @returns {string} 规范化后的路径
 */
function normalizePath(filePath) {
  return path.normalize(filePath);
}

/**
 * 读取 JSON 文件（跨平台）
 * @param {string} filePath - JSON 文件路径
 * @returns {Object|null} 解析后的 JSON 对象或 null
 */
function readJSON(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(content);
  } catch {
    return null;
  }
}

/**
 * 写入 JSON 文件（跨平台）
 * @param {string} filePath - JSON 文件路径
 * @param {Object} data - 要写入的数据
 * @param {number|object|string} space - JSON 缩进空格数
 * @returns {boolean} 是否成功
 */
function writeJSON(filePath, data, space = 2) {
  try {
    ensureDir(path.dirname(filePath));
    fs.writeFileSync(filePath, JSON.stringify(data, null, space), 'utf8');
    return true;
  } catch {
    return false;
  }
}

/**
 * 复制文件（跨平台）
 * @param {string} src - 源文件路径
 * @param {string} dest - 目标文件路径
 * @returns {boolean} 是否成功
 */
function copyFile(src, dest) {
  try {
    ensureDir(path.dirname(dest));
    fs.copyFileSync(src, dest);
    return true;
  } catch {
    return false;
  }
}

/**
 * 获取平台信息
 * @returns {Object} 平台信息对象
 */
function getPlatformInfo() {
  return {
    platform: process.platform,
    isWindows,
    isMacOS,
    isLinux,
    arch: process.arch,
    nodeVersion: process.version,
    homeDir: getHomeDir(),
    tempDir: os.tmpdir()
  };
}

// 导出所有函数
module.exports = {
  isWindows,
  isMacOS,
  isLinux,
  getHomeDir,
  ensureDir,
  commandExists,
  runCommand,
  getClaudeConfigDir,
  getProjectRoot,
  joinPath,
  resolvePath,
  normalizePath,
  readJSON,
  writeJSON,
  copyFile,
  getPlatformInfo
};
