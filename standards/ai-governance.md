# AIガバナンス標準（AI Governance Standard）

* Version: 0.3.0（Proposed / ドラフト）
* Date: 2026-04-01
* Last amended: 2026-08-24
* 上位規範: constitution.md（開発憲章）

本書は、AI 運用の詳細方針の正本（SSoT）であり、**憲章（原則）→ 本書（詳細方針）→ AGENTS.md（実行指示）** の中間層です（憲章「2. 文書管理階層」「6.」）。憲章と矛盾する場合は憲章が優先します（MUST）。本書自体は統治・強制機構であり、その変更は Class A です。

---

## 1. AIエージェントの自律範囲（憲章「6.」の委譲先）

AI は人間の事前承認なしに以下を**起案・準備**してよい（MAY）。最終的な反映（保護対象ブランチへのマージ）は承認マトリクスに従います。

* ドキュメントの草案作成・編集提案
* ADR ドラフト（Proposed 状態）の起票
* テストの追加・修正
* 公開インターフェースを変更しないリファクタリング（既存テストがグリーンを維持する範囲）
* バグ修正の PR 作成
* Lint / フォーマットの修正

---

## 2. Class D の自己反映の許可条件（憲章「4.」「6.」の例外の正本）

AI による Class D（統治文書を除く）の自己反映（自己マージ）は、次を**すべて**満たす場合に限り許可します（MAY）。いずれかを満たさない場合は人間承認が必要です。

* 対象パスが次に限られること（許可対象）:
  * `**/*.md`（ただし下記「除外パス」を除く）、ソースコードのコメント・フォーマットのみの変更
  * 上記の Class D には `memory/**` と `metrics/**` を含む（エージェントが自らの作業記憶・計測メモを維持できるようにする）。`prompts/**`（Class C）・`agents/**`（Class A）は自己反映の対象外。
* **除外パス（自己反映を禁止＝常に人間承認）**:
  * `constitution.md`、`.specify/memory/constitution.md`、`governance/**`、`standards/**`、`.github/**`、`AGENTS.md`、`CLAUDE.md`、`GEMINI.md`、`CODEX.md`、`OPENHANDS.md`、`TAKT.md`、`agents/**`、`SKILLS.md`、`adr-rules.md`、`adr-template.md`、`adr-template-minimal.md`、`adr/**`、`architecture/**`、`Taskfile.yml`、`lefthook.yml`、`.mise.toml`、`scripts/**`
* ドキュメント品質ゲート（Markdown Lint、Link Check）に**全通過**していること（MUST）。
* 変更がコードの挙動に影響しないこと（コメント・整形のみ）。

> 除外パスは「統治・強制機構」に一致します。これらは Class A であり「ドキュメント変更だから自律反映してよい」と解釈してはなりません（MUST NOT。憲章「4.」注）。

---

## 3. データ機密区分 × AI ツールの許容組み合わせ

本番由来データの AI／外部 AI への入力可否は standards/security-standards.md「2. AI 入力境界マトリクス」を正本とします。要点（再掲・正本は同表）:

* 本番の Confidential / Restricted（個人データ・顧客機密・秘密情報）は AI／外部 AI に入力してはなりません（MUST NOT）。
* 構造的強制を第一とし、AI に本番の機密データへ到達しうる接続権限を付与してはなりません（MUST NOT）。

---

## 4. アイデンティティと権限（憲章「権限・統治への変更」の委譲先）

* AI は人間の認証情報・アカウントで行為してはなりません（MUST NOT）。識別可能な専用マシンアカウントで行為します（MUST）。
* AI は自らが関与した権限拡大・統治機構の変更を承認・自己マージしてはなりません（MUST NOT）。作成者と承認者は分離します（MUST）。
* AI は、提案が自身の権限・自律範囲、または統治・強制機構に影響する場合、その旨を明示的に開示しなければなりません（MUST）。開示は自己申告のみに依存させず、統治パスへの変更検出による `permission-impact` ラベル自動付与で補完します（SHOULD。development-process.md「6.」）。
* AI が起案・生成した変更は `ai-generated` ラベル／コミットトレーラで識別しなければなりません（**MUST**）。開示は自己申告のみに依存させず、既知の AI エージェント・マシンアカウントが PR 作成者の場合はラベル自動付与を機械検証します。正確な記録方式・機械検証の実装状況・未行使であることの開示は development-process.md「6.」を正本とします（本書では重複記載しません）。

