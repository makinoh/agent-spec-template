# 強制台帳（Enforcement Ledger）

* Version: 0.2.3（Proposed / ドラフト）
* Date: 2026-04-01
* Last amended: 2026-08-08
* 上位規範: constitution.md（開発憲章「8. 機械的に検証可能なルール」）

本書は、憲章の各 MUST / MUST NOT に **強制手段**（構造的強制／機械強制／人間ゲート／ブートストラップ）と **整備状況** を割り当てる台帳の正本（SSoT）です。

> **品質ゲートの一元化（更新）**: 機械強制は `task verify`（`Taskfile.yml` ＋ `scripts/checks/`）に一元化し、CI は `.github/workflows/verify.yml` の単一ジョブ **`verify`** が `task verify`／pull_request 時は `task verify:pr` を実行します（Developer・AIエージェント・CI は同一コマンド＝SSoT）。旧ワークフロー名（`quality-gates.yml` / `governance-checks.yml`）は廃止し、各規範の検証箇所は `scripts/checks/*.sh` を正本として下表に明記します。ブランチ保護の必須ステータスチェックは **`verify`** を登録します（ADOPTION.md「3.」）。

> **保守方針（形骸化の防止）**: 本台帳は可能な限り憲章本文の MUST / MUST NOT 抽出から生成し、手動同期を最小化するべきです（SHOULD）。網羅性（憲章のすべての MUST / MUST NOT が割当を持つこと）は、憲章「7. 変更管理」定期見直し（6ヶ月ごと等）の必須確認項目とします（SHOULD）。整備された範囲は人間レビューから自動検証へ移行します（SHOULD）。

凡例: 強制手段 = 構造的 / 機械 / 人間 / ブートストラップ（=暫定的に人間レビューで担保）。整備状況 = 整備済み / 整備中 / 未整備。

