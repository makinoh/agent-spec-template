# 強制台帳（Enforcement Ledger）

* Version: 0.15.0（Proposed / ドラフト）
* Date: 2026-04-01
* Last amended: 2026-08-24
* 上位規範: constitution.md（開発憲章「8. 機械的に検証可能なルール」）

本書は、憲章の各 MUST / MUST NOT に **強制手段**（構造的強制／機械強制／人間ゲート（不可避）／人間ゲート（暫定））と **整備状況** を割り当てる台帳の正本（SSoT）です。

> **品質ゲートの一元化（更新）**: 機械強制は `task verify`（`Taskfile.yml` ＋ `scripts/checks/`）に一元化します（Developer・AIエージェント・CI は同一コマンド＝SSoT）。CI は2ワークフローに分離します: `.github/workflows/verify.yml` の単一ジョブ **`verify`** が `push`／`pull_request` 時に `task verify`（コード品質・統治文書の整合性等、PR自身の内容を検証してよい範囲）を実行し、`.github/workflows/governance-gate.yml` の **`governance-gate`** ジョブが `pull_request_target`（base ref のみを checkout。PR head は checkout・実行しない）で `task verify:pr`（ADR参照／permission-impact／ai-generated／ロールバック手順など、PR自身に改変されてはならない統治ゲート）を実行します（自己参照問題の是正。外部レビュー指摘・2026-08-21。#50）。旧ワークフロー名（`quality-gates.yml` / `governance-checks.yml`）は廃止し、各規範の検証箇所は `scripts/checks/*.sh` を正本として下表に明記します。ブランチ保護の必須ステータスチェックは **`verify`** と **`governance-gate`** の両方を登録します（ADOPTION.md「3.」）。

> **保守方針（形骸化の防止）**: 本台帳は可能な限り憲章本文の MUST / MUST NOT 抽出から生成し、手動同期を最小化するべきです（SHOULD）。網羅性（憲章のすべての MUST / MUST NOT が割当を持つこと）は、憲章「7. 変更管理」定期見直し（6ヶ月ごと等）の必須確認項目とします（SHOULD）。整備された範囲は人間レビューから自動検証へ移行します（SHOULD）。`scripts/checks/enforcement-ledger.sh` が下表のスキーマ整合性（理由区分・失効期限等の必須項目、失効期限超過ゼロ）を機械検証する（#33〜#34）。

凡例: 強制手段 = 構造的強制 / 機械強制 / 人間ゲート（不可避） / 人間ゲート（暫定）（＝機械強制への移行対象。失効期限を伴う。旧称「ブートストラップ」）。複数該当する場合は「＋」で併記する。整備状況 = 整備済み / 整備中 / 未整備。理由区分（人間ゲート（不可避）の行のみ・必須） = (a) 意味的判断 / (b) 責任の引受 / (c) 法令・契約・規制要求（constitution.md「3. 基本原則」検証手段の選択）。失効期限・担当・移行先ゲート（人間ゲート（暫定）の行のみ・必須） = 未確定は `TBD-HUMAN`（数値・人名の発明を避けるためのプレースホルダ。空欄・「—」は不可）。

