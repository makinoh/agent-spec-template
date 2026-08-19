# 強制台帳（Enforcement Ledger）

* Version: 0.6.0（Proposed / ドラフト）
* Date: 2026-04-01
* Last amended: 2026-08-20
* 上位規範: constitution.md（開発憲章「8. 機械的に検証可能なルール」）

本書は、憲章の各 MUST / MUST NOT に **強制手段**（構造的強制／機械強制／人間ゲート（不可避）／人間ゲート（暫定））と **整備状況** を割り当てる台帳の正本（SSoT）です。

> **品質ゲートの一元化（更新）**: 機械強制は `task verify`（`Taskfile.yml` ＋ `scripts/checks/`）に一元化し、CI は `.github/workflows/verify.yml` の単一ジョブ **`verify`** が `task verify`／pull_request 時は `task verify:pr` を実行します（Developer・AIエージェント・CI は同一コマンド＝SSoT）。旧ワークフロー名（`quality-gates.yml` / `governance-checks.yml`）は廃止し、各規範の検証箇所は `scripts/checks/*.sh` を正本として下表に明記します。ブランチ保護の必須ステータスチェックは **`verify`** を登録します（ADOPTION.md「3.」）。

> **保守方針（形骸化の防止）**: 本台帳は可能な限り憲章本文の MUST / MUST NOT 抽出から生成し、手動同期を最小化するべきです（SHOULD）。網羅性（憲章のすべての MUST / MUST NOT が割当を持つこと）は、憲章「7. 変更管理」定期見直し（6ヶ月ごと等）の必須確認項目とします（SHOULD）。整備された範囲は人間レビューから自動検証へ移行します（SHOULD）。`scripts/checks/enforcement-ledger.sh` が下表のスキーマ整合性（理由区分・失効期限等の必須項目、失効期限超過ゼロ）を機械検証する（#33〜#34）。

凡例: 強制手段 = 構造的強制 / 機械強制 / 人間ゲート（不可避） / 人間ゲート（暫定）（＝機械強制への移行対象。失効期限を伴う。旧称「ブートストラップ」）。複数該当する場合は「＋」で併記する。整備状況 = 整備済み / 整備中 / 未整備。理由区分（人間ゲート（不可避）の行のみ・必須） = (a) 意味的判断 / (b) 責任の引受 / (c) 法令・契約・規制要求（constitution.md「3. 基本原則」検証手段の選択）。失効期限・担当・移行先ゲート（人間ゲート（暫定）の行のみ・必須） = 未確定は `TBD-HUMAN`（数値・人名の発明を避けるためのプレースホルダ。空欄・「—」は不可）。

