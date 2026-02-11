# Citation Verification Reference Files

## 文件用途

本目录中的文件提供**背景知识和参考信息**，用于理解引用验证的原理和常见问题。

**重要**: 这些文件不是主要工作流的一部分。实际的引用验证使用 WebSearch 和 Google Scholar。

## 文件说明

### common-errors.md

**内容**: 常见引用错误模式和修复方法

**用途**:
- 了解学术写作中常见的引用错误
- 学习如何识别和修复这些错误
- 理解为什么需要验证引用

**何时参考**: 当需要了解引用错误的类型和修复方法时

### verification-rules.md

**内容**: 详细的验证规则和匹配算法

**用途**:
- 理解引用验证的完整逻辑
- 了解如何匹配标题、作者、年份等信息
- 学习验证的技术细节

**何时参考**: 当需要深入了解验证逻辑时

### api-usage.md

**内容**: API 使用指南（CrossRef、arXiv、Semantic Scholar）

**用途**:
- 了解学术API的使用方法
- 理解API验证的原理
- 参考高级用例的实现

**何时参考**: 当需要了解API验证方法时（注意：主要工作流使用 WebSearch）

## 主要工作流

**实际的引用验证应该使用 `ml-paper-writing` skill 中的 Citation Workflow：**

1. 使用 WebSearch 查找论文
2. 在 Google Scholar 上验证
3. 从 Google Scholar 获取 BibTeX
4. 验证声明（如需要）
5. 添加到 bibliography

详见 `ml-paper-writing` skill 的 "Citation Workflow (Hallucination Prevention)" 部分。

## 使用建议

**对于日常论文写作**:
- ✅ 使用 `ml-paper-writing` skill 的 Citation Workflow
- ✅ 使用 WebSearch 和 Google Scholar
- ✅ 参考这些文件了解背景知识
- ❌ 不要使用API方法作为主要工作流

**对于理解验证原理**:
- 阅读 `common-errors.md` 了解常见错误
- 阅读 `verification-rules.md` 了解验证逻辑
- 阅读 `api-usage.md` 了解API方法（参考用）

## 更多信息

详见 `citation-verification` skill 的 SKILL.md 文件。