| # | 規範（出所） | レベル | 強制手段 | 理由区分 | 整備状況 | 失効期限 | 担当 | 移行先ゲート | 検証箇所 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 秘密情報をハードコードしない（3章/8章） | MUST NOT | 機械強制（シークレットスキャン） | — | 整備済み（CI で実効。ローカルは gitleaks 不在時スキップ） | — | — | — | verify ジョブ → scripts/checks/secrets.sh（gitleaks） |
| 2 | 既知の重大脆弱性を含む依存をマージしない（依存/8章） | MUST NOT | 機械強制（依存スキャン, CVSS≥7.0） | — | 整備済み（CI で実効。ローカルは trivy 不在時スキップ）。**2026-08-24 追記（外部レビュー指摘）**: 実装は `--ignore-unfixed` を付けており、失敗させるのは**上流に修正版が存在する**脆弱性に限る。修正版の無い High/Critical は本ゲートでは検出されず、規範（security-standards.md「5.」の MUST NOT）を実装側が狭めていた。恒久的に赤いゲートは外される力学が働くため運用上の選択として維持するが、黙って狭めない（憲章「8. ブートストラップ規定」）。規範側に同一条件を明記し一致させ、修正版の無い重大脆弱性の受容可否は人間ゲート（不可避）(b) で担保する | — | — | — | verify ジョブ → scripts/checks/deps.sh（Trivy: HIGH/CRITICAL・`--ignore-unfixed` で fail）＋ standards/security-standards.md「5.」 |
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
| 21 | プロンプト資産はライフサイクル（status/owner/last_review）を持つ（IX/ai-governance「7.」） | SHOULD | 機械強制（FM 検査：キーの存在・値の非空・status の語彙・last_review の日付妥当性）＋人間ゲート（不可避） | (a)（内容レビューの妥当性） | 整備済み（資産追加時に活性化）。**2026-08-24 是正（外部レビュー指摘・再現確認済み）**: 旧実装は `index($0, k":")==1` でキーの存在しか見ておらず、値を空にしても status を語彙外にしても last_review を 1999 年にしても合格していた。「陳腐化検知に用いる」と自ら書いた項目が日付として解釈すらされておらず、同一リポジトリ内で check_enforcement_ledger.py（失効期限の日付比較）や waivers.py（プレースホルダを無効な期限として扱う）と厳格さが不揃いだった。値の非空・語彙・日付妥当性・未来日を検査し陰性テスト 5 件を追加。**陳腐化の上限日数は未確定（`TBD-HUMAN`）** ——運用値であり AI が発明しない（憲章「10.1.3」）。`PROMPT_REVIEW_MAX_AGE_DAYS` 設定時のみ hard-fail し、未設定時は経過日数を表示する | — | — | — | verify:fast → scripts/checks/prompts.sh |
| 22 | 採用配線（CODEOWNERS 実体化・ブランチ保護・必須チェック）の完遂（6章/8章/#12/#19） | MUST | 人間ゲート（不可避）＋機械強制（助言検知） | (a)（採用組織ごとの実体化判断） | **整備中** — ブランチ保護・必須チェックは完了（#19）。CODEOWNERS の `@org/*` とマシンID `@bot/*` は**テンプレート成果物の忠実性のため意図的に保持**しており、`adoption.sh` の warn は採用者向けの正しい通知として残す（[GD-0001](decisions/gd-0001-adoption-profile-lite.md)「5.」） | — | — | — | verify:pr → scripts/checks/adoption.sh ＋ ADOPTION.md。**注: ブランチ保護の点検は CI の `GITHUB_TOKEN` では実行できない**（管理者読み取り権限は GITHUB_TOKEN に付与できず、`administration` は `permissions:` の有効スコープでもない）。CI で実効化するには管理者読み取り権限を持つ PAT をシークレット `ADMIN_READ_TOKEN` に設定する。未設定時は「確認不能」として warn する（ADR-0006 とは無関係の別事項） |
| 23 | UI の値の真実源は `tokens/tokens.json`。生成物（`src/styles/tokens.css` 等）を手編集しない（10.1.1） | MUST / MUST NOT | 機械強制（再生成して差分ゼロ） | — | 整備済み（UI 採用時に活性化。未採用時は skip）。**注: `tokens:check` は Task の増分判定（`sources`/`generates`）を経由してはならない**。経由すると `.task` キャッシュが温まった環境で再生成がスキップされ、手編集を見逃す（2026-08-08 の再チェックで検出・修正済み） | — | — | — | verify → scripts/checks/ui.sh → `task ui:tokens:check`（`node tokens/build.mjs` を直接実行して差分検査） |
| 24 | CSS にトークン外の値を書かない／生のブレークポイントを直書きしない／フォーカスリングを消さない（10.1.1・10.1.2） | MUST / MUST NOT | 構造的強制（primitive を CSS 出力しない）＋機械強制（Stylelint・正規表現） | — | 整備済み（UI 採用時に活性化） | — | — | — | verify → scripts/checks/ui.sh → `task ui:lint:css`（.stylelintrc.json）・scripts/check-media-queries.mjs |
| 25 | `design-spec.md` に生の値（HEX / px / rem / ms）を書かない（10.1.1・10.1.7） | MUST NOT | 機械強制（正規表現） | — | 整備済み（UI 採用時に活性化） | — | — | — | verify → scripts/checks/ui.sh → scripts/check-spec-literals.mjs |
| 26 | Story 無きコンポーネントの禁止（必須ファイル構成。10.1.4） | MUST | 機械強制（構成検査） | — | 整備済み（UI 採用時に活性化） | — | — | — | verify → scripts/checks/ui.sh → scripts/check-component-stories.mjs |
| 27 | 視覚回帰の基準画像更新（`--update-snapshots`）は Class B。AI エージェントは実行しない（10.1.5-4） | MUST NOT | 人間ゲート（不可避）（PR レビュー・CODEOWNERS）＋規範（エージェント指示への明記） | (b) | 整備済み（実行者の識別は原理的に機械強制できないため、恒久的に人間ゲートで担保する設計。基準画像の差分は PR で人間が目視承認する） | — | — | — | AGENTS.md「8.」＋ development-process.md「1.」＋ .github/CODEOWNERS |
| 28 | 「差分なし」の自己申告を成果として認めない（10.1.5） | MUST NOT | 人間ゲート（不可避）（レビュー）＋機械強制（ゲート実行の事実） | (a) | 整備済み | — | — | — | AGENTS.md「8.」完了報告 ＋ verify ジョブのログ |
| **29** | **機械強制と定義したルールが実際に違反を検出すること**（8章「未整備の強制手段を整備済みであるかのように扱わない」） | MUST | 機械強制（陰性テスト：違反を注入してゲートが落ちるかを確認） | — | 整備済み（オフライン・決定論的）。**2026-08-24 是正（外部レビュー指摘）**: 本規範自体に開示されていない適用漏れがあった——`secrets.sh`（#1。最も優先度の高い MUST NOT）と `adr-immutability.sh`（#8）は陰性テストが無いうえ「対象外」の開示にも含まれていなかった。除外理由に挙げていた「ネットワーク依存」は gitleaks には当てはまらない（正規表現ベースでオフライン動作する）ため、技術的制約ではなく単なる漏れだった。両者の陰性テストを追加し、あわせて `build.sh` / `deps-audit.sh` / `adoption.sh` を理由付きで対象外として明記した | — | — | — | verify → scripts/checks/selftest.sh（陽性対照＋陰性テスト。対象外は links / deps の脆弱性部分 / 視覚回帰 / build.sh・deps-audit.sh〔外部依存〕/ adoption.sh〔助言専用の設計〕） |
| **30** | 依存・ツールチェーンの LTS 追随とレンジ上限、既知脆弱性の不在（security-standards「6.」/ 依存） | SHOULD / MUST NOT | 機械強制（版数照会 ＋ OSV） | — | 整備済み（**verify には含めない**。外部 API 依存のため月次スケジュールで実行） | — | — | — | .github/workflows/audit.yml → `task audit:deps` → scripts/audit_deps.py ＋ playbooks/dependency-audit.md |
| **31** | 強制手段は構造的強制→機械強制→人間ゲートの順に選択する（3章「検証手段の選択」/1.1） | MUST | 人間ゲート（不可避）（新設・改廃ルールの強制手段選定レビュー） | (a) | 整備済み（この判断は「この人間ゲートは(a)(b)(c)のいずれかに該当するか」という意味的評価そのものであり、原理的に機械検証できない。恒久的に人間ゲートとして設計する） | — | — | — | constitution.md「3. 基本原則」検証手段の選択／「1.1」 |
| **32** | 人間ゲートを「実装内容の理解確保」目的で設けない。正当な目的は (a) 意味的判断／(b) 責任の引受／(c) 法令・契約・規制要求 に限る（3章「検証手段の選択」） | MUST NOT | 人間ゲート（不可避）（新設・改廃時のレビュー） | (a) | 整備済み（#31 と同じ理由で恒久的に人間ゲート） | — | — | — | constitution.md「3. 基本原則」検証手段の選択／「6.」承認マトリクス理由区分列 |
| **33** | (a)(b)(c) いずれにも該当しない人間ゲートは失効期限・担当・移行先ゲートを付して強制台帳へ登録する（3章「検証手段の選択」/1.1） | MUST | 機械強制（必須項目の充足検査） | — | 整備済み（本 WU で `scripts/checks/enforcement-ledger.sh` を実装し、人間ゲート（暫定）行の失効期限・担当・移行先ゲートの非空を機械検証する） | — | — | — | verify:fast → scripts/checks/enforcement-ledger.sh（check_enforcement_ledger.py） |
| **34** | 失効期限を過ぎた人間ゲート（暫定）が 0 件である（8章ブートストラップ規定の機械化） | MUST | 機械強制（失効期限の日付比較） | — | 整備済み（現時点で人間ゲート（暫定）行は 0 件のため恒常的に合格するが、`scripts/checks/selftest.sh` が期限超過行の注入により検出能力を確認する） | — | — | — | verify:fast → scripts/checks/enforcement-ledger.sh（check_enforcement_ledger.py） |
| **35** | 台帳が憲章の全 MUST / MUST NOT を網羅する（既存の網羅性規定の機械化。1.1／8章） | SHOULD | 機械強制（advisory: 出現数の粗い突合）＋人間（定期見直しでの最終確認） | — | 整備中（1 MUST = 1 行の厳密な対応を機械検証する精度は本 WU では達成していない。非ブロッキングの助言出力に留め、憲章「7.」定期見直しで人間が最終確認する。過大な精度を主張しない） | — | — | — | verify:fast → scripts/checks/enforcement-ledger.sh（advisory 出力） |
| **36** | 変更ファイルの mutation score が最低基準を満たす（testing-standards.md「4.1」「4.2」／8章） | MUST | 人間ゲート（暫定） | — | 未整備（本リポジトリはコードスタックを持たず `scripts/checks/build.sh` が no code stack detected を報告する。mutation testing ツールの選定・CI 配線は採用スタックで実施する。整備までは人間レビューで担保し、整備済みと扱わない） | TBD-HUMAN | TBD-HUMAN | 採用スタックの mutation testing ツールを CI に配線し、変更ファイルの mutation score が「4.2」の閾値未満の場合に fail させる仕組み（具体的なツールは未選定） | standards/testing-standards.md「4.1」「4.2」（現状は人間レビュー。機械検証は未実装） |
| **37** | 受入基準に対応するテストは spec.md から導出する。実装を読んで書いたテストを充足根拠としない（testing-standards.md「4.3」／8章） | MUST / MUST NOT | 人間ゲート（暫定） | — | 未整備（テストが spec 由来か実装追従かを機械的に判別する手段が現状ない。コードレビューでの FR-ID/US-ID 対応確認により人間レビューで暫定担保） | TBD-HUMAN | TBD-HUMAN | テストコードへの FR-ID/US-ID トレーサビリティタグの必須化と、spec.md の要求IDとテストの対応表を機械検証する仕組み（設計は本 WU の範囲外） | standards/testing-standards.md「4.3」（現状は人間レビュー） |
| **38** | 認可を要するエンドポイントは権限を持たない主体からのアクセス拒否を検証するテストを備える（testing-standards.md「4.4」／8章） | MUST | 人間ゲート（暫定） | — | 未整備（個別テストの存在確認は人間レビュー。全ルートを漏れなく検証する仕組みは #39 を参照） | TBD-HUMAN | TBD-HUMAN | #39 のルートインベントリ設計の実装により、認可要求ルートに対応する否定パステストの存在を CI で検証する仕組み | standards/testing-standards.md「4.4」（現状は人間レビュー） |
| **39** | 認可否定パステストの網羅性検証（ルート一覧を生成物として持ち、生成処理の再実行で差分検証する設計。testing-standards.md「4.5」） | SHOULD（設計提案の実装可否） | 人間ゲート（暫定） | — | 未整備（設計案の提示のみ。実装は WU-05 の範囲外） | TBD-HUMAN | TBD-HUMAN | ルーティング定義（採用フレームワークのルート定義／OpenAPI 等）からルート一覧を生成物として出力し認可要求フラグを付与、対応する否定パステストの存在を機械検証。生成処理を CI で再実行し差分ゼロを確認する（SSoT パターン。憲章「3. 基本原則」） | standards/testing-standards.md「4.5」（設計案。実装未着手） |
| **40** | 第一者コードの静的解析（SAST）に合格すること（8章。WU-04で新設） | MUST | 機械強制（休眠/活性化のスタック検出とゲート配線）＋人間ゲート（暫定）（実ツールによる脆弱性検出ロジックは未配線） | — | 整備中（休眠時 skip・活性化時のツール解決ロジック〔`$SAST_CMD` または `scripts/dev/sast-tool.sh`〕は実装・動作確認済み〔dormant / no-tool-warn / tool-pass / tool-fail の4状態を確認〕。**実ツールによる脆弱性検出そのものは未整備**——SAST_CMD 未設定のため、現状は活性化時も「未配線」警告を出して exit 0 する。「整備済み」と扱わない（憲章「8. ブートストラップ規定」）） | TBD-HUMAN | TBD-HUMAN | ADR で SAST ツールを選定し `SAST_CMD`（または `scripts/dev/sast-tool.sh`）として配線。CI に実ツールを導入し、standards/security-standards.md「8.」の重大度カットオフを確定した上で hard-fail 化する | verify ジョブ → scripts/checks/sast.sh ＋ standards/security-standards.md「8.」「8.1」 |
| **41** | AI 生成の識別: PR 作成者が既知の AI エージェント・マシンアカウントの場合は `ai-generated` ラベルを機械要求。人間アカウント作成者の場合は自己申告に依存する（development-process.md「6.」/8章。WU07-01） | MUST | 機械強制（PR_AUTHOR 照合。既知マシンアカウントの場合。**未行使**）＋人間ゲート（暫定）（人間アカウント作成者の自己申告に依存する場合） | — | 整備中（機械強制メカニズムは実装済み・自己診断済み（`scripts/checks/selftest.sh`）だが、本テンプレートには実在の専用マシンアカウントが未発行のため実行機会がない＝未行使。#13 参照。人間アカウント作成者の場合は自己申告以外に機械検証できる手がかりがない） | TBD-HUMAN | TBD-HUMAN | #13（マシンアカウント発行）の解消後、AI 起案コミットが実際にマシンアカウント経由となり、本行の人間ゲート（暫定）部分を機械強制へ統合する | verify:pr → scripts/checks/pr_governance.sh ＋ development-process.md「6.」 |
| **42** | AI 識別トレーラ（`Assisted-by:` 等）にモデル識別子・バージョンを含める（Regulated プロファイル限定 MUST／他プロファイル SHOULD。development-process.md「6.」/8章。WU07-02） | MUST（Regulated 限定）／SHOULD（Lite・Standard） | 人間ゲート（暫定） | — | 未整備（トレーラ内容の正規表現検証は本 WU では実装しない。本リポジトリは Lite プロファイル採用（[GD-0001](decisions/gd-0001-adoption-profile-lite.md)）のため現時点では適用対象外＝休眠。記載内容の**真正性**（自己申告の正確さ）自体は原理的に機械検証できない意味的判断であり、機械化できるのは「トレーラに識別子・バージョンらしき文字列が存在するか」という形式検査までにとどまる） | TBD-HUMAN | TBD-HUMAN | Regulated プロファイル採用時に、コミットトレーラ内のモデル識別子・バージョン記載の**形式**を正規表現等で機械検証するスクリプトを実装（内容の真正性検証は対象外のまま） | development-process.md「6.」 |
| **43** | 本番障害の事後レビュー時、各エスケープ欠陥を3分類（ゲート未整備／ゲート設定不適切／機械検出不可能）で記録し、憲章「7.」定期見直しの入力に加える（governance/escape-analysis/README.md。WU07-03/04/05） | MUST | 人間ゲート（不可避） | (b) | 整備済み（`governance/escape-analysis/README.md` が記録項目・3分類・定期見直しへの接続を規定。実際の記録はまだ0件＝本テンプレートに本番運用・本番障害の実例がないため。分類の判定は事後レビュー担当者による意味的判断であり、原理的に機械検証できない） | — | — | — | governance/escape-analysis/README.md ＋ constitution.md「7. 変更管理」定期見直し |
| **44** | 機械強制率（(構造的強制＋機械強制) の MUST/MUST NOT 件数 ÷ 全 MUST/MUST NOT 件数）は非減少でなければならない。低下する PR は失敗させる（7章 定期見直し／統治健全性メトリクス） | MUST | 機械強制（baseline スナップショットとの比較。分数の整数交差乗算で厳密比較） | — | 整備済み（本 WU で `scripts/checks/governance-metrics.sh` を実装。baseline は `metrics/governance-health-snapshot.json`。算出は台帳を機械的に走査し、複数手段併記行は構造的強制／機械強制のいずれかを含めば inclusive に算入する。カウント方法の根拠は `scripts/check_governance_metrics.py` docstring 参照） | — | — | — | verify:fast → scripts/checks/governance-metrics.sh（check_governance_metrics.py）／基準値: metrics/governance-health-snapshot.json |
| **45** | #44 の低下が正当な場合、governance/waivers/ の**有効な**（target_check 一致・status=Active・失効期限が実日付かつ未経過の）waiver でのみ通過を許容し、無条件のバイパスを設けてはならない（7章 定期見直し／統治健全性メトリクス） | MUST NOT | 機械強制（waiver フロントマターの照合。TBD-HUMAN 等のプレースホルダは無効な失効期限として扱い waiver を無効化する） | — | 整備済み（本 WU で実装。waiver の記録項目は governance/waivers/README.md「機械可読な紐付け」に従う。現時点で該当 waiver は0件のため #44 は常に無条件では通過しない） | — | — | — | verify:fast → scripts/checks/governance-metrics.sh（check_governance_metrics.py）／governance/waivers/README.md |
| **46** | Class A/B の PR は変更行数の上限を超えてはならない（development-process.md「5.」／3章 検証手段の選択。WU-08） | MUST NOT | 機械強制（Class A=200行／Class B=400行。`DIFF_SIZE_LIMIT_CLASS_A`/`_CLASS_B` を governance-gate.yml に設定し hard-fail 化済み） | — | **整備済み（2026-08-22 に人間が上限値を確定。外部レビュー指摘への対応）** — 変更行数の計測・Class A/B 分類・生成物/ロックファイル除外・上限比較ロジックは実装済みで、`verify:pr`（governance-gate.yml）から実行される。数値の投入のみで advisory から hard-fail へ移行した（配線変更は不要だった。設計どおり）。上限を超える場合は変更を分割するか、[governance/waivers/](waivers/README.md) の時限的な適用除外を要する。**2026-08-24 追記**: この「適用除外」は従来 statement のみで実装が無く（`check_diff_size.py` は waiver を読んでいなかった）、案内された逃げ道が存在しないまま hard-fail していた。#45 と同一の gate-linked waiver 規約（`target_check` 一致・status=Active・expires が実日付かつ未経過）を、共通ローダ `scripts/waivers.py` 経由で本ゲートにも適用し是正した。対象ゲート識別子は Class ごとに分離する（`diff-size.class-a` / `diff-size.class-b`） | — | — | — | verify:pr（governance-gate.yml） → scripts/checks/diff-size.sh（check_diff_size.py）／照合は scripts/waivers.py・規約は governance/waivers/README.md「機械可読な紐付け」 |
| **47** | Class A の PR は本文にロールバック手順欄の記載（非プレースホルダの実体）を含まなければならない（development-process.md「7.」。WU-10で新設） | MUST | 機械強制（PR 本文検査。ADR不要理由の抽出と同一技術：見出し以下の本文を取り出し、HTML コメントを除去し、残りの非空白を検査する） | — | 整備済み（**2026-08-21 に2件のバグを是正**（外部レビュー指摘）: (1) HTML コメント除去が行単位の sed（`<!--.*-->`）で、`.github/pull_request_template.md` 実物の3行にまたがる案内コメントを除去できず、未編集テンプレートが「実体あり」と誤判定されていた。Python の `re.DOTALL` による複数行対応の除去へ修正。selftest.sh のフィクスチャも合成の1行コメントでは検出できなかったため、実物から抽出する方式へ変更した。(2) 発火条件が `class:A` ラベルの有無**のみ**に依存しており、ラベルを付け忘れると本チェック自体が丸ごと発火しない fail-open だった（permission-impact 側はパス由来で fail-close であり非対称）。統治パス変更（`$gov`）を OR 条件に追加し是正した） | — | — | — | verify:pr（governance-gate.yml） → scripts/checks/pr_governance.sh ＋ .github/pull_request_template.md「ロールバック手順」欄 |
| **48** | ロールバック手順**の内容**が復旧手段として妥当であること（development-process.md「7.」／playbooks/rollback.md。WU-10で新設） | MUST | 人間ゲート（不可避） | (b) | 整備済み（恒久的な人間ゲート。#47 の存在検証とは別。本番反映に対する意思決定であり、暫定・ブートストラップではない） | — | — | — | PR レビュー（development-process.md「5.」承認者）＋ constitution.md「3. 基本原則」検証手段の選択 |
| **49** | 簡潔ビュー（`.specify/memory/constitution.md`）は正本（constitution.md）の改正に追従する（`.specify/memory/constitution.md`「Governance」／7章）。spec-kit の Constitution Check（`/speckit.plan`）が読む派生サマリのため、陳腐化すると古い基準でゲートが走る（GP-0010「WU09-01」） | SHOULD | 機械強制（バージョン番号の一致検査） | — | **整備済み（バージョン欄のみ）** — `* Version: X.Y.Z` の一致のみを検証する。「Last amended」・原則本文等、簡潔ビューの他の内容の同期は未整備（生成化は本 WU の対象外。同期補助として `scripts/sync_constitution_version.py` を用意したが、バージョン番号のみを書き換える） | — | — | — | verify:fast → scripts/checks/constitution-sync.sh |
| **50** | PR-context の統治ゲート（ADR参照／permission-impact／ai-generated／ロールバック手順の各検証）は、検査対象の PR 自身が改変できないコードで実行されなければならない（自己参照の禁止。constitution.md「3. 基本原則」検証手段の選択／6章 AIエージェント統治） | MUST | 構造的強制（`pull_request_target` トリガで base ref のみを checkout し、PR head は checkout・実行しない設計。PR 由来のコードを一切実行しないため、PR 自身がこの検査ロジックを書き換えても検査結果に影響しない） | — | 整備済み（外部レビュー指摘・2026-08-21。是正前は `.github/workflows/verify.yml` が `pull_request` トリガで PR head を checkout し、その改変版の `scripts/checks/pr_governance.sh` で検査していたため、当該スクリプトの先頭に `exit 0` を1行足すだけで permission-impact ラベル要求ごと無効化できることを確認した（再現済み）。`.github/workflows/governance-gate.yml`（`pull_request_target`）へ分離し是正した） | — | — | — | .github/workflows/governance-gate.yml |
| **51** | constitution.md のバージョンは、governance/decisions/ で批准（status: Accepted）済みの最高 `target_version` を追い越してはならない（constitution.md 自身が「発効は governance/decisions/ での確定をもって」と明記する自己拘束。7章 変更管理） | SHOULD | 人間ゲート（暫定）＋機械強制（advisory 検出のみ。警告して exit 0。hard-fail 化の要否は未確定） | — | 整備中（外部レビュー指摘・2026-08-21。本 PR 時点で実際に乖離を検出する：constitution.md は v0.8.0 だが governance/decisions/ の批准最高版は GD-0004 の v0.3.0 にとどまり、0.4.0〜0.8.0（WU-01〜WU-03 が導入した selftest／diff-size／governance-metrics／constitution-sync／SAST の各原則）は未批准のまま機械強制されている。是正方法（governance/decisions/ へ確定記録を追加して批准するか、strictness を見直すか）は人間の判断のため、本チェックは hard-fail 化しない。AI が自己の提案した規範を自己で批准することはできない（MUST NOT）） | TBD-HUMAN | TBD-HUMAN | 人間が governance/decisions/gd-0005 等で 0.4.0〜0.8.0 を遡って批准するか、hard-fail 化の要否を決定した時点で機械強制のみへ移行する | verify:fast → scripts/checks/ratification-sync.sh（check_ratification.py） |
| **52** | 循環依存を導入してはならない（architecture-standards.md「1.」／architecture/boundaries.md「依存規則」。憲章「アーキテクチャの完全性」） | MUST NOT | 機械強制（休眠/活性化のスタック検出とゲート配線）＋人間ゲート（暫定）（実ツールによる依存方向検出ロジックは未配線） | — | 整備中（外部レビュー指摘・2026-08-22。休眠時 skip・活性化時のツール解決ロジック〔`$ARCH_BOUNDARY_CMD` または `scripts/dev/arch-boundary-tool.sh`〕は実装・動作確認済み（sast.sh と同一パターン。dormant / no-tool-warn / tool-pass / tool-fail の4状態を確認）。**実ツールによる依存方向検出そのものは未整備**——採用スタックにより適切なツール（import-linter / dependency-cruiser / ArchUnit / go-arch-lint 等）が異なるため未配線。「整備済み」と扱わない（憲章「8. ブートストラップ規定」）。従来はこの MUST NOT 自体が台帳に未登録だった（統治レイヤに比べアーキテクチャ層の機械検証投資が著しく手薄という指摘に対応）） | TBD-HUMAN | TBD-HUMAN | 採用組織が architecture/boundaries.md のレイヤ構成を実体化した上で、依存方向検査ツールを選定し `ARCH_BOUNDARY_CMD`（または `scripts/dev/arch-boundary-tool.sh`）として配線する | verify ジョブ → scripts/checks/arch-boundaries.sh ＋ architecture/boundaries.md「依存規則」 |
| **53** | Class A の PR は、変更を「間違いだった場合に安く戻せる」設計にしているか（フィーチャーフラグ／migration の down 定義／段階公開の有無）を PR 本文に記載しなければならない（development-process.md「7.」／architecture/principles.md「5. 可逆性・観測性を既定に」の実質化。WU-10 が導入したロールバック手順欄とは別の関心事） | MUST | 機械強制（PR 本文検査。ロールバック手順欄と同一技術：見出し以下の本文を取り出し、HTML コメントを除去し、残りの非空白を検査する） | — | 整備済み（外部レビュー指摘・2026-08-22。従来 playbooks/rollback.md の SHOULD 1行「コード変更を伴わずに機能を無効化できる手段が、可能な場合は用意されている」にとどまり、機械検証も PR テンプレートの必須欄も無かった。#47 と同一技術で「記載の有無」のみを機械検証する） | — | — | — | verify:pr（governance-gate.yml） → scripts/checks/pr_governance.sh ＋ .github/pull_request_template.md「可逆性」欄 |
| **54** | 可逆性欄**の内容**が可逆な設計として妥当であること（development-process.md「7.」／architecture/principles.md「5.」。#53 とは別） | MUST | 人間ゲート（不可避） | (b) | 整備済み（恒久的な人間ゲート。#53 の存在検証とは別。#48（ロールバック手順の内容の妥当性）と同型。本番反映に対する意思決定であり、暫定・ブートストラップではない） | — | — | — | PR レビュー（development-process.md「5.」承認者）＋ constitution.md「3. 基本原則」検証手段の選択 |
| **55** | 依存関係のライセンスは自組織の配布形態・契約と両立しなければならない。ライセンスの新規取り込み・上流でのライセンス変更は Class A として人間承認を要する（constitution.md「6.」承認マトリクス 理由区分 (a)(c)／constitution.md「依存関係」／development-process.md「1.」／standards/security-standards.md「6.1」） | MUST | 機械強制（休眠/活性化のマニフェスト検出とゲート配線）＋人間ゲート（暫定）（許可/禁止ライセンスの確定と実ポリシーが未配線） | — | 整備中（**2026-08-24 新設。外部レビュー指摘への対応**）。従来、憲章の承認マトリクスが理由区分 (c)（法令・契約・規制要求）として人間承認必須に置き、development-process.md「1.」が Class A に分類していたにもかかわらず、**本台帳に「ライセンス」の語が一度も出現せず**、機械検知の主体も存在しなかった（`deps.sh` は `--scanners vuln` のみ、`scripts/audit_deps.py` の照会先 4 系統にもライセンス照会は無い）。依存脆弱性が #2・#30 で二重に配線されているのと対照的に、規範だけがあって強制も開示も無い唯一の項目だった。本行の新設で「存在しないこと」をまず台帳に記録する。休眠時 skip・活性化時のツール解決ロジック〔`$LICENSE_SCAN_CMD` / `scripts/dev/license-tool.sh` / `$LICENSE_FAIL_SEVERITY`〕は実装・陰性テスト済み（#40・#52 と同一パターン）。**実ポリシー（許可/禁止ライセンスの一覧）は未整備**——受容可否は採用組織の法務・契約判断であり AI が発明してはならない（憲章「10.1.3 推測の禁止」）。既知の限界: クラス分類はパスベースのため `package.json` / `go.mod` 等の変更は機械的には Class C と判定され、ライセンス変更を含む依存更新が自動で Class A に上がるわけではない（人間ゲートで担保） | TBD-HUMAN | TBD-HUMAN | 採用組織が security-standards.md「6.1」の許可/禁止ライセンスを ADR で確定し、`LICENSE_SCAN_CMD`（または `scripts/dev/license-tool.sh` / `LICENSE_FAIL_SEVERITY`）として配線した時点で機械強制のみへ移行する | verify ジョブ → scripts/checks/deps.sh ＋ standards/security-standards.md「6.1」 |
| **56** | スタックごとにフォーマッタ／リンタを採用し CI で強制する。型チェックは可能な限り有効化する（standards/coding-standards.md「1. 整形・静的解析」） | SHOULD | 機械強制（休眠/活性化のスタック検出とゲート配線）＋人間ゲート（暫定）（実リンタ・実設定が未配線） | — | 整備中（**2026-08-24 新設。外部レビュー指摘への対応**）。従来、coding-standards.md「1.」が採用スタック側へ委譲する SHOULD を持つだけで、(1) lint 設定の雛形（`.eslintrc` / `ruff.toml` / `.golangci.yml` 等）を一切同梱せず、(2) `scripts/checks/build.sh` に lint の実行経路が無く（`npm run typecheck --if-present` は採用者が定義しなければ何も起きない）、(3) **この配線漏れが ADOPTION.md「ステップ 8」の未配線ゲート一覧にも本台帳にも登録されていなかった**——テンプレートが誠実に開示している未配線リストの唯一の穴だった。UI レイヤ（#23〜#28 のデザイントークン強制）にのみ一貫性の機械強制が存在し、バックエンド・アプリケーションコードには同等の投資が無いという非対称も同じ原因による。休眠時 skip・活性化時のツール解決ロジック〔`$LINT_CMD` または `scripts/dev/lint-tool.sh`〕は実装・陰性テスト済み（#40・#52 と同一パターン）。**実リンタ・実設定は未整備**——採用スタックにより適切なツールと規則が異なるため（統治文書に特定製品名を書かない方針）。なお本行は「命名規則・エラー処理の一貫性」そのものを機械検証するものではなく、その検査を行う入口を配線するに過ぎない | TBD-HUMAN | TBD-HUMAN | 採用組織がスタックに応じたフォーマッタ／リンタ／型チェッカを選定し、`LINT_CMD`（または `scripts/dev/lint-tool.sh`）として配線した時点で機械強制のみへ移行する | verify ジョブ → scripts/checks/build.sh ＋ standards/coding-standards.md「1.」 |
| **57** | GitHub 上のブランチ保護・CODEOWNERS・必須ステータスチェック等の実設定は、設定完了後も継続的にポリシーと突合されなければならない（設定ドリフトの検出。constitution.md「6. 権限・統治への変更」／「8.」） | MUST | 人間ゲート（暫定）（継続的ポリシー監視ツールが未配線） | — | 未整備（**2026-08-24 新設**。[GP-0012](proposals/gp-0012-external-framework-alignment.md) の外部フレームワーク突合で発見）。#5 / #12 / #19 / #22 はいずれも**一時点の設定確認**にとどまり、設定後にブランチ保護が外された・必須チェックが解除された等の乖離を継続検出しない。#22 が既に開示する「CI の GITHUB_TOKEN では管理者読み取り権限を付与できない」制約と同根の構造的な穴であり、赤くならないため最も気づきにくい（fail-open）。#40・#52・#55・#56 の「休眠/活性化・ツール未配線」とは別パターン（設定は完了しているが継続監視が無い） | TBD-HUMAN | TBD-HUMAN | ADR で継続的ポリシー監視ツールを選定し配線する（能力要件: GitHub App またはスケジュール実行でリポジトリ設定を定期読み取りし、期待ポリシーとの乖離を検出・通知すること。製品名は本行に固定しない〔standards/security-standards.md「8.」と同一方針〕） | 未実装（本行の新設時点） |

