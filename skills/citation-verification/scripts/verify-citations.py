#!/usr/bin/env python3
"""
Citation Verification Script

四层验证机制:
1. Format Validation - BibTeX 格式检查
2. Existence Verification - API 验证论文存在性
3. Information Matching - 信息匹配(标题、作者、年份)
4. Content Validation - 综合评分和判定

使用方法:
    python verify-citations.py references.bib
    python verify-citations.py paper.tex --check-latex
    python verify-citations.py references.bib --verbose --output report.md
"""

import argparse
import sys
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
import re
from difflib import SequenceMatcher

# 尝试导入 bibtexparser
try:
    import bibtexparser
    from bibtexparser.bparser import BibTexParser
except ImportError:
    print("错误: 需要安装 bibtexparser")
    print("运行: pip install bibtexparser")
    sys.exit(1)

# 尝试导入 API 客户端库
try:
    from semanticscholar import SemanticScholar
except ImportError:
    print("警告: semanticscholar 未安装,将跳过 Semantic Scholar 验证")
    print("运行: pip install semanticscholar")

try:
    import arxiv
except ImportError:
    print("警告: arxiv 未安装,将跳过 arXiv 验证")
    print("运行: pip install arxiv")

try:
    import requests
except ImportError:
    print("错误: 需要安装 requests")
    print("运行: pip install requests")
    sys.exit(1)


@dataclass
class VerificationResult:
    """验证结果数据类"""
    citation_key: str
    status: str  # verified, partial_match, low_match, failed, not_found
    confidence: str  # high_confidence, medium_confidence, low_confidence, no_confidence
    match_score: float
    format_errors: List[str]
    api_source: Optional[str]  # crossref, arxiv, semantic_scholar
    message: str


