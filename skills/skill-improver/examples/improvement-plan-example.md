# Skill Improvement Plan: example-skill

## Priority Summary
- **High Priority**: 2 items
- **Medium Priority**: 1 item
- **Low Priority**: 1 item

## High Priority Improvements

### 1. Fix Description Trigger Phrases
**File**: SKILL.md:3:4
**Dimension**: Description Quality
**Impact**: +20 points

**Current**:
```yaml
---
name: example-skill
description: A helpful skill for various tasks
---
```

**Suggested**:
```yaml
---
name: api-contract-manager
description: This skill should be used when the user asks to "validate API contract", "check API compatibility", or "detect breaking changes"
---
```

**Reason**: The current description lacks specific trigger phrases and uses first-person format. The suggested version follows third-person format with clear trigger phrases.

### 2. Convert to Imperative Form
**File**: SKILL.md:50:55
**Dimension**: Writing Style
**Impact**: +15 points

**Current**:
```markdown
You should create the file first.
You need to validate the input.
```

**Suggested**:
```markdown
Create the file first.
Validate the input.
```

**Reason**: Skills must use imperative form without second-person language.

## Medium Priority Improvements

### 3. Add Progressive Disclosure
**File**: SKILL.md
**Dimension**: Content Organization
**Impact**: +10 points

**Current**: All content in SKILL.md (3000+ words)

**Suggested**: Move detailed content to references/ directory, keep SKILL.md under 2000 words

**Reason**: SKILL.md should follow progressive disclosure principles with lean main content and detailed references.

## Low Priority Improvements

### 4. Add Examples
**File**: examples/demo.md (new file)
**Dimension**: Structural Integrity
**Impact**: +5 points

**Suggested**: Create examples/demo.md with working demonstration

**Reason**: Examples help users understand how to use the skill effectively.

## Estimated Time to Complete
- High Priority: 1 hour
- Medium Priority: 2 hours
- Low Priority: 30 minutes
- **Total**: 3.5 hours

## Expected Score Improvement
- Current: 67/100 (D+)
- After High Priority: 82/100 (B-)
- After All: 87/100 (B+)
