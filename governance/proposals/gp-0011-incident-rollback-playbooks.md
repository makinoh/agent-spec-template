---
id: GP-0011
title: "障害時点の空白を埋める：ロールバック Playbook と Class A ロールバック手順欄"
status: Proposed              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-20
last_updated: 2026-08-20
proposer: "claude-code (Sonnet 5)"
approvers: []                 # 承認待ち。Lite プロファイル（GD-0001）により定足数 1 名（オーナー）
target_version: "N/A（本提案は constitution.md を変更しない）"
supersedes: []
superseded_by: []
relates_to: [GP-0002]
---

# GP-0011: 障害時点の空白を埋める：ロールバック Playbook と Class A ロールバック手順欄

> ガバナンス決定（憲章「7. 変更管理」）。統治改訂プロンプト（Machine-First Verification 導入）WU-10 の成果物。

## 0. 前提の訂正（レビュアへ：最初にお読みください）

WU-10 の元プロンプトは「本体系はマージ時点の統治としては高度だが、障害時点については**空白**である」「`playbooks/` は本テーマについて実質空である」という前提で書かれていた。

**この前提は半分だけ正しかった。** 着手前にリポジトリを確認したところ、[playbooks/incident-response.md](../../playbooks/incident-response.md) は既に存在し、以下を備えた妥当な「雛形」であった。

* 前提（緊急承認者の指名・ロールバック手段の用意）
* 検知・初動
* 収束（Break-glass 適用の事実・理由・範囲・承認者の記録を含む）
* 確認チェックリスト
* 事後（72時間以内の事後レビュー要件。constitution.md「7.」を正しく引用）

さらに [metrics/dora.md](../../metrics/dora.md) から MTTR 計測の参照元としてクロスリファレンスもされていた。

真に欠落していたのは次の2点のみである。

1. `playbooks/rollback.md` — **存在しなかった**（インシデント対応と混同されがちだが、別関心事: 「戻すべきか・進むべきか」の判断とロールバック実行手順そのもの）。
2. `.github/pull_request_template.md` のロールバック手順欄 — **存在しなかった**。

したがって本提案は、`incident-response.md` を書き直す・重複させることはせず、**上記2点の欠落のみを埋める**（＋ development-process.md「7.」の参照更新）。この前提訂正は PR 本文でも冒頭に明示している。

## 1. 提案の要旨

development-process.md「7.」は「ロールバック/インシデント手順の詳細は本書付録または `standards/` で管理する（整備までは人間判断）」で止まっていた。統治体系がマージ時点（ADR・PR ゲート・強制台帳）に厚く投資している一方、人間ゲートを削減した分の負債は障害対応時に顕在化する。ここは GP-0002（WU-01）が定義した人間ゲートの正当な目的のうち **(b) 責任の引受**（不可逆操作・本番反映に対する意思決定）の中核であり、削減対象ではなく整備対象である。

本提案は次を行う。

1. `playbooks/rollback.md` を新設し、ロールバックの前提・判断基準・手順・確認・事後（`incident-response.md` への相互参照）を定義する。
2. `.github/pull_request_template.md` に「ロールバック手順」欄を新設し、development-process.md「7.」を実在する2 Playbook への参照へ更新する（「整備までは」の hedge を除去）。
3. Class A の PR について、ロールバック手順欄の**記載の有無**（非プレースホルダの実体）を `scripts/checks/pr_governance.sh` で機械検証する（`ADR不要理由` の抽出と同一技術）。記載**内容の妥当性**は機械検証できないため、GP-0002 の分類に従い **人間ゲート（不可避）(b) 責任の引受** として強制台帳へ登録する（暫定・ブートストラップ扱いにはしない）。
4. `standards/observability-standards.md` の整備優先度引き上げを提案する（実施は本提案の範囲外。「5. 未解決事項」参照）。

## 2. 変更内容

### 2.1 playbooks/（新規） — Class C

| 対象 | 変更 |
| --- | --- |
| `playbooks/rollback.md`（新規） | 前提（デプロイ成果物の再デプロイ可能性・migration の可逆性・フィーチャーフラグ）、判断基準（ロールバック vs 前進修正）、手順（緊急承認者の承認・AI は本番変更を単独実行しない）、確認、事後（`incident-response.md` への相互参照。重複させない）を定義。 |
| `playbooks/incident-response.md` | 既存文書は書き直さない。「収束」節に `rollback.md` への1行のクロスリファレンスのみ追加（内容の重複なし）。 |
| `playbooks/README.md` | 例示ツリーの `incident-response.md` の説明を実態に合わせ分割し、`rollback.md` を追記。 |