| # | 規範（出所） | レベル | 強制手段 | 理由区分 | 整備状況 | 失効期限 | 担当 | 移行先ゲート | 検証箇所 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 秘密情報をハードコードしない（3章/8章） | MUST NOT | 機械強制（シークレットスキャン） | — | 整備済み（CI で実効。ローカルは gitleaks 不在時スキップ） | — | — | — | verify ジョブ → scripts/checks/secrets.sh（gitleaks） |
| 2 | 既知の重大脆弱性を含む依存をマージしない（依存/8章） | MUST NOT | 機械強制（依存スキャン, CVSS≥7.0） | — | 整備済み（CI で実効。ローカルは trivy 不在時スキップ） | — | — | — | verify ジョブ → scripts/checks/deps.sh（Trivy: HIGH/CRITICAL で fail）＋ standards/security-standards.md「5.」 |
| 3 | 本番の個人データ・機密を AI/外部AIに入力しない（データ保護） | MUST NOT | 構造的強制（接続権限不付与）＋人間ゲート（不可避） | (a) | 整備中 | — | — | — | 環境分離 ＋ standards/ai-governance.md |
| 4 | クラス未確定の変更は Class A として扱う（4章） | MUST | 機械強制（パス対応表の自動分類）＋人間ゲート（不可避） | (a) | 整備済み（development-process.md「1.」対象パス表による自動分類は実装済み。境界事例の最終判定は恒久的に人間が行う） | — | — | — | development-process.md「1.」 |
| 5 | Class A/B を人間承認なしに保護対象ブランチへ反映しない（4章/6章） | MUST NOT | 人間ゲート（不可避）（ブランチ保護・CODEOWNERS・必須レビュア） | (a)(b)(c)（constitution.md「6.」承認マトリクスの当該行の理由区分に従う。行為により異なる） | 整備中（「作成者≠承認者」が未達。[RISK-0001](risk-register/risk-0001-single-maintainer-separation-of-duties.md)） | — | — | — | .github/CODEOWNERS ＋ ブランチ保護設定 |
| 6 | ADR ファイル名が命名規則に準拠（adr-rules.md/8章） | MUST | 機械強制（正規表現） | — | 整備済み | — | — | — | verify:fast → scripts/checks/adr.sh |
| 7 | ADR の status が管理語彙のいずれか（adr-rules.md/8章） | MUST | 機械強制 | — | 整備済み | — | — | — | verify:fast → scripts/checks/adr.sh |
| 8 | Accepted ADR の本文・FM 実体に差分がない（不変性/8章） | MUST | 機械強制（base status 起点・セクション差分）＋人間ゲート（不可避） | (a)（最終判断は CODEOWNERS の意味的判断） | 整備済み（CI/pull_request。判定起点を base=accepted に修正し、変更履歴以外の表・本文の改変を検出） | — | — | — | verify:pr → scripts/checks/adr-immutability.sh |
| 9 | ADR 必須セクション存在＋FM 値制約（id↔ファイル名・profile/scope enum・日付形式・accepted 時の decision-makers/review_after 非空。adr-rules.md「3.」「4.」/8章） | MUST | 機械強制（本文＋FM 値検査） | — | 整備済み | — | — | — | verify:fast → scripts/checks/adr-content.sh（check_adr_content.py） |
| 10 | A/B を含む PR に ADR 参照 or 不要理由（5章/8章） | MUST | 機械強制（PR 本文検査）＋人間ゲート（不可避） | (a)（記載の有無は機械検証できるが、理由の実質的妥当性は意味的判断） | 整備済み（**カーブアウトあり**: dependabot による `.github/workflows/**` の `uses:` 行のみの版数更新は本記載要件を免除。ラベル・CODEOWNERS は免除しない。ADR-0006） | — | — | — | verify:pr → scripts/checks/pr_governance.sh ＋ .github/pull_request_template.md |
| 11 | 統治パス変更 PR に permission-impact ラベル＋CODEOWNERS 承認（6章/8章） | MUST | 機械強制（自動ラベル）＋人間ゲート（不可避） | (a)（統治・強制機構への実質的影響の判断） | 整備中（ラベル自動化は完了。CODEOWNERS 承認は #5/#12 と同じ RISK-0001 の制約下。dependabot の PR は `.github/dependabot.yml` の `labels:` で自動付与。免除はしない。ADR-0006） | — | — | — | verify:pr → scripts/checks/pr_governance.sh ＋ CODEOWNERS ＋ development-process.md「6.」 |
| 12 | 作成者≠承認者・include administrators・force-push 禁止（6章/8章） | MUST | 構造的強制（ブランチ保護） | — | **整備中** — include administrators（`enforce_admins`）／force-push 禁止／ブランチ削除禁止／linear history／会話解決必須は **設定済み**。**作成者≠承認者は未整備**（コラボレータ 1 名のため構造的に成立せず。waiver/exception は安全・統治の核に適用不可のため、[RISK-0001](risk-register/risk-0001-single-maintainer-separation-of-duties.md) として受容・期限付き再評価。RISK-0001 自身が `review_after: 2027-02-08` を持ち、本行における人間ゲート（暫定）相当の期限追跡を代替する） | — | — | — | `main` のブランチ保護設定 ＋ [GD-0001](decisions/gd-0001-adoption-profile-lite.md)「4.」 |
| 13 | AI は専用マシンアイデンティティで行為（6章） | MUST | 構造的強制（アカウント分離） | — | 未整備（専用マシンアカウント未発行。`agents/README.md` の `@bot/*` はテンプレート忠実性のため意図的に保持。当面は `Assisted-by:` トレーラと `ai-generated` ラベルで AI 由来を識別するが、これは能動的なゲートではなく代替の弱い統制であることに留意） | — | — | — | 組織 IdP / マシンアカウント ＋ [GD-0001](decisions/gd-0001-adoption-profile-lite.md)「5.」 |
| 14 | AI は本書改正を単独承認しない（7章） | MUST NOT | 人間ゲート（不可避）（定足数） | (b) | 整備済み（development-process.md「5.」が承認者・定足数を定義。Lite プロファイルでは定足数 1 名のため RISK-0001 と同根の制約はあるが、規範自体（AI は自己承認しない）は本 PR 作成〜マージの実運用で遵守されている） | — | — | — | development-process.md「5.」 |
| 15a | ビルド・型・自動テスト合格（8章/9章） | MUST | 機械強制 | — | 整備済み（スタック自動検出で活性化。コード未追加時は skip） | — | — | — | verify ジョブ → scripts/checks/build.sh |
| 15b | カバレッジが最低基準を満たす（8章/9章） | MUST | 機械強制（閾値） | — | **未整備**（build.sh はカバレッジを強制しない。閾値・diff-cover の配線は採用スタックで実装する。整備までは人間レビューで担保） | — | — | — | scripts/checks/build.sh ＋ standards/testing-standards.md「1.」（要実装） |
| 16 | Markdown Lint / Link Check 合格（8章） | MUST | 機械強制 | — | 整備済み（md lint は CI/ローカルで実効／Link Check は lychee 不在時ローカルでスキップ・CI で実効） | — | — | — | verify ジョブ → scripts/checks/markdown.sh・links.sh ＋ .markdownlint.jsonc |
| 17 | README.md / AGENTS.md が存在、AGENTS が constitution を参照、ツール固有指示（CLAUDE.md / GEMINI.md / CODEX.md / OPENHANDS.md / TAKT.md / SKILLS.md）が AGENTS を参照（8章/6章） | MUST | 機械強制（存在＋参照検査） | — | 整備済み | — | — | — | verify:fast → scripts/checks/structure.sh |
| 18 | 機密区分・脆弱性閾値・PII 基準を standards で定義（複数章） | MUST | 人間ゲート（不可避）（文書整備）＋機械強制（存在検査） | (a) | 整備済み | — | — | — | standards/security-standards.md |
| 19 | 品質ゲート未通過の変更を保護対象ブランチへマージしない（8章） | MUST NOT | 機械強制（必須ステータスチェック） | — | **整備済み** — `main` のブランチ保護に必須チェック **`verify`** を登録済み（strict: 最新 main での再検証を要求）。`enforce_admins` 有効のため管理者にも適用 | — | — | — | ブランチ保護（必須チェック `verify`）＋ .github/workflows/verify.yml |
| 20 | 緊急例外は人間承認を免除しない／72h 以内に事後レビュー（7章） | MUST/MUST NOT | 人間ゲート（不可避） | (b) | 整備済み（development-process.md「7.」が緊急承認者・手順を定義。playbooks/incident-response.md が運用手順を保持） | — | — | — | development-process.md「7.」＋ playbooks/incident-response.md |
| 21 | プロンプト資産はライフサイクル（status/owner/last_review）を持つ（IX/ai-governance「7.」） | SHOULD | 機械強制（FM 検査）＋人間ゲート（不可避） | (a)（内容レビューの妥当性） | 整備済み（資産追加時に活性化） | — | — | — | verify:fast → scripts/checks/prompts.sh |
| 22 | 採用配線（CODEOWNERS 実体化・ブランチ保護・必須チェック）の完遂（6章/8章/#12/#19） | MUST | 人間ゲート（不可避）＋機械強制（助言検知） | (a)（採用組織ごとの実体化判断） | **整備中** — ブランチ保護・必須チェックは完了（#19）。CODEOWNERS の `@org/*` とマシンID `@bot/*` は**テンプレート成果物の忠実性のため意図的に保持**しており、`adoption.sh` の warn は採用者向けの正しい通知として残す（[GD-0001](decisions/gd-0001-adoption-profile-lite.md)「5.」） | — | — | — | verify:pr → scripts/checks/adoption.sh ＋ ADOPTION.md。**注: ブランチ保護の点検は CI の `GITHUB_TOKEN` では実行できない**（管理者読み取り権限は GITHUB_TOKEN に付与できず、`administration` は `permissions:` の有効スコープでもない）。CI で実効化するには管理者読み取り権限を持つ PAT をシークレット `ADMIN_READ_TOKEN` に設定する。未設定時は「確認不能」として warn する（ADR-0006 とは無関係の別事項） |
| 23 | UI の値の真実源は `tokens/tokens.json`。生成物（`src/styles/tokens.css` 等）を手編集しない（10.1.1） | MUST / MUST NOT | 機械強制（再生成して差分ゼロ） | — | 整備済み（UI 採用時に活性化。未採用時は skip）。**注: `tokens:check` は Task の増分判定（`sources`/`generates`）を経由してはならない**。経由すると `.task` キャッシュが温まった環境で再生成がスキップされ、手編集を見逃す（2026-08-08 の再チェックで検出・修正済み） | — | — | — | verify → scripts/checks/ui.sh → `task ui:tokens:check`（`node tokens/build.mjs` を直接実行して差分検査） |
| 24 | CSS にトークン外の値を書かない／生のブレークポイントを直書きしない／フォーカスリングを消さない（10.1.1・10.1.2） | MUST / MUST NOT | 構造的強制（primitive を CSS 出力しない）＋機械強制（Stylelint・正規表現） | — | 整備済み（UI 採用時に活性化） | — | — | — | verify → scripts/checks/ui.sh → `task ui:lint:css`（.stylelintrc.json）・scripts/check-media-queries.mjs |
| 25 | `design-spec.md` に生の値（HEX / px / rem / ms）を書かない（10.1.1・10.1.7） | MUST NOT | 機械強制（正規表現） | — | 整備済み（UI 採用時に活性化） | — | — | — | verify → scripts/checks/ui.sh → scripts/check-spec-literals.mjs |
| 26 | Story 無きコンポーネントの禁止（必須ファイル構成。10.1.4） | MUST | 機械強制（構成検査） | — | 整備済み（UI 採用時に活性化） | — | — | — | verify → scripts/checks/ui.sh → scripts/check-component-stories.mjs |
| 27 | 視覚回帰の基準画像更新（`--update-snapshots`）は Class B。AI エージェントは実行しない（10.1.5-4） | MUST NOT | 人間ゲート（不可避）（PR レビュー・CODEOWNERS）＋規範（エージェント指示への明記） | (b) | 整備済み（実行者の識別は原理的に機械強制できないため、恒久的に人間ゲートで担保する設計。基準画像の差分は PR で人間が目視承認する） | — | — | — | AGENTS.md「8.」＋ development-process.md「1.」＋ .github/CODEOWNERS |
| 28 | 「差分なし」の自己申告を成果として認めない（10.1.5） | MUST NOT | 人間ゲート（不可避）（レビュー）＋機械強制（ゲート実行の事実） | (a) | 整備済み | — | — | — | AGENTS.md「8.」完了報告 ＋ verify ジョブのログ |
| **29** | **機械強制と定義したルールが実際に違反を検出すること**（8章「未整備の強制手段を整備済みであるかのように扱わない」） | MUST | 機械強制（陰性テスト：違反を注入してゲートが落ちるかを確認） | — | 整備済み（オフライン・決定論的。実行時間 1 秒未満） | — | — | — | verify → scripts/checks/selftest.sh（陽性対照＋陰性テスト。対象外は links / deps / 視覚回帰） |
| **30** | 依存・ツールチェーンの LTS 追随とレンジ上限、既知脆弱性の不在（security-standards「6.」/ 依存） | SHOULD / MUST NOT | 機械強制（版数照会 ＋ OSV） | — | 整備済み（**verify には含めない**。外部 API 依存のため月次スケジュールで実行） | — | — | — | .github/workflows/audit.yml → `task audit:deps` → scripts/audit_deps.py ＋ playbooks/dependency-audit.md |
| **31** | 強制手段は構造的強制→機械強制→人間ゲートの順に選択する（3章「検証手段の選択」/1.1） | MUST | 人間ゲート（不可避）（新設・改廃ルールの強制手段選定レビュー） | (a) | 整備済み（この判断は「この人間ゲートは(a)(b)(c)のいずれかに該当するか」という意味的評価そのものであり、原理的に機械検証できない。恒久的に人間ゲートとして設計する） | — | — | — | constitution.md「3. 基本原則」検証手段の選択／「1.1」 |
| **32** | 人間ゲートを「実装内容の理解確保」目的で設けない。正当な目的は (a) 意味的判断／(b) 責任の引受／(c) 法令・契約・規制要求 に限る（3章「検証手段の選択」） | MUST NOT | 人間ゲート（不可避）（新設・改廃時のレビュー） | (a) | 整備済み（#31 と同じ理由で恒久的に人間ゲート） | — | — | — | constitution.md「3. 基本原則」検証手段の選択／「6.」承認マトリクス理由区分列 |
| **33** | (a)(b)(c) いずれにも該当しない人間ゲートは失効期限・担当・移行先ゲートを付して強制台帳へ登録する（3章「検証手段の選択」/1.1） | MUST | 機械強制（必須項目の充足検査） | — | 整備済み（本 WU で `scripts/checks/enforcement-ledger.sh` を実装し、人間ゲート（暫定）行の失効期限・担当・移行先ゲートの非空を機械検証する） | — | — | — | verify:fast → scripts/checks/enforcement-ledger.sh（check_enforcement_ledger.py） |
| **34** | 失効期限を過ぎた人間ゲート（暫定）が 0 件である（8章ブートストラップ規定の機械化） | MUST | 機械強制（失効期限の日付比較） | — | 整備済み（現時点で人間ゲート（暫定）行は 0 件のため恒常的に合格するが、`scripts/checks/selftest.sh` が期限超過行の注入により検出能力を確認する） | — | — | — | verify:fast → scripts/checks/enforcement-ledger.sh（check_enforcement_ledger.py） |
| **35** | 台帳が憲章の全 MUST / MUST NOT を網羅する（既存の網羅性規定の機械化。1.1／8章） | SHOULD | 機械強制（advisory: 出現数の粗い突合）＋人間（定期見直しでの最終確認） | — | 整備中（1 MUST = 1 行の厳密な対応を機械検証する精度は本 WU では達成していない。非ブロッキングの助言出力に留め、憲章「7.」定期見直しで人間が最終確認する。過大な精度を主張しない） | — | — | — | verify:fast → scripts/checks/enforcement-ledger.sh（advisory 出力） |
| **36** | 機械強制率（(構造的強制＋機械強制) の MUST/MUST NOT 件数 ÷ 全 MUST/MUST NOT 件数）は非減少でなければならない。低下する PR は失敗させる（7章 定期見直し／統治健全性メトリクス） | MUST | 機械強制（baseline スナップショットとの比較。分数の整数交差乗算で厳密比較） | — | 整備済み（本 WU で `scripts/checks/governance-metrics.sh` を実装。baseline は `metrics/governance-health-snapshot.json`。算出は台帳を機械的に走査し、複数手段併記行は構造的強制／機械強制のいずれかを含めば inclusive に算入する。カウント方法の根拠は `scripts/check_governance_metrics.py` docstring 参照） | — | — | — | verify:fast → scripts/checks/governance-metrics.sh（check_governance_metrics.py）／基準値: metrics/governance-health-snapshot.json |
| **37** | #36 の低下が正当な場合、governance/waivers/ の**有効な**（target_check 一致・status=Active・失効期限が実日付かつ未経過の）waiver でのみ通過を許容し、無条件のバイパスを設けてはならない（7章 定期見直し／統治健全性メトリクス） | MUST NOT | 機械強制（waiver フロントマターの照合。TBD-HUMAN 等のプレースホルダは無効な失効期限として扱い waiver を無効化する） | — | 整備済み（本 WU で実装。waiver の記録項目は governance/waivers/README.md「機械可読な紐付け」に従う。現時点で該当 waiver は0件のため #36 は常に無条件では通過しない） | — | — | — | verify:fast → scripts/checks/governance-metrics.sh（check_governance_metrics.py）／governance/waivers/README.md |