> 上表は代表的な規範の割当である。**網羅性は定期見直しで確認し**、追加・変更があれば本表を更新（または再生成）する。「未整備」項目（#13, #15b, #36〜#39, #42 等）はリポジトリ/組織設定の整備を優先する（憲章8章ブートストラップ規定）。#3〜#33 の再分類の結果、既存の「人間」を要する行（#1〜#35）はいずれも (a)/(b)/(c) のいずれかで恒久的に正当化される人間ゲート（不可避）と判定され、人間ゲート（暫定）に該当する行は0件だった（詳細は governance/proposals/gp-0003-enforcement-ledger-schema.md「5. 未解決事項」）。**#36〜#39（GP-0006／WU-05）が本台帳における最初の人間ゲート（暫定）行**、**#40（GP-0005／WU-04）が2組目**（SAST の実ツール検出部分）、続けて**#41・#42（GP-0008／WU-07）が3組目**として加わった（development-process.md「6.」の SHOULD→MUST 引き上げにともなう新規義務のうち、自己申告依存部分と Regulated 限定部分）。#43 は人間ゲート（不可避）(b) として登録した。#44〜#45（GP-0004／WU-03）は統治健全性メトリクス（機械強制率の非減少制約とその waiver 連携）であり、いずれも整備済み・機械強制のみの行のため人間ゲート（暫定）には該当しない。**#46（GP-0009／WU-08）は、当初は上限値が未確定（`TBD-HUMAN`）のまま計測・分類ロジックのみを実装した人間ゲート（暫定）だったが、2026-08-22 に人間が上限値（Class A=200行／Class B=400行）を確定し機械強制へ移行した（人間ゲート（暫定）からの卒業第1号）**。人間ゲート（暫定）行は現時点で **#36〜#39・#40・#41・#42・#51・#52 の9件**である。**#47・#48（GP-0011／WU-10）はロールバック手順**であり、#47（記載の有無）は機械強制、#48（内容の妥当性）は人間ゲート（不可避）(b) 責任の引受として登録した——いずれも暫定・ブートストラップ扱いではなく、恒久的な割当である。**#49（GP-0010／WU-09）** は簡潔ビュー（`.specify/memory/constitution.md`）のバージョン追従検証であり、#44・#45 と同様に整備済み・機械強制のみの行のため人間ゲート（暫定）には該当しない。**#50** は PR-context 統治ゲートの実行元を PR 自身が改変できない base ref に固定する構造的強制であり、恒久的な割当である。**#51** は constitution.md の批准状態と実際の強制状態の乖離を検出する advisory ゲートであり、外部レビューで発見された「未発効の規範を機械強制している」という実際の乖離（v0.8.0 と GD-0004・v0.3.0 の差）を伴う人間ゲート（暫定）の9組目として新設した。**#52** はアーキテクチャ境界（循環依存）の休眠/活性化ゲートであり、SAST（#40）と同型の実ツール未配線による人間ゲート（暫定）の10組目である。**#53・#54（可逆性欄）** はロールバック手順（#47・#48）と同型に、#53（記載の有無）を機械強制、#54（内容の妥当性）を人間ゲート（不可避）(b) として登録した——いずれも恒久的な割当である。テスト品質（#36〜#39）・SAST 実ツール検出（#40）・AI 生成識別トレーラ（#42）・アーキテクチャ境界の実ツール検出（#52）はいずれもこのリポジトリにコードスタックが存在しない、実ツール未配線、または Regulated プロファイル未採用のため実効的な機械検証を実装できておらず、失効期限・担当は `TBD-HUMAN`（未確定）のまま登録した。差分規模上限（#46）は2026-08-22 に上限値が確定し、この一覧からは外れた（機械強制へ移行済み）。PR #26（WU-04）・PR #27（WU-07）・PR #28（WU-08）・PR #29（WU-03）・本 PR（WU-09）はいずれも当初 #36／#40／#41／#34 を名乗っていたが、base への並行マージ順に応じて順次採番し直した（人間による行番号調整の実例）。**#47・#48 も同様に、起案時点（governance/proposals/gp-0011-incident-rollback-playbooks.md）では現行 6 列スキーマのまま #34・#35 を名乗っていたが、`governance/gp-0003-enforcement-ledger-schema`（WU-02）が先に 10 列スキーマへ拡張し、さらに WU-08 が #46 を確定済みであったため、本ブランチへのマージ時に #47・#48 へ改番した。**詳細は governance/proposals/gp-0005-sast-gate.md・gp-0006-test-quality-gates.md・gp-0008-auditability-and-escape-analysis.md・gp-0004-governance-health-metrics.md・gp-0009-human-gate-diff-size-limit.md「7. 未解決事項」（特に OUT-03）・gp-0011-incident-rollback-playbooks.md・gp-0010-doc-churn-reduction.md それぞれを参照。

