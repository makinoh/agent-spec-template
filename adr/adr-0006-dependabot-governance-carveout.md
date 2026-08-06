---
id: ADR-0006
title: "dependabot による Actions 版数更新の統治要件（ADR 記載要件のカーブアウト）"
status: proposed              # proposed | accepted | rejected | deprecated | superseded
date: 2026-08-07
last_updated: 2026-08-07
profile: full                 # minimal | full
scope: project
proposer: "（起案者名）"
decision-makers: []           # proposed 段階は空（accepted 時に非空・adr-rules.md「4.」）
consulted: []
informed: []
tags: [ci, governance, dependabot, supply-chain]
risk: medium
review_after: ""              # accepted 時に YYYY-MM-DD を記入
depends_on: []
supersedes: []
superseded_by: []
relates_to: []
---

# ADR-0006: dependabot による Actions 版数更新の統治要件（ADR 記載要件のカーブアウト）

> メタデータは冒頭フロントマターを唯一の正本とする（本文に再掲しない。adr-rules.md「3.」「4.」）。本ADRは完全プロファイル（Class A の決定のため。adr-rules.md「2.」）。
> 変更クラスは **A**（強制機構そのもの。development-process.md「1.」）。

## 変更履歴

| 日付 | 変更者 | 変更内容（ステータス遷移を含む） | 理由 |
|------|--------|----------------------------------|------|
| 2026-08-07 | （起案者） | 初版作成、Proposed に設定 | dependabot の PR が構造的に品質ゲートを通過できない問題への対処 |

## 適用スコープ

- スコープ: project（本リポジトリおよび本テンプレートの採用先）
- 対象: `scripts/checks/pr_governance.sh` の ADR 記載要件、`.github/dependabot.yml`
- 対象外: `permission-impact` ラベル要件、CODEOWNERS 承認、その他の品質ゲート（いずれも変更しない）

### 階層型ガバナンスにおける位置づけ

本決定は憲章「5. ADRポリシー」（Class A/B の PR は ADR 参照または不要理由を要する）の**運用細目**であり、憲章の義務そのものを変更しない。変更クラスの判定基準の正本は development-process.md「1.」であり、本 ADR はその既存分類と強制実装の齟齬を解消する。

## コンテキスト

### 背景

`.github/**` は development-process.md「1. 対象パス対応表」により Class A に分類される。このため `scripts/checks/pr_governance.sh` は当該パスの変更を含む PR に対し、次の 2 つを要求する。

1. `permission-impact` ラベル（＋ CODEOWNERS 承認）
2. 本文における `ADR-####` 参照、またはプレースホルダでない `ADR不要理由:`

dependabot が生成する PR は `dependencies` / `github_actions` ラベルしか持たず、本文は自動生成のリリースノートである。したがって **dependabot の PR は構造的に必ず `verify:pr` で失敗する**。

実測（2026-08-06 時点で滞留していた 5 本の PR で確認）:

```text
PR_LABELS="dependencies,github_actions"
  ✗ governance/enforcement path changed: PR requires the 'permission-impact' label   exit 1
+ permission-impact を付与
  ✗ Class A/B PR must reference ADR-#### or give a non-placeholder 'ADR不要理由:'      exit 1
+ 本文に ADR不要理由 を追記
  ✓ PR governance                                                                    exit 0
```

結果として、Actions の版数更新 PR が最長 2 ヶ月弱（#4 / #5 は 2026-06-14 起票）滞留した。**セキュリティ更新が統治要件のために適用されない**状態であり、憲章「依存関係とサプライチェーンの完全性」に反する。

### 前提（Assumptions）

- `PR_AUTHOR` は GitHub イベントペイロード（`github.event.pull_request.user.login`）由来であり、PR 作成者が詐称できない。
- dependabot の Actions 更新 PR の差分は `uses:` 行のみである。

### 制約（Constraints）

- 人間レビュー（CODEOWNERS）を免除してはならない（憲章「6.」）。
- 失敗したゲートを回避目的で弱めてはならない（憲章「自己修正ループの防止」）。

## 意思決定事項

- 決定の問い: dependabot の Actions 版数更新 PR を、統治を弱めずに品質ゲートへ通すにはどうするか。
- 含む: ADR 記載要件の適用範囲、ラベル付与の自動化。
- 含まない: Actions のピン留め方針（floating major / exact / SHA）— 別途 ADR を要する。

## 決定要因

- 人間レビュー（CODEOWNERS 承認）が維持されること
- 免除範囲が機械的に厳密に限定できること（拡大解釈の余地がないこと）
- 依存更新が滞留しないこと
- 既存の変更クラス定義と矛盾しないこと

## 評価観点

| # | 観点 | 重み | 判定基準 |
|---|------|------|----------|
| 1 | 人間レビューの維持 | 高 | CODEOWNERS 承認と permission-impact を免除しないか |
| 2 | 免除範囲の厳密性 | 高 | 作成者・パス・差分行の三重条件で機械判定できるか |
| 3 | 運用負荷 | 中 | 週次で人手作業が発生しないか |
| 4 | 既存分類との整合 | 中 | development-process.md「1.」と矛盾しないか |

## 検討項目

- `PR_AUTHOR` の詐称可能性（イベントペイロード由来か、本文由来か）
- `uses:` 行の書き換えによるサプライチェーン攻撃（別アクションへの差し替え）の残存リスク
- `labels:` を dependabot.yml に指定した場合の既定ラベル置換の挙動

