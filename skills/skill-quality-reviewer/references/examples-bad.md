# Common Skill Anti-Patterns

Collection of common mistakes and anti-patterns to avoid when creating Claude Skills. Learn from these examples to improve your skills.

## Anti-Pattern 1: Vague Description (F Grade)

### The Problem

```yaml
---
name: helper-skill
description: Use this skill to help with various tasks and provide useful
assistance for users.
version: 1.0.0
---
```

**Why this fails:**
- ❌ No specific trigger phrases
- ❌ Second person ("Use this skill")
- ❌ Vague and generic
- ❌ No clue what it actually does
- ❌ Users will never discover it

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Description Quality | 0/100 | No triggers, second person, vague |
| Overall | F | Cannot even get started |

### The Fix

```yaml
---
name: api-contract-manager
description: This skill should be used when the user asks to "validate API
contract", "check API compatibility", "version API schema", or "detect
breaking changes". Manages API contracts through validation, versioning,
and compatibility checking for OpenAPI 3.0 specifications.
version: 1.0.0
---
```

**Improvement:** 0/100 → 90/100 in description quality

---

## Anti-Pattern 2: Second Person Throughout (D Grade)

### The Problem

```markdown
# My Skill

## Overview
You should use this skill when you need to process data files.

## How to Use
First, you need to select your input file. You can choose from CSV,
JSON, or XML formats. Then you should configure the processing options.

## Configuration
You can set the following options:
- You must specify the output format
- You should choose a delimiter
- You need to define the schema
```

**Why this fails:**
- ❌ "You should", "you need", "you can" throughout
- ❌ Not imperative form
- ❌ Conversational rather than instructional
- ❌ Unprofessional tone

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Writing Style | 5/100 | Over 20 instances of "you" |
| Overall | D | Major style issue |

### The Fix

```markdown
# Data File Processor

## Overview
Process data files in CSV, JSON, or XML formats with configurable
schemas and output options.

## Usage
Select the input file. Configure processing options. Specify output
format and delimiter.

## Configuration
Set the following options:
- Output format (required)
- Field delimiter
- Data schema
```

**Improvement:** 5/100 → 85/100 in writing style

---

## Anti-Pattern 3: Everything in One File (C Grade)

### The Problem

```
my-skill/
└── SKILL.md (12,000 words)
```

**SKILL.md contains:**
- Overview
- Detailed API documentation (3,000 words)
- 20 complete code examples (5,000 words)
- Troubleshooting guide (2,000 words)
- FAQ (1,000 words)
- Changelog (1,000 words)

**Why this is problematic:**
- ❌ SKILL.md is 12,000 words (should be <5,000)
- ❌ Detailed content always loaded
- ❌ Wastes tokens on rarely-used content
- ❌ Difficult to navigate
- ❌ Violates progressive disclosure

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Content Organization | 10/100 | No progressive disclosure |
| Overall | C | Major organizational issue |

### The Fix

```
my-skill/
├── SKILL.md (1,800 words)
├── references/
│   ├── api-reference.md (3,000 words)
│   ├── troubleshooting.md (2,000 words)
│   └── faq.md (1,000 words)
└── examples/
    ├── basic-usage.md (1,000 words)
    ├── advanced-usage.md (2,000 words)
    └── edge-cases.md (2,000 words)
```

**SKILL.md now contains:**
- Overview
- Quick start
- Basic operations
- Links to detailed references

**Improvement:** 10/100 → 85/100 in content organization

---

## Anti-Pattern 4: Missing Required Fields (F Grade)

### The Problem

```yaml
---
name: my-skill
# Missing description!
version: 1.0.0
author: Someone
tags: [utility, helper]
---
```

**Why this fails:**
- ❌ Missing required `description` field
- ❌ Skill will never trigger
- ❌ Has unnecessary fields (author, tags)
- ❌ Cannot be discovered

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Structural Integrity | 0/100 | Missing required field |
| Description Quality | 0/100 | No description to evaluate |
| Overall | F | Fundamentally broken |

### The Fix

