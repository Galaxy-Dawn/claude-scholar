# Recommended Plugins

This document lists the recommended plugins for Claude Scholar. These plugins enhance functionality but are optional - the core skills and commands work without them.

## Official Plugins

### Superpowers (Required)
**Installation:**
```bash
claude mcp add superpowers -- npx -y mcp-remote "https://mcp.superpowers.ai/v1"
```

**Purpose:** Provides essential superpowers commands for project management, brainstorming, and development workflows.

---

### GitHub Integration
**Installation:**
```bash
claude mcp add github -- npx -y mcp-remote "https://mcp.github.io"
```

**Purpose:** Enables GitHub integration for creating repositories, managing issues, and pull requests.

---

### Figma Integration
**Installation:**
```bash
claude mcp add figma -- npx -y mcp-remote "https://mcp.figma.com"
```

**Purpose:** Enables Figma integration for design system creation and implementation.

---

## Marketplace Plugins

### AI Research Skills
**Marketplace:** `ai-research-skills`

**Skills Included:**
- `ml-paper-writing` - Academic paper writing guidance
- `model-architecture` - ML architecture patterns
- `emerging-techniques` - Latest research techniques
- `distributed-training` - Distributed training patterns
- `fine-tuning` - Model fine-tuning workflows
- And more...

**Installation:**
```bash
claude mcp add ai-research-skills -- "https://github.com/zechenzhangAGI/ai-research-SKILLs"
```

---

### Document Skills
**Marketplace:** `anthropic-agent-skills`

**Skills Included:**
- Document processing (PDF, DOCX, PPTX)
- Collaboration workflows
- Design tools
- And more...

**Installation:**
```bash
claude mcp add document-skills -- "https://github.com/anthropics/anthropic-agent-skills"
```

---

## Installation Summary

To install all recommended plugins:

```bash
# Core functionality
claude mcp add superpowers -- npx -y mcp-remote "https://mcp.superpowers.ai/v1"

# GitHub integration
claude mcp add github -- npx -y mcp-remote "https://mcp.github.io"

# Figma integration
claude mcp add figma -- npx -y mcp-remote "https://mcp.figma.com"

# AI research skills
claude mcp add ai-research-skills -- "https://github.com/zechenzhangAGI/ai-research-SKILLs"

# Document skills
claude mcp add document-skills -- "https://github.com/anthropics/anthropic-agent-skills"
```

## Note

- All plugins are **optional** - Claude Scholar works without them
- Plugins provide **enhanced functionality** for specific workflows
- Install plugins based on your specific needs
