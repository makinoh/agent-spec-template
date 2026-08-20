# 強制台帳（Enforcement Ledger）

* Version: 0.7.0（Proposed / ドラフト）
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
| **36** | 変更ファイルの mutation score が最低基準を満たす（testing-standards.md「4.1」「4.2」／8章） | MUST | 人間ゲート（暫定） | — | 未整備（本リポジトリはコードスタックを持たず `scripts/checks/build.sh` が no code stack detected を報告する。mutation testing ツールの選定・CI 配線は採用スタックで実施する。整備までは人間レビューで担保し、整備済みと扱わない） | TBD-HUMAN | TBD-HUMAN | 採用スタックの mutation testing ツールを CI に配線し、変更ファイルの mutation score が「4.2」の閾値未満の場合に fail させる仕組み（具体的なツールは未選定） | standards/testing-standards.md「4.1」「4.2」（現状は人間レビュー。機械検証は未実装） |
| **37** | 受入基準に対応するテストは spec.md から導出する。実装を読んで書いたテストを充足根拠としない（testing-standards.md「4.3」／8章） | MUST / MUST NOT | 人間ゲート（暫定） | — | 未整備（テストが spec 由来か実装追従かを機械的に判別する手段が現状ない。コードレビューでの FR-ID/US-ID 対応確認により人間レビューで暫定担保） | TBD-HUMAN | TBD-HUMAN | テストコードへの FR-ID/US-ID トレーサビリティタグの必須化と、spec.md の要求IDとテストの対応表を機械検証する仕組み（設計は本 WU の範囲外） | standards/testing-standards.md「4.3」（現状は人間レビュー） |
| **38** | 認可を要するエンドポイントは権限を持たない主体からのアクセス拒否を検証するテストを備える（testing-standards.md「4.4」／8章） | MUST | 人間ゲート（暫定） | — | 未整備（個別テストの存在確認は人間レビュー。全ルートを漏れなく検証する仕組みは #39 を参照） | TBD-HUMAN | TBD-HUMAN | #39 のルートインベントリ設計の実装により、認可要求ルートに対応する否定パステストの存在を CI で検証する仕組み | standards/testing-standards.md「4.4」（現状は人間レビュー） |
| **39** | 認可否定パステストの網羅性検証（ルート一覧を生成物として持ち、生成処理の再実行で差分検証する設計。testing-standards.md「4.5」） | SHOULD（設計提案の実装可否） | 人間ゲート（暫定） | — | 未整備（設計案の提示のみ。実装は WU-05 の範囲外） | TBD-HUMAN | TBD-HUMAN | ルーティング定義（採用フレームワークのルート定義／OpenAPI 等）からルート一覧を生成物として出力し認可要求フラグを付与、対応する否定パステストの存在を機械検証。生成処理を CI で再実行し差分ゼロを確認する（SSoT パターン。憲章「3. 基本原則」） | standards/testing-standards.md「4.5」（設計案。実装未着手） |
| **40** | 第一者コードの静的解析（SAST）に合格すること（8章。WU-04で新設） | MUST | 機械強制（休眠/活性化のスタック検出とゲート配線）＋人間ゲート（暫定）（実ツールによる脆弱性検出ロジックは未配線） | — | 整備中（休眠時 skip・活性化時のツール解決ロジック〔`$SAST_CMD` または `scripts/dev/sast-tool.sh`〕は実装・動作確認済み〔dormant / no-tool-warn / tool-pass / tool-fail の4状態を確認〕。**実ツールによる脆弱性検出そのものは未整備**——SAST_CMD 未設定のため、現状は活性化時も「未配線」警告を出して exit 0 する。「整備済み」と扱わない（憲章「8. ブートストラップ規定」）） | TBD-HUMAN | TBD-HUMAN | ADR で SAST ツールを選定し `SAST_CMD`（または `scripts/dev/sast-tool.sh`）として配線。CI に実ツールを導入し、standards/security-standards.md「8.」の重大度カットオフを確定した上で hard-fail 化する | verify ジョブ → scripts/checks/sast.sh ＋ standards/security-standards.md「8.」「8.1」 |
| **41** | AI 生成の識別: PR 作成者が既知の AI エージェント・マシンアカウントの場合は `ai-generated` ラベルを機械要求。人間アカウント作成者の場合は自己申告に依存する（development-process.md「6.」/8章。WU07-01） | MUST | 機械強制（PR_AUTHOR 照合。既知マシンアカウントの場合。**未行使**）＋人間ゲート（暫定）（人間アカウント作成者の自己申告に依存する場合） | — | 整備中（機械強制メカニズムは実装済み・自己診断済み（`scripts/checks/selftest.sh`）だが、本テンプレートには実在の専用マシンアカウントが未発行のため実行機会がない＝未行使。#13 参照。人間アカウント作成者の場合は自己申告以外に機械検証できる手がかりがない） | TBD-HUMAN | TBD-HUMAN | #13（マシンアカウント発行）の解消後、AI 起案コミットが実際にマシンアカウント経由となり、本行の人間ゲート（暫定）部分を機械強制へ統合する | verify:pr → scripts/checks/pr_governance.sh ＋ development-process.md「6.」 |
| **42** | AI 識別トレーラ（`Assisted-by:` 等）にモデル識別子・バージョンを含める（Regulated プロファイル限定 MUST／他プロファイル SHOULD。development-process.md「6.」/8章。WU07-02） | MUST（Regulated 限定）／SHOULD（Lite・Standard） | 人間ゲート（暫定） | — | 未整備（トレーラ内容の正規表現検証は本 WU では実装しない。本リポジトリは Lite プロファイル採用（[GD-0001](decisions/gd-0001-adoption-profile-lite.md)）のため現時点では適用対象外＝休眠。記載内容の**真正性**（自己申告の正確さ）自体は原理的に機械検証できない意味的判断であり、機械化できるのは「トレーラに識別子・バージョンらしき文字列が存在するか」という形式検査までにとどまる） | TBD-HUMAN | TBD-HUMAN | Regulated プロファイル採用時に、コミットトレーラ内のモデル識別子・バージョン記載の**形式**を正規表現等で機械検証するスクリプトを実装（内容の真正性検証は対象外のまま） | development-process.md「6.」 |
| **43** | 本番障害の事後レビュー時、各エスケープ欠陥を3分類（ゲート未整備／ゲート設定不適切／機械検出不可能）で記録し、憲章「7.」定期見直しの入力に加える（governance/escape-analysis/README.md。WU07-03/04/05） | MUST | 人間ゲート（不可避） | (b) | 整備済み（`governance/escape-analysis/README.md` が記録項目・3分類・定期見直しへの接続を規定。実際の記録はまだ0件＝本テンプレートに本番運用・本番障害の実例がないため。分類の判定は事後レビュー担当者による意味的判断であり、原理的に機械検証できない） | — | — | — | governance/escape-analysis/README.md ＋ constitution.md「7. 変更管理」定期見直し |