> 上表は代表的な規範の割当である。**網羅性は定期見直しで確認し**、追加・変更があれば本表を更新（または再生成）する。「未整備」項目（#13, #15b 等）はリポジトリ/組織設定の整備を優先する（憲章8章ブートストラップ規定）。人間ゲート（暫定）行は現時点で 0 件である（#3〜#33 の再分類の結果、既存の「人間」を要する行はいずれも (a)/(b)/(c) のいずれかで恒久的に正当化される人間ゲート（不可避）と判定されたため。この判定自体の妥当性は人間による確認を要する。詳細は governance/proposals/gp-0003-enforcement-ledger-schema.md「5. 未解決事項」）。

---

## 改正履歴

### [0.6.0] - 2026-08-20（Proposed）

正本記録: governance/proposals/gp-0004-governance-health-metrics.md（WU-03）

**Added**

* #36 を新設: 機械強制率（(構造的強制＋機械強制) の MUST/MUST NOT 件数 ÷ 全件数）の非減少制約。低下する PR は `scripts/checks/governance-metrics.sh` が `task verify:fast` で失敗させる。基準値は `metrics/governance-health-snapshot.json`（本 WU で台帳の現状から実測して初期シード値 30/36 を記録）。
* #37 を新設: #36 の低下を正当化する経路として `governance/waivers/` の waiver 連携を実装。waiver は `target_check` 一致・`status: Active`・実日付かつ未経過の `expires` をすべて満たす場合のみ有効とし、無条件のバイパスを設けない（`governance/waivers/README.md`「機械可読な紐付け」を新設）。
* `scripts/check_governance_metrics.py` は本台帳のパーサ（`scripts/check_enforcement_ledger.py` の `load_rows` / `DATE_RE` / `GATE_BOOTSTRAP`）を再利用し、正規表現を分岐させていない。

