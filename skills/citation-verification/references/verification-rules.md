# 验证规则

本文档详细说明四层验证机制的具体规则和匹配算法。

## Layer 1: Format Validation (格式验证)

### BibTeX 格式检查

**必填字段验证:**

不同类型的 BibTeX 条目有不同的必填字段要求:

**@article (期刊论文):**
- 必填: `author`, `title`, `journal`, `year`
- 可选: `volume`, `number`, `pages`, `doi`

**@inproceedings (会议论文):**
- 必填: `author`, `title`, `booktitle`, `year`
- 可选: `pages`, `organization`, `doi`

**@book (书籍):**
- 必填: `author` 或 `editor`, `title`, `publisher`, `year`
- 可选: `volume`, `series`, `address`

**@misc (其他):**
- 必填: `title`
- 可选: `author`, `howpublished`, `year`, `note`

### 格式检查规则

**1. 条目结构检查**
```python
def check_bibtex_structure(entry):
    """检查 BibTeX 条目结构"""
    errors = []

    # 检查是否有类型
    if not entry.get('ENTRYTYPE'):
        errors.append("Missing entry type")

    # 检查是否有 ID
    if not entry.get('ID'):
        errors.append("Missing citation key")

    # 检查必填字段
    required = get_required_fields(entry.get('ENTRYTYPE'))
    for field in required:
        if not entry.get(field):
            errors.append(f"Missing required field: {field}")

    return errors
```

**2. 字段格式检查**
```python
def check_field_format(entry):
    """检查字段格式"""
    errors = []

    # 年份格式检查
    if 'year' in entry:
        year = entry['year']
        if not year.isdigit() or len(year) != 4:
            errors.append(f"Invalid year format: {year}")
        if int(year) < 1900 or int(year) > 2030:
            errors.append(f"Year out of reasonable range: {year}")

    # DOI 格式检查
    if 'doi' in entry:
        doi = entry['doi']
        if not doi.startswith('10.'):
            errors.append(f"Invalid DOI format: {doi}")

    return errors
```

### LaTeX 引用检查

**1. 引用命令检查**
```python
def check_latex_citations(tex_content):
    """检查 LaTeX 引用命令"""
    import re

    # 查找所有引用命令
    cite_pattern = r'\\cite(?:\[[^\]]*\])?\{([^}]+)\}'
    citations = re.findall(cite_pattern, tex_content)

    # 展开多个引用
    all_keys = []
    for cite in citations:
        keys = [k.strip() for k in cite.split(',')]
        all_keys.extend(keys)

    return all_keys
```

**2. 引用一致性检查**
```python
def check_citation_consistency(tex_keys, bib_keys):
    """检查引用一致性"""
    tex_set = set(tex_keys)
    bib_set = set(bib_keys)

    # 未定义的引用
    undefined = tex_set - bib_set

    # 未使用的引用
    unused = bib_set - tex_set

    return {
        'undefined': list(undefined),
        'unused': list(unused)
    }
```

## Layer 2: Existence Verification (存在性验证)

### API 验证流程

**验证步骤:**
1. 根据引用信息选择 API (DOI → CrossRef, arXiv ID → arXiv, 其他 → Semantic Scholar)
2. 调用 API 获取论文信息
3. 判断论文是否存在

**验证结果:**
- `exists` - 论文存在
- `not_found` - 论文不存在
- `api_error` - API 调用失败,需要人工验证

### 验证代码示例

```python
def verify_existence(citation_info):
    """验证论文存在性"""
    # DOI 优先
    if citation_info.get('doi'):
        result = verify_with_crossref(citation_info['doi'])
        if result['status'] == 'success':
            return {'exists': True, 'source': 'crossref', 'data': result['data']}

    # arXiv ID
    if citation_info.get('arxiv_id'):
        result = verify_with_arxiv(citation_info['arxiv_id'])
        if result['status'] == 'success':
            return {'exists': True, 'source': 'arxiv', 'data': result['data']}

    # 通用搜索
    if citation_info.get('title'):
        result = verify_with_semantic_scholar(citation_info['title'])
        if result['status'] == 'success' and result['data']:
            return {'exists': True, 'source': 'semantic_scholar', 'data': result['data']}

    return {'exists': False, 'source': None}
```

## Layer 3: Information Matching (信息匹配)

### 匹配算法

**1. 标题匹配**

使用模糊匹配算法,允许轻微差异:

```python
from difflib import SequenceMatcher

def match_title(title1, title2, threshold=0.85):
    """标题匹配"""
    # 标准化:小写、去除标点
    def normalize(text):
        import re
        text = text.lower()
        text = re.sub(r'[^\w\s]', '', text)
        return ' '.join(text.split())

    t1 = normalize(title1)
    t2 = normalize(title2)

    # 计算相似度
    ratio = SequenceMatcher(None, t1, t2).ratio()

    return {
        'match': ratio >= threshold,
        'similarity': ratio
    }
```

**2. 作者匹配**

考虑作者顺序和名字格式差异:

