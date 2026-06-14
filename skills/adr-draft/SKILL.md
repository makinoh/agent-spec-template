---
name: adr-draft
description: Class A/B または長期的影響を持つ設計判断が生じたときに使う。Proposed 状態の ADR を起草する。起案のみ。Accepted 化は人間（Class A）。
class: B（起案のみ）
status: active
owner: ""                     # 採用時に確定
last_review: "2026-04-01"
tool_boundary: 非破壊。status を accepted にしてはならない（MUST NOT）。
references:
  - adr-rules.md
  - adr-template-minimal.md
  - adr-template.md
  - scripts/generate_adr_index.py
---

# スキル: adr-draft

> 本スキルは [SKILLS.md](../../SKILLS.md) の規約に従う。実行指示の正本は [AGENTS.md](../../AGENTS.md)。

## 用途

「なぜこの設計か」を ADR として記録する。spec（何を）と重複させない。

## 入力

- 決定すべき問い・選択肢・制約
- プロファイル判定（[adr-rules.md](../../adr-rules.md)「2.」。project 粒度なら最小プロファイル可）

## 手順

1. 採番（`adr/` の連番、欠番は詰めない）。最小は [adr-template-minimal.md](../../adr-template-minimal.md)、完全は [adr-template.md](../../adr-template.md) を使う。
2. フロントマター必須キーを埋める（`status: proposed`、`decision-makers`/`review_after` は proposed 段階は空でよい）。
3. コンテキスト・意思決定事項・選択肢（現状維持を含む）・決定（案）を記述する。値の決め打ち・スコア事前記入をしない。
4. `python scripts/generate_adr_index.py` で索引を再生成する。

## 出力

- `adr/adr-NNNN-<short-title>.md`（status: proposed）／更新された `adr/INDEX.md`

## ツール／MCP 境界

非破壊。**status を accepted へ遷移してはならない**（承認は人間・Class A。憲章「6.」）。

## 停止必須（HITL）

ADR と既存実装・憲章に矛盾を検出したら自律修正せず人間に諮る（憲章「6.」）。
