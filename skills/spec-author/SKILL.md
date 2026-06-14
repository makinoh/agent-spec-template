---
name: spec-author
description: 新機能の着手時に使う。要求から specs/<feature>/spec.md（What/Why）を起草する。Class A/B の実装は spec なしに開始しない（憲章・原則 I）。
class: C/D
status: active
owner: ""                     # 採用時に確定
last_review: "2026-04-01"
tool_boundary: 非破壊（ローカルファイルのみ）。外部送信・本番接続なし。
references:
  - .specify/templates/spec-template.md
  - development-process.md
  - standards/security-standards.md
  - glossary.md
---

# スキル: spec-author

> 本スキルは [SKILLS.md](../../SKILLS.md) の規約に従う。実行指示の正本は [AGENTS.md](../../AGENTS.md)。

## 用途

機能要求を、実装方法を含まない「何を・なぜ」の仕様へ構造化する。`/speckit.specify` 相当。

## 入力

- ユーザ要求・課題（自然言語）
- 既存 spec・[glossary.md](../../glossary.md) の関連語彙

## 手順

1. [spec-template.md](../../.specify/templates/spec-template.md) を雛形に `specs/<NNN-feature-name>/spec.md` を作成する。
2. 概要・ユーザシナリオ（Given/When/Then）・機能要求（テスト可能・一意 ID）・非機能要求を記述する。
3. 不確実な点は `[NEEDS CLARIFICATION: 質問]` を残す（`/speckit.clarify` で解消）。
4. 扱うデータの**機密区分**を特定し AI 入力境界に照合する（[security-standards.md](../../standards/security-standards.md)「2.」）。
5. §6 Constitution Alignment を自己点検する。

## 出力

- `specs/<feature>/spec.md`（status: draft → clarified）

## ツール／MCP 境界

非破壊。実装・How は書かない（How は plan-and-check へ）。

## 停止必須（HITL）

機密区分が未確定でデータの AI 入力可否が不明なときは停止し人間に諮る（憲章「6.」）。
