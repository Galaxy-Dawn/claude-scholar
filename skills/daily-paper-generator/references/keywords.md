# 搜索关键词列表

## 核心搜索关键词

### 脑电解码 (EEG Decoding)
- `EEG decoding`
- `brain decoding`
- `neural decoding`
- `EEG classification`
- `brain signal decoding`

### 脑电语音解码 (EEG Speech Decoding)
- `speech decoding from EEG`
- `EEG speech reconstruction`
- `articulatory feature from EEG`
- `EEG to speech`
- `neural speech decoding`

### 脑电大模型 (EEG Foundation Models)
- `EEG foundation model`
- `large EEG model`
- `pretrained EEG model`
- `brain foundation model`
- `EEG representation learning`
- `self-supervised EEG`
- `contrastive learning EEG`

### 相关主题 (Related Topics)
- `brain-computer interface`
- `BCI`
- `EEG transformer`
- `EEG language model`

## arXiv 分类筛选

推荐搜索以下 arXiv 分类：
- `cs.CV` (Computer Vision and Pattern Recognition)
- `cs.LG` (Machine Learning)
- `cs.NE` (Neural and Evolutionary Computing)
- `cs.AI` (Artificial Intelligence)
- `cs.HC` (Human-Computer Interaction)
- `q-bio.NC` (Neurons and Cognition)
- `stat.ML` (Machine Learning)

## 搜索策略

1. **组合搜索**：将关键词组合以提高精度
   - 例如：`EEG + speech + decoding`
   - 例如：`foundation + model + EEG`

2. **时间过滤**：搜索最近3个月的论文
   - 使用 `submittedDate` 排序
   - 手动过滤日期范围

3. **分类过滤**：限制在相关分类
   - 优先 `cs.CV`, `cs.LG`, `q-bio.NC`

## arXiv API 查询示例

```
# 基础查询
http://export.arxiv.org/api/query?search_query=all:EEG+decoding&start=0&max_results=50&sortBy=submittedDate&sortOrder=descending

# 分类过滤查询
http://export.arxiv.org/api/query?search_query=cat:cs.CV+OR+cat:cs.LG+OR+cat:q-bio.NC+AND+all:EEG+AND+speech+decoding&start=0&max_results=50&sortBy=submittedDate&sortOrder=descending

# 大模型查询
http://export.arxiv.org/api/query?search_query=all:EEG+AND+foundation+model&start=0&max_results=50&sortBy=submittedDate&sortOrder=descending
```
