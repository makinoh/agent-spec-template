---
# ===== 機械可読メタデータ =====
feature_id: ""                # 例: 001-user-login（specs/ 配下のディレクトリ名と一致）
title: ""
status: draft                 # draft | clarified | planned | implemented | superseded
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
scope: project                # organization | division | department | product | project
change_class_hint: ""         # A | B | C | D（暫定。最終判定は development-process.md）
related_adrs: []              # 関連 ADR（例: [ADR-0002]）
---

# 仕様（Specification）: [機能名]

> **目的**: 本書は「**何を・なぜ**（What/Why）」の正本である。**どう作るか（How）は書かない**
> （How は `plan.md`、判断根拠は ADR）。`/speckit.specify` で起票し、`/speckit.clarify` で曖昧点を解消する。
> 不確実な箇所は `[NEEDS CLARIFICATION: 質問]` を明示的に残し、`/speckit.clarify` で解消する。

## 1. 概要 / 問題

- 背景・解決したい課題（ユーザ視点）:
- このスペックが達成するゴール:
- 非ゴール（スコープ外）:

## 2. ユーザシナリオ（受け入れ可能な振る舞い）

> 検証可能な形（Given/When/Then）で記述する。実装語彙ではなく振る舞いで書く。

- **US-1**: ある利用者として、〜できる。
  - Given … / When … / Then …
- **US-2**: …

## 3. 機能要求（Functional Requirements）

> 各要求は **テスト可能** で **一意 ID** を持つ。曖昧語（速い・使いやすい等）は禁止——測れる基準にする。
> 記述は **EARS 記法**（Easy Approach to Requirements Syntax）を推奨する。条件・トリガ・応答が明確になり、AI が解釈しやすい。

EARS パターン（RFC 2119 の MUST/SHOULD と併用する）:

- ユビキタス: 「システムは <応答> しなければならない（MUST）。」
- イベント駆動: 「**WHEN** <トリガ>、システムは <応答> しなければならない。」
- 状態駆動: 「**WHILE** <状態>、システムは <応答> しなければならない。」
- 望ましくない事象: 「**IF** <条件>、**THEN** システムは <応答> しなければならない。」
- オプション機能: 「**WHERE** <機能が有効>、システムは <応答> しなければならない。」

要求の例（EARS ＋ RFC 2119）:

- **FR-1**: WHEN <トリガ>、システムは … しなければならない（MUST）。
- **FR-2**: IF <異常条件>、THEN システムは … しなければならない（MUST）。
- **FR-3**: [NEEDS CLARIFICATION: 未確定の論点があれば明示]

## 4. 非機能要求・制約（NFR / Constraints）

- 性能・可用性・スケール（測定可能な目標。正本は standards/performance-standards.md）:
- セキュリティ・プライバシー: 扱うデータの**機密区分**と、AI/外部AIへの入力可否を明記する
  （standards/security-standards.md・standards/ai-governance.md に照合。本番個人データ・機密は AI 入力禁止）。
- アクセシビリティ（UI を持つ場合。standards/accessibility-standards.md）:
- 既存標準・契約・互換性の制約:

## 5. 主要エンティティ / データ（任意）

> 概念モデル（属性・関係）。物理スキーマ設計は plan.md / data-model.md で行う。

## 6. Constitution Alignment（憲章整合・自己点検）

- [ ] What/Why に限定し、How を含めていない（plan.md と責務分離）
- [ ] 扱うデータの機密区分を特定し、AI 入力境界に照合した（原則 IV）
- [ ] 暫定の変更クラス（`change_class_hint`）を置いた（最終判定は development-process.md・原則 V）
- [ ] Class A/B が見込まれる設計判断は、ADR 起票が必要になり得ると認識した（原則 II）

## 7. Definition of Ready（着手可能条件 / `/speckit.clarify` 完了条件）

> 本チェックをすべて満たすと plan/implement へ着手してよい（DoR）。完了条件（DoD）は constitution.md「9.」。

- [ ] すべての `[NEEDS CLARIFICATION]` が解消、または「結果」追跡対象として明記された
- [ ] 各 FR がテスト可能で曖昧語を含まない（EARS 記法を推奨）
- [ ] ユーザシナリオが受け入れ基準として機能する
- [ ] 非ゴール（スコープ外）が明記されている
- [ ] 扱うデータの **機密区分（PII 等）を分類** し、AI 入力境界に照合した（原則 IV）

## 8. 未解決の問い

- [NEEDS CLARIFICATION: …]
