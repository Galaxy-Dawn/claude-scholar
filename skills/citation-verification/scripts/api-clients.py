#!/usr/bin/env python3
"""
API Clients for Citation Verification

提供三个主要 API 客户端:
1. CrossRefClient - DOI 验证
2. ArXivClient - arXiv 论文验证
3. SemanticScholarClient - 通用学术搜索

每个客户端都包含:
- 错误处理
- 重试机制
- 速率限制
- 结果标准化
"""

import time
import requests
from typing import Dict, List, Optional
from abc import ABC, abstractmethod


class RateLimiter:
    """速率限制器"""

    def __init__(self, calls_per_minute: int):
        self.calls_per_minute = calls_per_minute
        self.last_call = 0
        self.min_interval = 60.0 / calls_per_minute

    def wait_if_needed(self):
        """如果需要,等待以满足速率限制"""
        elapsed = time.time() - self.last_call
        if elapsed < self.min_interval:
            time.sleep(self.min_interval - elapsed)
        self.last_call = time.time()


class APIClient(ABC):
    """API 客户端基类"""

    def __init__(self, rate_limit: int = 20):
        """
        Args:
            rate_limit: 每分钟最大请求数
        """
        self.rate_limiter = RateLimiter(rate_limit)

    @abstractmethod
    def search(self, **kwargs) -> Optional[Dict]:
        """搜索论文"""
        pass

    def _retry_request(self, func, max_retries: int = 3):
        """带重试的请求"""
        for i in range(max_retries):
            try:
                self.rate_limiter.wait_if_needed()
                return func()
            except requests.exceptions.RequestException as e:
                if i == max_retries - 1:
                    raise
                time.sleep(2 ** i)  # 指数退避
        return None


class CrossRefClient(APIClient):
    """CrossRef API 客户端

    用于通过 DOI 验证论文信息

    API 文档: https://api.crossref.org/
    """

    def __init__(self, rate_limit: int = 50):
        """
        Args:
            rate_limit: 每分钟最大请求数 (CrossRef 限制较宽松)
        """
        super().__init__(rate_limit)
        self.base_url = "https://api.crossref.org"

    def search_by_doi(self, doi: str) -> Optional[Dict]:
        """通过 DOI 搜索论文

        Args:
            doi: DOI 标识符 (如 10.1038/nature12345)

        Returns:
            标准化的论文信息字典,如果未找到则返回 None
        """
        def request():
            url = f"{self.base_url}/works/{doi}"
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            return response.json()

        try:
            data = self._retry_request(request)
            if data and 'message' in data:
                return self._normalize_result(data['message'])
            return None
        except Exception as e:
            print(f"CrossRef API 错误: {e}")
            return None

    def search(self, doi: str = None, **kwargs) -> Optional[Dict]:
        """搜索论文 (统一接口)"""
        if doi:
            return self.search_by_doi(doi)
        return None

    def _normalize_result(self, data: Dict) -> Dict:
        """标准化 CrossRef 返回结果"""
        # 提取标题
        title = data.get('title', [''])[0] if 'title' in data else ''

        # 提取作者
        authors = []
        if 'author' in data:
            for author in data['author']:
                given = author.get('given', '')
                family = author.get('family', '')
                if given and family:
                    authors.append(f"{given} {family}")
                elif family:
                    authors.append(family)

        # 提取年份
        year = None
        if 'published' in data:
            date_parts = data['published'].get('date-parts', [[]])[0]
            if date_parts:
                year = date_parts[0]
        elif 'created' in data:
            date_parts = data['created'].get('date-parts', [[]])[0]
            if date_parts:
                year = date_parts[0]

        # 提取期刊/会议名称
        venue = ''
        if 'container-title' in data:
            venue = data['container-title'][0] if data['container-title'] else ''

        return {
            'title': title,
            'authors': authors,
            'year': year,
            'venue': venue,
            'doi': data.get('DOI', ''),
            'type': data.get('type', ''),
            'source': 'crossref'
        }

    def get_bibtex(self, doi: str) -> Optional[str]:
        """通过 DOI 获取 BibTeX

        Args:
            doi: DOI 标识符

        Returns:
            BibTeX 字符串,如果失败则返回 None
        """
        def request():
            url = f"https://doi.org/{doi}"
            headers = {"Accept": "application/x-bibtex"}
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            return response.text

        try:
            return self._retry_request(request)
        except Exception as e:
            print(f"获取 BibTeX 失败: {e}")
            return None


