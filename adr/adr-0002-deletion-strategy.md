---
id: ADR-0002
title: "アカウント削除戦略（ソフト削除＋猶予期間）の選定"
status: proposed              # proposed | accepted | rejected | deprecated | superseded
date: 2026-04-01
last_updated: 2026-04-01
profile: minimal              # minimal | full
scope: project
proposer: "（起案者名）"
decision-makers: []           # proposed 段階は空（accepted 時に非空・adr-rules.md「4.」）
consulted: []
informed: []
review_after: ""              # accepted 時に YYYY-MM-DD を記入
depends_on: []
supersedes: []
superseded_by: []
relates_to: [ADR-0001]
tags: [account, deletion, gdpr]
---

# ADR-0002: アカウント削除戦略（ソフト削除＋猶予期間）の選定

> メタデータは冒頭フロントマターを唯一の正本とする（adr-rules.md「3.」「4.」）。本ADRは最小プロファイル。
> 関連: 機能仕様 specs/002-account-deletion/spec.md。ドメイン知識 knowledge/domain/account-data.md。

## 変更履歴

| 日付 | 変更者 | 変更内容（ステータス遷移を含む） | 理由 |
|------|--------|----------------------------------|------|
| | | | |

## コンテキスト

### 背景

feature 002（アカウント削除）で、消去権（GDPR 第17条）に応えつつ、誤削除からの復旧と不可逆操作のリスクを両立する削除戦略を決める。ハード削除は不可逆操作であり Class A に相当する。

### 前提 / 制約

- 対象に PII（Restricted）を含む（knowledge/domain/account-data.md）。
- 法的保持義務（legal hold）のある項目が存在し得る。

## 決定要因

- 可逆性（誤削除からの復旧。憲章「変更の可逆性」）
- 規制適合（消去権の実効性）と監査適合
- 実装・運用コスト

## 意思決定事項

- 決定の問い: アカウント削除をどの戦略で実装するか。
- 含む: 削除の状態遷移と既定の猶予期間。
- 含まない: バックアップ媒体からの消去 SLA（運用 playbook で別途）。

## 選択肢

### 選択肢 A：即時ハード削除

**メリット**: 実装が単純・消去が即時。

**デメリット**: 不可逆で誤削除からの復旧が不可能。可逆性の原則に反する。

### 選択肢 B：ソフト削除＋猶予期間→ハード削除

**メリット**: 猶予期間内は可逆。消去権も猶予後のハード削除で満たす。監査しやすい。

**デメリット**: 状態管理とスケジュールジョブが必要。

### 選択肢 C：匿名化のみ

**メリット**: 統計利用を残せる。

**デメリット**: 「消去」と言えるかが規制解釈に依存。再識別リスクが残る。

## 決定（案）

- 採用案: **B（ソフト削除＋猶予期間 30 日 → ハード削除）**
- 決定理由: 可逆性（誤削除復旧）と消去権の双方を満たす。法的保持対象は purge から除外する。
- 不採用案の理由: A は不可逆で可逆性原則に反する／C は消去の実効性が不確実。

## 承認

> （承認待ち。Accepted 化時に下表を記入し、フロントマター `status`/`decision-makers`/`review_after` を同時更新する。承認は Class A・人間必須＝constitution.md「6.」）

| 項目 | 内容 |
|------|------|
| 確定した決定 | |
| 承認者・承認日 | |
| 見直し時期（レビュー期日） | |

## 結果

> （承認後・見直し期日に記入）

- 肯定的な結果 / 否定的な結果・副作用 / 残存リスク: [記入]
