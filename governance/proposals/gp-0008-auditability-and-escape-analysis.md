---
id: GP-0008
title: "監査可能性と測定基盤（AI 生成識別の MUST 化とエスケープ欠陥の分類台帳）"
status: Proposed              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-20
last_updated: 2026-08-20
proposer: "claude-code (Sonnet 5)"
approvers: []                 # 承認待ち。Lite プロファイル（GD-0001）により定足数 1 名（オーナー）
target_version: null          # constitution.md 0.4.0 → 0.5.0／development-process.md 0.2.1 → 0.3.0／standards/ai-governance.md 0.1.0 → 0.2.0／governance/enforcement-ledger.md 0.5.0 → 0.6.0（いずれも提案・MINOR）
supersedes: []
superseded_by: []
relates_to: [GP-0002, GP-0003]
---

# GP-0008: 監査可能性と測定基盤

> ガバナンス決定（憲章「7. 変更管理」）。統治改訂プロンプト（Machine-First Verification 導入）WU-07。
> WU-01（[GP-0002](gp-0002-machine-first-verification.md)。PR #22、`refactor/framework-neutral-ui-governance` へマージ済み）・
> WU-02（[GP-0003](gp-0003-enforcement-ledger-schema.md)。PR #23、同ブランチへマージ済み）に依存する。
> 本ブランチは `governance/gp-0003-enforcement-ledger-schema`（WU-02 のベース）から分岐している（後述「8. なぜ base が main でないか」）。

## 1. 提案の要旨

本改訂（Machine-First Verification）はここまで「強制手段の選択順位」（WU-01）と「強制台帳のスキーマ」（WU-02）を整えたが、2つの積み残しがある。

1. **AI 生成識別が SHOULD のまま**: development-process.md「6.」は「AI は専用マシンアカウントで行為する（MUST）」を既に定めているにもかかわらず、`ai-generated` ラベルと `Assisted-by:` トレーラは SHOULD にとどまり、機械判定できるはずの手がかり（コミット作者）を実際には使っていない。
2. **本改訂の前提が未検証**: 「機械検証で足りる」は経験的仮説であり、反証可能な形で検証する仕組みがない。人間ゲート（不可避）の正当化根拠（意味的判断であること）を事後的に確認する手段が存在しない。

本提案は、(a) AI 生成識別を MUST 化し、機械判定可能な部分を実際に機械化し、(b) 本番障害の事後レビューでエスケープ欠陥を3分類し、憲章の定期見直しへ接続する台帳を新設する。

## 2. 変更内容

### 2.1 development-process.md「6.」— Class A（WU07-01・WU07-02）

| 項目 | 変更 |
| --- | --- |
| AI 生成の識別 | SHOULD → **MUST**。既知の AI エージェント・マシンアカウントが PR 作成者の場合は `ai-generated` ラベルを機械要求（`scripts/checks/pr_governance.sh`）。人間アカウント作成者の場合（AI が支援したが人間が committer である現状の大半のケース）は自己申告に依存する人間ゲート（暫定）とし、強制台帳 #36 で追跡する。 |
| AI 識別トレーラの内容 | 新設。コミットトレーラにモデル識別子・バージョンを含める規定を SHOULD として追加し、**Regulated プロファイル採用時は MUST** とする。強制台帳 #37 で追跡する。 |
| バージョン | 0.2.1 → **0.3.0（提案・MINOR）** |

### 2.2 standards/ai-governance.md「4.」— Class A

AI 生成識別を MUST とする条を追加。正確な記録方式・機械検証の実装状況は development-process.md「6.」を正本とし、本書では重複記載しない（SSoT。development-process.md 側で「重複させない」意図を明記）。バージョン: 0.1.0 → **0.2.0（提案・MINOR）**。

> **配置の判断**: WU07-02 のトレーラ内容規定は、内容そのもの（development-process.md「6. 監査証跡の記録方式」の対象）であって、standards/ai-governance.md「4. アイデンティティと権限」が扱う「誰が行為するか」の範囲外と判断し、development-process.md 側にのみ規定した。ai-governance.md 側には development-process.md への誘導のみを追加し、正本を分割しない。

### 2.3 scripts/checks/pr_governance.sh — Class A（WU07-01 の機械化）

`permission-impact` チェックと同一パターンで、PR 作成者が既知の AI エージェント・マシンアカウント（`agents/README.md`「1.」の命名 claude/codex/gemini/openhands/takt に由来する許容パターン）に一致する場合、`ai-generated` ラベルを要求する。CI では非ゼロ終了、ローカルでは警告に留める（既存の `${CI:-}` 分岐を踏襲）。判定は PR の diff の有無に依存しない（作成者の属性はファイル差分と独立のため、既存の「diff なしは skip」より前に置いた）。