class ArXivClient(APIClient):
    """arXiv API 客户端

    用于验证 arXiv 预印本论文

    API 文档: https://info.arxiv.org/help/api/
    """

    def __init__(self, rate_limit: int = 20):
        """
        Args:
            rate_limit: 每分钟最大请求数
        """
        super().__init__(rate_limit)
        try:
            import arxiv
            self.arxiv = arxiv
        except ImportError:
            raise ImportError("需要安装 arxiv 库: pip install arxiv")

    def search_by_id(self, arxiv_id: str) -> Optional[Dict]:
        """通过 arXiv ID 搜索论文

        Args:
            arxiv_id: arXiv 标识符 (如 2301.12345 或 cs/0703001)

        Returns:
            标准化的论文信息字典,如果未找到则返回 None
        """
        def request():
            search = self.arxiv.Search(id_list=[arxiv_id])
            paper = next(search.results())
            return paper

        try:
            self.rate_limiter.wait_if_needed()
            paper = request()
            return self._normalize_result(paper)
        except StopIteration:
            print(f"arXiv 论文未找到: {arxiv_id}")
            return None
        except Exception as e:
            print(f"arXiv API 错误: {e}")
            return None

    def search_by_title(self, title: str, max_results: int = 5) -> Optional[Dict]:
        """通过标题搜索论文

        Args:
            title: 论文标题
            max_results: 最大返回结果数

        Returns:
            标准化的论文信息字典(第一个结果),如果未找到则返回 None
        """
        def request():
            search = self.arxiv.Search(
                query=f'ti:"{title}"',
                max_results=max_results,
                sort_by=self.arxiv.SortCriterion.Relevance
            )
            results = list(search.results())
            return results[0] if results else None

        try:
            self.rate_limiter.wait_if_needed()
            paper = request()
            if paper:
                return self._normalize_result(paper)
            return None
        except Exception as e:
            print(f"arXiv API 错误: {e}")
            return None

    def search(self, arxiv_id: str = None, title: str = None, **kwargs) -> Optional[Dict]:
        """搜索论文 (统一接口)"""
        if arxiv_id:
            return self.search_by_id(arxiv_id)
        elif title:
            return self.search_by_title(title)
        return None

    def _normalize_result(self, paper) -> Dict:
        """标准化 arXiv 返回结果"""
        # 提取 arXiv ID
        arxiv_id = paper.entry_id.split('/')[-1]

        return {
            'title': paper.title,
            'authors': [a.name for a in paper.authors],
            'year': paper.published.year,
            'venue': 'arXiv',
            'arxiv_id': arxiv_id,
            'doi': paper.doi if hasattr(paper, 'doi') else None,
            'abstract': paper.summary,
            'pdf_url': paper.pdf_url,
            'source': 'arxiv'
        }

    @staticmethod
    def extract_arxiv_id(text: str) -> Optional[str]:
        """从文本中提取 arXiv ID

        Args:
            text: 包含 arXiv ID 的文本

        Returns:
            arXiv ID,如果未找到则返回 None
        """
        import re

        # 匹配新格式: YYMM.NNNNN
        match = re.search(r'\d{4}\.\d{4,5}', text)
        if match:
            return match.group()

        # 匹配旧格式: arch-ive/YYMMNNN
        match = re.search(r'[a-z-]+/\d{7}', text)
        if match:
            return match.group()

        return None


class SemanticScholarClient(APIClient):
    """Semantic Scholar API 客户端

    用于通用学术论文搜索和验证

    API 文档: https://api.semanticscholar.org/api-docs/
    """

    def __init__(self, rate_limit: int = 20):
        """
        Args:
            rate_limit: 每分钟最大请求数 (Semantic Scholar 限制: 100 requests/5min)
        """
        super().__init__(rate_limit)
        try:
            from semanticscholar import SemanticScholar
            self.sch = SemanticScholar()
        except ImportError:
            raise ImportError("需要安装 semanticscholar 库: pip install semanticscholar")

    def search_by_title(self, title: str, max_results: int = 5) -> Optional[Dict]:
        """通过标题搜索论文

        Args:
            title: 论文标题
            max_results: 最大返回结果数

        Returns:
            标准化的论文信息字典(第一个结果),如果未找到则返回 None
        """
        try:
            self.rate_limiter.wait_if_needed()
            results = self.sch.search_paper(title, limit=max_results)

            if not results:
                return None

            # 返回第一个结果
            paper = results[0]
            return self._normalize_result(paper)
        except Exception as e:
            print(f"Semantic Scholar API 错误: {e}")
            return None

    def search_by_doi(self, doi: str) -> Optional[Dict]:
        """通过 DOI 搜索论文

        Args:
            doi: DOI 标识符

        Returns:
            标准化的论文信息字典,如果未找到则返回 None
        """
        try:
            self.rate_limiter.wait_if_needed()
            paper = self.sch.get_paper(f"DOI:{doi}")
            if paper:
                return self._normalize_result(paper)
            return None
        except Exception as e:
            print(f"Semantic Scholar API 错误: {e}")
            return None

    def search(self, title: str = None, doi: str = None, **kwargs) -> Optional[Dict]:
        """搜索论文 (统一接口)"""
        if doi:
            return self.search_by_doi(doi)
        elif title:
            return self.search_by_title(title)
        return None

    def _normalize_result(self, paper) -> Dict:
        """标准化 Semantic Scholar 返回结果"""
        # 提取作者
        authors = []
        if paper.authors:
            authors = [a.name for a in paper.authors]

        # 提取外部 ID
        external_ids = paper.externalIds if hasattr(paper, 'externalIds') else {}
        doi = external_ids.get('DOI') if external_ids else None
        arxiv_id = external_ids.get('ArXiv') if external_ids else None

        return {
            'title': paper.title,
            'authors': authors,
            'year': paper.year,
            'venue': paper.venue if hasattr(paper, 'venue') else '',
            'paperId': paper.paperId,
            'doi': doi,
            'arxiv_id': arxiv_id,
            'citationCount': paper.citationCount if hasattr(paper, 'citationCount') else 0,
            'abstract': paper.abstract if hasattr(paper, 'abstract') else '',
            'source': 'semantic_scholar'
        }