---

## 改正履歴

### [0.15.0] - 2026-08-24（Proposed）

正本記録: 既存プロジェクトへの導入（brownfield）経路の整備。手順書は後続 PR で `ADOPTION-EXISTING.md` として追加する（本エントリ時点では未追加のためリンクしない）

**Changed（台帳の行・強制手段・整備状況の変更なし。既存ゲートの適用範囲の明確化）**

* `scripts/checks/adoption.sh`（#22）に、ADOPTION.md「ステップ9」（テンプレート由来の統治履歴・サンプルの相続）と
  保護対象ブランチ名の不一致の検出を追加した。いずれも従来まったく機械点検が無く文書に書いてあるだけだった。
  既定ブランチが `main` でない既存リポジトリでは CI が一度も起動せず**沈黙して**強制が働かない（fail-open）ため、
  赤くならないぶん最も気づきにくく、検出価値が高い。
* `.github/workflows/verify.yml` の `pull_request` トリガに `types: [opened, synchronize, reopened, edited]` を
  明示した（#19 関連）。既定の activity types は `edited` を含まないため、ベースブランチの付け替え
  （stacked PR で上流マージ後に GitHub が自動で行う）では `verify` が**一度も起動しなかった**。
  `governance-gate.yml` は `edited` を列挙しており起動するため、「governance-gate だけが緑」の PR が生まれる。
  必須チェックの登録漏れ（#22 の休眠）と重なると `verify` を通さずマージできる（fail-open）。
  差分規模の上限（#46）が PR 分割＝stacked PR を促す以上、本テンプレートはこの経路を常用させるため、
  「整備済みに見えて機能していない」状態だった（#50 と同種の構造的欠陥）。本 PR スタックの #38 で実地に発生した。
