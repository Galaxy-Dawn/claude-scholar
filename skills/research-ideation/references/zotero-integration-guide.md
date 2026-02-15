# Zotero MCP 集成指南

通过 Zotero MCP 服务器实现文献管理的自动化集成。

## 1. 可用工具

### 1.1 浏览工具

| 工具 | 功能 | 使用场景 |
|------|------|---------|
| `get_collections` | 列出所有集合 | 查看已有研究项目 |
| `get_collection_items` | 获取集合中的条目 | 浏览特定集合的论文 |
| `search_library` | 搜索库中的条目 | 按关键词查找已有论文 |
| `get_items_details` | 批量获取条目元数据 | 获取论文详细信息 |
| `get_item_fulltext` | 获取 PDF 全文 | 阅读论文内容 |

### 1.2 添加工具

| 工具 | 功能 | 使用场景 |
|------|------|---------|
| `add_items_by_doi` | 通过 DOI 添加论文 | 自动获取元数据和 OA PDF |
| `add_web_item` | 保存网页为条目 | 保存非论文资源 |
| `create_collection` | 创建集合 | 组织研究项目 |
| `import_pdf_to_zotero` | 导入 PDF | 上传本地或在线 PDF |
| `find_and_attach_pdfs` | 批量附加 OA PDF | 为已有条目查找 PDF |
| `add_linked_url_attachment` | 附加 URL 链接 | 关联在线资源 |

### 1.3 引用工具

| 工具 | 功能 | 使用场景 |
|------|------|---------|
| `inject_citations` | 注入引用到 Word | 生成引用格式 |

## 2. 集合组织策略

### 2.1 命名规范

```
Research-{主题关键词}-{YYYY}
```

示例：
- `Research-TransformerInterpretability-2026`
- `Research-BrainDecoding-2026`
- `Research-RLHF-2026`

### 2.2 标准子集合结构

```
📁 Research-{topic}-{date}
  ├── 📁 Core Papers（核心论文）
  ├── 📁 Methods（方法论文）
  ├── 📁 Applications（应用论文）
  ├── 📁 Baselines（基线论文）
  └── 📁 To-Read（待读论文）
```

各子集合用途：

| 子集合 | 收录标准 | 典型数量 |
|--------|---------|---------|
| Core Papers | 直接相关、高引用的关键论文 | 5-15 篇 |
| Methods | 技术方法参考，可借鉴的方法论 | 10-20 篇 |
| Applications | 应用场景参考，领域实践 | 5-10 篇 |
| Baselines | 实验对比基准，需要复现的工作 | 3-8 篇 |
| To-Read | 初步筛选，待深入阅读 | 不限 |

## 3. 自动化工作流

### 3.1 论文发现与导入

```
WebSearch 搜索论文
    ↓
从搜索结果中提取 DOI
    ↓
add_items_by_doi 批量添加到 Zotero
    ↓
find_and_attach_pdfs 自动附加 OA PDF
    ↓
get_item_fulltext 读取全文进行分析
```

### 3.2 DOI 提取技巧

**从搜索结果 URL 中识别 DOI**：
- `https://doi.org/10.xxxx/xxxxx` — 直接 DOI 链接
- `https://dl.acm.org/doi/10.xxxx/xxxxx` — ACM Digital Library
- `https://arxiv.org/abs/xxxx.xxxxx` — arXiv（DOI：`10.48550/arXiv.xxxx.xxxxx`）

**常见 DOI 格式**：
- 以 `10.` 开头，包含 `/` 分隔符
- 例：`10.1038/s41586-023-06747-5`（Nature）
- 例：`10.48550/arXiv.2301.00234`（arXiv）
- 例：`10.1145/3580305.3599256`（ACM/KDD）

**CrossRef 查询**：
- 当 URL 中没有明显 DOI 时，可通过论文标题在 CrossRef 搜索获取 DOI

### 3.3 全文阅读与笔记

```
get_item_fulltext 获取全文
    ↓
分析论文内容
    ↓
提取关键信息
    ↓
生成结构化笔记
```

### 3.4 笔记模板

每篇论文的结构化笔记应包含：

```markdown
## [论文标题]

**基本信息**：
- 作者：
- 会议/期刊：
- 年份：
- DOI：

**研究问题**：
- 解决什么问题？
- 为什么重要？

**核心方法**：
- 主要技术路线
- 关键创新点

**关键发现**：
- 主要实验结果
- 重要结论

**局限性**：
- 方法局限
- 实验局限

**与本研究的关联**：
- 可借鉴之处
- 差异和改进空间
```

## 4. 常见问题

### 4.1 API 速率限制

Zotero API 有速率限制，批量添加时建议：
- 每批不超过 10 篇论文
- 批次之间适当间隔
- 如遇到 429 错误，等待后重试

### 4.2 PDF 全文索引延迟

新上传的 PDF 需要时间索引：
- `get_item_fulltext` 返回空时，稍后重试
- Zotero 客户端需要运行才能完成索引
- 大型 PDF 索引时间较长

### 4.3 DOI 无法识别

部分论文可能没有标准 DOI：
- arXiv 预印本：使用 `10.48550/arXiv.{id}` 格式
- Workshop 论文：尝试从出版商页面获取
- 无法获取 DOI：使用 `add_web_item` 保存网页链接

### 4.4 OA PDF 不可用

非开放获取论文无法通过 Unpaywall 获取 PDF：
- 检查作者主页是否有预印本版本
- 检查 arXiv 是否有对应版本
- 需手动上传时使用 `import_pdf_to_zotero`
