#!/usr/bin/env node
'use strict';

// Execute the installed shell commands, without running real hooks or using the
// developer's home directory. The space in the test home catches path quoting bugs.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const settingsPath = process.argv[2] || path.join(__dirname, '..', 'settings.json.template');
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
const hookFiles = {
  PreToolUse: 'security-guard.js',
  SessionEnd: 'session-summary.js',
  SessionStart: 'session-start.js',
  Stop: 'stop-summary.js',
  UserPromptSubmit: 'skill-forced-eval.js',
};
const testRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'scholar hook test '));

try {
  const hookDir = path.join(testRoot, '.claude', 'hooks');
  fs.mkdirSync(hookDir, { recursive: true });
  const input = JSON.stringify({ cwd: testRoot, tool_name: 'Bash' });
  const env = { ...process.env, HOME: testRoot, USERPROFILE: testRoot };

  for (const [event, filename] of Object.entries(hookFiles)) {
    const hooks = (settings.hooks[event] || []).flatMap((matcher) => matcher.hooks || []);
    const matching = hooks.filter((hook) => hook.command && hook.command.includes(filename));
    assert.equal(matching.length, 1, `${event}: expected one launcher for ${filename}`);

    for (const exitCode of [0, 2]) {
      fs.writeFileSync(path.join(hookDir, filename), [
        "const fs = require('node:fs');",
        "process.stdout.write(fs.readFileSync(0, 'utf8'));",
        "process.stderr.write('hook stderr');",
        `process.exit(${exitCode});`,
        '',
      ].join('\n'));

      const result = spawnSync(matching[0].command, {
        shell: process.env.SCHOLAR_TEST_SHELL || true,
        env,
        input,
        encoding: 'utf8',
        timeout: 10000,
        windowsHide: true,
      });
      assert.ifError(result.error);
      assert.equal(result.status, exitCode, `${event}: ${result.stderr}`);
      assert.equal(result.stdout, input, `${event}: stdin/stdout must reach the hook`);
      assert.equal(result.stderr, 'hook stderr', `${event}: stderr must reach the caller`);
    }
    console.log(`[PASS] ${event}: home path with spaces, stdio and exit codes`);
  }
} finally {
  fs.rmSync(testRoot, { recursive: true, force: true });
}