* `scripts/checks/build.sh`（#15b 関連）に `BUILD_CMD` / `scripts/dev/build-tool.sh` による入口の差し替えを、
  `scripts/checks/secrets.sh`（#1 関連）に gitleaks の `--baseline-path` 連携を追加した。いずれも既定動作は
  変更せず、**終了コードはそのまま伝播**するため強制は弱まらない（緩和ではない）。baseline 適用中は件数とともに
  警告を出し続ける（黙って緑にしない。憲章「8. ブートストラップ規定」）。

**増分の根拠**: 既存の義務の**撤廃・反転はない**。台帳行の追加も無く（行数・機械強制率は不変）、既存ゲートの
適用範囲の明確化にとどまるため、憲章「7. 変更管理」バージョニング方針の MINOR に該当する。

### [0.14.0] - 2026-08-24（Proposed）

正本記録: 既存プロジェクトへの導入（brownfield）経路の整備。手順書は後続 PR で `ADOPTION-EXISTING.md` として追加する（本エントリ時点では未追加のためリンクしない）

**Fixed（統治文書と実装の乖離。#46 の記述を更新）**

* `scripts/check_diff_size.py` が **waiver を一切読んでいなかった**。development-process.md「5.」・本台帳 #46・
  当該スクリプト自身のエラーメッセージはいずれも「上限を超える場合は変更を分割するか、governance/waivers/ に
  登録された時限的な適用除外を要する」と案内していたが、その適用除外は実装上存在せず、Class A の 200行超は
  分割以外に合法的な通過手段が無かった。**統治文書が案内する手段が実際には機能しない状態**（憲章「8. ブートストラップ規定」が
  禁じる「整備済みに見えて機能していない」状態）であり、#45 で既に確立していた gate-linked waiver 規約を適用して是正した。
  この乖離は既存リポジトリへの導入で最初に顕在化する（統治文書一式の導入 PR は不可分な数千行の Class A 変更であり、
  逃げ道が無ければ採用者は上限引き上げかゲート撤去に流れる＝憲章「6.」MUST NOT を誘発する設計上の欠陥だった）。
