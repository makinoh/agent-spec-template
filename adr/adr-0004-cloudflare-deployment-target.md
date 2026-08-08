---
id: ADR-0004
title: "Cloudflare のデプロイ先（Workers + Static Assets / Pages）"
status: proposed              # proposed | accepted | rejected | deprecated | superseded
date: 2026-08-06
last_updated: 2026-08-06
profile: minimal              # minimal | full
scope: project
proposer: "makinoh"
decision-makers: []           # proposed 段階は空（accepted 時に非空・adr-rules.md「4.」）
consulted: []
informed: []
tags: [infrastructure, cloudflare]
review_after: ""              # accepted 時に YYYY-MM-DD を記入
depends_on: []
supersedes: []
superseded_by: []
relates_to: []
---

# ADR-0004: Cloudflare のデプロイ先（Workers + Static Assets / Pages）

> メタデータは冒頭フロントマターを唯一の正本とする（本文に再掲しない。adr-rules.md「3.」「4.」）。本ADRは最小プロファイル。
> 変更クラスは **A**（インフラ構成。development-process.md「1.」）。
> 関連標準: [standards/frontend-ui.md](../standards/frontend-ui.md)「7.」。

## 変更履歴

| 日付 | 変更者 | 変更内容（ステータス遷移を含む） | 理由 |
|------|--------|----------------------------------|------|
| 2026-08-06 | （起案者） | 初版作成、Proposed に設定 | UI 再現性レイヤ導入にあたり、着手前に確定が必要な前提として起案 |

## コンテキスト

### 背景

Cloudflare は Workers が静的アセットを直接配信できるようになり、静的サイトとサーバロジックを単一デプロイに載せられるようになった。新規プロジェクトについては Workers + Static Assets が推奨される一方、Pages も引き続きサポートされている。

### 前提（Assumptions）

- Astro の静的出力と R2 上のメディア配信を行う。
- 将来的にフォーム送信やプレビュー用のエンドポイントが必要になる可能性がある。

### 制約（Constraints）

- `_headers` のキャッシュ・セキュリティヘッダ設定は [standards/frontend-ui.md](../standards/frontend-ui.md)「7.」の内容に従う。

## 決定要因

- 将来の動的処理（フォーム・プレビュー）への拡張コスト
- Git 連携によるプレビューデプロイの運用容易性
- バインディング（R2 / KV / D1）の追加容易性

## 意思決定事項

- 決定の問い: Cloudflare 上のどのデプロイ先を採用するか。
- 含む: 本番・プレビュー環境の配信基盤。
- 含まない: CDN キャッシュ戦略の詳細（standards/frontend-ui.md「7.」を正本とする）。

## 選択肢

### 選択肢 A：Workers + Static Assets

**メリット**: 静的配信と将来の動的処理が同一デプロイ・同一ランタイム。R2 / KV / D1 のバインディングを再プラットフォームなしで追加できる。`_headers` / `_redirects` はそのまま使える。
**デメリット**: Git 連携のプレビューデプロイ体験は Pages の方が枯れている。本番／プレビューでのバインディング切り替えに工夫が必要。

### 選択肢 B：Cloudflare Pages（ベースライン）

**メリット**: Git push だけで完結する運用がシンプル。ブランチデプロイの設定が細かい。
**デメリット**: 動的処理が必要になった時点で移行が発生する。プラットフォーム機能は Workers 側に先に出る傾向。

## 決定（案）

- 採用する選択肢（案）: **保留**（採用プロジェクトが実装着手前に A / B を確定する。既定候補は A）
- 決定理由: 本テンプレートはデプロイ対象を持たないため先に固定しない。将来の動的処理が見込まれる案件では A を既定候補とする。
- 不採用案の理由: 現時点で不採用と確定した案はない。

## 承認

> 承認者が記入。Accepted への遷移（変更履歴に記録）とフロントマター `status`/`decision-makers`/`review_after` の同時更新で確定する。承認は Class A・人間必須（constitution.md「6.」）。

| 項目 | 内容 |
|------|------|
| 確定した決定 | |
| 承認者・承認日 | |
| 見直し時期 | YYYY-MM-DD |

## 結果

> 承認後・見直し期日に記入。

- `wrangler.jsonc` の `compatibility_date` を採用日で固定する。
- `_headers` のキャッシュ・CSP 設定は [standards/frontend-ui.md](../standards/frontend-ui.md)「7.」の内容を使う。
- A を選ぶ場合、`.assetsignore` で `node_modules` 等の除外を明示する（Pages が暗黙に行っていた除外は Workers では自動ではない）。
