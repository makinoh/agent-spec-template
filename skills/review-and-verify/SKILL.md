---
name: review-and-verify
description: PR を作成・マージする前に使う。差分を自己レビューし、完了条件（DoD）を検証する。
class: C
status: active
owner: ""                     # 採用時に確定
last_review: "2026-04-01"
tool_boundary: 非破壊（ローカルの build/test/lint 実行は可）。本番接続・外部送信なし。
references:
  - constitution.md
  - .github/pull_request_template.md
  - standards/testing-standards.md
---

# スキル: review-and-verify

> 本スキルは [SKILLS.md](../../SKILLS.md) の規約に従う。実行指示の正本は [AGENTS.md](../../AGENTS.md)。

## 用途

完了条件（[constitution.md](../../constitution.md)「9.」＋「8.」）を満たすかを反映前に検証する。

## 入力

- 変更差分・対象の変更クラス

## 手順

1. 変更クラスを確認し、PR テンプレート（[pull_request_template.md](../../.github/pull_request_template.md)）の項目を埋める。
2. ローカルで build・型・テスト・カバレッジ（[testing-standards.md](../../standards/testing-standards.md)）・lint を実行する。
3. Class A/B なら ADR 参照または「ADR不要理由」を PR 本文に記載する。
4. 秘密情報の混入・PII のテスト利用（合成データか）を確認する。
5. 監査証跡（AI 起案ラベル・コミットトレーラ・作成者≠承認者）を確認する。

## 出力

- 充足した PR チェックリスト／レビュー所見

## ツール／MCP 境界

非破壊。失敗ゲートを回避目的で弱めない（MUST NOT。憲章「自己修正ループの防止」）。原因側を修正する。

## 停止必須（HITL）

統治・強制機構に触れる変更は permission-impact を開示し、自己マージしない（憲章「6.」）。