| # | 規範（出所） | レベル | 強制手段 | 整備状況 | 検証箇所 |
| --- | --- | --- | --- | --- | --- |
| 1 | 秘密情報をハードコードしない（3章/8章） | MUST NOT | 機械（シークレットスキャン） | 整備済み（CI で実効。ローカルは gitleaks 不在時スキップ） | verify ジョブ → scripts/checks/secrets.sh（gitleaks） |
| 2 | 既知の重大脆弱性を含む依存をマージしない（依存/8章） | MUST NOT | 機械（依存スキャン, CVSS≥7.0） | 整備済み（CI で実効。ローカルは trivy 不在時スキップ） | verify ジョブ → scripts/checks/deps.sh（Trivy: HIGH/CRITICAL で fail）＋ standards/security-standards.md「5.」 |
| 3 | 本番の個人データ・機密を AI/外部AIに入力しない（データ保護） | MUST NOT | 構造的（接続権限不付与）＋人間 | 整備中 | 環境分離 ＋ standards/ai-governance.md |
| 4 | クラス未確定の変更は Class A として扱う（4章） | MUST | 人間＋機械（パス対応表の自動分類） | ブートストラップ | development-process.md「1.」 |
| 5 | Class A/B を人間承認なしに保護対象ブランチへ反映しない（4章/6章） | MUST NOT | 人間（ブランチ保護・CODEOWNERS・必須レビュア） | 整備中 | .github/CODEOWNERS ＋ ブランチ保護設定 |
| 6 | ADR ファイル名が命名規則に準拠（adr-rules.md/8章） | MUST | 機械（正規表現） | 整備済み | verify:fast → scripts/checks/adr.sh |
| 7 | ADR の status が管理語彙のいずれか（adr-rules.md/8章） | MUST | 機械 | 整備済み | verify:fast → scripts/checks/adr.sh |
| 8 | Accepted ADR の本文・FM 実体に差分がない（不変性/8章） | MUST | 機械（base status 起点・セクション差分）＋人間 | 整備済み（CI/pull_request。判定起点を base=accepted に修正し、変更履歴以外の表・本文の改変を検出。最終判断は CODEOWNERS） | verify:pr → scripts/checks/adr-immutability.sh |
| 9 | ADR 必須セクション存在＋FM 値制約（id↔ファイル名・profile/scope enum・日付形式・accepted 時の decision-makers/review_after 非空。adr-rules.md「3.」「4.」/8章） | MUST | 機械（本文＋FM 値検査） | 整備済み | verify:fast → scripts/checks/adr-content.sh（check_adr_content.py） |
| 10 | A/B を含む PR に ADR 参照 or 不要理由（5章/8章） | MUST | 機械（PR 本文検査）＋人間 | ブートストラップ（**カーブアウトあり**: dependabot による `.github/workflows/**` の `uses:` 行のみの版数更新は本記載要件を免除。ラベル・CODEOWNERS は免除しない。ADR-0006） | verify:pr → scripts/checks/pr_governance.sh ＋ .github/pull_request_template.md |
| 11 | 統治パス変更 PR に permission-impact ラベル＋CODEOWNERS 承認（6章/8章） | MUST | 人間＋機械（自動ラベル） | ブートストラップ（dependabot の PR は `.github/dependabot.yml` の `labels:` で自動付与。免除はしない。ADR-0006） | verify:pr → scripts/checks/pr_governance.sh ＋ CODEOWNERS ＋ development-process.md「6.」 |
| 12 | 作成者≠承認者・include administrators・force-push 禁止（6章/8章） | MUST | 構造的（ブランチ保護） | **整備中** — include administrators（`enforce_admins`）／force-push 禁止／ブランチ削除禁止／linear history／会話解決必須は **設定済み**。**作成者≠承認者は未整備**（コラボレータ 1 名のため構造的に成立せず。waiver/exception は安全・統治の核に適用不可のため、[RISK-0001](risk-register/risk-0001-single-maintainer-separation-of-duties.md) として受容・期限付き再評価） | `main` のブランチ保護設定 ＋ [GD-0001](decisions/gd-0001-adoption-profile-lite.md)「4.」 |
| 13 | AI は専用マシンアイデンティティで行為（6章） | MUST | 構造的（アカウント分離） | 未整備（専用マシンアカウント未発行。`agents/README.md` の `@bot/*` はテンプレート忠実性のため意図的に保持。当面は `Assisted-by:` トレーラと `ai-generated` ラベルで AI 由来を識別） | 組織 IdP / マシンアカウント ＋ [GD-0001](decisions/gd-0001-adoption-profile-lite.md)「5.」 |
| 14 | AI は本書改正を単独承認しない（7章） | MUST NOT | 人間（定足数） | ブートストラップ | development-process.md「5.」 |
| 15a | ビルド・型・自動テスト合格（8章/9章） | MUST | 機械 | 整備済み（スタック自動検出で活性化。コード未追加時は skip） | verify ジョブ → scripts/checks/build.sh |
| 15b | カバレッジが最低基準を満たす（8章/9章） | MUST | 機械（閾値） | **未整備**（build.sh はカバレッジを強制しない。閾値・diff-cover の配線は採用スタックで実装する。整備までは人間レビューで担保） | scripts/checks/build.sh ＋ standards/testing-standards.md「1.」（要実装） |
| 16 | Markdown Lint / Link Check 合格（8章） | MUST | 機械 | 整備済み（md lint は CI/ローカルで実効／Link Check は lychee 不在時ローカルでスキップ・CI で実効） | verify ジョブ → scripts/checks/markdown.sh・links.sh ＋ .markdownlint.jsonc |
| 17 | README.md / AGENTS.md が存在、AGENTS が constitution を参照、ツール固有指示（CLAUDE.md / GEMINI.md / CODEX.md / OPENHANDS.md / TAKT.md / SKILLS.md）が AGENTS を参照（8章/6章） | MUST | 機械（存在＋参照検査） | 整備済み | verify:fast → scripts/checks/structure.sh |
| 18 | 機密区分・脆弱性閾値・PII 基準を standards で定義（複数章） | MUST | 人間（文書整備）＋機械（存在検査） | 整備済み | standards/security-standards.md |
| 19 | 品質ゲート未通過の変更を保護対象ブランチへマージしない（8章） | MUST NOT | 機械（必須ステータスチェック） | **整備済み** — `main` のブランチ保護に必須チェック **`verify`** を登録済み（strict: 最新 main での再検証を要求）。`enforce_admins` 有効のため管理者にも適用 | ブランチ保護（必須チェック `verify`）＋ .github/workflows/verify.yml |
| 20 | 緊急例外は人間承認を免除しない／72h 以内に事後レビュー（7章） | MUST/MUST NOT | 人間 | ブートストラップ | development-process.md「7.」 |
| 21 | プロンプト資産はライフサイクル（status/owner/last_review）を持つ（IX/ai-governance「7.」） | SHOULD | 機械（FM 検査）＋人間 | 整備済み（資産追加時に活性化） | verify:fast → scripts/checks/prompts.sh |
| 22 | 採用配線（CODEOWNERS 実体化・ブランチ保護・必須チェック）の完遂（6章/8章/#12/#19） | MUST | 人間＋機械（助言検知） | **整備中** — ブランチ保護・必須チェックは完了（#19）。CODEOWNERS の `@org/*` とマシンID `@bot/*` は**テンプレート成果物の忠実性のため意図的に保持**しており、`adoption.sh` の warn は採用者向けの正しい通知として残す（[GD-0001](decisions/gd-0001-adoption-profile-lite.md)「5.」） | verify:pr → scripts/checks/adoption.sh ＋ ADOPTION.md。**注: ブランチ保護の点検は CI の `GITHUB_TOKEN` では実行できない**（管理者読み取り権限は GITHUB_TOKEN に付与できず、`administration` は `permissions:` の有効スコープでもない）。CI で実効化するには管理者読み取り権限を持つ PAT をシークレット `ADMIN_READ_TOKEN` に設定する。未設定時は「確認不能」として warn する（ADR-0006 とは無関係の別事項） |
| 23 | UI の値の真実源は `tokens/tokens.json`。生成物（`src/styles/tokens.css` 等）を手編集しない（10.1.1） | MUST / MUST NOT | 機械（再生成して差分ゼロ） | 整備済み（UI 採用時に活性化。未採用時は skip） | verify → scripts/checks/ui.sh → `task ui:tokens:check`（tokens/build.mjs） |
| 24 | CSS にトークン外の値を書かない／生のブレークポイントを直書きしない／フォーカスリングを消さない（10.1.1・10.1.2） | MUST / MUST NOT | 構造的（primitive を CSS 出力しない）＋機械（Stylelint・正規表現） | 整備済み（UI 採用時に活性化） | verify → scripts/checks/ui.sh → `task ui:lint:css`（.stylelintrc.json）・scripts/check-media-queries.mjs |
| 25 | `design-spec.md` に生の値（HEX / px / rem / ms）を書かない（10.1.1・10.1.7） | MUST NOT | 機械（正規表現） | 整備済み（UI 採用時に活性化） | verify → scripts/checks/ui.sh → scripts/check-spec-literals.mjs |
| 26 | Story 無きコンポーネントの禁止（必須ファイル構成。10.1.4） | MUST | 機械（構成検査） | 整備済み（UI 採用時に活性化） | verify → scripts/checks/ui.sh → scripts/check-component-stories.mjs |
| 27 | 視覚回帰の基準画像更新（`--update-snapshots`）は Class B。AI エージェントは実行しない（10.1.5-4） | MUST NOT | 人間（PR レビュー・CODEOWNERS）＋規範（エージェント指示への明記） | **ブートストラップ**（実行者の識別は機械強制できない。基準画像の差分は PR で人間が目視承認する） | AGENTS.md「8.」＋ development-process.md「1.」＋ .github/CODEOWNERS |
| 28 | 「差分なし」の自己申告を成果として認めない（10.1.5） | MUST NOT | 人間（レビュー）＋機械（ゲート実行の事実） | ブートストラップ | AGENTS.md「8.」完了報告 ＋ verify ジョブのログ |