**増分の根拠**: 既存の義務の撤廃・反転はない。新規行2件（#36・#37）の追加と、それを裏づける新規機械検証スクリプトの追加であり、憲章「7. 変更管理」バージョニング方針の MINOR 例示（機械検証ルールの追加）に該当する。

### [0.5.0] - 2026-08-19（Proposed）

正本記録: governance/proposals/gp-0003-enforcement-ledger-schema.md（WU-02）

**Added**

* 新規列「理由区分」「失効期限」「担当」「移行先ゲート」を追加（憲章「3. 基本原則」検証手段の選択が要求するスキーマ拡張）。
* `scripts/check_enforcement_ledger.py` ＋ `scripts/checks/enforcement-ledger.sh` を新設し、`verify:fast` に配線。人間ゲート（不可避）行の理由区分の非空、人間ゲート（暫定）行の失効期限・担当・移行先ゲートの非空、失効期限超過ゼロ、を機械検査する（#33・#34）。`scripts/checks/selftest.sh` に陰性テストを2件追加（理由区分欠落／失効期限超過）。
* #35 を新設: 憲章の全 MUST/MUST NOT 出現数と台帳行数の粗い突合（advisory・非ブロッキング）。1 MUST = 1 行の厳密な保証はできないため、精度を過大に主張せず「整備中」として登録する。