### 2.2 development-process.md「7.」— Class A（統治パス。development-process.md は AGENTS.md「1.」参照順序の正本文書であり `permission-impact` 対象）

| 対象 | 変更 |
| --- | --- |
| 「7. 緊急時例外（Break-glass）とインシデント対応」 | 「ロールバック/インシデント手順の詳細は本書付録または `standards/` で管理する（整備までは人間判断）」を、実在する2文書（`playbooks/incident-response.md` / `playbooks/rollback.md`）への参照へ置換。「整備までは」の hedge を除去（両文書とも「雛形」であることは維持し、過大な主張はしない）。Class A PR のロールバック手順欄の記載要件（機械検証は有無のみ・内容の妥当性は人間ゲート（不可避）(b)）を追記。 |
| バージョン | 0.2.1 → 0.2.2（改正履歴に記録済み） |

### 2.3 .github/pull_request_template.md — Class A

「ADR」欄の直後に「ロールバック手順（Class A の場合は必須。development-process.md「7.」）」欄を新設。既存の ADR 欄・権限影響欄と同じ HTML コメント案内文スタイルに揃えた。

### 2.4 scripts/checks/pr_governance.sh — Class A（ゲート実体）

`PR_LABELS` に `class:A` が含まれる場合、PR 本文の「## ロールバック手順」見出し以下の本文を抽出し、HTML コメントを除去した残りが非空白であるかを検査する。ADR不要理由の抽出（`sed -n 's/.*ADR不要理由[：:]//p'` → プレースホルダ判定）と同じ「見出しの存在ではなく実体を検査する」技術を、見出し以下の**セクション全体**（awk で次の `##` 見出しまでを切り出す）に適用した。ローカル実行時は warn（advisory）、CI（`CI=true`）では PR 本文にプレースホルダしかない場合に exit 1 で落ちる。

**実測**（`scripts/checks/pr_governance.sh` を直接呼び出し、`CI=true` ・ `PR_LABELS="class:A"` を付与）:

* プレースホルダ（HTML コメントのみ）の PR_BODY → `✗ class:A PR must include non-placeholder content under '## ロールバック手順' in the body` で exit 1
* 見出し自体が欠落した PR_BODY → 同様に exit 1
* 実体のある PR_BODY（例: 「直前のデプロイ成果物へ再デプロイし、feature flag rollback_x を無効化する。」）→ `✓ PR governance` で exit 0

### 2.5 scripts/checks/selftest.sh — Class A（ゲートの一部）

`pr_governance.sh` のロールバック手順欄チェックに対する陰性テストを1ケース追加した（プレースホルダのみの PR_BODY を注入し、ゲートが exit 1 で検出することを確認。検出できなければ selftest.sh 自体が exit 1 で失敗する）。既存12ケース→13ケースに更新（台帳 #29 の記載も同期）。

### 2.6 governance/enforcement-ledger.md — Class A

新設した2つの MUST を #34・#35 として登録した（現行スキーマのまま。GP-0002/WU-02 が別途進めているスキーマ拡張には依存しない）。

| # | 規範 | 強制手段 | 整備状況 |
| --- | --- | --- | --- |
| 34 | Class A PR のロールバック手順欄の記載の有無 | 機械（PR 本文検査） | 整備済み |
| 35 | ロールバック手順の内容の妥当性 | 人間ゲート（不可避）(b) 責任の引受 | 整備済み（**恒久的**な人間ゲート。#31〜#33 のような未整備・移行待ちの行ではない） |

## 3. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転なし**。development-process.md「7.」の hedge 除去は、既存の Break-glass／72時間以内事後レビュー義務を変えない。新設した Class A ロールバック手順欄の記載義務は、既存の PR テンプレート必須欄（ADR・権限影響）と同型の**追加**義務である |
| `playbooks/incident-response.md` | 内容は変更しない（1行のクロスリファレンス追加のみ）。既存の `metrics/dora.md` からの参照は影響を受けない |
| CI（`task verify:pr` → `scripts/checks/pr_governance.sh`） | Class A ラベルが付いた既存 Open PR がロールバック欄未記載の場合、次回 CI 実行時に本チェックで落ちるようになる（advisory から enforcement への移行と同じパターン。#10/#11 の前例に倣う） |
| UI を持たない採用 | 影響なし |
| WU-02（governance/gp-0003-enforcement-ledger-schema、別ブランチ・別 PR） | 台帳スキーマ（列追加）には**依存しない・変更しない**。本提案は現行 6 列スキーマのまま #34・#35 を追加する |