class CitationAPIManager:
    """统一的 API 管理器

    协调三个 API 客户端,实现智能的 API 选择策略
    """

    def __init__(self):
        """初始化所有 API 客户端"""
        self.crossref = None
        self.arxiv = None
        self.semantic_scholar = None

        # 尝试初始化各个客户端
        try:
            self.crossref = CrossRefClient()
        except Exception as e:
            print(f"警告: CrossRef 客户端初始化失败: {e}")

        try:
            self.arxiv = ArXivClient()
        except Exception as e:
            print(f"警告: arXiv 客户端初始化失败: {e}")

        try:
            self.semantic_scholar = SemanticScholarClient()
        except Exception as e:
            print(f"警告: Semantic Scholar 客户端初始化失败: {e}")

    def verify_citation(self, citation_info: Dict) -> tuple[bool, Optional[str], Optional[Dict]]:
        """验证引用

        实现 API 选择策略:
        1. DOI 优先 → CrossRef
        2. arXiv ID → arXiv
        3. 标题搜索 → Semantic Scholar

        Args:
            citation_info: 引用信息字典,可能包含 doi, arxiv_id, title, authors 等字段

        Returns:
            (exists, api_source, api_data)
            - exists: 论文是否存在
            - api_source: 验证来源 ('crossref', 'arxiv', 'semantic_scholar')
            - api_data: API 返回的标准化数据
        """
        # 策略 1: DOI 优先
        if 'doi' in citation_info and self.crossref:
            data = self.crossref.search_by_doi(citation_info['doi'])
            if data:
                return True, 'crossref', data

        # 策略 2: arXiv ID
        arxiv_id = citation_info.get('arxiv_id')
        if not arxiv_id and 'note' in citation_info:
            # 尝试从 note 字段提取 arXiv ID
            arxiv_id = ArXivClient.extract_arxiv_id(citation_info['note'])

        if arxiv_id and self.arxiv:
            data = self.arxiv.search_by_id(arxiv_id)
            if data:
                return True, 'arxiv', data

        # 策略 3: 通用搜索 (Semantic Scholar)
        if 'title' in citation_info and self.semantic_scholar:
            data = self.semantic_scholar.search_by_title(citation_info['title'])
            if data:
                return True, 'semantic_scholar', data

        return False, None, None

    def get_bibtex(self, doi: str) -> Optional[str]:
        """通过 DOI 获取 BibTeX

        Args:
            doi: DOI 标识符

        Returns:
            BibTeX 字符串,如果失败则返回 None
        """
        if self.crossref:
            return self.crossref.get_bibtex(doi)
        return None


# ============================================================================
# 使用示例
# ============================================================================

if __name__ == '__main__':
    # 示例 1: 使用 CrossRef 客户端
    print("示例 1: CrossRef 客户端")
    print("-" * 60)
    crossref = CrossRefClient()
    result = crossref.search_by_doi("10.48550/arXiv.1706.03762")
    if result:
        print(f"标题: {result['title']}")
        print(f"作者: {', '.join(result['authors'][:3])}")
        print(f"年份: {result['year']}")
    print()

    # 示例 2: 使用 arXiv 客户端
    print("示例 2: arXiv 客户端")
    print("-" * 60)
    try:
        arxiv_client = ArXivClient()
        result = arxiv_client.search_by_id("1706.03762")
        if result:
            print(f"标题: {result['title']}")
            print(f"作者: {', '.join(result['authors'][:3])}")
            print(f"年份: {result['year']}")
    except ImportError as e:
        print(f"跳过: {e}")
    print()

    # 示例 3: 使用 Semantic Scholar 客户端
    print("示例 3: Semantic Scholar 客户端")
    print("-" * 60)
    try:
        ss_client = SemanticScholarClient()
        result = ss_client.search_by_title("Attention is All You Need")
        if result:
            print(f"标题: {result['title']}")
            print(f"作者: {', '.join(result['authors'][:3])}")
            print(f"年份: {result['year']}")
            print(f"引用数: {result['citationCount']}")
    except ImportError as e:
        print(f"跳过: {e}")
    print()

    # 示例 4: 使用统一管理器
    print("示例 4: 统一 API 管理器")
    print("-" * 60)
    manager = CitationAPIManager()
    citation_info = {
        'title': 'Attention is All You Need',
        'authors': ['Vaswani', 'Shazeer'],
        'year': '2017'
    }
    exists, source, data = manager.verify_citation(citation_info)
    if exists:
        print(f"验证成功!")
        print(f"来源: {source}")
        print(f"标题: {data['title']}")
        print(f"年份: {data['year']}")