---

## 5. Human-in-the-Loop（停止必須点・要約）

AI は次の時点で停止し人間に諮らなければなりません（MUST。正本は憲章「6.」）。

* 原則間の競合を自律解消できないとき
* 参照すべき下位文書が未整備で判断根拠が不足するとき
* 機密区分が未確定のデータの入力可否が不明なとき
* 自身の権限・統治機構に影響する変更を提案するとき
* 憲章・ADR・実装の間に矛盾を検出したとき

---

## 6. ツール／MCP 実行境界（憲章「データ保護とAI入力境界」「6.」の委譲先）

AIエージェントが利用するツール（MCP サーバ・CLI・スクリプト等）の実行は、以下の境界に従わなければなりません。スキル（[../SKILLS.md](../SKILLS.md)）・プロンプト（[../prompts/](../prompts/)）も本境界に従います。

* **読み取りと起案は自律可（MAY）**: 検索・読込・ローカル検証・ドラフト生成等の非破壊・非送信ツールは、人間の事前承認なしに使用してよい。
* **承認を要する操作（MUST）**: 以下は人間承認なしに実行してはなりません（MUST NOT）。
  * 本番環境への接続・本番データの操作・削除を伴う不可逆操作（憲章「6.」承認マトリクス）。
  * 外部サービスへのデータ送信（外部 AI サービスを含む）。送信可否は security-standards.md「2. AI 入力境界マトリクス」に照合する（MUST）。
  * 認証情報・秘密情報へのアクセス、課金・送金・取引等の実世界アクション。
* **構造的強制を第一とする（MUST）**: AI には本番の Confidential / Restricted へ到達しうる接続権限・ツール権限を付与してはなりません（MUST NOT）。許可ツールは最小権限で構成します。
* **監査**: ツール実行（特に承認対象）は監査可能な形で記録するべきです（SHOULD。development-process.md「6.」）。

---

## 7. プロンプト・記憶の統治（憲章「IX」「Documentation as Code」の委譲先）

* プロンプトは設計資産であり、ライフサイクル（`status` / `owner` / `last_review`）を持つべきです（SHOULD。正本は [../prompts/README.md](../prompts/README.md)）。重要なプロンプトは回帰テスト（`prompts/evaluations/`）を備えるべきです（SHOULD）。
* プロンプト資産に本番の個人データ・機密を含めてはなりません（MUST NOT）。合成データを用います。
* 間接的プロンプトインジェクション（外部文書・ツール出力経由の指示混入）を脅威として扱い、[../governance/risk-register/](../governance/risk-register/) に登録し、ツール出力を無条件に信頼しないべきです（SHOULD）。
* エージェントの作業記憶 `memory/` は非規範のステージングであり、確定知見は正本（`adr/`・`knowledge/` 等）へ昇格させます（SHOULD）。`memory/` に本番の個人データ・機密を書き込んではなりません（MUST NOT）。

## 8. 外部監査アンカー（参照規範。憲章「2. 文書管理階層」の裾野）

本書「1.〜7.」は本テンプレート固有の実行指示です。これらが業界標準・政府機関の公表文書とどう対応するかを外部の監査者・採用組織が確認できるよう、以下を**情報提供の参照**として記載します（MUST/MUST NOT ではなく SHOULD。本節の追加は既存条項を撤廃・変更しません）。