> 上表は代表的な規範の割当である。**網羅性は定期見直しで確認し**、追加・変更があれば本表を更新（または再生成）する。「未整備」項目（#12, #13 等）はリポジトリ/組織設定の整備を優先する（憲章8章ブートストラップ規定）。

---

## 改正履歴

### [0.2.3] - 2026-08-08（Accepted）

* #22 に、ブランチ保護の点検が **CI の `GITHUB_TOKEN` では実行できない**制約を明記（`ADMIN_READ_TOKEN` による opt-in を追記）。
  従来は CI で保護が設定済みでも「未設定の可能性」と警告し続けており、台帳の記載（検証箇所＝adoption.sh）と実効性が乖離していた。
  `scripts/checks/adoption.sh` を修正し、「未設定」と「確認不能（認証・権限不足）」を区別して報告するようにした。

### [0.2.2] - 2026-08-08（Accepted）

* #12 / #19 / #22 の整備状況を実態へ更新（`main` のブランチ保護と必須チェック `verify` の設定完了を反映）。正本記録: [GD-0001](decisions/gd-0001-adoption-profile-lite.md)。
* #19 を「整備済み」へ。#12 は「作成者≠承認者」のみ未整備として [RISK-0001](risk-register/risk-0001-single-maintainer-separation-of-duties.md) を参照。
* #13 / #22 にプレースホルダを意図的に保持する判断（GD-0001「5.」）を明記。

### [0.2.1] - 2026-08-07（Accepted / 2026-08-08 承認）

* #10 / #11 に dependabot の Actions 版数更新に関するカーブアウトを注記（[ADR-0006](../adr/adr-0006-dependabot-governance-carveout.md)）。免除は ADR の**記載要件のみ**で、`permission-impact` ラベルと CODEOWNERS 承認は維持する。
* 検証箇所を `scripts/checks/pr_governance.sh` に明記（従来は workflows とだけ記載していた）。

### [0.2.0] - 2026-08-06（Accepted / 2026-08-08 承認）

* 憲章「10.1 UI 再現性」の新設にともない、規範 #23〜#28 を追加（正本記録: [proposals/gp-0001-ui-reproducibility.md](proposals/gp-0001-ui-reproducibility.md)）。
* #23〜#26 は機械強制（UI 採用時に活性化）、#27・#28 はブートストラップ（人間レビューで担保）。

### [0.1.0] - 2026-04-01

* 初版ドラフト。