* 照合ロジックを `scripts/waivers.py` へ集約した（`check_governance_metrics.py` と共有。規約の解釈が
  2箇所へ分岐する前に共通化する。SSoT）。対象ゲート識別子は Class ごとに分離し（`diff-size.class-a` /
  `diff-size.class-b`）、Class B 向けの waiver が Class A の超過を通過させないようにした。
* `scripts/checks/selftest.sh` に陰性テスト3件（失効 waiver／`expires: TBD-HUMAN`／Class 違いの waiver では
  通過しない）と陽性確認1件（有効な waiver では通過する＝案内された逃げ道が実在する）を追加した。

**増分の根拠**: 既存の義務の**撤廃・反転はない**。新規行の追加もない（台帳の行数・機械強制率は不変）。
実装が欠けていた既存 MUST NOT（#46）の適用除外経路を、既に確立済みの規約（#45）に沿って実装した修正であり、
憲章「7. 変更管理」バージョニング方針の MINOR（後方互換な追加・実質的拡張）に該当する。

### [0.13.0] - 2026-08-22（Proposed）

正本記録: 外部レビュー（2026-08-22付）「AI統制能力」と「レビューが安く済むシステムを設計する能力」の指摘への対応

**Added**

* **#52 を新設**: 循環依存の禁止（architecture-standards.md「1.」）を、SAST（#40）と同一の休眠/活性化パターンで機械検証する `scripts/checks/arch-boundaries.sh` を新設した。従来この MUST NOT 自体が台帳に未登録だった。統治・規範レイヤ（本台帳含め約5,000行）に対しアーキテクチャ層（architecture/** ＋ standards/architecture-standards.md）が171行しかなく、「読まなくていい範囲を作る」局所性への投資が「誰が承認するかを決める」統治への投資の約1/29という指摘（レビューコストを下げる3方向「量を減らす／機械に移す／代償を下げる」のうち「機械に移す」が最も手薄）を受け、既存の休眠/活性化ゲートの型をそのまま流用して配線した。あわせて architecture/boundaries.md のレイヤ構成（従来「（例: presentation → application → domain ← infrastructure）」という置換前提が伝わらないプレースホルダのまま放置されていた）を、置換前提が明確な記入例へ拡充した。
* **#53・#54 を新設**: development-process.md「7.」に、Class A PR の可逆性欄（フィーチャーフラグ／migration の down 定義／段階公開の有無）の記載要件を追加した。#47・#48（ロールバック手順。事後の復旧手順）とは別の関心事で、こちらは変更そのものの設計を対象とする。#53（記載の有無）を機械強制、#54（内容の妥当性）を人間ゲート（不可避）(b) として、ロールバック手順と同一の分割で登録した。従来 playbooks/rollback.md の SHOULD 1行にとどまり、machine検証も PR テンプレートの必須欄も無かった（可逆性がレビューコストを下げる最強の手段のひとつであるにもかかわらず、投資配分が目的関数と合っていないという指摘への対応）。

**Changed**

* **#46 を機械強制へ移行**: 差分規模の上限（Class A/B の変更行数）について、人間が上限値（Class A=200行／Class B=400行）を確定した（2026-08-22。複数の実証研究に基づく値を採用）。`scripts/checks/diff-size.sh` は配線変更なしで advisory から hard-fail ゲートへ移行した（設計どおり。強制手段を「人間ゲート（暫定）＋機械強制」から純粋な「機械強制」へ、失効期限・担当・移行先ゲートを `TBD-HUMAN` から `—` へ更新）。人間ゲート（暫定）から機械強制への移行の最初の実例である。

**増分の根拠**: 既存の義務の撤廃・反転はない。新規行3件（#52・#53・#54）の追加と、既存 MUST NOT（#46）の未確定パラメータの確定（義務そのものは変えず、advisory から hard-fail への移行のみ）であり、憲章「7. 変更管理」バージョニング方針の MINOR 例示（機械検証ルールの追加）に該当する。

### [0.12.0] - 2026-08-21（Proposed）

正本記録: 外部レビュー（2026-08-21付、PR未起票時点の指摘）への対応

**Fixed（既存ゲートのバグ。#47 の記述を更新）**

* `scripts/checks/pr_governance.sh` のロールバック手順チェック（#47）: HTML コメント除去が行単位の `sed` で、`.github/pull_request_template.md` 実物の3行コメントを除去できず、未編集テンプレートが「実体あり」と誤判定されていた（fail-open）。再現確認の上、Python `re.DOTALL` による複数行対応へ修正。
* 同チェックの発火条件を `class:A` ラベル単独から、統治パス変更（`$gov`）との OR 条件へ拡張（ラベル未付与による fail-open を是正。permission-impact 側の fail-close との非対称を解消）。
* `scripts/checks/selftest.sh` の該当フィクスチャを、合成の1行コメントから `.github/pull_request_template.md` 実物の抽出へ変更（合成フィクスチャが実物の複数行構造から乖離していたために上記バグを見逃していた。selftest 導入時の教訓「通ることは確認できても落ちることは確認していなかった」がここでも再発していた）。