## 選択肢

### 選択肢 A：三重条件のカーブアウト＋ラベル自動付与

`pr_governance.sh` に、(1) 作成者が `dependabot[bot]`、(2) 変更ファイルが `.github/workflows/*.yml` のみ、(3) 差分行が `uses: owner/repo@ref` の形だけ、の**すべて**を満たす場合に限り ADR 記載要件を免除する分岐を追加する。あわせて `.github/dependabot.yml` の `labels:` で `permission-impact` / `class:A` を自動付与する。

**メリット**: 免除範囲が機械的に限定される。人間レビューは維持される。運用負荷ゼロ。
**デメリット**: 強制機構のコードが増える（保守対象）。

### 選択肢 B：ラベル自動付与のみ（dependabot.yml の `labels:`）

**メリット**: 実装が 1 ファイル 4 行で済む。
**デメリット**: ADR 記載要件が残るため**問題の半分しか解決しない**。本文は dependabot が生成するため人手での追記が週次で発生し続ける。

### 選択肢 C：`.github/**` を Class A から外す

**メリット**: 一律に解決する。
**デメリット**: CI/CD 定義は権限・強制機構そのものであり、Class A から外すことは統治の実質的な後退。却下。

### 選択肢 D：現状維持（毎回手作業。ベースライン）

**メリット**: 変更なし。
**デメリット**: 週次の手作業が破綻し、実績として 2 ヶ月弱の滞留を生んでいる。セキュリティ更新の遅延は憲章「サプライチェーンの完全性」に反する。

## 評価

スコアは 1（劣る）〜 5（優れる）。重み: 高 = 3、中 = 2。

| 観点（重み） | A: 三重条件＋自動ラベル | B: ラベルのみ | C: Class 引下げ | D: 現状維持 |
|---|---|---|---|---|
| 人間レビューの維持（3） | 5 | 5 | 1 | 5 |
| 免除範囲の厳密性（3） | 5 | 5 | 1 | 5 |
| 運用負荷（2） | 5 | 2 | 5 | 1 |
| 既存分類との整合（2） | 5 | 4 | 2 | 4 |
| **加重合計** | **50** | **42** | **20** | **40** |

## 決定（案）

- 採用する選択肢（案）: **A（三重条件のカーブアウト ＋ ラベル自動付与）**
- 決定理由: 免除するのは「ADR 参照または不要理由の**記載**」要件のみであり、`permission-impact` ラベルと CODEOWNERS 承認（＝人間レビュー）は維持される。免除条件は作成者・パス・差分行の三重で機械判定され、拡大解釈の余地がない。development-process.md「1.」が依存のパッチ／マイナー更新を Class C（ADR 原則不要）と定めていることとも整合し、**新たな緩和ではなく既存分類と強制実装の齟齬の解消**である。
- 不採用案の理由: B は問題の半分しか解決しない（本文追記が週次で残る）。C は統治の実質的後退。D は実績として滞留を生んでいる。

### 残存リスクと受容理由

`uses:` 行の書き換えによる**別アクションへの差し替え**（サプライチェーン攻撃）は、本カーブアウトの対象範囲に入る。ただし、

- `permission-impact` ラベルと CODEOWNERS 承認は維持されるため、**人間が必ず差分を見る**。
- 免除されるのは PR 本文のテキスト要件のみであり、これは元よりサプライチェーン攻撃を検出する機構ではない。

したがって本カーブアウトによる検出力の低下はない。より強い保証が必要な場合は Actions の **SHA 固定**を別 ADR で決定すること（憲章 参考文献の SLSA 参照）。

## 承認

> 承認者が記入。Accepted への遷移（変更履歴に記録）とフロントマター `status`/`decision-makers`/`review_after` の同時更新で確定する。承認は Class A・人間必須（constitution.md「6.」）。

| 項目 | 内容 |
|------|------|
| 確定した決定 | |
| 承認者・承認日 | |
| 見直し時期 | YYYY-MM-DD |

## 結果

> 承認後・見直し期日に記入。

- `scripts/checks/pr_governance.sh` に `is_dependabot_action_bump()` を追加。`.github/workflows/verify.yml` は `PR_AUTHOR` を渡す。
- `.github/dependabot.yml` の `labels:` に `permission-impact` / `class:A` を追加（既定ラベルは置換されるため `dependencies` / `github_actions` も明記）。指定するラベルはリポジトリに事前に存在している必要がある。
- 強制台帳 #10 / #11 に本カーブアウトを注記する。

## 関連ADR

| 関係 | ADR | 内容 |
|------|-----|------|
| （なし） | — | Actions のピン留め方針（floating major / exact / SHA 固定）は未決。必要時に別 ADR を起票する |

## 参考資料

- [development-process.md](../development-process.md)「1. 変更クラスの判定基準」— `.github/**` = Class A、依存のパッチ／マイナー更新 = Class C
- [governance/enforcement-ledger.md](../governance/enforcement-ledger.md) #10 / #11
- [standards/security-standards.md](../standards/security-standards.md)「6. サプライチェーン完全性（SLSA / SBOM）」
- [.github/CODEOWNERS](../.github/CODEOWNERS) — `.github/**` の必須レビュア