* **NIST SP 800-218A**（Secure Software Development Practices for Generative AI and Dual-Use Foundation Models: An SSDF Community Profile。2024-07-26 公開、Executive Order 14110 に基づき NIST が策定）: SP 800-218（SSDF）を生成AI・基盤モデル向けに拡張したコミュニティプロファイル。AI モデル開発ライフサイクル全体（データ管理・訓練・評価・展開）に関する実務を追加で規定する。本書「1.」（AI の自律範囲）「4.」（アイデンティティと権限）「6.」（ツール／MCP 実行境界）を採用組織の該当プラクティスへ対応付けたい場合の外部参照として用いるべきです（SHOULD）。対応付け表の作成・維持は本節の対象外（採用組織が必要に応じて作成する）。
* **CoSAI Risk Map（CoSAI-RM）**（Coalition for Secure AI、OASIS Open Project。Google の SAIF を起源とするコミュニティ運営のリスク分類）: AI 開発ライフサイクルを Data / Infrastructure / Model / Application の4層に分け、各層の資産・リスク・コントロールを Persona（Model Creator / Model Consumer / Application Developer 等）ごとに関連付ける動的なグラフ構造を持つ。MITRE ATLAS・NIST AI RMF への相互参照を含む。standards/security-standards.md「2. AI 入力境界マトリクス」の機密区分判断や、governance/risk-register/ へのリスク登録の粒度を検討する際の外部参照として用いるべきです（SHOULD）。
* 上記2件はいずれも**規範文書または分類法**であり、機械強制ゲートではありません。本書・constitution.md に強制ルールとして直接組み込む場合は、対応する MUST/MUST NOT を新設し、governance/ の手続き（本書冒頭）に従わなければなりません（MUST）。本節は「参照してよい」を定めるにとどまり、「参照した」ことを義務化しません。
* **AI 生成コードのセキュアコーディング・ガイダンス資産**（例: CoSAI Project CodeGuard 等、AI コーディングエージェント向けにセキュアコーディング規範をルール化し複数エージェント形式へ変換する OSS フレームワーク）は、standards/security-standards.md「8. 第一者コードの静的解析（SAST）」が担う**事後的検出**（生成されたコードの脆弱性パターン検査）とは異なり、**予防的**（生成時点でのガイダンス注入）に位置づけられ、両者は代替関係ではなく補完関係にあります。採用組織が [SKILLS.md](../SKILLS.md) の枠組みでこの種のガイダンス資産をスキル化するかどうかは、本書「1.」の「AI は起案してよい」範囲内で検討してよく（MAY）、本書は特定製品を指定しません（NG-05 と同趣旨。governance/proposals/gp-0012-external-framework-alignment.md「3.1」）。

---

## 9. 改正履歴

### [0.3.0] - 2026-08-24（Proposed）

正本記録: [governance/proposals/gp-0012-external-framework-alignment.md](../governance/proposals/gp-0012-external-framework-alignment.md)

* 「8. 外部監査アンカー（参照規範）」を新設。外部レビューが提案した層別フレームワーク採用（CoSAI CodeGuard / OSPS Baseline / OPA・Semgrep+Allstar / NIST SP 800-218A / CoSAI-RM）の妥当性検証を受け、NIST SP 800-218A・CoSAI Risk Map を情報提供の参照として追加し、CoSAI Project CodeGuard 等のガイダンス資産は SAST と代替関係でなく補完関係であることを明記した。特定製品を MUST/MUST NOT の対象にはしていない（NG-05 準拠）。
* **増分の根拠**: 新設節は既存の MUST/MUST NOT を撤廃・変更しない（すべて SHOULD の参照案内）ため MINOR。

### [0.2.0] - 2026-08-20（Proposed）

正本記録: [governance/proposals/gp-0008-auditability-and-escape-analysis.md](../governance/proposals/gp-0008-auditability-and-escape-analysis.md)（WU-07）

* 「4.」に、AI 生成識別（`ai-generated` ラベル／トレーラ）を MUST とする条を追加。正確な記録方式・機械検証の実装状況は development-process.md「6.」を正本とし、本書は重複させない旨を明記した（WU07-01）。
* **増分の根拠**: 新規 MUST 条の追加（既存 SSoT への誘導のみで内容の重複はなし）のため MINOR。

（それ以前は初版ドラフトのため履歴なし）
