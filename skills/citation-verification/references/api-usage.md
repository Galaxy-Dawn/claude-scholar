# API 使用指南

本文档详细说明如何使用三个主要 API 进行文献验证。

## Semantic Scholar API

### 概述

Semantic Scholar 是一个免费的学术搜索引擎,提供强大的 API 用于论文检索和元数据获取。

**优势:**
- 免费使用,无需 API key
- 覆盖广泛的学科领域
- 提供丰富的元数据
- 支持模糊搜索

**限制:**
- 请求频率限制:100 requests/5min
- 部分论文可能缺失

### API 端点

**1. 通过 Paper ID 获取论文**
```
GET https://api.semanticscholar.org/graph/v1/paper/{paper_id}
```

**2. 搜索论文**
```
GET https://api.semanticscholar.org/graph/v1/paper/search?query={query}
```

### Python 示例

**安装:**
```bash
pip install semanticscholar
```

**基本用法:**
```python
from semanticscholar import SemanticScholar

sch = SemanticScholar()

# 通过标题搜索
results = sch.search_paper("Attention is All You Need", limit=5)
for paper in results:
    print(f"Title: {paper.title}")
    print(f"Authors: {[a.name for a in paper.authors]}")
    print(f"Year: {paper.year}")
    print(f"DOI: {paper.externalIds.get('DOI', 'N/A')}")
    print("---")
```

**通过 DOI 获取:**
```python
# DOI 格式: DOI:10.48550/arXiv.1706.03762
paper = sch.get_paper("DOI:10.48550/arXiv.1706.03762")
print(f"Title: {paper.title}")
print(f"Citations: {paper.citationCount}")
```

### 字段说明

**返回的主要字段:**
- `paperId` - Semantic Scholar 内部 ID
- `title` - 论文标题
- `authors` - 作者列表
- `year` - 发表年份
- `venue` - 发表场所(会议/期刊)
- `externalIds` - 外部标识符(DOI, arXiv, PubMed 等)
- `citationCount` - 引用次数
- `abstract` - 摘要

### 错误处理

```python
try:
    paper = sch.get_paper("invalid_id")
except Exception as e:
    print(f"Error: {e}")
    # 处理错误:标记需要人工验证
```

## arXiv API

### 概述

arXiv 是预印本论文库,提供免费的 API 用于访问论文元数据。

**优势:**
- 完全免费,无需认证
- 覆盖物理、数学、计算机科学等领域
- 提供完整的论文 PDF
- 更新及时

**限制:**
- 仅限预印本论文
- 不包含已发表的期刊版本信息

### API 端点

**查询接口:**
```
GET http://export.arxiv.org/api/query?search_query={query}&start={start}&max_results={max}
```

### Python 示例

**安装:**
```bash
pip install arxiv
```

**基本用法:**
```python
import arxiv

# 通过 arXiv ID 获取
paper = next(arxiv.Search(id_list=["1706.03762"]).results())
print(f"Title: {paper.title}")
print(f"Authors: {[a.name for a in paper.authors]}")
print(f"Published: {paper.published}")
print(f"PDF URL: {paper.pdf_url}")

# 通过标题搜索
search = arxiv.Search(
    query="Attention is All You Need",
    max_results=5,
    sort_by=arxiv.SortCriterion.Relevance
)

for result in search.results():
    print(f"Title: {result.title}")
    print(f"arXiv ID: {result.entry_id.split('/')[-1]}")
    print("---")
```

### arXiv ID 格式

**识别 arXiv ID:**
- 新格式: `YYMM.NNNNN` (如 2301.12345)
- 旧格式: `arch-ive/YYMMNNN` (如 cs/0703001)

**从 URL 提取:**
```python
import re

def extract_arxiv_id(text):
    # 匹配新格式
    match = re.search(r'\d{4}\.\d{4,5}', text)
    if match:
        return match.group()
    # 匹配旧格式
    match = re.search(r'[a-z-]+/\d{7}', text)
    if match:
        return match.group()
    return None
```

## CrossRef API

### 概述

CrossRef 是 DOI 注册机构,提供权威的学术文献元数据。

**优势:**
- DOI 是最可靠的唯一标识符
- 覆盖几乎所有正式发表的论文
- 数据质量高,权威性强
- 支持 BibTeX 格式直接获取

**限制:**
- 仅限有 DOI 的论文
- 预印本通常没有 DOI

### API 端点

**通过 DOI 获取元数据:**
```
GET https://api.crossref.org/works/{doi}
```

