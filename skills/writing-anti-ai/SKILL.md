---
name: writing-anti-ai
description: This skill should be used when the user asks to "remove AI writing patterns", "humanize this text", "make this sound more natural", "remove AI-generated traces", "fix robotic writing", or needs to eliminate AI writing patterns from prose. Supports both English and Chinese text. Based on Wikipedia's "Signs of AI writing" guide, detects and fixes inflated symbolism, promotional language, superficial -ing analyses, vague attributions, AI vocabulary, negative parallelisms, and excessive conjunctive phrases.
version: 1.0.0
author: gaoruizhang
license: MIT
tags: [Writing, AI, Anti-AI, Humanizer]
---

# Writing Anti-AI

Remove AI-generated writing patterns from text to make it sound natural and human-written. Supports both English and Chinese.

## Overview

This skill identifies and eliminates predictable AI writing patterns from prose, based on [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), maintained by WikiProject AI Cleanup.

**Core insight**: LLMs use statistical algorithms to predict what should come next. The result tends toward the most statistically likely outcome that applies to the widest variety of cases—creating detectable patterns.

## When to Use This Skill

**Trigger phrases:**
- "Humanize this text" / "人性化处理这段文字"
- "Remove AI writing patterns" / "去除 AI 写作痕迹"
- "Make this sound more natural" / "让这段文字更自然"
- "This sounds robotic/AI-generated" / "这听起来像机器写的"
- "Fix the AI patterns" / "修复 AI 模式"

**Use cases:**
- Editing AI-generated content to sound human
- Reviewing text for AI patterns before publication
- Polishing academic or professional writing
- Removing "slop" from prose

## Core Rules (快速检查清单)

### 1. Cut Filler Phrases
Remove throat-clearing openers and emphasis crutches.

**English examples**:
- "In order to achieve this goal" → "To achieve this"
- "Due to the fact that" → "Because"
- "It is important to note that" → (delete)

**中文示例**:
- "为了实现这一目标" → "为了实现这一点"
- "值得注意的是" → (删除)
- "基于……的事实" → "因为"

### 2. Break Formulaic Structures
Avoid binary contrasts, dramatic fragmentation, rhetorical setups.

**Patterns to avoid**:
- Negative parallelisms: "It's not just X, it's Y"
- Rule of three: "A, B, and C" (prefer two or four items)
- Em-dash reveals: "X—Y" (just use commas)

### 3. Vary Rhythm
Mix sentence lengths. End paragraphs differently.

**Check**:
- Three consecutive sentences same length? Break one.
- Paragraph ends with punchy one-liner? Vary it.

### 4. Trust Readers
State facts directly. Skip softening, justification, hand-holding.

**Bad**: "It could potentially be argued that the policy might have some effect."
**Good**: "The policy may affect outcomes."

### 5. Cut Quotables
If it sounds like a pull-quote, rewrite it.

**Bad**: "This represents a major step in the right direction."
**Good**: "The company plans to open two more locations."

## Common AI Patterns (常见 AI 模式)

### Content Patterns (内容模式)

| Pattern | Description | 中文描述 |
|---------|-------------|----------|
| **Undue emphasis** | "stands as a testament", "crucial role" | "作为……的证明"，"关键作用" |
| **Promotional language** | "vibrant", "rich heritage", "breathtaking" | "充满活力的"，"丰富遗产"，"令人叹为观止" |
| **Vague attributions** | "Experts believe", "Observers note" | "专家认为"，"观察者指出" |
| **Superficial -ing analyses** | "highlighting the importance", "ensuring that" | "强调……的重要性"，"确保……" |
| **Formulaic "challenges" sections** | "Despite X, faces challenges" | "尽管……面临挑战" |

### Language Patterns (语言模式)

| Pattern | Description | 中文描述 |
|---------|-------------|----------|
| **AI vocabulary** | Additionally, crucial, delve, enhance, landscape | 此外，至关重要，深入探讨，增强，格局 |
| **Copula avoidance** | "serves as", "stands for", "represents" | "作为"，"代表"，"充当" |
| **Em dash overuse** | Using — more than humans | 过度使用破折号 |
| **Rule of three** | Forcing ideas into groups of three | 强行三段式 |
| **Elegant variation** | Excessive synonym substitution | 过度换词 |

For comprehensive pattern lists, see:
- **`references/patterns-english.md`** - Complete English pattern reference
- **`references/patterns-chinese.md`** - Complete Chinese pattern reference

