/**
 * 跨平台功能测试脚本
 * 验证工具函数和包管理器检测在当前平台上的正确性
 *
 * @module test-cross-platform
 */

const path = require('path');
const utils = require('./lib/utils');
const packageManager = require('./lib/package-manager');

// 测试计数器
let passedTests = 0;
let failedTests = 0;

/**
 * 测试函数
 * @param {string} name - 测试名称
 * @param {Function} fn - 测试函数
 */
function test(name, fn) {
  try {
    fn();
    console.log(`  ✓ ${name}`);
    passedTests++;
    return true;
  } catch (err) {
    console.log(`  ✗ ${name}`);
    console.log(`    Error: ${err.message}`);
    failedTests++;
    return false;
  }
}

/**
 * 断言相等
 * @param {*} actual - 实际值
 * @param {*} expected - 期望值
 * @param {string} message - 错误消息
 */
function assertEqual(actual, expected, message) {
  if (actual !== expected) {
    throw new Error(message || `Expected ${expected}, but got ${actual}`);
  }
}

/**
 * 断言为真
 * @param {*} value - 值
 * @param {string} message - 错误消息
 */
function assertTrue(value, message) {
  if (!value) {
    throw new Error(message || 'Expected value to be truthy');
  }
}

/**
 * 断言为假
 * @param {*} value - 值
 * @param {string} message - 错误消息
 */
function assertFalse(value, message) {
  if (value) {
    throw new Error(message || 'Expected value to be falsy');
  }
}

/**
 * 断言存在
 * @param {*} value - 值
 * @param {string} message - 错误消息
 */
function assertExists(value, message) {
  if (value === null || value === undefined) {
    throw new Error(message || 'Expected value to exist');
  }
}

/**
 * 测试套件
 * @param {string} name - 测试套件名称
 * @param {Function} fn - 测试函数
 */
function suite(name, fn) {
  console.log(`\n${name}`);
  fn();
}

// ============ 测试用例 ============

// 平台检测测试
suite('平台检测测试', () => {
  test('应该正确检测 Windows 平台', () => {
    if (process.platform === 'win32') {
      assertTrue(utils.isWindows, 'isWindows should be true on Windows');
    } else {
      assertFalse(utils.isWindows, 'isWindows should be false on non-Windows');
    }
  });

  test('应该正确检测 macOS 平台', () => {
    if (process.platform === 'darwin') {
      assertTrue(utils.isMacOS, 'isMacOS should be true on macOS');
    } else {
      assertFalse(utils.isMacOS, 'isMacOS should be false on non-macOS');
    }
  });

  test('应该正确检测 Linux 平台', () => {
    if (process.platform === 'linux') {
      assertTrue(utils.isLinux, 'isLinux should be true on Linux');
    } else {
      assertFalse(utils.isLinux, 'isLinux should be false on non-Linux');
    }
  });

  test('至少有一个平台标志为真', () => {
    assertTrue(
      utils.isWindows || utils.isMacOS || utils.isLinux,
      'At least one platform flag should be true'
    );
  });
});

// 路径处理测试
suite('路径处理测试', () => {
  test('getHomeDir 应该返回有效的用户目录', () => {
    const homeDir = utils.getHomeDir();
    assertExists(homeDir, 'homeDir should exist');
    assertTrue(homeDir.length > 0, 'homeDir should not be empty');
  });

  test('joinPath 应该正确拼接路径', () => {
    const result = utils.joinPath('a', 'b', 'c');
    assertTrue(result.includes('a') && result.includes('b') && result.includes('c'), 'Path should contain all parts');
  });

  test('resolvePath 应该返回绝对路径', () => {
    const result = utils.resolvePath('test');
    assertTrue(path.isAbsolute(result), 'Path should be absolute');
  });

  test('normalizePath 应该规范化路径', () => {
    const result = utils.normalizePath('a/b/../c');
    assertFalse(result.includes('..'), 'Path should not contain ..');
  });
});

// 目录操作测试
suite('目录操作测试', () => {
  const testDir = path.join(require('os').tmpdir(), 'claude-test-dir');

  test('ensureDir 应该创建目录', () => {
    const result = utils.ensureDir(testDir);
    assertTrue(require('fs').existsSync(result), 'Directory should exist');
  });

  test('ensureDir 多次调用应该安全', () => {
    const result1 = utils.ensureDir(testDir);
    const result2 = utils.ensureDir(testDir);
    assertEqual(result1, result2, 'Should return same path');
  });

  // 清理测试目录
  try {
    require('fs').rmSync(testDir, { recursive: true, force: true });
  } catch (err) {
    // 忽略清理错误
  }
});