```python
def match_authors(authors1, authors2, threshold=0.7):
    """作者匹配"""
    def normalize_name(name):
        # 处理 "Last, First" 和 "First Last" 格式
        parts = name.replace(',', '').split()
        return ' '.join(sorted(parts)).lower()

    names1 = [normalize_name(a) for a in authors1]
    names2 = [normalize_name(a) for a in authors2]

    # 计算交集比例
    set1 = set(names1)
    set2 = set(names2)
    intersection = len(set1 & set2)
    union = len(set1 | set2)

    if union == 0:
        return {'match': False, 'similarity': 0}

    ratio = intersection / union

    return {
        'match': ratio >= threshold,
        'similarity': ratio
    }
```

**3. 年份匹配**

允许 ±1 年的差异(考虑预印本和正式发表的时间差):

```python
def match_year(year1, year2, tolerance=1):
    """年份匹配"""
    try:
        y1 = int(year1)
        y2 = int(year2)
        diff = abs(y1 - y2)
        return {
            'match': diff <= tolerance,
            'difference': diff
        }
    except (ValueError, TypeError):
        return {'match': False, 'difference': None}
```

## Layer 4: Content Validation (内容验证)

### 综合匹配评分

综合所有匹配结果,计算总体匹配分数:

```python
def calculate_match_score(citation, api_data):
    """计算综合匹配分数"""
    scores = {}
    weights = {
        'title': 0.4,
        'authors': 0.3,
        'year': 0.2,
        'venue': 0.1
    }

    # 标题匹配
    if citation.get('title') and api_data.get('title'):
        result = match_title(citation['title'], api_data['title'])
        scores['title'] = result['similarity']

    # 作者匹配
    if citation.get('authors') and api_data.get('authors'):
        result = match_authors(citation['authors'], api_data['authors'])
        scores['authors'] = result['similarity']

    # 年份匹配
    if citation.get('year') and api_data.get('year'):
        result = match_year(citation['year'], api_data['year'])
        scores['year'] = 1.0 if result['match'] else 0.0

    # 计算加权总分
    total_score = 0
    total_weight = 0
    for key, weight in weights.items():
        if key in scores:
            total_score += scores[key] * weight
            total_weight += weight

    if total_weight == 0:
        return 0

    return total_score / total_weight
```

### 验证结果判定

根据匹配分数判定验证结果:

```python
def judge_verification_result(match_score):
    """判定验证结果"""
    if match_score >= 0.9:
        return {
            'status': 'verified',
            'level': 'high_confidence',
            'message': '✅ 验证通过 - 信息完全匹配'
        }
    elif match_score >= 0.7:
        return {
            'status': 'partial_match',
            'level': 'medium_confidence',
            'message': '⚠️ 部分匹配 - 信息有轻微差异,建议人工确认'
        }
    elif match_score >= 0.5:
        return {
            'status': 'low_match',
            'level': 'low_confidence',
            'message': '❌ 匹配度低 - 信息差异较大,需要人工验证'
        }
    else:
        return {
            'status': 'failed',
            'level': 'no_confidence',
            'message': '❌ 验证失败 - 信息严重不匹配或论文不存在'
        }
```

## 完整验证流程

### 主验证函数

```python
def verify_citation_complete(citation):
    """完整的引用验证流程"""
    result = {
        'citation_key': citation.get('ID'),
        'layers': {}
    }

    # Layer 1: 格式验证
    format_errors = check_bibtex_structure(citation)
    format_errors.extend(check_field_format(citation))
    result['layers']['format'] = {
        'passed': len(format_errors) == 0,
        'errors': format_errors
    }

    # Layer 2: 存在性验证
    existence = verify_existence(citation)
    result['layers']['existence'] = existence

    if not existence['exists']:
        result['final_status'] = 'not_found'
        return result

    # Layer 3 & 4: 信息匹配和内容验证
    api_data = existence['data']
    match_score = calculate_match_score(citation, api_data)
    judgment = judge_verification_result(match_score)

    result['layers']['matching'] = {
        'score': match_score,
        'judgment': judgment
    }

    result['final_status'] = judgment['status']
    result['confidence'] = judgment['level']

    return result
```

## 验证阈值配置

### 可调整的阈值参数

```python
VERIFICATION_THRESHOLDS = {
    # 匹配阈值
    'title_similarity': 0.85,      # 标题相似度阈值
    'author_similarity': 0.70,     # 作者相似度阈值
    'year_tolerance': 1,           # 年份容差

    # 判定阈值
    'high_confidence': 0.90,       # 高置信度阈值
    'medium_confidence': 0.70,     # 中等置信度阈值
    'low_confidence': 0.50,        # 低置信度阈值

    # 权重配置
    'weights': {
        'title': 0.4,
        'authors': 0.3,
        'year': 0.2,
        'venue': 0.1
    }
}
```

### 阈值调整建议

**严格模式** (用于正式发表):
- title_similarity: 0.90
- author_similarity: 0.80
- high_confidence: 0.95

**宽松模式** (用于初稿):
- title_similarity: 0.80
- author_similarity: 0.60
- high_confidence: 0.85