**Added**

* **#50 を新設**: PR-context の統治ゲート（ADR参照／permission-impact／ai-generated／ロールバック手順）は、検査対象の PR 自身が改変できないコードで実行されなければならない（自己参照の禁止）。是正前は `.github/workflows/verify.yml` が `pull_request` トリガで PR head を checkout し、その改変版のスクリプトで自分自身を検査していた（`pr_governance.sh` の先頭に `exit 0` を足すだけで permission-impact 要求ごと無効化できることを再現確認した）。`.github/workflows/governance-gate.yml`（`pull_request_target`。base ref のみ checkout、PR head は fetch のみで実行しない）へ分離し、構造的強制（迂回不可能な設計）として登録した。`verify.yml` 側の PR-triggered `task verify:pr` は撤去した（重複・権威の曖昧化を避けるため）。
* **#51 を新設**: constitution.md のバージョンが governance/decisions/ の批准（status: Accepted の最高 `target_version`）を追い越していないかを検証する advisory ゲート（`scripts/check_ratification.py`）。本 PR 時点の実測で実際に乖離を検出する（constitution.md v0.8.0 ＞ GD-0004 の v0.3.0）。「未発効の規範を機械強制している」状態を可視化する。是正（遡って批准するか、strictness を見直すか）は人間の判断であり、AI は自己の提案した規範を自己で批准できない（MUST NOT）ため hard-fail 化はしない。人間ゲート（暫定）として登録（失効期限・担当は `TBD-HUMAN`）。

**増分の根拠**: 既存の義務の撤廃・反転はない。既存ゲート2件のバグ修正（fail-open の是正。義務を弱めるのではなく本来の強度へ戻す）と、新規行2件（#50・#51）の追加であり、憲章「7. 変更管理」バージョニング方針の MINOR 例示（機械検証ルールの追加）に該当する。

### [0.11.0] - 2026-08-20（Proposed）

正本記録: governance/proposals/gp-0010-doc-churn-reduction.md（WU-09）

**Added**

* #49 を新設: 簡潔ビュー（`.specify/memory/constitution.md`）のバージョン欄が正本（constitution.md）に追従しているかの機械検証（GP-0010「WU09-01」）。本行の起票時点で、正本は `0.4.0`（GP-0002／WU-01）へ改正済みだったが簡潔ビューは `0.3.0` のまま乖離しており、これが実際の検出対象になった（生きた不整合。GP-0002「5. 未解決事項」Q-02 も参照）。`scripts/sync_constitution_version.py` によりバージョン番号のみを同期し（他の手書き内容は不変）、`scripts/checks/constitution-sync.sh` を `task verify:fast` に接続した。整備範囲は「バージョン番号の一致」のみであり、簡潔ビューの内容全体（原則本文・Last amended 等）の同期は未整備のまま（整備済みであるかのように扱わない。憲章「8. ブートストラップ規定」）。

**行番号について**: 本エントリはもともと #34 として起案したが（本 WU の起案時点の base は #33 までしか含んでいなかった）、並行して進んでいた他の作業単位（WU-02〜WU-10）が base へ先にマージされたことで base が #48 まで進んでいたため、`origin/governance/gp-0003-enforcement-ledger-schema` を本ブランチへマージした時点で #49 へ繰り下げた（当初の2段階目マージでは #47 と見込んでいたが、その後 WU-10 が #47・#48 を確定させたため、3段階目のマージでさらに #49 へ繰り下げた）。あわせて、WU-02（[0.5.0] - 2026-08-19）が導入した新スキーマ（理由区分／失効期限／担当／移行先ゲート列）に合わせて行を記述し直した。#49 は完全な機械強制のみで人間ゲートを伴わないため、理由区分・失効期限・担当・移行先ゲートはいずれも「—」とした。

**増分の根拠**: 既存の義務の撤廃・反転はない。新規行1件（#49）の追加であり、憲章「7. 変更管理」バージョニング方針の MINOR 例示（機械検証ルールの追加）に該当する。台帳自身の改正履歴の先例（新規行追加＝MINOR）にも整合する。0.10.0 は WU-10（GP-0011）が既に確定した番号であるため、本エントリはその次の 0.11.0 とした。

### [0.10.0] - 2026-08-20（Proposed）

正本記録: governance/proposals/gp-0011-incident-rollback-playbooks.md（WU-10）

**Added**

* #47 を新設: Class A の PR は本文にロールバック手順欄（非プレースホルダの実体）を含まなければならない（development-process.md「7.」）。記載の**有無**を `scripts/checks/pr_governance.sh` が機械検証する（ADR不要理由の抽出と同一技術。`.github/pull_request_template.md`「ロールバック手順」欄）。
* #48 を新設: ロールバック手順**の内容**が復旧手段として妥当であること。記載内容の意味的妥当性は原理的に機械検証できないため、恒久的な人間ゲート（不可避）(b) 責任の引受として登録した（暫定・ブートストラップ扱いにはしない）。
* `scripts/checks/selftest.sh` に、#47 の陰性テスト（プレースホルダのみの PR_BODY を注入し、ゲートが検出することを確認）を1件追加した。
* `playbooks/rollback.md` を新設し、ロールバックの前提・判断基準・手順・確認・事後（`playbooks/incident-response.md` への相互参照。内容の重複なし）を定義した。着手前の調査で `playbooks/incident-response.md` は既に妥当な雛形として存在していたことを確認しており、本 WU はそれを書き直さず、真に欠落していた2点（`playbooks/rollback.md` とロールバック手順欄）のみを埋めた（詳細は governance/proposals/gp-0011-incident-rollback-playbooks.md「0. 前提の訂正」）。

**行番号について**: 本 WU の起案時点（governance/proposals/gp-0011-incident-rollback-playbooks.md）では、まだ現行 6 列スキーマ（強制手段／整備状況／検証箇所のみ）だった base 上で #34・#35 を名乗っていた。本ブランチへ `governance/gp-0003-enforcement-ledger-schema`（WU-02 以降。10 列スキーマへの拡張済み base）をマージした結果、base の最終行が #46（WU-08／GP-0009 が確定済み）であることが判明したため、マージ時に #47・#48 へ改番し、表記を新スキーマ（理由区分／失効期限／担当／移行先ゲート列）へ合わせて移行した。#47 は理由区分列を「—」（機械強制のみ・人間ゲートを伴わない）、#48 は「(b)」（責任の引受）とした。

**増分の根拠**: 既存の義務の撤廃・反転はない。新規行2件（#47・#48）の追加と、それを裏づける新規機械検証ロジック（`pr_governance.sh`）・陰性テスト・Playbook 文書の追加であり、憲章「7. 変更管理」バージョニング方針の MINOR 例示（機械検証ルールの追加）に該当する（#44・#45（[0.8.0]）と同型の判断）。0.9.0 は WU-08（GP-0009）が既に確定した番号であるため、本エントリはその次の 0.10.0 とした。

### [0.9.0] - 2026-08-20（Proposed）

正本記録: governance/proposals/gp-0009-human-gate-diff-size-limit.md（WU-08）

**Added**

* **#46 を新設**: 「Class A/B の PR は変更行数の上限を超えてはならない（MUST NOT）」（development-process.md「5.」新設・WU-08）を人間ゲート（暫定）として登録。失効期限・担当は `TBD-HUMAN`（上限値の具体的な数値を AI が発明することを避けるためのプレースホルダ。development-process.md「1.」検証手段の選択の趣旨）。移行先ゲートは `scripts/checks/diff-size.sh`（`scripts/check_diff_size.py`）に閾値環境変数を設定することで hard-fail 化する具体的な移行手段を明記した。
* `scripts/check_diff_size.py` ＋ `scripts/checks/diff-size.sh` を新設し、`verify:pr` に配線（`pr_governance.sh` と同じ `BASE_SHA`/`HEAD_SHA` を再利用。新規 env var は追加していない）。閾値が未設定の現状は advisory 出力のみで hard-fail しない。
* `scripts/checks/selftest.sh` に、閾値を一時的に設定した場合の hard-fail 検出を確認する陰性テストを1件追加。

