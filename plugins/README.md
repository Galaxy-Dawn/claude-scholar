# Recommended Plugins

This document lists the recommended plugins for Claude Scholar. These plugins enhance functionality but are **optional** - the core skills and commands work without them.

## What are Plugins?

Plugins extend Claude Code with additional **skills**, **commands**, and **agents** from external sources.

## Installation Steps

### Step 1: Add Plugin Marketplace

First, add the official Claude plugins marketplace:

```bash
claude plugin marketplace add https://github.com/anthropics/claude-plugins-official
```

### Step 2: Install Plugins

After adding the marketplace, install specific plugins:

```bash
# Superpowers - Project management and development workflows
claude plugin install superpowers@claude-plugins-official

# GitHub - GitHub integration
claude plugin install github@claude-plugins-official

# Figma - Design integration
claude plugin install figma@claude-plugins-official

# Hookify - Hook development
claude plugin install hookify@claude-plugins-official
```

---

## Community Marketplaces

### AI Research Skills
**Source:** `zechenzhangAGI/AI-research-SKILLs`

**Skills Included:**
- `ml-paper-writing` - Academic paper writing guidance
- `model-architecture` - ML architecture patterns
- `emerging-techniques` - Latest research techniques
- `distributed-training` - Distributed training patterns
- `fine-tuning` - Model fine-tuning workflows
- And more...

**Installation:**

First add the marketplace:
```bash
claude plugin marketplace add https://github.com/zechenzhangAGI/AI-research-SKILLs
```

Then install skills:
```bash
claude plugin install ml-paper-writing@ai-research-skills
claude plugin install model-architecture@ai-research-skills
```

---

### Document Skills
**Source:** `anthropics/skills`

**Skills Included:**
- Document processing (PDF, DOCX, PPTX, XLSX)
- Collaboration workflows (doc-coauthoring)
- Design tools (canvas-design, brand-guidelines)
- Algorithmic art generation
- And more...

**Installation:**

First add the marketplace:
```bash
claude plugin marketplace add https://github.com/anthropics/skills
```

Then install skills:
```bash
claude plugin install pdf@document-skills
claude plugin install docx@document-skills
```

---

## Quick Setup Script

```bash
# 1. Add official marketplace
claude plugin marketplace add https://github.com/anthropics/claude-plugins-official

# 2. Install official plugins
claude plugin install superpowers@claude-plugins-official
claude plugin install github@claude-plugins-official
claude plugin install figma@claude-plugins-official
claude plugin install hookify@claude-plugins-official

# 3. Add AI research skills marketplace
claude plugin marketplace add https://github.com/zechenzhangAGI/AI-research-SKILLs

# 4. Add document skills marketplace
claude plugin marketplace add https://github.com/anthropics/skills

# 5. Install specific skills from marketplaces
claude plugin install ml-paper-writing@ai-research-skills
```

## Notes

- All plugins are **optional** - Claude Scholar works without them
- Plugins provide **enhanced functionality** for specific workflows
- Install plugins based on your specific needs
- Check each plugin's documentation for additional setup requirements