**Changed（用語の一括移行）**

* 凡例および #1〜#32 の「強制手段」列を、旧称（構造的／機械／人間／ブートストラップ）から新称（構造的強制／機械強制／人間ゲート（不可避）／人間ゲート（暫定））へ移行した。#31 の改正履歴（[0.4.0]）で明記した「意図的な未実施」を解消する。
* #4・#10・#11・#14・#20・#27・#28 は、旧版で「整備状況」列に強制手段の値であるはずの「ブートストラップ」が誤って記載されていた（凡例上「整備状況」は 整備済み／整備中／未整備 の3値のみ）。本改訂でこの列の誤用を是正し、各行の本来の強制手段（人間ゲート（不可避）または機械強制＋人間ゲート（不可避）の組み合わせ）と理由区分を割り当てた。
* #3〜#33 を新分類（人間ゲート（不可避）／（暫定））で再評価した結果、既存30行のうち「人間」を要する行はすべて (a)/(b)/(c) のいずれかで恒久的に正当化される人間ゲート（不可避）と判定され、人間ゲート（暫定）に該当する行は0件だった。これは実質的な発見であり、機械化が進んでいないことの追認ではなく、既存の「ブートストラップ」表記の多くが「未整備」ではなく「意図的な恒久人間ゲート」の誤記だったことを示す。この判定自体の妥当性は人間の確認を要する（未解決事項 Q-01・Q-02 参照）。
* #31・#32（WU-01 で新設）を「未整備」から「整備済み」へ再分類した。これらの人間レビューは新設ゲートの是非という意味的評価そのものであり、原理的に機械検証できない恒久的な人間ゲートであるため。
* #33（WU-01 で新設）を「人間＋機械（将来実装予定）」から「機械強制」へ格上げした。本 WU-02 が `scripts/checks/enforcement-ledger.sh` を実装したことによる。