**注記（行番号について）**: 本 WU-08 は当初 #40、続いて #41、#44 を採番していたが、base への並行マージ順（WU-04／SAST が #40、WU-07／AI生成識別ほかが #41〜#43、WU-03／統治健全性メトリクスが #44〜#45 を確定）に応じて、本コンフリクト解消時に #46 へ改番した。あわせて、台帳のバージョンヘッダが WU-03 のマージ時に更新漏れ（changelog は [0.8.0] を記載済みだが `* Version:` 行が 0.7.0 のまま）だったことに気づいたため、本コンフリクト解消時に 0.9.0 へ是正した。

### [0.8.0] - 2026-08-20（Proposed）

正本記録: governance/proposals/gp-0004-governance-health-metrics.md（WU-03）

**Added**

* #44 を新設: 機械強制率（(構造的強制＋機械強制) の MUST/MUST NOT 件数 ÷ 全件数）の非減少制約。低下する PR は `scripts/checks/governance-metrics.sh` が `task verify:fast` で失敗させる。基準値は `metrics/governance-health-snapshot.json`（本 WU で台帳の現状から実測して初期シード値を記録）。
* #45 を新設: #44 の低下を正当化する経路として `governance/waivers/` の waiver 連携を実装。waiver は `target_check` 一致・`status: Active`・実日付かつ未経過の `expires` をすべて満たす場合のみ有効とし、無条件のバイパスを設けない（`governance/waivers/README.md`「機械可読な紐付け」を新設）。
* `scripts/check_governance_metrics.py` は本台帳のパーサ（`scripts/check_enforcement_ledger.py` の `load_rows` / `DATE_RE` / `GATE_BOOTSTRAP`）を再利用し、正規表現を分岐させていない。

**行番号について**: 本 WU の起案時点の base（`governance/gp-0003-enforcement-ledger-schema`）は #36〜#39（GP-0006／WU-05）を既に含んでいたため、本 WU の新規行は当初案の #36・#37 から #40・#41 へ、さらに base への並行マージ順（WU-04／SAST が #40 を確定、続けて WU-07／AI生成識別ほかが #41〜#43 を確定）に応じて最終的に #44・#45 へ改番した。

**増分の根拠**: 既存の義務の撤廃・反転はない。新規行2件（#44・#45）の追加と、それを裏づける新規機械検証スクリプトの追加であり、憲章「7. 変更管理」バージョニング方針の MINOR 例示（機械検証ルールの追加）に該当する。

### [0.7.0] - 2026-08-20（Proposed）

正本記録: governance/proposals/gp-0008-auditability-and-escape-analysis.md（WU-07）

**Added**

* #40 を新設: AI 生成識別（development-process.md「6.」SHOULD→MUST 引き上げ）。既知の AI エージェント・マシンアカウントが PR 作成者の場合の機械強制（`scripts/checks/pr_governance.sh` 拡張。実装済みだが実在アカウント未発行のため未行使）と、人間アカウント作成者の場合の人間ゲート（暫定）を単一行に併記した。
* #41 を新設: AI 識別トレーラのモデル識別子・バージョン記載（Regulated プロファイル限定 MUST／他 SHOULD）。人間ゲート（暫定）として登録し、機械化は Regulated プロファイル採用時の課題として先送りした。
* #42 を新設: `governance/escape-analysis/` の新設にともなう、エスケープ欠陥の3分類記録義務と憲章「7.」定期見直しへの接続。人間ゲート（不可避）(b) として登録した。
* 本 WU により、**人間ゲート（暫定）行が新たに2件（#40・#41）加わった**（既存の #36〜#39 は WU-05／GP-0006 が新設。合計6件）。当初 WU-02（[0.5.0]）時点では暫定該当は0件だったが、以降の2つの WU（WU-05・WU-07）がそれぞれ暫定該当を持つ新規 MUST を追加したことで、「機械化待ちの一時措置」が実例として蓄積し始めている。

**注記（行番号の再採番）**: 本エントリの行番号はもともと #36〜#38 として起案したが、`origin/governance/gp-0003-enforcement-ledger-schema` を本ブランチへマージした時点で、WU-05（[GP-0006](proposals/gp-0006-test-quality-gates.md)）が先に #36〜#39 を採番済みであることが判明したため、マージ後に #40〜#42 へ繰り下げた。並行起票中だった WU-03（governance-health-metrics）は #44〜#45 として、WU-08（human-gate-diff-size-limit）は #46 として、いずれも本エントリのさらに後に採番し直された（上記 [0.9.0]・[0.8.0] を参照）。

### [0.6.0] - 2026-08-20（Proposed）

正本記録: governance/proposals/gp-0006-test-quality-gates.md（WU-05）＋ governance/proposals/gp-0005-sast-gate.md（WU-04）

**Added（GP-0006／WU-05）**

* #36〜#39 を新設: constitution.md「8.」に追加された新規テスト品質 MUST（mutation score／spec由来テスト／認可否定パステスト。standards/testing-standards.md「4.」）と、その網羅性検証の設計案（ルートインベントリ・testing-standards.md「4.5」）を、いずれも未整備の人間ゲート（暫定）として登録した。失効期限・担当は `TBD-HUMAN`（数値・人名の発明を避けるためのプレースホルダ）。
* 本 WU-05 が新設する3つの MUST は、このリポジトリにコードスタックが存在しない（`scripts/checks/build.sh` が「no code stack detected」を報告する）ため、実効的な機械検証を今回は実装していない。整備済みと僭称しない（憲章「8. ブートストラップ規定」）。

**Added（GP-0005／WU-04）**

* #40 を新設: 第一者コードの静的解析（SAST）に合格すること（constitution.md「8.」新設 MUST）。休眠/活性化のスタック検出とゲート配線（`scripts/checks/sast.sh`）は機械強制・整備済みだが、実ツールによる脆弱性検出そのものは `SAST_CMD` 未配線のため未整備であり、**人間ゲート（暫定）として失効期限・担当・移行先ゲートをすべて `TBD-HUMAN` で登録**する。移行先ゲートには、ADR による SAST ツール選定・`SAST_CMD` 配線・重大度カットオフ確定という具体的な技術的道筋を記載した。
* `scripts/checks/selftest.sh` に、sast.sh の休眠/活性化切り替えと SAST_CMD 配線時の合否伝播を検証するケースを追加（WU04-02 の活性化検出が実際に動作することの陰性/陽性確認）。

**Changed**

* 「人間ゲート（暫定）行は現時点で0件」としていた表下の注記を更新し、#36〜#40 の5件が該当する旨を明記した。#36〜#39 は本台帳における最初の人間ゲート（暫定）行（GP-0003／WU-02 の再分類では該当0件だった）。

**行番号の衝突とその解消（コンフリクト解消の実例）**: WU-04（PR #26）と WU-05（PR #24）はいずれも同じベース（`governance/gp-0003-enforcement-ledger-schema`）の最終行（#35）から独立に #36 を採番した。WU-05 が先に base へマージされたため、WU-04 の #36 は本コンフリクト解消時に #40 へ採番し直した。#36〜#39 も、同じ base から並行して起案されている他の作業単位（WU-03・07〜09 等）と同じ番号帯を採番している可能性があり、マージ時に人間が行番号の重複を解消する必要がある（governance/proposals/gp-0006-test-quality-gates.md「未解決事項」参照）。**WU-03（governance/proposals/gp-0004-governance-health-metrics.md）は当初 #40・#41 として改番したが、WU-04 の #40 確定後さらに #41・#42 へ改番した。詳細は上記 [0.7.0] を参照。**

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
* **#34〜#35 を新設**（2026-08-20 追記。[gp-0011](proposals/gp-0011-incident-rollback-playbooks.md)）: development-process.md「7.」の空白（ロールバック/インシデント手順の詳細は整備までは人間判断）を埋めるにあたり新設した2つの MUST を登録した。#34（Class A PR のロールバック手順欄の**記載の有無**）は機械強制として整備済み（`scripts/checks/pr_governance.sh` を拡張。ADR不要理由の抽出と同一技術）。#35（記載**内容の妥当性**）は #31〜#33 とは異なり、整備待ちの未整備行ではなく、GP-0002 の分類 (b) 責任の引受に該当する**恒久的な**人間ゲート（不可避）として登録した（自動化への移行対象ではない）。#29 のケース数（selftest.sh）を 12→13 に更新（#34 の陰性テストを追加）。

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