**通过 DOI 获取 BibTeX:**
```
GET https://doi.org/{doi}
Headers: Accept: application/x-bibtex
```

### Python 示例

**通过 DOI 获取元数据:**
```python
import requests

def get_crossref_metadata(doi):
    url = f"https://api.crossref.org/works/{doi}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        return data['message']
    return None

# 示例
doi = "10.48550/arXiv.1706.03762"
metadata = get_crossref_metadata(doi)
if metadata:
    print(f"Title: {metadata['title'][0]}")
    print(f"Authors: {[f\"{a['given']} {a['family']}\" for a in metadata['author']]}")
    print(f"Published: {metadata['published']['date-parts'][0]}")
```

**通过 DOI 获取 BibTeX:**
```python
def doi_to_bibtex(doi):
    url = f"https://doi.org/{doi}"
    headers = {"Accept": "application/x-bibtex"}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.text
    return None

# 示例
bibtex = doi_to_bibtex("10.48550/arXiv.1706.03762")
print(bibtex)
```

### DOI 格式

**标准格式:**
- `10.XXXX/suffix` (如 10.1038/nature12345)
- 前缀 `10.` 是固定的
- 中间是注册机构代码
- 后缀是出版商定义的

**从文本中提取 DOI:**
```python
import re

def extract_doi(text):
    # 匹配 DOI 格式
    match = re.search(r'10\.\d{4,}/[^\s]+', text)
    if match:
        return match.group()
    return None
```

## API 选择策略

根据引用信息选择最合适的 API:

### 决策流程

```
有 DOI?
  ├─ 是 → CrossRef API (最可靠)
  └─ 否 → 有 arXiv ID?
      ├─ 是 → arXiv API
      └─ 否 → Semantic Scholar API (通用搜索)
```

### 实现示例

```python
def verify_citation(citation_info):
    """
    根据引用信息选择合适的 API 进行验证

    Args:
        citation_info: dict with keys: doi, arxiv_id, title, authors

    Returns:
        验证结果字典
    """
    # 策略 1: DOI 优先
    if citation_info.get('doi'):
        return verify_with_crossref(citation_info['doi'])

    # 策略 2: arXiv ID
    if citation_info.get('arxiv_id'):
        return verify_with_arxiv(citation_info['arxiv_id'])

    # 策略 3: 通用搜索
    if citation_info.get('title'):
        return verify_with_semantic_scholar(
            citation_info['title'],
            citation_info.get('authors')
        )

    return {'status': 'insufficient_info'}
```

## 最佳实践

### 1. 错误处理

```python
import time
from requests.exceptions import RequestException

def api_call_with_retry(func, max_retries=3):
    """带重试的 API 调用"""
    for i in range(max_retries):
        try:
            return func()
        except RequestException as e:
            if i == max_retries - 1:
                raise
            time.sleep(2 ** i)  # 指数退避
```

### 2. 速率限制

```python
import time

class RateLimiter:
    def __init__(self, calls_per_minute):
        self.calls_per_minute = calls_per_minute
        self.last_call = 0

    def wait_if_needed(self):
        elapsed = time.time() - self.last_call
        min_interval = 60.0 / self.calls_per_minute
        if elapsed < min_interval:
            time.sleep(min_interval - elapsed)
        self.last_call = time.time()

# 使用示例
limiter = RateLimiter(calls_per_minute=20)
limiter.wait_if_needed()
result = api_call()
```

### 3. 缓存结果

```python
import json
from pathlib import Path

class APICache:
    def __init__(self, cache_dir=".cache"):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(exist_ok=True)

    def get(self, key):
        cache_file = self.cache_dir / f"{key}.json"
        if cache_file.exists():
            return json.loads(cache_file.read_text())
        return None

    def set(self, key, value):
        cache_file = self.cache_dir / f"{key}.json"
        cache_file.write_text(json.dumps(value))
```

## 总结

### API 对比

| API | 优势 | 限制 | 推荐场景 |
|-----|------|------|----------|
| **CrossRef** | 最权威,支持 BibTeX | 仅限有 DOI 的论文 | 有 DOI 时首选 |
| **arXiv** | 免费,更新快 | 仅限预印本 | arXiv 论文 |
| **Semantic Scholar** | 覆盖广,模糊搜索 | 部分论文缺失 | 通用搜索 |

### 验证可靠性排序

1. **CrossRef (DOI)** - 最可靠
2. **arXiv (arXiv ID)** - 可靠
3. **Semantic Scholar (标题搜索)** - 较可靠,需要人工确认