// JSON 操作测试
suite('JSON 操作测试', () => {
  const testFile = path.join(require('os').tmpdir(), 'claude-test.json');
  const testData = { name: 'test', value: 123 };

  test('writeJSON 应该写入 JSON 文件', () => {
    const result = utils.writeJSON(testFile, testData);
    assertTrue(result, 'writeJSON should return true');
  });

  test('readJSON 应该读取 JSON 文件', () => {
    const result = utils.readJSON(testFile);
    assertEqual(result.name, testData.name, 'Name should match');
    assertEqual(result.value, testData.value, 'Value should match');
  });

  test('readJSON 应该处理不存在的文件', () => {
    const result = utils.readJSON('/nonexistent/file.json');
    assertEqual(result, null, 'Should return null for non-existent file');
  });

  // 清理测试文件
  try {
    require('fs').unlinkSync(testFile);
  } catch (err) {
    // 忽略清理错误
  }
});

// 命令检测测试
suite('命令检测测试', () => {
  test('commandExists 应该检测 node 命令', () => {
    const result = utils.commandExists('node');
    assertTrue(result, 'node command should exist');
  });

  test('commandExists 应该拒绝无效命令', () => {
    const result = utils.commandExists('this-command-definitely-does-not-exist-12345');
    assertFalse(result, 'Invalid command should not exist');
  });

  test('commandExists 应该防止命令注入', () => {
    const result1 = utils.commandExists('node; rm -rf /');
    assertFalse(result1, 'Should reject command with semicolon');
    const result2 = utils.commandExists('$(whoami)');
    assertFalse(result2, 'Should reject command with command substitution');
  });
});

// 平台信息测试
suite('平台信息测试', () => {
  test('getPlatformInfo 应该返回完整的平台信息', () => {
    const info = utils.getPlatformInfo();
    assertExists(info.platform, 'platform should exist');
    assertExists(info.arch, 'arch should exist');
    assertExists(info.nodeVersion, 'nodeVersion should exist');
    assertExists(info.homeDir, 'homeDir should exist');
    assertExists(info.tempDir, 'tempDir should exist');
  });

  test('getPlatformInfo 的 platform 应该匹配 process.platform', () => {
    const info = utils.getPlatformInfo();
    assertEqual(info.platform, process.platform, 'platform should match');
  });
});

// Claude 配置目录测试
suite('Claude 配置测试', () => {
  test('getClaudeConfigDir 应该返回 .claude 目录', () => {
    const result = utils.getClaudeConfigDir();
    assertTrue(result.includes('.claude'), 'Path should contain .claude');
  });
});

// 包管理器检测测试
suite('包管理器检测测试', () => {
  test('getPackageManager 应该返回有效的包管理器', () => {
    const result = packageManager.getPackageManager();
    assertExists(result.name, 'name should exist');
    assertExists(result.source, 'source should exist');
    assertExists(result.config, 'config should exist');
  });

  test('getPackageManager 应该至少检测到 npm', () => {
    const result = packageManager.getPackageManager();
    assertTrue(
      ['npm', 'pnpm', 'yarn', 'bun'].includes(result.name),
      'Should detect a known package manager'
    );
  });

  test('getAvailablePackageManagers 应该返回列表', () => {
    const result = packageManager.getAvailablePackageManagers();
    assertTrue(Array.isArray(result), 'Should return an array');
    assertTrue(result.length > 0, 'Should have at least one package manager');
  });

  test('getAvailablePackageManagers 每项应该有 name 和 available', () => {
    const result = packageManager.getAvailablePackageManagers();
    result.forEach(pm => {
      assertExists(pm.name, 'name should exist');
      assertExists(pm.available, 'available should exist');
    });
  });
});

// 命令构建测试
suite('命令构建测试', () => {
  test('buildCommand 应该构建安装命令', () => {
    const result = packageManager.buildCommand('install');
    assertTrue(result.includes('install'), 'Command should include install');
  });

  test('buildCommand 应该构建运行命令', () => {
    const result = packageManager.buildCommand('run', { script: 'test' });
    assertTrue(result.includes('test'), 'Command should include script name');
  });

  test('buildCommand 应该构建执行命令', () => {
    const result = packageManager.buildCommand('exec', { package: 'typescript' });
    assertTrue(result.length > 0, 'Command should not be empty');
  });
});

// ============ 测试报告 ============

console.log('\n=================================');
console.log('测试报告');
console.log('=================================');
console.log(`✓ 通过: ${passedTests}`);
console.log(`✗ 失败: ${failedTests}`);
console.log(`总计: ${passedTests + failedTests}`);
console.log(`成功率: ${((passedTests / (passedTests + failedTests)) * 100).toFixed(1)}%`);
console.log('=================================\n');

// 打印平台信息
console.log('平台信息:');
const platformInfo = utils.getPlatformInfo();
console.log(`  平台: ${platformInfo.platform}`);
console.log(`  架构: ${platformInfo.arch}`);
console.log(`  Node.js: ${platformInfo.nodeVersion}`);
console.log(`  主目录: ${platformInfo.homeDir}`);
console.log(`  临时目录: ${platformInfo.tempDir}`);

// 打印包管理器信息
console.log('\n包管理器信息:');
packageManager.printPackageManagerInfo();

// 退出码
process.exit(failedTests > 0 ? 1 : 0);
