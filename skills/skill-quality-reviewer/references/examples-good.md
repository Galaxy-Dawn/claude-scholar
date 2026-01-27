# Exemplary Skill Examples

Collection of high-quality skill examples demonstrating best practices across all quality dimensions. Study these when creating or improving skills.

## Example 1: hook-development (A+ Grade)

An exemplary skill demonstrating excellent description quality, progressive disclosure, and writing style.

### Frontmatter (Description Quality)

```yaml
---
name: hook-development
description: This skill should be used when the user asks to "create a hook",
"add a PreToolUse hook", "validate tool use", "implement prompt-based hooks",
"use ${CLAUDE_PLUGIN_ROOT}", "set up event-driven automation", "block dangerous
commands", or mentions hook events (PreToolUse, PostToolUse, Stop, SubagentStop,
SessionStart, SessionEnd, UserPromptSubmit, PreCompact, Notification). Provides
comprehensive guidance for creating and implementing Claude Code plugin hooks
with focus on advanced prompt-based hooks API.
version: 0.1.0
---
```

**Why this is excellent:**
- ✅ 8+ specific trigger phrases covering diverse scenarios
- ✅ Third-person format throughout
- ✅ Includes specific hook events for precision
- ✅ Mentions key concepts (prompt-based hooks API)
- ✅ Length is appropriate (~400 characters, acceptable for complex skill)

### Progressive Disclosure (Content Organization)

**SKILL.md structure:**
- Overview (50 words)
- Core concepts (200 words)
- Hook events reference (300 words)
- Development workflow (500 words)
- Best practices (400 words)
- **Total: ~1,650 words** - excellent length

**References/ directory:**
```
references/
├── prompt-based-hooks.md (800 words) - Detailed guide
├── hook-patterns.md (1,200 words) - Common patterns
└── migration-guide.md (900 words) - Migration info
```

**Why this is excellent:**
- ✅ SKILL.md is concise and focused
- ✅ Detailed content moved to 3 reference files
- ✅ Clear progressive disclosure
- ✅ Each reference file has specific purpose

### Writing Style (Imperative Form)

**Example from SKILL.md:**
```markdown
## Hook Development Workflow

### Step 1: Define the Hook Event
Identify which event the hook should trigger on. Review available events
in the Hook Events Reference section.

### Step 2: Create hooks.json
Create a hooks.json file in the plugin's .claude-plugin/ directory.
Specify the event type and command to execute.

### Step 3: Implement the Hook Script
Write the hook script. Ensure it is executable. Follow the prompt-based
hooks API for complex hooks.

### Step 4: Test the Hook
Test the hook locally. Verify it triggers on the correct event.
Check output and error handling.
```

**Why this is excellent:**
- ✅ Every instruction uses imperative form
- ✅ No "you", "your", "should"
- ✅ Clear, actionable steps
- ✅ Consistent style throughout

---

## Example 2: agent-development (A Grade)

Strong skill with good description and organization.

### Frontmatter

```yaml
---
name: agent-development
description: This skill should be used when the user asks to "create an agent",
"add an agent", "write a subagent", "agent frontmatter", "when to use description",
"agent examples", "agent tools", "agent colors", "autonomous agent", or needs
guidance on agent structure, system prompts, triggering conditions, or agent
development best practices for Claude Code plugins.
version: 0.1.0
---
```

**Strengths:**
- ✅ Multiple specific trigger phrases
- ✅ Covers agent creation scenarios
- ✅ Mentions specific agent attributes

### Directory Structure

```
agent-development/
├── SKILL.md (1,438 words)
├── references/
│   ├── agent-generation-prompt.md (500 words)
│   └── agent-anatomy.md (400 words)
└── examples/
    ├── task-agent.md (complete example)
    ├── review-agent.md (complete example)
    └── interactive-agent.md (complete example)
```

**Strengths:**
- ✅ Lean SKILL.md
- ✅ Focused reference files
- ✅ Complete working examples
- ✅ Clear organization

---

## Example 3: mcp-integration (A- Grade)

Comprehensive skill with excellent progressive disclosure.

### Frontmatter

```yaml
---
name: mcp-integration
description: This skill should be used when the user asks to "add MCP server",
"integrate MCP", "configure MCP in plugin", "use .mcp.json", "set up Model
Context Protocol", "connect external service", mentions "${CLAUDE_PLUGIN_ROOT}
with MCP", or discusses MCP server types (SSE, stdio, HTTP, WebSocket). Provides
comprehensive guidance for integrating Model Context Protocol servers into Claude
Code plugins for external tool and service integration.
version: 0.1.0
---
```

**Strengths:**
- ✅ Specific MCP-related trigger phrases
- ✅ Lists server types for precision
- ✅ Mentions key configuration elements

### Progressive Disclosure

**SKILL.md**: ~1,800 words (core concepts, basic setup)

