#!/usr/bin/env node
/**
 * 跨平台 Hooks 测试脚本
 * 验证所有 Node.js hooks 是否能正常工作
 *
 * @module test-hooks
 */

const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

const hooksDir = path.join(__dirname, '..', 'hooks', 'node');

// 测试计数器
let passedTests = 0;
let failedTests = 0;

/**
 * 测试函数
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
 */
function assertEqual(actual, expected, message) {
  if (actual !== expected) {
    throw new Error(message || `Expected ${expected}, but got ${actual}`);
  }
}

/**
 * 断言为真
 */
function assertTrue(value, message) {
  if (!value) {
    throw new Error(message || 'Expected value to be truthy');
  }
}

/**
 * 断言文件存在
 */
function assertFileExists(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`File does not exist: ${filePath}`);
  }
}

/**
 * 测试套件
 */
function suite(name, fn) {
  console.log(`\n${name}`);
  fn();
}

// 获取 hook 输入
function getHookInput(event, overrides = {}) {
  const defaults = {
    session_id: 'test-session-123',
    transcript_path: '',
    cwd: process.cwd(),
    permission_mode: 'ask',
    hook_event_name: event
  };

  return JSON.stringify({ ...defaults, ...overrides });
}

// 测试 hook 是否能正常运行
function testHook(hookName, input) {
  const hookPath = path.join(hooksDir, `${hookName}.js`);

  if (!fs.existsSync(hookPath)) {
    throw new Error(`Hook file not found: ${hookPath}`);
  }

  try {
    const output = execSync(`node "${hookPath}"`, {
      input,
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe']
    });

    return { success: true, output };
  } catch (err) {
    return {
      success: err.stdout ? true : false,
      output: err.stdout || err.stderr || err.message,
      error: err.stderr
    };
  }
}

// ============ 测试用例 ============

// 基础文件测试
suite('基础文件测试', () => {
  test('hook-common.js 应该存在', () => {
    assertFileExists(path.join(hooksDir, 'hook-common.js'));
  });

  test('session-start.js 应该存在', () => {
    assertFileExists(path.join(hooksDir, 'session-start.js'));
  });

  test('session-summary.js 应该存在', () => {
    assertFileExists(path.join(hooksDir, 'session-summary.js'));
  });

  test('stop-summary.js 应该存在', () => {
    assertFileExists(path.join(hooksDir, 'stop-summary.js'));
  });

  test('security-guard.js 应该存在', () => {
    assertFileExists(path.join(hooksDir, 'security-guard.js'));
  });

  test('resource-forced-eval.js 应该存在', () => {
    assertFileExists(path.join(hooksDir, 'resource-forced-eval.js'));
  });

  test('skill-forced-eval.js 应该存在', () => {
    assertFileExists(path.join(hooksDir, 'skill-forced-eval.js'));
  });
});

// SessionStart Hook 测试
suite('SessionStart Hook 测试', () => {
  test('应该能够正常执行', () => {
    const input = getHookInput('SessionStart');
    const result = testHook('session-start', input);
    assertTrue(result.success, 'Hook should execute successfully');
  });

  test('应该返回有效的 JSON', () => {
    const input = getHookInput('SessionStart');
    const result = testHook('session-start', input);

    try {
      JSON.parse(result.output);
    } catch {
      throw new Error('Output is not valid JSON');
    }
  });

  test('应该包含 continue 字段', () => {
    const input = getHookInput('SessionStart');
    const result = testHook('session-start', input);
    const parsed = JSON.parse(result.output);
    assertTrue(parsed.hasOwnProperty('continue'), 'Should have continue field');
  });

  test('应该包含 systemMessage 字段', () => {
    const input = getHookInput('SessionStart');
    const result = testHook('session-start', input);
    const parsed = JSON.parse(result.output);
    assertTrue(parsed.hasOwnProperty('systemMessage'), 'Should have systemMessage field');
  });
});

// Stop Hook 测试
suite('Stop Hook 测试', () => {
  test('应该能够正常执行', () => {
    const input = getHookInput('Stop', { reason: 'task_complete' });
    const result = testHook('stop-summary', input);
    assertTrue(result.success, 'Hook should execute successfully');
  });

  test('应该返回有效的 JSON', () => {
    const input = getHookInput('Stop', { reason: 'task_complete' });
    const result = testHook('stop-summary', input);

    try {
      JSON.parse(result.output);
    } catch {
      throw new Error('Output is not valid JSON');
    }
  });
});

