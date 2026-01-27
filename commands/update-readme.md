---
description: Update README documentation and push changes to GitHub.
---

# Update README

Update README.md file with latest project information and push to GitHub.

## Instructions

1. **Analyze Current State**
   - Read existing README.md
   - Check recent code changes (git log)
   - Identify documentation gaps

2. **Determine Updates Needed**
   Check for:
   - New features added
   - Configuration changes
   - Dependencies updated
   - Installation instructions
   - Usage examples
   - API changes

3. **Propose README Updates**
   Show sections that need updating:
   ```markdown
   Proposed changes:
   - [ ] Update Installation section (new dependencies)
   - [ ] Add usage example for feature X
   - [ ] Update API documentation
   - [ ] Fix broken links
   ```

4. **Update README**
   - Apply proposed changes
   - Maintain markdown formatting
   - Keep language consistent (中文/English)
   - Preserve structure

5. **Commit and Push**
   - Run `/update-github` with `docs(readme):` type
   - Example commit: `docs(readme): Update README Documentation`

## Example Usage

```
User: /update-readme

1. Analyzing repository state...

Recent changes:
- feat(data): Add新的Data加载器
- fix(model): Fix训练时的内存泄漏
- chore: UpdateDependency到 v2.0.0

2. Checking README.md...

Current README sections:
- Installation
- Usage
- API Reference
- Contributing

3. Proposed updates:
   [ ] Installation - Add新的Dependency说明
   [ ] Usage - AddData加载器Example
   [ ] API Reference - Update模型InterfaceDocumentation

4. Applying updates...

   Updating Installation:
   + pip install torch>=2.0.0
   + pip install transformers>=4.30.0

   Adding usage example:
   ## Data加载Example
   ```python
   from data import DataLoader
   loader = DataLoader(batch_size=32)
   ```

5. Review changes before committing...
   [Show diff]

6. Proceed with commit?
   > yes

7. Committing with: docs(readme): Update README Documentation
   Co-Authored-By: Claude <noreply@anthropic.com>

✅ README updated and pushed to GitHub!
```

## README Structure Template

When updating README, follow this structure:

```markdown
# ProjectName

简短DescriptionProject用途。

## 安装

### Dependency要求
- Python >= 3.8
- uv 或 pip

### 安装Step
```bash
uv sync
```

## 使用

### 基本用法
```python
# ExampleCode
```

### Configuration
说明ConfigurationFile位置和格式。

## API Documentation

主要Interface说明。

## Development

### RunTesting
```bash
pytest
```

### CodeStandard
- 遵循 PEP 8
- 使用 mypy 进行Class型Check
- 使用 ruff 进行 linting

## 贡献

欢迎Commit Pull Request。

## 许可证

MIT License
```

## Arguments

$ARGUMENTS can be:
- `--full` - Complete README rewrite
- `--quick` - Only update critical sections (installation, usage)
- `<section>` - Update specific section only

## Integration

After updating README, this command automatically invokes `/update-github` with `docs(readme):` commit type.