**誠実な開示**: 本テンプレートには実在の専用マシンアカウントが未発行であり（強制台帳 #13）、`agents/README.md`「1.」の `@bot/*` は採用時に置換される意図的なプレースホルダである。したがって本メカニズムは**正しく実装されているが、本リポジトリでは実行機会がない（未行使）**。動作は合成の `PR_AUTHOR` 値で自己診断済み（`scripts/checks/selftest.sh` に負のテストを追加。下記「6.」参照）。dependabot 等の依存自動更新ボットは、これらが「AI が起案・生成した変更」の定義に該当しないため対象外とした。

### 2.4 governance/escape-analysis/ — Class A（WU07-03・04・05）

| ファイル | 内容 |
| --- | --- |
| `governance/escape-analysis/README.md`（新設） | `governance/risk-register/README.md` 等の既存 `governance/*/README.md` と同一の構造（上位規範／変更クラス行・記録項目テーブル・規約）で新設。3分類（①ゲート未整備／②ゲート設定不適切／③機械検出不可能）を定義し、①②の蓄積を機械強制整備の優先度根拠、③の蓄積を人間ゲート（不可避）(a) の正当化根拠とする旨を明記した（WU07-04）。 |
| `governance/escape-analysis/TEMPLATE.md`（新設） | 個別記録のテンプレート。risk-0001 の frontmatter 形式を参考に、`ESCAPE-NNNN` の frontmatter・本文構成を定義。実例はまだ0件のため、架空の事例を実例として記載していない（CON-05 / IMP-05）。 |

### 2.5 constitution.md「7. 変更管理」定期見直し — Class A（WU07-05）

「定期見直し」の入力に、`governance/escape-analysis/` が記録するエスケープ欠陥の3分類を含めることを MUST 化した。バージョン: 0.4.0 → **0.5.0（提案・MINOR）**。

> **並行 WU との衝突可能性**: 「7. 定期見直し」は、本 PR と並行して起票されている別 WU（WU-03、監査ログ・DORA計測基盤）でも同一段落付近に計測指標を追加する変更が見込まれる。マージ時に人間による競合解消が必要になる可能性が高く、本 PR 側では調整しない（「9. 未解決事項」参照）。

### 2.6 governance/enforcement-ledger.md — Class A

新規行 #36（AI 生成識別）・#37（トレーラ内容規定）・#38（escape-analysis 記録義務）を追加。凡例直下の「人間ゲート（暫定）行は現時点で0件」という記載を、本 WU で新設した #36・#37 の2件を反映して更新した。バージョン: 0.5.0 → **0.6.0（提案・MINOR）**。

## 3. IMP-01 適用の詳細（各新設 MUST の強制手段）

| WU | 新設規範 | 強制手段の選択 | 理由 |
| --- | --- | --- | --- |
| WU07-01（マシンアカウント作成者） | `ai-generated` ラベル自動要求 | **機械強制**（実装・自己診断済み。未行使） | PR 作成者ログインという構造化データからパターン照合できる。permission-impact チェックと同型 |
| WU07-01（人間アカウント作成者） | 同上（自己申告経路） | **人間ゲート（暫定）**（強制台帳 #36） | 機械検証できる作成者側の手がかりが無い（人間の GitHub アカウントから「AI 支援の有無」は判定不能）。専用マシンアカウント発行（#13）後に機械強制へ統合できる見込みがあるため不可避ではなく暫定とした |
| WU07-02 | トレーラのモデル識別子・バージョン記載 | **人間ゲート（暫定）**（強制台帳 #37） | 記載の**形式**検査は将来実装可能（正規表現）だが、**内容の真正性**（自己申告の正確さ）は原理的に機械検証できない。本 WU では形式検査すら実装せず（Regulated プロファイル未採用のため優先度低。範囲外＝スコープ縮小の判断）、将来実装の対象として登録した。「不可避」ではなく「暫定」とした理由: 形式検査自体は技術的に可能であり、「現行技術で不可能」（分類3）には該当しないため |
| WU07-03/04/05 | escape-analysis 3分類記録義務＋定期見直しへの接続 | **人間ゲート（不可避）(b) 責任の引受** | 本番障害の根本原因がどの分類に該当するかの判定は、事後レビュー担当者が「何が起きたかをどう総括するか」という説明責任の引受であり、機械化の実質的な対象がない。既存の #14・#20 と同型の理由区分 |