## 4. バージョン増分の判定

**本提案は constitution.md を変更しない**（「対象」は development-process.md「7.」・`playbooks/`・`.github/PULL_REQUEST_TEMPLATE`。憲章「3. 基本原則」「8.」の該当箇所は既に「ロールバック手段を備えるべき（SHOULD）」「development-process.md または standards/ で管理するべき（SHOULD）」と委譲済みであり、本提案はその委譲先を実装するのみで、委譲の構造自体は変えない）。

* `development-process.md`: 0.2.1 → **0.2.2（MINOR 未満の追記的更新）**。既存の MUST/MUST NOT を撤廃・反転せず、空白だった参照先を実体で埋め、新規の記載要件を1件追加した。
* `governance/enforcement-ledger.md`: 0.4.0（Proposed のまま）。GP-0002 がまだ未承認のドラフト版に、後方互換な行を追加した。
* `.github/pull_request_template.md` / `scripts/checks/pr_governance.sh` / `scripts/checks/selftest.sh`: バージョン管理対象外（Taskfile.yml 同様、ゲートの実体。変更履歴は本提案とコミット履歴で追跡）。

**この判定はAIによる提案であり、確定は人間承認者が行う**（憲章「7.」：AI は本書改正を単独で承認・反映してはならない MUST NOT）。

## 5. 未解決事項

| ID | 種別 | 内容 | 必要な判断 |
| --- | --- | --- | --- |
| Q-01 | scope 確認 | constitution.md「8. 機械的に検証可能なルール」「プロセス」の MUST 一覧（例:「重大な変更（Class A／Class B）を含むPRに、ADRへの参照またはADR不要理由が記載されていること」）には、ADR 要件は既に列挙されているが、本提案が新設した Class A ロールバック手順欄の MUST は**列挙していない**。既存パターンとの一貫性のためには追加すべきだが、WU-10 の元プロンプトの「対象」リストは constitution.md を含んでいなかったため、本提案では**意図的に見送った**（NG-07: 対象外の改善は実装せず提起する）。追加する場合は MINOR バージョン増分・改正履歴記載を伴う別提案（または本提案の拡張）が必要 | 人間が、この整合を別 WU として起票するか、本提案に含めて再起案させるかを判断する |
| Q-02 | 提案 (WU10-03 由来) | `standards/observability-standards.md`（Version 0.2.0、Date 2026-07-05）は、ロールバック後の「確認」（観測性によるロールバック成功の確認）が前提とする文書だが、SLI/SLO・監査ログの改ざん耐性など詳細が薄い（「2. SLI / SLO」が3行のみ）。ロールバック・インシデント対応の実効性は可観測性に依存するため、本書の整備優先度を引き上げることを提案する。**本提案の範囲外**（MAY。実施しない） | 人間が、この提案を採択し別 WU として起票するかを判断する |
| Q-03 | サブ WU の重複可能性 | 元プロンプトにより、WU-06・WU-09 が同一ベースブランチ（`refactor/framework-neutral-ui-governance`）から並行して起票されている。`scripts/checks/pr_governance.sh`・`.github/pull_request_template.md`・`governance/enforcement-ledger.md` の行番号（#34 以降）は、他 WU と衝突する可能性がある（低確率だが、対象パスが重なるため要確認）。本提案は**衝突の解消は行わず**、PR 本文で明示するにとどめる | マージ時に人間が競合を解消する |
| Q-04 | バージョン増分の確定 | 「4.」の development-process.md 0.2.2 判定を確定するか、別の判定を採るか | 承認者が確定 |

**上記が未解決の間、本提案の値を確定として扱わない**（プロンプト側制約 OUT-03: TBD-HUMAN を暫定値で埋めて先に進まない）。

## 6. 承認

> development-process.md「7.」・`.github/**`・`governance/**` の改正は統治承認者の承認を要する（development-process.md「5.」）。本リポジトリは Lite プロファイル（[GD-0001](../decisions/gd-0001-adoption-profile-lite.md)）のため定足数 1 名。AI エージェントは単独で承認・反映してはならない（MUST NOT。憲章「7.」）。

| 項目 | 内容 |
| --- | --- |
| 起案者 | claude-code（Sonnet 5）。統治改訂プロンプト（Machine-First Verification 導入）WU-10 |
| 承認者・承認日 | 未承認（本提案は Proposed） |
| 定足数の充足 | 未充足（承認待ち） |
| 確定結果 | 未確定 |

## 7. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-20 | claude-code (Sonnet 5) | 初版作成、Proposed に設定 | 統治改訂プロンプト WU-10 の起案 |
