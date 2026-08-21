---
id: GP-0006
title: "テスト品質ゲートの実質化（Mutation Score・Spec 由来テスト・認可否定パス）"
status: Proposed              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-20
last_updated: 2026-08-20
proposer: "claude-code (Sonnet 5)"
approvers: []                 # 承認待ち。Lite プロファイル（GD-0001）により定足数 1 名（オーナー）
target_version: null          # standards/testing-standards.md は 0.2.0 → 0.3.0、constitution.md は 0.4.0 → 0.5.0、governance/enforcement-ledger.md は 0.5.0 → 0.6.0（いずれも提案・MINOR）
supersedes: []
superseded_by: []
relates_to: [GP-0002, GP-0003]
---

# GP-0006: テスト品質ゲートの実質化（Mutation Score・Spec 由来テスト・認可否定パス）

> ガバナンス決定（憲章「7. 変更管理」）。統治改訂プロンプト（Machine-First Verification 導入）WU-05。
> WU-01（[GP-0002](gp-0002-machine-first-verification.md)。PR #22、マージ済み）・WU-02（[GP-0003](gp-0003-enforcement-ledger-schema.md)。PR #23、マージ済み）に基づく。base は WU-02 のブランチ（`governance/gp-0003-enforcement-ledger-schema`）。

## 1. 提案の要旨

憲章「6. AIエージェント統治と自律境界」は、テストの追加・修正を AI エージェントの自律行為として許可している。一方で、これまでテスト品質の唯一のゲートはカバレッジだった（standards/testing-standards.md「1.」）。**同一エージェントが実装とテストの両方を書き、カバレッジのみを見る構成は、検証が自己言及に陥る**。実装のバグをそのまま反映したテストは、実装と一致する限りカバレッジを満たしてしまうため、そのバグを検出しない。

この論証は、憲章「10.1.7 UI 文書の役割分担」が Storybook についてすでに述べているものと同一の構造である。同節は「Storybook を『唯一のUI仕様』と位置づけてはならない（MUST NOT）。仕様と検証装置を同一視すると、実装に合わせて Story を書き換える経路が開き、検証が自己言及に陥る」と定める。本提案は、この論証をユニットテスト一般へ一般化する。

追加する規範は3つの新規 MUST / MUST NOT である。

1. 変更ファイルに対する mutation score が最低基準を満たさなければならない（MUST）。全体実行はコストが高いため差分（changed files）に限定してよい（MAY）。
2. 受入基準に対応するテストは spec.md から導出しなければならない（MUST）。実装を読んで書いたテストを、受入基準の充足根拠としてはならない（MUST NOT）。
3. 認可を要するエンドポイントは、権限を持たない主体からのアクセスが拒否されることを検証するテストを備えなければならない（MUST）。

あわせて、3の網羅性（全エンドポイントに漏れなく否定パステストが存在すること）を検証する仕組みの**設計案**を提示する（実装は本 WU の範囲外）。

## 2. 変更内容

### 2.1 standards/testing-standards.md — Class A

新設「4. テスト品質ゲート（Mutation Score・Spec 由来・認可否定パス）」。

| 小節 | 内容 |
| --- | --- |
| 冒頭 | 自己言及の論証（10.1.7 の一般化）＋休眠・活性化パターン（コードスタック未導入時は休眠。`scripts/checks/build.sh` の「no code stack detected」と同じ設計。**WU05-04 対応**） |
| 4.1 | カバレッジ（前提条件＝実行されたことのみ示す）と mutation score（判定条件＝バグを実際に検出できることを示す）の関係を、具体例（アサーションの無いテスト）とともに明記。カバレッジの代替ではなく、カバレッジ達成後に追加で満たす条件である旨を明記（**WU05-01 対応**） |
| 4.2 | 段階導入プロファイル（Lite / Standard / Regulated）別 mutation score 初期値の表。development-process.md「8.」の比較表と同じ形。**全セル `TBD-HUMAN`**（数値を発明しない。**WU05-02 対応**） |
| 4.3 | 受入基準からのテスト導出（spec.md の US-#/FR-# 由来）。`specs/001-user-profile-export/spec.md`・`specs/002-account-deletion/spec.md` の US-3/FR-3（いずれも「他者のデータを取得・削除できない」という否定形の受入基準）を具体例として引用 |
| 4.4 | 認可否定パステスト（権限を持たない主体からのアクセス拒否の検証）。同spec の FR-3／FR-2 を具体例として引用 |
| 4.5 | 否定パステストの網羅性検証の**設計案**（ルート一覧を生成物として持ち、生成処理の再実行で差分検証。憲章「3. 基本原則」SSoT パターンに整合）。実装は本 WU の範囲外と明記し、強制台帳 #39 として登録（**WU05-03 対応**） |