## Personality and Soul (注入灵魂)

Avoiding AI patterns is only half the job. Sterile, voiceless writing is just as obvious.

### Signs of soulless writing:
- Every sentence is the same length and structure
- No opinions, just neutral reporting
- No acknowledgment of uncertainty or mixed feelings
- No first-person perspective when appropriate
- No humor, no edge, no personality

### How to add voice:

**Have opinions.** Don't just report facts—react to them.

> "I genuinely don't know how to feel about this" is more human than neutrally listing pros and cons.

**Vary your rhythm.** Short punchy sentences. Then longer ones that take their time.

**Acknowledge complexity.** Real humans have mixed feelings.

> "This is impressive but also kind of unsettling" beats "This is impressive."

**Use "I" when it fits.** First person isn't unprofessional—it's honest.

> "I keep coming back to..." signals a real person thinking.

**中文示例**：
> "我真的不知道该怎么看待这件事"比中立地列出利弊更有人味。
>
> "这令人印象深刻但也有点不安"胜过"这令人印象深刻"。

## Workflow (工作流程)

### For English Text:

1. **Identify patterns** - Scan for AI patterns listed above
2. **Rewrite sections** - Replace AI-isms with natural alternatives
3. **Preserve meaning** - Keep core message intact
4. **Maintain voice** - Match intended tone (formal, casual, technical)
5. **Add soul** - Inject personality and opinions

### For Chinese Text (中文文本):

1. **识别 AI 模式** - 扫描上述列出的模式
2. **重写问题片段** - 用自然替代方案替换
3. **保留含义** - 保持核心信息完整
4. **维持语调** - 匹配预期的语气（正式、随意、技术）
5. **注入灵魂** - 添加个性和观点

## Quick Scoring (快速评分)

Rate the text 1-10 on each dimension (总分 50):

| Dimension | Question | 问题 | Score |
|-----------|----------|------|-------|
| **Directness** | Direct statements or announcements? | 直接陈述还是绕圈宣告？ | /10 |
| **Rhythm** | Varied or metronomic? | 节奏变化还是机械重复？ | /10 |
| **Trust** | Respects reader intelligence? | 尊重读者智慧吗？ | /10 |
| **Authenticity** | Sounds human? | 听起来像真人吗？ | /10 |
| **Density** | Anything cuttable? | 有可删减的内容吗？ | /10 |

**Standard**:
- 45-50: Excellent, AI patterns removed
- 35-44: Good, room for improvement
- Below 35: Needs revision

## Examples (示例)

See **`examples/`** for before/after transformations:
- **`examples/english.md`** - English text examples
- **`examples/chinese.md`** - Chinese text examples

## Quick Reference (快速参考)

### English - Common Fixes:
| Before | After |
|--------|-------|
| "serves as a testament to" | "shows" |
| "Moreover, it provides" | "It adds" |
| "It's not just X, it's Y" | "X does Y" |
| "Industry experts believe" | "According to [specific source]" |

### 中文 - 常见修复：
| 改写前 | 改写后 |
|--------|--------|
| "作为……的证明" | "表明" |
| "此外，……提供了" | "……增加了" |
| "这不仅仅是……而是……" | "……是……" |
| "专家认为" | "根据[具体来源]" |

## Additional Resources

### Reference Files
- **`references/patterns-english.md`** - Complete English pattern reference
- **`references/patterns-chinese.md`** - 完整中文模式参考
- **`references/phrases-to-cut.md`** - Filler phrases to remove (需删除的填充短语)
- **`references/wikipedia-source.md`** - Original Wikipedia source material

### Example Files
- **`examples/english.md`** - English before/after examples
- **`examples/chinese.md`** - 中文改写示例

## Best Practices

✅ **DO**:
- Combine pattern detection with soul injection
- Support both English and Chinese
- Use progressive disclosure (core rules here, details in references/)
- Vary sentence structure and rhythm
- Add specific details instead of vague claims
- Use simple constructions (is/are/have) where appropriate

❌ **DON'T**:
- Just remove patterns without adding voice
- Leave stereotypic structures intact
- Over-correct and lose the original meaning
- Ignore language-specific patterns
- Make all sentences the same length

## License

MIT

## Attribution

Based on [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia/Signs_of_AI_writing), maintained by WikiProject AI Cleanup. Merges content from `humanizer`, `humanizer-zh`, and `stop-slop` skills.