**References/**:
- `mcp-server-types.md` - Detailed server type comparisons
- `mcp-configuration.md` - Configuration examples
- `mcp-best-practices.md` - Integration patterns
- `mcp-troubleshooting.md` - Common issues

**Why this works:**
- ✅ Main SKILL.md covers essentials
- ✅ Each reference is 1,000-2,000 words
- ✅ Loaded only when needed
- ✅ Clear topic separation

---

## Excellent Description Examples

### Example: API-Contract Skill (Ideal Description)

```yaml
---
name: api-contract-manager
description: This skill should be used when the user asks to "validate API contract",
"check API compatibility", "version API schema", "detect breaking changes", or
"ensure API contract compliance". Manages API contracts through validation,
versioning, and compatibility checking. Use when designing new endpoints or
ensuring backward compatibility.
version: 0.1.0
---
```

**Analysis:**
- ✅ 5 specific trigger phrases
- ✅ Third person throughout
- ✅ 230 characters (ideal length)
- ✅ Clear use cases
- ✅ Mentions when to use (designing, compatibility)

### Example: PDF-Editor Skill (Ideal Description)

```yaml
---
name: pdf-editor
description: This skill should be used when the user asks to "rotate PDF", "merge
PDF files", "split PDF pages", "compress PDF", or "crop PDF pages". Perform common
PDF manipulation operations including rotation, merging, splitting, compression,
and cropping. Works with local PDF files.
version: 0.1.0
---
```

**Analysis:**
- ✅ 5 specific operations as triggers
- ✅ Lists all supported operations
- ✅ Specifies working context (local files)
- ✅ 180 characters (excellent length)

---

## Excellent Progressive Disclosure Examples

### Example: Frontend-Builder Skill

**SKILL.md** (1,800 words):
- Overview
- Quick Start (5 steps)
- Basic Component Creation
- Common Operations
- Reference to detailed guides

**References/**:
- `react-patterns.md` (2,500 words) - React specific patterns
- `vue-patterns.md` (2,000 words) - Vue specific patterns
- `styling-guide.md` (1,800 words) - CSS/styling approaches
- `deployment.md` (1,500 words) - Build and deploy

**Examples/**:
- `hello-world-react/` - Complete React example
- `hello-world-vue/` - Complete Vue example
- `component-library/` - Reusable components

**Why this works:**
1. SKILL.md gets users started quickly
2. Framework-specific details in references/
3. Complete examples for copy-paste
4. Progressive: overview → basics → details → examples

---

## Excellent Writing Style Examples

### Example: From Test-Driven Development Skill

```markdown
## TDD Workflow

### Red: Write a Failing Test
Start by writing a test that fails. This test defines the desired behavior.
Run the test to confirm it fails.

### Green: Make the Test Pass
Write the minimum code to make the test pass. Focus on making it work,
not making it perfect. Run the test to confirm it passes.

### Refactor: Improve the Code
Refactor the code while keeping tests green. Improve structure, readability,
and maintainability. Run tests after each change.

### Repeat
Continue the cycle for each feature. Write test, make it pass, refactor.
```

**Analysis:**
- ✅ Imperative form throughout
- ✅ Clear, actionable instructions
- ✅ No second person
- ✅ Consistent style
- ✅ Easy to follow

---

## Excellent Reference File Organization

### Example: Git-Workflow Skill References

```
references/
├── commit-conventions.md (1,500 words)
│   ├── Commit message format
│   ├── Type categories
│   ├── Scope values
│   └── Examples by type
├── branch-strategy.md (1,800 words)
│   ├── Branch types
│   ├── Merging policies
│   ├── Release workflow
│   └── Hotfix procedures
└── troubleshooting.md (1,200 words)
    ├── Common issues
    ├── Recovery procedures
    └── Best practices
```

**Each reference file:**
- ✅ Focused on single topic
- ✅ Self-contained
- ✅ Cross-references others when needed
- ✅ Loaded only when relevant

---

## Key Takeaways from Excellent Skills

### 1. Description Quality

**Good descriptions:**
- Have 5+ specific trigger phrases
- Use third person consistently
- Are 100-300 characters long
- Include concrete use cases

**Example template:**
```yaml
description: This skill should be used when the user asks to "action 1",
"action 2", "action 3", or "action 4". Brief description of what the skill
does. When to use it.
```

### 2. Progressive Disclosure

**Good organization:**
- SKILL.md: 1,500-2,000 words (core only)
- references/: 1,500-2,500 words per file (details)
- examples/: Complete working code
- scripts/: Utility tools

**Rule of thumb:** If a section exceeds 500 words and covers details,
consider moving it to references/.

### 3. Writing Style

**Good style:**
- Use imperative verbs: Create, Validate, Check, Run
- Avoid: You should, You can, You need to
- Be objective and factual
- Keep instructions actionable

### 4. Structural Integrity

**Good structure:**
```
skill-name/
├── SKILL.md (required)
├── references/ (optional, for details)
├── examples/ (optional, for working code)
└── scripts/ (optional, for utilities)
```

**Validation checklist:**
- [ ] YAML frontmatter has name and description
- [ ] All referenced files exist
- [ ] Examples are complete
- [ ] Scripts are executable

---

## Study These Skills

For hands-on learning, study these high-quality skills in your environment:

```bash
# Explore hook-development structure
ls -la ~/.claude/plugins/cache/*/skills/hook-development/

# Read agent-development SKILL.md
cat ~/.claude/skills/agent-development/SKILL.md

# Review mcp-integration references
ls -la ~/.claude/skills/mcp-integration/references/
```

Each demonstrates different strengths:
- **hook-development**: Progressive disclosure, utilities
- **agent-development**: Clean examples, focused content
- **mcp-integration**: Comprehensive references, clear organization

Use these as templates when creating or improving your own skills.