バージョン: 0.2.0 → **0.3.0（提案・MINOR）**。既存規範の撤廃・反転はなく、新規セクションの追加。

### 2.2 constitution.md「8.」— Class A

「8. 機械的に検証可能なルール」コード品質・セキュリティの箇条書きに、既存の「テストカバレッジが standards/testing-standards.md に定める最低基準を満たすこと」に並置する形で新規バレットを追加した。

> テスト品質（mutation score・spec 由来のテスト・認可の否定パステストを含む）が standards/testing-standards.md に定める基準を満たすこと

**constitution.md を変更する判断について**: WU-05 のタスク定義は対象に「constitution.md 8章」を明示している。既存の「テストカバレッジ」バレットが standards/testing-standards.md へ委譲する形で存在するのと同じパターンで、テスト品質（mutation score 等）も憲章側に1行の参照バレットを置くことが一貫すると判断した。detail（具体的な基準・初期値・設計）はすべて standards/testing-standards.md「4.」に置き、憲章側は再掲しない（SSoT・「9. 完了条件」の重複回避方針に整合）。

バージョン: 0.4.0 → **0.5.0（提案・MINOR）**。「7. 変更管理」バージョニング方針の MINOR 例示「第8章への MUST ルール追加」に該当。「13. 改正履歴」に `[0.5.0]` エントリを追加した。

### 2.3 governance/enforcement-ledger.md — Class A

新規4行（#36〜#39）を追加した。IMP-01（このリポジトリにコードスタックが存在せず、3つの新規 MUST に実効的な機械検証を実装できない）に従い、**すべて `人間ゲート（暫定）`** として登録し、失効期限・担当は `TBD-HUMAN` とした。移行先ゲートには具体的なツール名を挙げず（NG-05）、能力要件のみを記述した。

| # | 規範 | 移行先ゲート（要旨） |
| --- | --- | --- |
| #36 | mutation score 最低基準（testing-standards.md「4.1」「4.2」） | 採用スタックの mutation testing ツールを CI に配線し、閾値未満で fail させる仕組み |
| #37 | spec 由来テスト（testing-standards.md「4.3」） | FR-ID/US-ID トレーサビリティタグの必須化＋対応表の機械検証 |
| #38 | 認可否定パステスト（testing-standards.md「4.4」） | #39 のルートインベントリ設計の実装による自動検証 |
| #39 | 否定パステストの網羅性検証・設計案（testing-standards.md「4.5」） | ルートインベントリの生成物化＋差分検証（設計提示のみ。実装は本 WU の範囲外） |

あわせて、表下の「人間ゲート（暫定）行は現時点で0件」という注記（WU-02 が確定させた記述）を更新し、#36〜#39 が最初の該当行である旨を明記した。

バージョン: 0.5.0 → **0.6.0（提案・MINOR）**。新規行の追加が中心で既存規範の意味を反転させる変更はない。

**行番号の重複についての注意（重要）**: #36〜#39 は本 PR 起案時点の base（`governance/gp-0003-enforcement-ledger-schema`。当時の最終行 #35）からの連番である。同じ base から並行して起案されている他の作業単位（WU-03・04・06〜09 等）も同じ番号帯（#36〜）を採番している可能性が高い。**マージ時に人間が行番号の重複を解消する必要がある**（本提案「7. 未解決事項」Q-02 参照）。

## 3. WU-05 の各要求と対応

| ID | 要求 | 対応箇所 |
| --- | --- | --- |
| WU05-01 | mutation score とカバレッジの関係を明記（前提条件／判定条件の区別） | testing-standards.md「4.1」 |
| WU05-02 | 段階導入プロファイル別 mutation score 初期値の表。数値を発明しない・`TBD-HUMAN` | testing-standards.md「4.2」＋本書「6. 未解決事項」 |
| WU05-03 | 否定パステストの存在検証を、ルート一覧を生成物として持つ設計案として提示（実装は範囲外・人間ゲート（暫定）として台帳登録） | testing-standards.md「4.5」＋強制台帳 #39 |
| WU05-04 | 休眠・活性化パターンの遵守 | testing-standards.md「4.」冒頭の休眠・活性化注記（`scripts/checks/build.sh` と同じ設計） |

## 4. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転なし**。3つの新規 MUST / MUST NOT の追加と、その網羅性検証の設計提示（実装なし）が中心 |
| `task verify` / `task verify:fast` | 変更なし。本 PR は新規の `scripts/checks/*` を追加していない（3つの新規 MUST はいずれも `人間ゲート（暫定）` としての登録のみで、機械検証の実装は本 WU の範囲外） |
| コードを含まない採用（本リポジトリ自身を含む） | 影響なし。「4.」全体が休眠する（WU05-04） |
| コードスタック採用後のプロジェクト | 影響あり。コードスタック導入時点から「4.」の3 MUST が適用され、mutation testing・spec 由来テスト・認可否定パステストの整備が必要になる。ただし数値基準（4.2）は `TBD-HUMAN` のため、確定するまで機械強制はできない |
| AI エージェントの権限 | 変更なし。テストの追加・修正が AI の自律行為であること自体は変更していない（憲章「6.」）。本提案は「その品質をどう判定するか」を追加するのみ |
| specs/001-user-profile-export/・specs/002-account-deletion/ | **編集していない**（IMP-06）。具体例として US-3/FR-3・FR-2 を引用のみ |