```yaml
---
name: data-validator
description: This skill should be used when the user asks to "validate data",
"check data format", "verify data schema", or "sanitize input". Validate and
sanitize data files against JSON schemas with support for custom validation
rules.
version: 1.0.0
---
```

**Improvement:** F → B- (80) overall

---

## Anti-Pattern 5: Broken References (D Grade)

### The Problem

**SKILL.md says:**
```markdown
## Additional Resources

See `references/api-guide.md` for complete API documentation.
Check `examples/complete-example.py` for a working example.
```

**Actual directory structure:**
```
my-skill/
├── SKILL.md
├── references/
│   └── setup-guide.md  # No api-guide.md!
└── examples/
    └── basic-example.py  # No complete-example.py!
```

**Why this fails:**
- ❌ Referenced files don't exist
- ❌ Users get errors when trying to follow references
- ❌ Incomplete skill structure

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Structural Integrity | 15/100 | Multiple broken references |
| Overall | D | Structural issues |

### The Fix

Option 1: Create the referenced files
```
my-skill/
├── SKILL.md
├── references/
│   ├── api-guide.md  # Created!
│   └── setup-guide.md
└── examples/
    ├── complete-example.py  # Created!
    └── basic-example.py
```

Option 2: Update SKILL.md to match actual files
```markdown
## Additional Resources

See `references/setup-guide.md` for setup instructions.
Check `examples/basic-example.py` for a working example.
```

**Improvement:** 15/100 → 90/100 in structural integrity

---

## Anti-Pattern 6: Inconsistent Style (C Grade)

### The Problem

```markdown
## Workflow

### Step 1: Prepare
First you should create the directory structure.

### Step 2: Configure
Configure the settings file. You need to specify the endpoint.

### Step 3: Deploy
Deploy the application. Check the logs to verify.
```

**Why this fails:**
- ❌ Mixes imperative ("Configure", "Deploy") with second person ("you should")
- ❌ Inconsistent throughout
- ❌ Confusing to read

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Writing Style | 30/100 | Inconsistent style |
| Overall | C | Style issues |

### The Fix

```markdown
## Workflow

### Step 1: Prepare
Create the directory structure.

### Step 2: Configure
Specify the endpoint in the settings file.

### Step 3: Deploy
Deploy the application. Verify by checking the logs.
```

**Improvement:** 30/100 → 85/100 in writing style

---

## Anti-Pattern 7: Overly Long Description (B Grade)

### The Problem

```yaml
---
name: file-processor
description: This skill should be used when the user asks to "process files",
"convert file formats", "validate file structure", "check file integrity",
"transform file data", "merge multiple files", "split large files", "compress
file size", "encrypt file contents", "decrypt file contents", "archive files",
"extract archives", "generate file checksums", "verify file signatures", or
"optimize file storage". This comprehensive file processing utility supports
over 50 different file formats including PDF, DOCX, XLSX, CSV, JSON, XML,
HTML, TXT, and many more. It provides advanced features like batch processing,
parallel execution, error recovery, automatic backup creation, detailed logging,
progress tracking, and notification support. Ideal for data migration tasks,
content management workflows, archival operations, and file system maintenance.
version: 1.0.0
---
```

**Why this is problematic:**
- ❌ 900+ characters (way too long)
- ❌ Lists too many trigger phrases (dilutes effectiveness)
- ❌ Becomes unreadable
- ❌ Loses focus

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Description Quality | 15/100 | Too long, unfocused |
| Overall | B | Description issue |

### The Fix

```yaml
---
name: file-processor
description: This skill should be used when the user asks to "process files",
"convert file formats", "validate file structure", "merge files", or
"compress files". Supports common formats (PDF, DOCX, CSV, JSON) with
batch processing and error recovery.
version: 1.0.0
---
```

**Improvement:** 15/100 → 85/100 in description quality

---

## Anti-Pattern 8: No Examples (C Grade)

### The Problem

```
my-skill/
├── SKILL.md (2,000 words of theory)
└── references/
    └── detailed-guide.md (3,000 words more theory)
```