## 4. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転なし**。development-process.md「6.」の SHOULD→MUST 引き上げは義務を**強める**変更であり後方互換。既存30行の強制台帳は無変更 |
| `task verify:pr` | `scripts/checks/pr_governance.sh` に新規チェックが追加される。現状は合成テスト以外で発火しない（実在するマシンアカウントが無いため） |
| `task verify:fast` | `scripts/checks/enforcement-ledger.sh` が新規3行（#36〜#38）のスキーマ整合性を検査する。#36・#37 は人間ゲート（暫定）として TBD-HUMAN を記入済みのため合格する |
| コードを含まない採用 | 影響なし |
| AI エージェントの権限 | 変更なし。本提案は識別・記録の仕組みを追加するのみで、AI の自律範囲・承認マトリクスの対象行為は変えていない |
| Regulated プロファイル未採用の組織 | WU07-02 は事実上休眠（development-process.md「8.」の UI 節が UI 未採用時に休眠するのと同型） |

## 5. バージョン増分の判定

| 文書 | 増分 | 根拠 |
| --- | --- | --- |
| constitution.md | 0.4.0 → 0.5.0（MINOR） | 「7. 定期見直し」への入力追加という後方互換な拡張。既存 SHOULD の反転・削除なし |
| development-process.md | 0.2.1 → 0.3.0（MINOR） | SHOULD→MUST の引き上げ（義務を強める後方互換拡張）と新規 MUST（トレーラ内容）の追加 |
| standards/ai-governance.md | 0.1.0 → 0.2.0（MINOR） | 新規 MUST 条の追加（development-process.md への誘導のみ） |
| governance/enforcement-ledger.md | 0.5.0 → 0.6.0（MINOR） | 新規行3件の追加。既存行の意味変更なし |

いずれも `0.y.z`（Status: Proposed の未批准期間）であり後方互換性は保証されないが、実質が追加的拡張であるため MINOR 系列を維持することが実態に即している。**この判定はAIによる提案であり、確定は人間承認者が行う**（憲章「7.」）。

## 6. 実行した検証（生の出力）

`task` 本体が未導入のため、`Taskfile.yml` が定義する各チェックを個別スクリプトとして直接実行した（`verify:fast` ＋ `verify:pr` ＋ `verify` 相当）。

```text
== structure / adr / adr-content / frontmatter / prompts / enforcement-ledger / adr-index / adr-immutability ==
✓ structure
✓ ADR naming & status
ADR 本文・フロントマター値検査: OK（7 件）
✓ ADR content & front-matter values
✓ Front matter keys
✓ Prompt asset lifecycle
advisory: constitution.md 中の（MUST）/（MUST NOT）出現数 96 件 ／ 台帳行数 39 件（定期見直しで確認する）
✓ Enforcement ledger schema (39 rows checked)
adr/INDEX.md は最新です。
✓ ADR index
✓ Accepted ADR immutability

== pr_governance（ローカル・advisory。PR_AUTHOR/PR_LABELS 未設定のため新規チェックは非発火） ==
⚠ governance path changed — ensure the PR has the 'permission-impact' label
⚠ Class A/B path changed — PR body must reference ADR-#### or give a real 'ADR不要理由:'（プレースホルダ不可）
✓ PR governance

== markdown（node 24 使用） ==
markdownlint-cli2 v0.22.1 (markdownlint v0.40.0)
Linting: 142 file(s)
Summary: 0 error(s)
✓ Markdown lint

== adoption / secrets / deps / build / links（既存の警告・skip。本 PR による新規の失敗なし） ==
⚠ CODEOWNERS に未置換のプレースホルダ '@org/*' が残存（ADOPTION.md「2.」）
⚠ agents/README.md にマシンID プレースホルダ '@bot/*' が残存（ADOPTION.md「4.」）
✓ adoption wiring (warnings — 本番運用前に解消)
⚠ gitleaks not found — skipped locally (CI runs it)
⚠ trivy not found — skipped locally (CI runs it)
⚠ no code stack detected — build/test skipped
⚠ coverage gate NOT enforced yet（ledger #15b）
✓ build/test
⚠ lychee not found — skipped locally (CI runs it)

== selftest（gate self-test） ==
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
[検出] pr_governance.sh: 既知AIエージェント識別のPR作成者にai-generatedラベル欠落   ← 本 WU で追加
⚠ skip: ui: tokens:check が生成物の手編集を検出（task が無いため検出可否を判定できない）
⚠ 対象外: links.sh／deps.sh／視覚回帰
自己診断: 検出 14 件 / 見逃し 0 件 / skip 1 件
✓ Gate self-test

== 新規チェックの直接検証（合成 PR_AUTHOR。development-process.md「6.」MUST の動作確認） ==
$ CI=true PR_AUTHOR=claude-code-bot PR_LABELS=class:A bash scripts/checks/pr_governance.sh
✗ PR author 'claude-code-bot' matches a known AI-agent machine identity: PR requires the 'ai-generated' label (development-process.md「6.」MUST)
exit=1   （期待どおり: ラベル欠落を検出）

$ CI=true PR_AUTHOR=claude-code-bot PR_LABELS=class:A,ai-generated bash scripts/checks/pr_governance.sh
（新規チェックはサイレントに通過。他の permission-impact 等の既存チェックのみ発火）

$ CI=true PR_AUTHOR='dependabot[bot]' PR_LABELS=class:A bash scripts/checks/pr_governance.sh
（新規チェックはサイレントに通過＝dependabot は対象外。既存 permission-impact 等はそのまま発火）

$ PR_AUTHOR=claude-code-bot PR_LABELS=class:A bash scripts/checks/pr_governance.sh   （CI 未設定＝ローカル）
⚠ PR author 'claude-code-bot' looks like a known AI-agent machine identity — ensure the PR has the 'ai-generated' label
exit=0   （期待どおり: ローカルでは警告のみ）
```