## 5. バージョン増分の判定

**standards/testing-standards.md: 0.2.0 → 0.3.0（提案・MINOR）**。**constitution.md: 0.4.0 → 0.5.0（提案・MINOR）**。**governance/enforcement-ledger.md: 0.5.0 → 0.6.0（提案・MINOR）**。

根拠:

* いずれも既存の MUST / MUST NOT の**撤廃・反転はない**。すべて新規追加。
* 「7. 変更管理」バージョニング方針の MINOR 例示（新しい原則の追加、第8章への MUST ルール追加）に該当する。
* MAJOR の例示（承認マトリクスの要件削除、原則の規範的意味の変更、Class定義の再定義）には該当しない。

**この判定はAIによる提案であり、確定（Accepted 化）は人間承認者が行う**（憲章「7.」：AI は本書改正を単独で承認・反映してはならない MUST NOT）。

## 6. 実行した検証（生の出力）

`task` 本体は本環境に未導入のため、`scripts/checks/*.sh` を個別に直接実行した（Node が必要な markdown.sh のみ `nvm use 24` 後に実行）。

```text
== structure ==
✓ structure

== adr ==
✓ ADR naming & status

== adr-content ==
ADR 本文・フロントマター値検査: OK（7 件）
✓ ADR content & front-matter values

== frontmatter ==
✓ Front matter keys

== prompts ==
✓ Prompt asset lifecycle

== enforcement-ledger ==
advisory: constitution.md 中の（MUST）/（MUST NOT）出現数 95 件 ／ 台帳行数 40 件（1 MUST = 1 行の厳密な対応は求めない。定期見直しで確認する）
✓ Enforcement ledger schema (40 rows checked)

== markdown（node v24.19.0）==
markdownlint-cli2 v0.22.1 (markdownlint v0.40.0)
Finding: **/*.md
Linting: 140 file(s)
Summary: 0 error(s)
✓ Markdown lint

== selftest ==
（陽性対照: structure / adr / adr-content / frontmatter / prompts / markdown / enforcement-ledger すべて無傷で合格）
[検出] adr.sh: ADR 命名規則違反
[検出] adr.sh: status が管理語彙の外
[検出] adr-content.sh: id とファイル名の不一致
[検出] adr-content.sh: accepted なのに決裁者が空
[検出] adr-content.sh: 必須セクションの欠落
[検出] frontmatter.sh: 必須キーの欠落
[検出] prompts.sh: last_review の欠落
[検出] structure.sh: AGENTS.md が憲章参照を失う
[検出] structure.sh: 必須文書の欠落
[検出] adr-index.sh: 索引が陳腐化
[検出] markdown.sh: Markdown Lint 違反
[検出] enforcement-ledger.sh: 人間ゲート（不可避）の理由区分欠落
[検出] enforcement-ledger.sh: 人間ゲート（暫定）の失効期限超過
⚠ skip: ui: tokens:check が生成物の手編集を検出（task が無いため検出可否を判定できない）
⚠ 対象外: links.sh（lychee・ネットワーク依存）／deps.sh（trivy・脆弱性DB依存）／視覚回帰（ブラウザ必須）
自己診断: 検出 13 件 / 見逃し 0 件 / skip 1 件
✓ Gate self-test

== build ==
⚠ no code stack detected — build/test skipped (activates when a manifest is added)
⚠ coverage gate NOT enforced yet — wire a threshold in your stack (ledger #15b)
✓ build/test

== pr_governance（ローカル・advisory）==
⚠ governance path changed — ensure the PR has the 'permission-impact' label
⚠ Class A/B path changed — PR body must reference ADR-#### or give a real 'ADR不要理由:'（プレースホルダ不可）
✓ PR governance
```

いずれも exit 0（合格）。新規追加した #36〜#39 の4行は `人間ゲート（暫定）` として `失効期限`／`担当` に `TBD-HUMAN` を設定しており、`enforcement-ledger.sh` のスキーマ検査（WU-02 実装）が要求する「空欄・『—』は不可、`TBD-HUMAN` は許容」を満たすことを確認済み（40 rows checked が合格を示す）。`build.sh`・`pr_governance.sh` の警告はいずれも既知・想定どおり（コードスタック未導入、および本 PR が統治パスに触れることによるラベル要求の advisory）。

