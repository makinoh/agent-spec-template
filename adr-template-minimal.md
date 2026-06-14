---
# ===== 機械可読メタデータ（正本。adr-rules.md「4.」） =====
id: ADR-NNNN
title: "[意思決定タイトル]"
status: proposed              # proposed | accepted | rejected | deprecated | superseded
date: YYYY-MM-DD
last_updated: YYYY-MM-DD
profile: minimal
scope: project                # organization | division | department | product | project
proposer: ""
decision-makers: []           # accepted 時に非空（adr-rules.md「4.」）
consulted: []
informed: []
review_after: ""              # accepted 時に YYYY-MM-DD
depends_on: []
supersedes: []
superseded_by: []
relates_to: []
---

# ADR-NNNN: [意思決定タイトル]

> 最小プロファイル用の軽量テンプレート。必須セクションは adr-rules.md「3.」に準拠。
> 完全プロファイル（評価観点・評価・関連ADR 等）が必要な場合は adr-template.md を使う。
> メタdata は冒頭フロントマターを唯一の正本とし、本文に再掲しない。記入後はコメント（#・>）を削除してよい。

## 変更履歴

| 日付 | 変更者 | 変更内容（ステータス遷移を含む） | 理由 |
|------|--------|----------------------------------|------|
| YYYY-MM-DD | （起案者） | 初版作成、Proposed に設定 | 新規起案 |

## コンテキスト

- 背景: [なぜ決める必要があるか]
- 前提 / 制約: [前提・制約。なければ「特になし」]

## 決定要因

- [決定を左右する主要因。最小プロファイルでは記入を推奨]

## 意思決定事項

- 決定の問い: [1文で]
- 含む / 含まない: [範囲]

## 選択肢

### 選択肢 A: [名称]

- メリット: [記入]　／　デメリット: [記入]

### 選択肢 B: 現状維持（ベースライン）

- メリット: [記入]　／　デメリット: [記入]

## 決定（案）

- 採用案: [A / B / 保留]
- 決定理由: [決定要因に基づく根拠]
- 不採用案の理由: [トレードオフ]

## 承認

> 承認者が記入。Accepted への遷移（変更履歴に記録）とフロントマター `status`/`decision-makers`/`review_after` の同時更新で確定する。承認は Class A・人間必須（constitution.md「6.」）。

| 項目 | 内容 |
|------|------|
| 確定した決定 | |
| 承認者・承認日 | |
| 見直し時期 | YYYY-MM-DD |

## 結果

> 承認後・見直し期日に記入。

- 肯定的な結果 / 否定的な結果・副作用 / 残存リスク: [記入]