def parse_arguments():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(
        description='验证 BibTeX 引用的准确性和完整性',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s references.bib
  %(prog)s paper.tex --check-latex
  %(prog)s references.bib --verbose --output report.md
  %(prog)s references.bib --api-only
        """
    )

    parser.add_argument(
        'input_file',
        type=str,
        help='BibTeX 文件(.bib)或 LaTeX 文件(.tex)'
    )

    parser.add_argument(
        '--check-latex',
        action='store_true',
        help='检查 LaTeX 引用一致性(需要提供 .tex 文件)'
    )

    parser.add_argument(
        '--verbose',
        action='store_true',
        help='显示详细验证信息'
    )

    parser.add_argument(
        '--output',
        type=str,
        help='输出报告文件路径(Markdown 格式)'
    )

    parser.add_argument(
        '--api-only',
        action='store_true',
        help='仅进行 API 验证,跳过格式检查'
    )

    parser.add_argument(
        '--format-only',
        action='store_true',
        help='仅进行格式检查,跳过 API 验证'
    )

    parser.add_argument(
        '--threshold',
        type=float,
        default=0.85,
        help='匹配阈值(0.0-1.0),默认 0.85'
    )

    return parser.parse_args()


def load_bibtex(file_path: str) -> List[Dict]:
    """加载 BibTeX 文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            parser = BibTexParser(common_strings=True)
            bib_database = bibtexparser.load(f, parser)
            return bib_database.entries
    except FileNotFoundError:
        print(f"错误: 文件不存在: {file_path}")
        sys.exit(1)
    except Exception as e:
        print(f"错误: 无法解析 BibTeX 文件: {e}")
        sys.exit(1)


def extract_latex_citations(tex_file: str) -> List[str]:
    """从 LaTeX 文件中提取引用"""
    try:
        with open(tex_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # 匹配 \cite{...} 命令
        cite_pattern = r'\\cite(?:\[[^\]]*\])?\{([^}]+)\}'
        citations = re.findall(cite_pattern, content)

        # 展开多个引用
        all_keys = []
        for cite in citations:
            keys = [k.strip() for k in cite.split(',')]
            all_keys.extend(keys)

        return list(set(all_keys))  # 去重
    except FileNotFoundError:
        print(f"错误: 文件不存在: {tex_file}")
        sys.exit(1)
    except Exception as e:
        print(f"错误: 无法解析 LaTeX 文件: {e}")
        sys.exit(1)


# ============================================================================
# Layer 1: Format Validation (格式验证)
# ============================================================================

def get_required_fields(entry_type: str) -> List[str]:
    """获取 BibTeX 条目类型的必填字段"""
    required_fields = {
        'article': ['author', 'title', 'journal', 'year'],
        'inproceedings': ['author', 'title', 'booktitle', 'year'],
        'book': ['title', 'publisher', 'year'],
        'misc': ['title'],
        'phdthesis': ['author', 'title', 'school', 'year'],
        'mastersthesis': ['author', 'title', 'school', 'year'],
        'techreport': ['author', 'title', 'institution', 'year'],
    }
    return required_fields.get(entry_type.lower(), ['title'])


def check_bibtex_format(entry: Dict) -> List[str]:
    """检查 BibTeX 条目格式

    Returns:
        错误列表
    """
    errors = []

    # 检查条目类型
    if 'ENTRYTYPE' not in entry:
        errors.append("缺少条目类型")
        return errors

    # 检查 ID
    if 'ID' not in entry:
        errors.append("缺少 citation key")

    # 检查必填字段
    entry_type = entry.get('ENTRYTYPE', '')
    required = get_required_fields(entry_type)
    for field in required:
        if field not in entry or not entry[field].strip():
            errors.append(f"缺少必填字段: {field}")

    # 年份格式检查
    if 'year' in entry:
        year = entry['year'].strip()
        if not year.isdigit() or len(year) != 4:
            errors.append(f"年份格式错误: {year}")
        else:
            year_int = int(year)
            if year_int < 1900 or year_int > 2030:
                errors.append(f"年份超出合理范围: {year}")

    # DOI 格式检查
    if 'doi' in entry:
        doi = entry['doi'].strip()
        if not doi.startswith('10.'):
            errors.append(f"DOI 格式错误: {doi}")

    return errors


def check_citation_consistency(tex_keys: List[str], bib_keys: List[str]) -> Dict:
    """检查 LaTeX 引用与 BibTeX 的一致性

    Returns:
        {'undefined': [...], 'unused': [...]}
    """
    tex_set = set(tex_keys)
    bib_set = set(bib_keys)

    return {
        'undefined': list(tex_set - bib_set),
        'unused': list(bib_set - tex_set)
    }


# ============================================================================
# Layer 2: Existence Verification (存在性验证)
# ============================================================================

def verify_with_crossref(doi: str) -> Optional[Dict]:
    """通过 CrossRef API 验证 DOI"""
    try:
        url = f"https://api.crossref.org/works/{doi}"
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            return data.get('message')
        return None
    except Exception as e:
        print(f"CrossRef API 错误: {e}")
        return None


def verify_with_arxiv(arxiv_id: str) -> Optional[Dict]:
    """通过 arXiv API 验证"""
    try:
        search = arxiv.Search(id_list=[arxiv_id])
        paper = next(search.results())
        return {
            'title': paper.title,
            'authors': [a.name for a in paper.authors],
            'year': paper.published.year,
            'arxiv_id': arxiv_id
        }
    except Exception as e:
        print(f"arXiv API 错误: {e}")
        return None


def verify_with_semantic_scholar(title: str, authors: Optional[List[str]] = None) -> Optional[Dict]:
    """通过 Semantic Scholar API 验证"""
    try:
        sch = SemanticScholar()
        results = sch.search_paper(title, limit=5)

        if not results:
            return None

        # 返回第一个结果
        paper = results[0]
        return {
            'title': paper.title,
            'authors': [a.name for a in paper.authors] if paper.authors else [],
            'year': paper.year,
            'paperId': paper.paperId
        }
    except Exception as e:
        print(f"Semantic Scholar API 错误: {e}")
        return None


def verify_existence(entry: Dict) -> Tuple[bool, Optional[str], Optional[Dict]]:
    """验证论文存在性

    Returns:
        (exists, api_source, api_data)
    """
    # 策略 1: DOI 优先
    if 'doi' in entry:
        data = verify_with_crossref(entry['doi'])
        if data:
            return True, 'crossref', data

    # 策略 2: arXiv ID
    if 'eprint' in entry or 'arxiv' in entry.get('note', '').lower():
        arxiv_id = entry.get('eprint', '')
        if not arxiv_id:
            # 尝试从 note 中提取
            match = re.search(r'arXiv:(\d{4}\.\d{4,5})', entry.get('note', ''))
            if match:
                arxiv_id = match.group(1)

        if arxiv_id:
            data = verify_with_arxiv(arxiv_id)
            if data:
                return True, 'arxiv', data

    # 策略 3: 通用搜索
    if 'title' in entry:
        authors = entry.get('author', '').split(' and ') if 'author' in entry else None
        data = verify_with_semantic_scholar(entry['title'], authors)
        if data:
            return True, 'semantic_scholar', data

    return False, None, None


# ============================================================================
# Layer 3 & 4: Information Matching & Content Validation (信息匹配和内容验证)
# ============================================================================

def normalize_text(text: str) -> str:
    """标准化文本用于匹配"""
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)
    return ' '.join(text.split())


def match_title(title1: str, title2: str, threshold: float = 0.85) -> Dict:
    """标题匹配"""
    t1 = normalize_text(title1)
    t2 = normalize_text(title2)

    ratio = SequenceMatcher(None, t1, t2).ratio()

    return {
        'match': ratio >= threshold,
        'similarity': ratio
    }


def normalize_author_name(name: str) -> str:
    """标准化作者名"""
    parts = name.replace(',', '').split()
    return ' '.join(sorted(parts)).lower()


def match_authors(authors1: List[str], authors2: List[str], threshold: float = 0.7) -> Dict:
    """作者匹配"""
    names1 = [normalize_author_name(a) for a in authors1]
    names2 = [normalize_author_name(a) for a in authors2]

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


def match_year(year1: str, year2: int, tolerance: int = 1) -> Dict:
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


def calculate_match_score(entry: Dict, api_data: Dict, threshold: float) -> float:
    """计算综合匹配分数"""
    scores = {}
    weights = {
        'title': 0.4,
        'authors': 0.3,
        'year': 0.2,
        'venue': 0.1
    }

    # 标题匹配
    if 'title' in entry and 'title' in api_data:
        result = match_title(entry['title'], api_data['title'], threshold)
        scores['title'] = result['similarity']

    # 作者匹配
    if 'author' in entry and 'authors' in api_data:
        entry_authors = entry['author'].split(' and ')
        result = match_authors(entry_authors, api_data['authors'])
        scores['authors'] = result['similarity']

    # 年份匹配
    if 'year' in entry and 'year' in api_data:
        result = match_year(entry['year'], api_data['year'])
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


def judge_verification_result(match_score: float) -> Dict:
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


def verify_citation(entry: Dict, args) -> VerificationResult:
    """完整的引用验证流程"""
    citation_key = entry.get('ID', 'unknown')

    # Layer 1: 格式验证
    format_errors = []
    if not args.api_only:
        format_errors = check_bibtex_format(entry)

    # Layer 2: 存在性验证
    if args.format_only:
        return VerificationResult(
            citation_key=citation_key,
            status='format_checked',
            confidence='n/a',
            match_score=0.0,
            format_errors=format_errors,
            api_source=None,
            message='仅格式检查'
        )

    exists, api_source, api_data = verify_existence(entry)

    if not exists:
        return VerificationResult(
            citation_key=citation_key,
            status='not_found',
            confidence='no_confidence',
            match_score=0.0,
            format_errors=format_errors,
            api_source=None,
            message='❌ 论文不存在 - 无法通过任何 API 验证'
        )

    # Layer 3 & 4: 信息匹配和内容验证
    match_score = calculate_match_score(entry, api_data, args.threshold)
    judgment = judge_verification_result(match_score)

    return VerificationResult(
        citation_key=citation_key,
        status=judgment['status'],
        confidence=judgment['level'],
        match_score=match_score,
        format_errors=format_errors,
        api_source=api_source,
        message=judgment['message']
    )


# ============================================================================
# Report Generation (报告生成)
# ============================================================================

def print_summary(results: List[VerificationResult], verbose: bool = False):
    """打印验证摘要"""
    total = len(results)
    verified = sum(1 for r in results if r.status == 'verified')
    partial = sum(1 for r in results if r.status == 'partial_match')
    low = sum(1 for r in results if r.status == 'low_match')
    failed = sum(1 for r in results if r.status in ['failed', 'not_found'])

    print("\n" + "="*60)
    print("验证摘要")
    print("="*60)
    print(f"总引用数: {total}")
    print(f"✅ 验证通过: {verified} ({verified/total*100:.1f}%)")
    print(f"⚠️  部分匹配: {partial} ({partial/total*100:.1f}%)")
    print(f"❌ 匹配度低: {low} ({low/total*100:.1f}%)")
    print(f"❌ 验证失败: {failed} ({failed/total*100:.1f}%)")
    print("="*60)

    if verbose:
        print("\n详细结果:\n")
        for result in results:
            print(f"[{result.citation_key}]")
            print(f"  状态: {result.message}")
            print(f"  匹配分数: {result.match_score:.2f}")
            if result.api_source:
                print(f"  验证源: {result.api_source}")
            if result.format_errors:
                print(f"  格式错误: {', '.join(result.format_errors)}")
            print()


def generate_markdown_report(results: List[VerificationResult], output_file: str):
    """生成 Markdown 格式的验证报告"""
    total = len(results)
    verified = sum(1 for r in results if r.status == 'verified')
    partial = sum(1 for r in results if r.status == 'partial_match')
    low = sum(1 for r in results if r.status == 'low_match')
    failed = sum(1 for r in results if r.status in ['failed', 'not_found'])

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# Citation Verification Report\n\n")

        # 总体统计
        f.write("## 总体统计\n\n")
        f.write(f"- **总引用数**: {total}\n")
        f.write(f"- **✅ 验证通过**: {verified} ({verified/total*100:.1f}%)\n")
        f.write(f"- **⚠️ 部分匹配**: {partial} ({partial/total*100:.1f}%)\n")
        f.write(f"- **❌ 匹配度低**: {low} ({low/total*100:.1f}%)\n")
        f.write(f"- **❌ 验证失败**: {failed} ({failed/total*100:.1f}%)\n\n")

        # 详细结果
        f.write("## 详细结果\n\n")

        # 按状态分组
        for status, emoji, title in [
            ('verified', '✅', '验证通过'),
            ('partial_match', '⚠️', '部分匹配'),
            ('low_match', '❌', '匹配度低'),
            ('failed', '❌', '验证失败'),
            ('not_found', '❌', '论文不存在')
        ]:
            status_results = [r for r in results if r.status == status]
            if status_results:
                f.write(f"### {emoji} {title} ({len(status_results)})\n\n")
                for result in status_results:
                    f.write(f"#### `{result.citation_key}`\n\n")
                    f.write(f"- **状态**: {result.message}\n")
                    f.write(f"- **匹配分数**: {result.match_score:.2f}\n")
                    f.write(f"- **置信度**: {result.confidence}\n")
                    if result.api_source:
                        f.write(f"- **验证源**: {result.api_source}\n")
                    if result.format_errors:
                        f.write(f"- **格式错误**:\n")
                        for error in result.format_errors:
                            f.write(f"  - {error}\n")
                    f.write("\n")

        # 建议操作
        f.write("## 建议操作\n\n")
        if failed > 0:
            f.write("### 需要修正的引用\n\n")
            failed_results = [r for r in results if r.status in ['failed', 'not_found']]
            for result in failed_results:
                f.write(f"- `{result.citation_key}`: {result.message}\n")
            f.write("\n")

        if partial > 0 or low > 0:
            f.write("### 需要人工确认的引用\n\n")
            check_results = [r for r in results if r.status in ['partial_match', 'low_match']]
            for result in check_results:
                f.write(f"- `{result.citation_key}`: {result.message}\n")
            f.write("\n")

    print(f"\n报告已保存到: {output_file}")


# ============================================================================
# Main Function (主函数)
# ============================================================================

def main():
    """主函数"""
    args = parse_arguments()

    # 加载 BibTeX 文件
    print(f"正在加载 BibTeX 文件: {args.input_file}")
    entries = load_bibtex(args.input_file)
    print(f"找到 {len(entries)} 个引用条目")

    # LaTeX 一致性检查
    if args.check_latex:
        tex_file = args.input_file.replace('.bib', '.tex')
        if Path(tex_file).exists():
            print(f"\n正在检查 LaTeX 引用一致性: {tex_file}")
            tex_keys = extract_latex_citations(tex_file)
            bib_keys = [e['ID'] for e in entries]
            consistency = check_citation_consistency(tex_keys, bib_keys)

            if consistency['undefined']:
                print(f"⚠️  未定义的引用 ({len(consistency['undefined'])}): {', '.join(consistency['undefined'])}")
            if consistency['unused']:
                print(f"⚠️  未使用的引用 ({len(consistency['unused'])}): {', '.join(consistency['unused'])}")
            if not consistency['undefined'] and not consistency['unused']:
                print("✅ LaTeX 引用与 BibTeX 完全一致")

    # 验证每个引用
    print("\n开始验证引用...")
    results = []
    for i, entry in enumerate(entries, 1):
        citation_key = entry.get('ID', 'unknown')
        print(f"[{i}/{len(entries)}] 验证 {citation_key}...", end=' ')

        result = verify_citation(entry, args)
        results.append(result)

        # 简短状态输出
        if result.status == 'verified':
            print("✅")
        elif result.status == 'partial_match':
            print("⚠️")
        else:
            print("❌")

    # 打印摘要
    print_summary(results, args.verbose)

    # 生成报告
    if args.output:
        generate_markdown_report(results, args.output)

    # 返回退出码
    failed_count = sum(1 for r in results if r.status in ['failed', 'not_found'])
    return 0 if failed_count == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