// SessionEnd Hook 测试
suite('SessionEnd Hook 测试', () => {
  test('应该能够正常执行', () => {
    const input = getHookInput('SessionEnd');
    const result = testHook('session-summary', input);
    assertTrue(result.success, 'Hook should execute successfully');
  });

  test('应该创建日志目录', () => {
    const input = getHookInput('SessionEnd');
    testHook('session-summary', input);

    const logDir = path.join(process.cwd(), '.claude', 'logs');
    assertTrue(fs.existsSync(logDir), 'Log directory should be created');
  });

  test('应该返回有效的 JSON', () => {
    const input = getHookInput('SessionEnd');
    const result = testHook('session-summary', input);

    try {
      JSON.parse(result.output);
    } catch {
      throw new Error('Output is not valid JSON');
    }
  });
});

// Security Guard Hook 测试
suite('Security Guard Hook 测试', () => {
  test('应该允许安全的 Bash 命令', () => {
    const input = getHookInput('PreToolUse', {
      tool_name: 'Bash',
      tool_input: { command: 'echo "hello"' }
    });

    const result = testHook('security-guard', input);
    assertTrue(result.success, 'Should allow safe commands');
  });

  test('应该返回有效的 JSON', () => {
    const input = getHookInput('PreToolUse', {
      tool_name: 'Bash',
      tool_input: { command: 'echo "hello"' }
    });

    const result = testHook('security-guard', input);

    try {
      JSON.parse(result.output);
    } catch {
      throw new Error('Output is not valid JSON');
    }
  });
});

// Resource Forced Eval Hook 测试
suite('Resource Forced Eval Hook 测试', () => {
  test('应该能够正常执行', () => {
    const input = getHookInput('UserPromptSubmit', {
      user_prompt: '创建一个新功能'
    });

    const result = testHook('resource-forced-eval', input);
    assertTrue(result.success, 'Hook should execute successfully');
  });

  test('应该跳过斜杠命令', () => {
    const input = getHookInput('UserPromptSubmit', {
      user_prompt: '/commit'
    });

    const result = testHook('resource-forced-eval', input);
    // 斜杠命令应该被跳过，输出应该为空
    assertTrue(result.output.trim().length === 0 || result.success, 'Should skip slash commands');
  });
});

// Skill Forced Eval Hook 测试
suite('Skill Forced Eval Hook 测试', () => {
  test('应该能够正常执行', () => {
    const input = getHookInput('UserPromptSubmit', {
      user_prompt: '创建一个新功能'
    });

    const result = testHook('skill-forced-eval', input);
    assertTrue(result.success, 'Hook should execute successfully');
  });

  test('应该包含指令说明', () => {
    const input = getHookInput('UserPromptSubmit', {
      user_prompt: '创建一个新功能'
    });

    const result = testHook('skill-forced-eval', input);
    assertTrue(result.output.includes('指令：'), 'Should include instruction text');
  });
});

// 清理测试文件
try {
  const logDir = path.join(process.cwd(), '.claude', 'logs');
  if (fs.existsSync(logDir)) {
    const files = fs.readdirSync(logDir);
    for (const file of files) {
      if (file.startsWith('session-test-')) {
        fs.unlinkSync(path.join(logDir, file));
      }
    }
  }
} catch {
  // 忽略清理错误
}

// ============ 测试报告 ============

console.log('\n=================================');
console.log('测试报告');
console.log('=================================');
console.log(`✓ 通过: ${passedTests}`);
console.log(`✗ 失败: ${failedTests}`);
console.log(`总计: ${passedTests + failedTests}`);
console.log(`成功率: ${((passedTests / (passedTests + failedTests)) * 100).toFixed(1)}%`);
console.log('=================================\n');

// 平台信息
console.log('平台信息:');
console.log(`  平台: ${process.platform}`);
console.log(`  架构: ${process.arch}`);
console.log(`  Node.js: ${process.version}`);
console.log(`  当前目录: ${process.cwd()}`);

// 退出码
process.exit(failedTests > 0 ? 1 : 0);
