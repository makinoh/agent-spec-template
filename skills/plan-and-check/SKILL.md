---
name: plan-and-check
description: spec が clarified になった後に使う。plan.md（How）を作り、Constitution Check を Phase 0 前と Phase 1 設計後に実施し、Class A/B なら ADR を起票する。
class: B/C
status: active
owner: ""                     # 採用時に確定
last_review: "2026-04-01"
tool_boundary: 非破壊（ローカルファイル・設計のみ）。
references:
  - .specify/templates/plan-template.md
  - .specify/memory/constitution.md
  - development-process.md
  - adr-rules.md
---

# スキル: plan-and-check

> 本スキルは [SKILLS.md](../../SKILLS.md) の規約に従う。実行指示の正本は [AGENTS.md](../../AGENTS.md)。

## 用途

仕様（What/Why）を実装方法（How）へ落とし、憲章ゲートを通す。`/speckit.plan` 相当。

## 入力

- 対象 `specs/<feature>/spec.md`
- ゲート簡潔ビュー [.specify/memory/constitution.md](../../.specify/memory/constitution.md)

## 手順

1. [plan-template.md](../../.specify/templates/plan-template.md) を雛形に `plan.md` を作成する。
2. 変更クラスを [development-process.md](../../development-process.md)「1.」対応表で**確定**する（不明なら Class A）。
3. **Constitution Check を Phase 0 の前に実施**。各原則の Gate を判定し、違反は Complexity Tracking に記録する。
4. Phase 1（data-model / contracts）を設計し、**設計後に Constitution Check を再実施**する。
5. Class A/B の設計判断があれば adr-draft スキルで ADR を起票し `related_adrs` に反映する。

## 出力

- `specs/<feature>/plan.md`、`data-model.md`、`contracts/`、必要なら `research.md`

## ツール／MCP 境界

非破壊。生成物（OpenAPI 等）は正本を手編集しない（憲章「SSoT」）。

## 停止必須（HITL）

正当化できない Constitution 違反がある場合は設計をやり直すか人間に諮る。