### [0.4.0] - 2026-08-19（Proposed）

* **#31〜#33 を新設**: 憲章「3. 基本原則」に新設された「検証手段の選択（Machine-First Verification）」が導入する3つの新規 MUST / MUST NOT を登録した（強制手段の選択順位・人間ゲートの目的限定・(a)(b)(c) 非該当ゲートの台帳登録義務）。いずれも現時点は人間レビューで担保する未整備行であり、整備済みであるかのように扱わない（憲章「8. ブートストラップ規定」）。
* 用語の一部不整合について明記: 憲章「1.1」は強制手段の呼称を「人間ゲート（不可避）／人間ゲート（暫定）」へ改称したが、本表の凡例および #1〜#30 の既存行は旧称（「人間」／「ブートストラップ」）のままである。旧称から新称への一括移行・理由区分列と失効期限列の追加は、依存後続の作業単位で実施する。

### [0.3.0] - 2026-08-09（Accepted）

* **#29 を新設**: ゲート自己診断（陰性テスト）。本台帳が「整備済み」と主張するゲートが、実際に違反を検出するかを機械で確認する。
  2026-08-06〜08 に「整備済みに見えて機能していないゲート」が 3 件（lychee の偽陽性 / adoption.sh の CI 無効化 / ui:tokens:check の誤合格）見つかったことへの構造的対処。
  実測: `tokens:check` のバグを再注入すると自己診断が exit 1 で検出する（ハーネス故障も陽性対照で検出）。
* **#30 を新設**: 依存・ツールチェーン監査。trivy はマニフェストのない段階で空振りするため、その空白を埋める。
  外部 API 依存のため `task verify` には含めず、必須ゲートの決定論性を保つ。

### [0.2.4] - 2026-08-08（Accepted）

* #23 に、`task ui:tokens:check` が Task の増分判定を経由すると手編集を見逃す不具合と、その修正（ビルダー直接実行）を記録。
  定期再チェックの陰性テスト（違反を入れてゲートが落ちるか）で検出した。台帳が「整備済み」と主張していた一方、
  ローカル（`.task` キャッシュが温まった状態）では誤合格していた。

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
