---
id: GD-0003
title: "憲章 0.2.1（PATCH: 「10. 標準文書」の例示補完）"
status: Accepted              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-08
last_updated: 2026-08-08
proposer: "makinoh"
approvers: ["makinoh"]        # Lite プロファイル（GD-0001）により定足数 1 名
target_version: 0.2.1
supersedes: []
superseded_by: []
relates_to: [GD-0001, GD-0002]
---

# GD-0003: 憲章 0.2.1（PATCH: 「10. 標準文書」の例示補完）

> ガバナンス決定の確定記録（憲章「7. 変更管理」）。**PATCH** 改正のため提案（proposal）は起票せず、本記録のみとします。

## 1. 決定

憲章「10. 標準文書（Standards）」の `standards/` 例示に、`design-tokens.md` と `frontend-ui.md` を追加します。
バージョンを **0.2.0 → 0.2.1（PATCH）** とします。

## 2. 理由

0.2.0 で新設した「10.1 UI 再現性」は `standards/design-tokens.md` / `standards/frontend-ui.md` を実装標準として参照していますが、
同じ憲章内の「10.」の一覧にはこれらが載っていませんでした。定期的な再チェックで検出した文書内の不整合です。

## 3. 増分種別の判定

**PATCH**（規範的意味を変えない改善）。根拠:

- 当該箇所は「例：」で始まる**例示**であり、網羅列挙の規範ではない。
- 既存の義務（MUST / MUST NOT）の追加・撤廃・反転・意味変更を含まない。
- 追加した 2 文書は 0.2.0 の時点で既に憲章「10.1」が参照しており、新たな規範を導入していない。

（「7. 変更管理」バージョニング方針: MAJOR=後方非互換／MINOR=後方互換な追加・実質的拡張／PATCH=規範的意味を変えない改善）

## 4. 定足数

| 項目 | 内容 |
| --- | --- |
| 承認者 | `makinoh`（リポジトリオーナー） |
| 承認日 | 2026-08-08 |
| 定足数 | 1 名（Lite プロファイル・[GD-0001](gd-0001-adoption-profile-lite.md)） — 充足 |

> 起案は AI エージェント（Claude Code / Opus 5）。承認・反映は人間が行いました
> （憲章「7.」: AI エージェントは本書改正を単独で承認・反映してはならない MUST NOT）。
> 作成者＝承認者である点は [RISK-0001](../risk-register/risk-0001-single-maintainer-separation-of-duties.md) として受容済みの既知事項です。

## 5. 同期

[.specify/memory/constitution.md](../../.specify/memory/constitution.md)（ゲート用簡潔ビュー）のバージョンを 0.2.1 へ追従させました。
本 PATCH は簡潔ビューの**規範的内容を変更しません**（本体の例示補完のみ）。

## 6. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-08 | makinoh | 初版作成、Accepted | 定期再チェックで検出した憲章内の不整合の是正 |