**SKILL.md describes concepts but never shows:**
- How to actually use the skill
- What input looks like
- What output looks like
- Concrete usage patterns

**Why this fails:**
- ❌ Users can't visualize usage
- ❌ No working code to copy
- ❌ Theory without practice

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Structural Integrity | 50/100 | No examples despite theory |
| Overall | C | Missing practical component |

### The Fix

```
my-skill/
├── SKILL.md (2,000 words)
├── references/
│   └── detailed-guide.md
└── examples/
    ├── basic-usage.sh (working example)
    ├── advanced-usage.sh (working example)
    └── input-output-examples.md (before/after)
```

**Improvement:** 50/100 → 85/100 in structural integrity

---

## Anti-Pattern 9: Subjective Language (D Grade)

### The Problem

```markdown
## Overview

This is a really great skill that I think you'll find super useful.
It's awesome for handling difficult tasks. The best part is how
easy it is to use - you'll love it!

## Features

- Amazing performance
- Incredible flexibility
- Fantastic user experience
```

**Why this fails:**
- ❌ Highly subjective ("really great", "super useful")
- ❌ Marketing language, not instructional
- ❌ First person ("I think")
- ❌ Unprofessional tone
- ❌ No concrete information

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Writing Style | 20/100 | Subjective, unprofessional |
| Overall | D | Style issues |

### The Fix

```markdown
## Overview

Handle complex data processing tasks with configurable validation
and error recovery. Supports CSV, JSON, and XML formats with
batch processing capabilities.

## Features

- Processes 10,000+ records per second
- Configurable validation rules
- Automatic error recovery
- Detailed logging
```

**Improvement:** 20/100 → 80/100 in writing style

---

## Anti-Pattern 10: Invalid YAML (F Grade)

### The Problem

```yaml
---
name: my-skill
description: This skill should be used when the user asks to "validate data"
or "check schemas". It's designed for: data validation, schema checking, and
format verification.
version: 1.0.0
---
```

**Error:** Colon after "for" creates invalid YAML syntax

**Why this fails:**
- ❌ YAML cannot be parsed
- ❌ Skill fails to load
- ❌ Completely non-functional

### Score Impact

| Dimension | Score | Why |
|-----------|-------|-----|
| Structural Integrity | 0/100 | Invalid YAML |
| Overall | F | Cannot load |

### The Fix

```yaml
---
name: data-validator
description: This skill should be used when the user asks to "validate data",
"check schemas", or "verify formats". Performs data validation, schema
checking, and format verification.
version: 1.0.0
---
```

**Improvement:** F → B (83) overall

---

## Quick Anti-Pattern Checklist

### Description Quality
- [ ] Not vague like "helps with tasks"
- [ ] Has 3-5 specific trigger phrases
- [ ] Uses third person, not second person
- [ ] Is 100-300 characters long
- [ ] Mentions concrete use cases

### Content Organization
- [ ] SKILL.md under 5,000 words
- [ ] Detailed content in references/
- [ ] Examples in examples/ directory
- [ ] Progressive disclosure followed

### Writing Style
- [ ] No "you", "your", "you're" in body
- [ ] Uses imperative verbs (Create, Check, Run)
- [ ] Objective and factual
- [ ] No marketing language

### Structural Integrity
- [ ] YAML has name and description
- [ ] All referenced files exist
- [ ] Examples are complete
- [ ] Scripts are executable

---

## Learn From Mistakes

Each anti-pattern above represents real issues found in actual skills. Avoid these common mistakes:

1. **Vague descriptions** → Be specific with trigger phrases
2. **Second person** → Use imperative form
3. **No progressive disclosure** → Move details to references/
4. **Missing fields** → Include name and description
5. **Broken references** → Verify all files exist
6. **Inconsistent style** → Stick to imperative form
7. **Too long description** → Keep under 300 characters
8. **No examples** → Include working code
9. **Subjective language** → Be factual and objective
10. **Invalid YAML** → Validate YAML syntax

Use `examples-good.md` as a reference for what to do right.
