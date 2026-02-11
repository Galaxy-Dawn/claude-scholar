# Citation Verification Scripts

## 状态说明

**这些脚本是参考实现，不是主要工作流的一部分。**

本目录中的Python脚本提供了基于API的引用验证实现，但**实际的引用验证工作流使用WebSearch和Google Scholar**，而不是这些脚本。

## 为什么保留这些脚本？

这些脚本作为**参考实现**保留，用于：

1. **理解验证逻辑** - 展示引用验证的完整逻辑和步骤
2. **学习API使用** - 了解如何使用CrossRef、arXiv、Semantic Scholar等API
3. **高级用例** - 对于需要批量验证或自动化的场景，可以参考这些实现

## 主要工作流

**实际的引用验证应该使用 `ml-paper-writing` skill 中的 Citation Workflow：**

1. 使用 WebSearch 查找论文
2. 在 Google Scholar 上验证
3. 从 Google Scholar 获取 BibTeX
4. 验证声明（如需要）
5. 添加到 bibliography

详见 `ml-paper-writing` skill 的 "Citation Workflow (Hallucination Prevention)" 部分。

## 脚本说明

### verify-citations.py

完整的引用验证脚本，包含：
- 四层验证机制（格式、存在性、信息匹配、内容验证）
- 多API支持（CrossRef、arXiv、Semantic Scholar）
- 报告生成

**用途**: 参考实现，了解完整的验证逻辑

### api-clients.py

API客户端库，包含：
- CrossRefClient - DOI验证
- ArXivClient - arXiv论文验证
- SemanticScholarClient - 通用学术搜索
- CitationAPIManager - 统一API管理

**用途**: 参考实现，了解如何使用学术API

### format-checker.py

BibTeX和LaTeX格式检查工具，包含：
- BibTeX格式验证
- LaTeX引用检查
- 格式错误报告

**用途**: 参考实现，了解格式检查逻辑

## 使用建议

**对于日常论文写作**:
- ✅ 使用 `ml-paper-writing` skill 的 Citation Workflow
- ✅ 使用 WebSearch 和 Google Scholar
- ❌ 不要使用这些Python脚本

**对于批量验证或自动化**:
- 可以参考这些脚本的实现
- 根据需要修改和使用
- 注意API速率限制

## 依赖安装

如果需要运行这些脚本（仅用于参考或高级用例）：

```bash
pip install bibtexparser requests semanticscholar arxiv
```

## 更多信息

详见 `citation-verification` skill 的 SKILL.md 文件。
