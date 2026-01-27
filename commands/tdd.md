---
description: Enforce test-driven development workflow. Scaffold interfaces, generate tests FIRST, then implement minimal code to pass. Ensure 80%+ coverage.
---

# TDD Command

This command invokes the **tdd-guide** agent to enforce test-driven development methodology.

## What This Command Does

1. **Scaffold Interfaces** - Define types/interfaces first
2. **Generate Tests First** - Write failing tests (RED)
3. **Implement Minimal Code** - Write just enough to pass (GREEN)
4. **Refactor** - Improve code while keeping tests green (REFACTOR)
5. **Verify Coverage** - Ensure 80%+ test coverage

## When to Use

Use `/tdd` when:
- Implementing new features
- Adding new functions/components
- Fixing bugs (write test that reproduces bug first)
- Refactoring existing code
- Building critical business logic

## How It Works

The tdd-guide agent will:

1. **Define interfaces** for inputs/outputs
2. **Write tests that will FAIL** (because code doesn't exist yet)
3. **Run tests** and verify they fail for the right reason
4. **Write minimal implementation** to make tests pass
5. **Run tests** and verify they pass
6. **Refactor** code while keeping tests green
7. **Check coverage** and add more tests if below 80%

## TDD Cycle

```
RED → GREEN → REFACTOR → REPEAT

RED:      Write a failing test
GREEN:    Write minimal code to pass
REFACTOR: Improve code, keep tests passing
REPEAT:   Next feature/scenario
```

## Example Usage

```
User: /tdd I need a function to calculate market liquidity score

Agent (tdd-guide):
# TDD Session: Market Liquidity Score Calculator

## Step 1: Define Interface (SCAFFOLD)

```python
# lib/liquidity.py
from dataclasses import dataclass
from datetime import datetime
from typing import NotRequired

@dataclass
class MarketData:
    totalVolume: float
    bidAskSpread: float
    activeTraders: int
    lastTradeTime: datetime

def calculateLiquidityScore(market: MarketData) -> float:
    # TODO: Implementation
    raise NotImplementedError('Not implemented')
```

## Step 2: Write Failing Test (RED)

```python
# tests/test_liquidity.py
import pytest
from lib.liquidity import calculateLiquidityScore, MarketData
from datetime import datetime

def test_liquid_market_high_score():
    """Test that liquid market gets high score."""
    market = MarketData(
        totalVolume=100000,
        bidAskSpread=0.01,
        activeTraders=500,
        lastTradeTime=datetime.now()
    )

    score = calculateLiquidityScore(market)

    assert 80 < score <= 100

def test_illiquid_market_low_score():
    """Test that illiquid market gets low score."""
    market = MarketData(
        totalVolume=100,
        bidAskSpread=0.5,
        activeTraders=2,
        lastTradeTime=datetime.fromtimestamp(datetime.now().timestamp() - 86400)  # 1 day ago
    )

    score = calculateLiquidityScore(market)

    assert 0 <= score < 30

def test_zero_volume_edge_case():
    """Test that zero volume returns score of 0."""
    market = MarketData(
        totalVolume=0,
        bidAskSpread=0,
        activeTraders=0,
        lastTradeTime=datetime.now()
    )

    score = calculateLiquidityScore(market)

    assert score == 0
```

## Step 3: Run Tests - Verify FAIL

```bash
pytest tests/test_liquidity.py -v

FAILED test_liquidity.py::test_liquid_market_high_score
    NotImplementedError: Not implemented

1 test failed, 0 passed
```

✅ Tests fail as expected. Ready to implement.

## Step 4: Implement Minimal Code (GREEN)

```python
# lib/liquidity.py
def calculateLiquidityScore(market: MarketData) -> float:
    # Handle zero volume edge case
    if market.totalVolume == 0:
        return 0.0

    # Calculate component scores (0-100 scale)
    volumeScore = min(market.totalVolume / 1000, 100)
    spreadScore = max(100 - (market.bidAskSpread * 1000), 0)
    traderScore = min(market.activeTraders / 10, 100)

    # Recent activity bonus
    hoursSinceLastTrade = (datetime.now().timestamp() - market.lastTradeTime.timestamp()) / 3600
    recencyScore = max(100 - (hoursSinceLastTrade * 10), 0)

    # Weighted average
    score = (
        volumeScore * 0.4 +
        spreadScore * 0.3 +
        traderScore * 0.2 +
        recencyScore * 0.1
    )

    return max(0, min(score, 100))  # Clamp to 0-100
```

## Step 5: Run Tests - Verify PASS

```bash
pytest tests/test_liquidity.py -v

PASSED test_liquidity.py::test_liquid_market_high_score
PASSED test_liquidity.py::test_illiquid_market_low_score
PASSED test_liquidity.py::test_zero_volume_edge_case

3 tests passed
```

✅ All tests passing!

## Step 6: Refactor (IMPROVE)

```python
# lib/liquidity.py - Refactored with constants and better readability
from dataclasses import dataclass

WEIGHTS = {
    'VOLUME': 0.4,
    'SPREAD': 0.3,
    'TRADERS': 0.2,
    'RECENCY': 0.1,
}

SCALE_FACTORS = {
    'VOLUME': 1000,
    'SPREAD': 1000,
    'TRADERS': 10,
    'RECENCY_PENALTY': 10,
}

def clamp(value: float, min_val: float, max_val: float) -> float:
    """Clamp value between min and max."""
    return max(min(value, max_val), min_val)

def calculateLiquidityScore(market: MarketData) -> float:
    if market.totalVolume == 0:
        return 0.0

    volumeScore = min(market.totalVolume / SCALE_FACTORS['VOLUME'], 100)
    spreadScore = clamp(100 - (market.bidAskSpread * SCALE_FACTORS['SPREAD']), 0, 100)
    traderScore = min(market.activeTraders / SCALE_FACTORS['TRADERS'], 100)

    hoursSinceLastTrade = (datetime.now().timestamp() - market.lastTradeTime.timestamp()) / 3600
    recencyScore = clamp(100 - (hoursSinceLastTrade * SCALE_FACTORS['RECENCY_PENALTY']), 0, 100)

    weightedScore = (
        volumeScore * WEIGHTS['VOLUME'] +
        spreadScore * WEIGHTS['SPREAD'] +
        traderScore * WEIGHTS['TRADERS'] +
        recencyScore * WEIGHTS['RECENCY']
    )

    return clamp(weightedScore, 0, 100)
```

## Step 7: Verify Tests Still Pass

```bash
pytest tests/test_liquidity.py -v

PASSED test_liquidity.py::test_liquid_market_high_score
PASSED test_liquidity.py::test_illiquid_market_low_score
PASSED test_liquidity.py::test_zero_volume_edge_case

3 tests passed
```

✅ Refactoring complete, tests still passing!

## Step 8: Check Coverage

```bash
pytest --cov=lib --cov-report=term-missing tests/test_liquidity.py

File           | % Stmts | % Branch | % Funcs | % Lines
---------------|---------|----------|---------|--------
liquidity.py   |   100   |   100    |   100   |   100

Coverage: 100% ✅ (Target: 80%)
```

✅ TDD session complete!
```

## TDD Best Practices

**DO:**
- ✅ Write the test FIRST, before any implementation
- ✅ Run tests and verify they FAIL before implementing
- ✅ Write minimal code to make tests pass
- ✅ Refactor only after tests are green
- ✅ Add edge cases and error scenarios
- ✅ Aim for 80%+ coverage (100% for critical code)

**DON'T:**
- ❌ Write implementation before tests
- ❌ Skip running tests after each change
- ❌ Write too much code at once
- ❌ Ignore failing tests
- ❌ Test implementation details (test behavior)
- ❌ Mock everything (prefer integration tests)

## Test Types to Include

**Unit Tests** (Function-level):
- Happy path scenarios
- Edge cases (empty, null, max values)
- Error conditions
- Boundary values

**Integration Tests** (Component-level):
- API endpoints
- Database operations
- External service calls
- React components with hooks

**E2E Tests** (use `/e2e` command):
- Critical user flows
- Multi-step processes
- Full stack integration

## Coverage Requirements

- **80% minimum** for all code
- **100% required** for:
  - Financial calculations
  - Authentication logic
  - Security-critical code
  - Core business logic

## Important Notes

**MANDATORY**: Tests must be written BEFORE implementation. The TDD cycle is:

1. **RED** - Write failing test
2. **GREEN** - Implement to pass
3. **REFACTOR** - Improve code

Never skip the RED phase. Never write code before tests.

## Integration with Other Commands

- Use `/plan` first to understand what to build
- Use `/tdd` to implement with tests
- Use `/build-and-fix` if build errors occur
- Use `/code-review` to review implementation
- Use `/test-coverage` to verify coverage

## Related Agents

This command invokes the `tdd-guide` agent located at:
`~/.claude/agents/tdd-guide.md`

And can reference the `tdd-workflow` skill at:
`~/.claude/skills/tdd-workflow/`