## 7. スコープ外（NG-07: 別途の改善提案として記録するのみで実装しない）

* WU07-02 のトレーラ**形式**検査（正規表現によるモデル識別子・バージョンらしき文字列の存在確認）は、Regulated プロファイル未採用の現状では実装しなかった。将来 WU の対象とする（強制台帳 #37「移行先ゲート」参照）。
* `agents/README.md`「1.」の許容パターンを、実在のマシンアカウント発行時に実名へ更新する作業（強制台帳 #13 の解消）は本 WU のスコープ外。

## 8. なぜ base が `governance/gp-0003-enforcement-ledger-schema` であって `main` でないか

本 WU は WU-02（強制台帳のスキーマ拡張）が追加した10列スキーマ（理由区分・失効期限・担当・移行先ゲート）に依存して新規行 #36〜#38 を追加する。WU-02 の内容が `main` へマージされるまでの間、本 PR は WU-02 のブランチを base として作業する（WU-01・WU-02 と同じ運用）。WU-02（PR #23）は本 WU の作業開始後に `refactor/framework-neutral-ui-governance` へマージ済みと連絡を受けたが、base の付け替え（rebase）は本 PR のスコープ外の破壊的操作であり、人間が指示するまで実施しない。

## 9. 未解決事項

| ID | 種別 | 内容 | 必要な判断 |
| --- | --- | --- | --- |
| Q-01 | 強制手段の妥当性 | WU07-01 の許容パターン（`^(claude\|codex\|gemini\|openhands\|takt)([-_](code\|cli\|agent\|bot))*(\[bot\])?$`）は agents/README.md の名簿由来の**暫定的な**命名規則であり、実際に発行されるマシンアカウント名と一致する保証がない | 実アカウント発行時（強制台帳 #13 解消時）にパターンを実名へ更新することの確認 |
| Q-02 | 理由区分の妥当性 | WU07-03/04/05 の理由区分を (b) 責任の引受とした。(a) 意味的判断（分類の技術的判定という側面）との境界がやや曖昧 | 人間による理由区分の確認 |
| Q-03 | 並行 WU との重複行番号 | 強制台帳 #36〜#38 は本 WU（WU-07）が採番した。WU-03〜WU-06・WU-08・WU-09 が同じ base から並行して起票されており、同じ行番号帯を主張する可能性がある | マージ時に人間が行番号を再採番・調整する |
| Q-04 | constitution.md「7. 定期見直し」の競合 | 「2.5」で述べた通り、WU-03 が同一段落付近を編集する可能性が高い | マージ時に人間が競合を解消する |
| Q-05 | development-process.md「6.」の記述粒度 | AI 生成識別を「マシンアカウント作成者／人間アカウント作成者」の二経路に分けて記述した。この粒度が過剰（読みにくい）か、逆に必要な区別かは人間の判断を要する | 記述粒度の妥当性確認 |

**上記が未解決の間、本提案の値を確定として扱いません。**

## 10. 承認

| 項目 | 内容 |
| --- | --- |
| 起案者 | claude-code（Sonnet 5）。統治改訂プロンプト WU-07 |
| 承認者・承認日 | 未承認（本提案は Proposed） |
| 定足数の充足 | 未充足（承認待ち） |
| 確定結果 | 未確定 |

## 11. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-20 | claude-code (Sonnet 5) | 初版作成、Proposed に設定 | 統治改訂プロンプト WU-07 の起案 |
