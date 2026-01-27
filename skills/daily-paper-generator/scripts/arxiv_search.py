#!/usr/bin/env python3
"""
arXiv 论文搜索脚本

用于搜索 arXiv 上与脑电解码相关的论文。

用法:
    python arxiv_search.py --query "EEG speech decoding" --max-results 50
    python arxiv_search.py --keywords EEG speech decoding --months 3
"""

import argparse
import feedparser
import re
from datetime import datetime, timedelta
from typing import List, Dict, Optional
from urllib.parse import quote_plus


def search_arxiv(
    query: str,
    max_results: int = 50,
    categories: Optional[List[str]] = None,
    months: int = 3
) -> List[Dict]:
    """
    搜索 arXiv 论文

    Args:
        query: 搜索查询字符串
        max_results: 最大结果数
        categories: arXiv 分类列表 (如 ['cs.CV', 'cs.LG'])
        months: 搜索最近几个月的论文

    Returns:
        论文列表，每个论文包含标题、作者、摘要、链接等信息
    """
    # 构建 arXiv API 查询
    base_url = "http://export.arxiv.org/api/query?"

    # 添加分类过滤
    if categories:
        cat_query = " OR ".join([f"cat:{cat}" for cat in categories])
        search_query = f"search_query=({quote_plus(cat_query)})+AND+all:{quote_plus(query)}"
    else:
        search_query = f"search_query=all:{quote_plus(query)}"

    # 其他参数
    params = f"&start=0&max_results={max_results}&sortBy=submittedDate&sortOrder=descending"
    url = base_url + search_query + params

    print(f"正在搜索: {url}")

    # 执行查询
    feed = feedparser.parse(url)
    papers = []

    # 计算时间截止
    cutoff_date = datetime.now() - timedelta(days=months * 30)

    for entry in feed.entries:
        # 解析日期
        published = datetime(*entry.published_parsed[:6])

        # 时间过滤
        if published < cutoff_date:
            continue

        # 解析作者
        authors = [author.name for author in entry.authors]
        first_author = authors[0] if authors else "Unknown"

        # 解析 arXiv ID
        arxiv_id = entry.id.split("/abs/")[-1]
        arxiv_link = f"https://arxiv.org/abs/{arxiv_id}"

        # 解析摘要（去除多余空白）
        summary = re.sub(r'\s+', ' ', entry.summary).strip()

        paper = {
            "title": entry.title,
            "authors": authors,
            "first_author": first_author,
            "summary": summary,
            "published": published.strftime("%Y-%m-%d"),
            "arxiv_id": arxiv_id,
            "arxiv_link": arxiv_link,
            "pdf_link": f"https://arxiv.org/pdf/{arxiv_id}.pdf",
            "categories": [tag.term for tag in entry.tags],
        }
        papers.append(paper)

    print(f"找到 {len(papers)} 篇相关论文（最近{months}个月）")
    return papers


def print_papers(papers: List[Dict], limit: int = 10):
    """打印论文列表"""
    print(f"\n=== 最近 {min(limit, len(papers))} 篇论文 ===\n")
    for i, paper in enumerate(papers[:limit]):
        print(f"[{i+1}] {paper['title']}")
        print(f"    作者: {paper['first_author']} et al.")
        print(f"    发表: {paper['published']}")
        print(f"    链接: {paper['arxiv_link']}")
        print(f"    摘要: {paper['summary'][:150]}...")
        print()


def main():
    parser = argparse.ArgumentParser(description="搜索 arXiv 论文")
    parser.add_argument("--query", "-q", type=str, help="搜索查询字符串")
    parser.add_argument("--keywords", "-k", nargs="+", help="搜索关键词列表")
    parser.add_argument("--max-results", "-n", type=int, default=50, help="最大结果数")
    parser.add_argument("--categories", "-c", nargs="+",
                        default=["cs.CV", "cs.LG", "q-bio.NC"],
                        help="arXiv 分类")
    parser.add_argument("--months", "-m", type=int, default=3,
                        help="搜索最近几个月的论文")
    parser.add_argument("--output", "-o", type=str, help="输出 JSON 文件路径")

    args = parser.parse_args()

    # 构建查询
    if args.query:
        query = args.query
    elif args.keywords:
        query = "+".join(args.keywords)
    else:
        # 默认查询：脑电语音解码
        query = "EEG+speech+decoding"

    # 执行搜索
    papers = search_arxiv(
        query=query,
        max_results=args.max_results,
        categories=args.categories,
        months=args.months
    )

    # 打印结果
    print_papers(papers, limit=10)

    # 输出 JSON
    if args.output:
        import json
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(papers, f, ensure_ascii=False, indent=2)
        print(f"\n结果已保存到 {args.output}")


if __name__ == "__main__":
    main()
