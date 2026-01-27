# Recommended Plugins

This document lists the recommended plugins for Claude Scholar. These plugins enhance functionality but are **optional** - the core skills and commands work without them.

## Official Plugins (claude-plugins-official)

### Superpowers
**Purpose:** Essential superpowers commands for project management, brainstorming, and development workflows.

**Installation:**
```bash
claude mcp add superpowers -- github anthropics/claude-plugins-official
```

---

### GitHub
**Purpose:** GitHub integration for creating repositories, managing issues, and pull requests.

**Installation:**
```bash
claude mcp add github -- github anthropics/claude-plugins-official
```

---

### Figma
**Purpose:** Figma integration for design system creation and implementation.

**Installation:**
```bash
claude mcp add figma -- github anthropics/claude-plugins-official
```

---

### Hookify
**Purpose:** Hook development and event handling capabilities.

**Installation:**
```bash
claude mcp add hookify -- github anthropics/claude-plugins-official
```

---

## Marketplace Plugins

### AI Research Skills
**Repository:** `zechenzhangAGI/AI-research-SKILLs`

**Skills Included:**
- `ml-paper-writing` - Academic paper writing guidance
- `model-architecture` - ML architecture patterns
- `emerging-techniques` - Latest research techniques
- `distributed-training` - Distributed training patterns
- `fine-tuning` - Model fine-tuning workflows
- `post-training` - Post-training techniques
- `inference-serving` - Model serving
- `mechanistic-interpretability` - Interpretability methods
- `data-processing` - Data processing pipelines
- And more...

**Installation:**
```bash
claude mcp add ai-research-skills -- github zechenzhangAGI/AI-research-SKILLs
```

---

### Document Skills
**Repository:** `anthropics/skills`

**Skills Included:**
- Document processing (PDF, DOCX, PPTX, XLSX)
- Collaboration workflows (doc-coauthoring)
- Design tools (canvas-design, brand-guidelines)
- Algorithmic art generation
- And more...

**Installation:**
```bash
claude mcp add document-skills -- github anthropics/skills
```

---

## Quick Install All Recommended Plugins

```bash
# Official plugins
claude mcp add superpowers -- github anthropics/claude-plugins-official
claude mcp add github -- github anthropics/claude-plugins-official
claude mcp add figma -- github anthropics/claude-plugins-official
claude mcp add hookify -- github anthropics/claude-plugins-official

# Marketplace plugins
claude mcp add ai-research-skills -- github zechenzhangAGI/AI-research-SKILLs
claude mcp add document-skills -- github anthropics/skills
```

## Notes

- All plugins are **optional** - Claude Scholar works without them
- Plugins provide **enhanced functionality** for specific workflows
- Install plugins based on your specific needs
- Some plugins may require additional setup (check their documentation)