> 上表は代表的な規範の割当である。**網羅性は定期見直しで確認し**、追加・変更があれば本表を更新（または再生成）する。「未整備」項目（#13, #15b, #36〜#39, #42 等）はリポジトリ/組織設定の整備を優先する（憲章8章ブートストラップ規定）。#3〜#33 の再分類の結果、既存の「人間」を要する行（#1〜#35）はいずれも (a)/(b)/(c) のいずれかで恒久的に正当化される人間ゲート（不可避）と判定され、人間ゲート（暫定）に該当する行は0件だった（詳細は governance/proposals/gp-0003-enforcement-ledger-schema.md「5. 未解決事項」）。**#36〜#39（GP-0006／WU-05）が本台帳における最初の人間ゲート（暫定）行**、**#40（GP-0005／WU-04）が3組目**（SAST の実ツール検出部分）、続けて**#41・#42（GP-0008／WU-07）が4組目**として加わった（development-process.md「6.」の SHOULD→MUST 引き上げにともなう新規義務のうち、自己申告依存部分と Regulated 限定部分）。#43 は人間ゲート（不可避）(b) として登録した。人間ゲート（暫定）行は現時点で **#36〜#39・#40・#41・#42 の7件**である。テスト品質（#36〜#39）・SAST 実ツール検出（#40）・AI 生成識別トレーラ（#42）はいずれもこのリポジトリにコードスタックが存在しない、実ツール未配線、または Regulated プロファイル未採用のため実効的な機械検証を実装できておらず、失効期限・担当は `TBD-HUMAN`（未確定）のまま登録した。PR #26（WU-04）・PR #27（WU-07）はいずれも当初 #36／#40 を名乗っていたが、base への並行マージ順に応じて #40／#41〜#43 へ順次採番し直した（人間による行番号調整の実例）。詳細は governance/proposals/gp-0005-sast-gate.md・gp-0006-test-quality-gates.md・gp-0008-auditability-and-escape-analysis.md それぞれの「未解決事項」を参照。

---

## 改正履歴

### [0.7.0] - 2026-08-20（Proposed）

正本記録: governance/proposals/gp-0008-auditability-and-escape-analysis.md（WU-07）

**Added**

* #40 を新設: AI 生成識別（development-process.md「6.」SHOULD→MUST 引き上げ）。既知の AI エージェント・マシンアカウントが PR 作成者の場合の機械強制（`scripts/checks/pr_governance.sh` 拡張。実装済みだが実在アカウント未発行のため未行使）と、人間アカウント作成者の場合の人間ゲート（暫定）を単一行に併記した。
* #41 を新設: AI 識別トレーラのモデル識別子・バージョン記載（Regulated プロファイル限定 MUST／他 SHOULD）。人間ゲート（暫定）として登録し、機械化は Regulated プロファイル採用時の課題として先送りした。
* #42 を新設: `governance/escape-analysis/` の新設にともなう、エスケープ欠陥の3分類記録義務と憲章「7.」定期見直しへの接続。人間ゲート（不可避）(b) として登録した。
* 本 WU により、**人間ゲート（暫定）行が新たに2件（#40・#41）加わった**（既存の #36〜#39 は WU-05／GP-0006 が新設。合計6件）。当初 WU-02（[0.5.0]）時点では暫定該当は0件だったが、以降の2つの WU（WU-05・WU-07）がそれぞれ暫定該当を持つ新規 MUST を追加したことで、「機械化待ちの一時措置」が実例として蓄積し始めている。

**注記（行番号の再採番）**: 本エントリの行番号はもともと #36〜#38 として起案したが、`origin/governance/gp-0003-enforcement-ledger-schema` を本ブランチへマージした時点で、WU-05（[GP-0006](proposals/gp-0006-test-quality-gates.md)）が先に #36〜#39 を採番済みであることが判明したため、マージ後に #40〜#42 へ繰り下げた。番号の重複は解消済みである。並行起票中の他の作業単位（WU-03・04・06・08・09 等）が本マージ時点でまだ base に到達していない場合、さらなる番号調整が必要になる可能性がある。

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

**行番号の衝突とその解消（コンフリクト解消の実例）**: WU-04（PR #26）と WU-05（PR #24）はいずれも同じベース（`governance/gp-0003-enforcement-ledger-schema`）の最終行（#35）から独立に #36 を採番した。WU-05 が先に base へマージされたため、WU-04 の #36 は本コンフリクト解消時に #40 へ採番し直した。両 PR 自身が「他の並行作業単位と行番号が衝突しうる」と明記しており、想定どおりの人間による調整である。

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