## 7. 未解決事項

### 7.1 TBD-HUMAN プレースホルダ一覧（OUT-03 対応。数値・人名を発明しないための明示プレースホルダ）

| ID | 所在 | 内容 | 必要な判断 |
| --- | --- | --- | --- |
| T-01 | testing-standards.md「4.2」表 | mutation score 初期値（変更ファイル差分）— Lite | Lite プロファイルにおける差分 mutation score の初期閾値（%）を確定する |
| T-02 | testing-standards.md「4.2」表 | mutation score 初期値（変更ファイル差分）— Standard（既定） | Standard プロファイルにおける差分 mutation score の初期閾値（%）を確定する |
| T-03 | testing-standards.md「4.2」表 | mutation score 初期値（変更ファイル差分）— Regulated | Regulated プロファイルにおける差分 mutation score の初期閾値（%）を確定する |
| T-04 | testing-standards.md「4.2」表 | 適用対象・除外基準 — Lite | 生成コード・自明な getter/setter 等、mutation score 計測から除外してよい対象の基準（Lite） |
| T-05 | testing-standards.md「4.2」表 | 適用対象・除外基準 — Standard | 同上（Standard） |
| T-06 | testing-standards.md「4.2」表 | 適用対象・除外基準 — Regulated | 同上（Regulated） |
| T-07 | 強制台帳 #36 | 失効期限 | mutation score の機械強制（CI 配線）をいつまでに完了させるか |
| T-08 | 強制台帳 #36 | 担当 | mutation testing ツール選定・CI 配線の担当者／チーム |
| T-09 | 強制台帳 #37 | 失効期限 | spec 由来トレーサビリティ機構の実装期限 |
| T-10 | 強制台帳 #37 | 担当 | 同上の担当者／チーム |
| T-11 | 強制台帳 #38 | 失効期限 | 認可否定パステストの存在確認（個別）を機械化する期限 |
| T-12 | 強制台帳 #38 | 担当 | 同上の担当者／チーム |
| T-13 | 強制台帳 #39 | 失効期限 | ルートインベントリ設計の実装着手・完了期限 |
| T-14 | 強制台帳 #39 | 担当 | 同上の担当者／チーム |

**上記14件が未解決の間、mutation score ゲートおよび #36〜#39 の機械強制を「整備済み」として扱ってはなりません（MUST NOT。憲章「8. ブートストラップ規定」）。**

### 7.2 その他の未解決事項

| ID | 種別 | 内容 | 必要な判断 |
| --- | --- | --- | --- |
| Q-01 | 設計判断 | constitution.md「8.」に mutation score 参照の MUST バレットを追加した（既存の「テストカバレッジ」バレットに並置）。追加せず testing-standards.md 内で完結させる案も可能だった | この追加が適切か、それとも見送るべきか |
| Q-02 | 行番号の重複 | #36〜#39 は本 PR 起案時点の base（`governance/gp-0003-enforcement-ledger-schema`）における最終行（#35）からの連番。並行して起案されている他の WU（03・04・06〜09）が同じ base から同じ番号帯を採番している可能性がある | マージ時に人間が行番号の重複を解消する |
| Q-03 | バージョン増分の確定 | testing-standards.md 0.2.0→0.3.0、constitution.md 0.4.0→0.5.0、enforcement-ledger.md 0.5.0→0.6.0（いずれも MINOR 提案） | 承認者が確定 |
| Q-04 | 網羅性検証の実装時期 | 「4.5」のルートインベントリ設計は本 WU では設計提示のみ（WU-05 の範囲外と明示）。実装をいつ・どの WU で行うか | 後続 WU の要否・時期を人間が判断 |
| Q-05 | 除外基準の要否 | 「4.2」に「適用対象・除外基準」の行を設けたが、これ自体が新たな検討事項を追加している（生成コード除外の要否等） | 除外基準を設けるか、シンプルに全変更ファイルへ一律適用するか |

**上記が未解決の間、本提案の値を確定として扱いません。**

## 8. 承認

> 憲章の改正は憲章承認者グループの承認を要する（development-process.md「5.」）。本リポジトリは Lite プロファイル（[GD-0001](../decisions/gd-0001-adoption-profile-lite.md)）のため定足数 1 名。AI エージェントは単独で承認・反映してはならない（MUST NOT。憲章「7.」）。

| 項目 | 内容 |
| --- | --- |
| 起案者 | claude-code（Sonnet 5）。統治改訂プロンプト（Machine-First Verification 導入）WU-05 |
| 承認者・承認日 | 未承認（本提案は Proposed） |
| 定足数の充足 | 未充足（承認待ち） |
| 確定結果 | 未確定 |

## 9. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-20 | claude-code (Sonnet 5) | 初版作成、Proposed に設定 | 統治改訂プロンプト WU-05 の起案 |
