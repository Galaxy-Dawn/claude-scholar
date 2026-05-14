# Example: Code Task Report

```text
结论：这个 bug 的根因是配置读取顺序反了，环境变量被默认值覆盖。

我改了：
- `src/config.py`：先读默认值，再用环境变量覆盖。
- `tests/test_config.py`：新增环境变量优先级测试。

我检查了：
- `uv run pytest -q tests/test_config.py` 通过。

风险/限制：
- 我没有跑全量测试；这次改动只覆盖配置模块。

下一步建议：
- 如果要合并，跑一次 `uv run pytest -q` 做全量回归。
```
