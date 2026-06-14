<!--
SYNC IMPACT REPORT
- Version change: (none) → 0.1.0
- Source of truth: /constitution.md（開発憲章・本体）。本ファイルはその簡潔な派生ビューであり、
  spec-kit の Constitution Check（/speckit.plan）専用のゲート要約である。矛盾時は本体が優先する。
- Principles (derived): I 仕様ファースト / II ADRファースト / III SSoT & Docs as Code /
  IV 既定で安全・AI入力境界 / V 変更分類と人間承認 / VI AI自律境界とHITL /
  VII 機械検証可能なゲート / VIII 監査証跡と可逆性 / IX 知識・記憶・プロンプトSSoTと段階導入
- Added sections: Constitution Check（ゲート手順）, Governance（改正・バージョニング）
- Templates requiring update:
  ✅ .specify/templates/plan-template.md（Constitution Check 節が本ビューを参照）
  ✅ .specify/templates/spec-template.md（Constitution Alignment 節）
  ✅ .specify/templates/tasks-template.md（DoD/クラス連動）
- Deferred TODOs: RATIFICATION_DATE（正式批准日。Status: Accepted 時に確定）
-->

# Constitution（ゲート用簡潔ビュー）

* Version: 0.1.0（Proposed / ドラフト）
* Ratification date: TODO（正式批准時に確定）
* Last amended: 2026-04-01
* 正本: [/constitution.md](../../constitution.md)（本ファイルはその派生サマリ。規範の正本は本体）

> 本ビューは spec-kit の **Constitution Check** で参照するための簡潔版です。原則は宣言的・テスト可能な
> 形で記述し、各原則に「Gate（合否判定）」を付しています。詳細・例外・強制手段の割当は本体の該当章を
> 正本とします（矛盾時は本体が優先）。RFC 2119 のキーワード（MUST/SHOULD/MAY）の意味は本体「1.」に従います。

## 原則（Principles）

### I. 仕様ファースト（Specification First）

Class A/B の実装は、対応する spec（要求・振る舞い）が存在しない状態で開始しない（SHOULD NOT）。
仕様変更を伴う実装は、同一 PR に spec 更新を含める（SHOULD）。
*根拠*: 実装先行は設計意図の喪失と手戻りを生む。
**Gate**: 対象機能の `specs/<feature>/spec.md` が存在し、本変更と整合しているか。

### II. ADRファースト（Record the Why）

長期的影響を持つ設計判断、および Class A/B の設計判断は ADR として記録する（SHOULD）。
ADR は「なぜこの設計か」の正本であり、spec（何を）と重複させない。
**Gate**: Class A/B を含むなら、ADR 参照または「ADR 不要理由」が PR に記載されているか（本体「5.」）。

### III. 単一情報源と Docs as Code（SSoT & DaC）

同一情報を複数箇所で管理しない（SHOULD NOT）。各情報は単一の正本を持つ。
コードから生成可能な定義（OpenAPI/スキーマ/IaC 等）は生成元を正本とし、生成物を手編集しない（SHOULD NOT）。
**Gate**: 生成物に手編集がないか（CI 再生成で差分ゼロ）。新たな二重管理を導入していないか。

### IV. 既定で安全・データ保護と AI 入力境界（Secure by Default）

秘密情報をコード/設定にハードコードしない（MUST NOT）。
本番の個人データ・顧客機密・秘密情報を AI／外部 AI に入力しない（MUST NOT。構造的強制を第一とする）。
機密区分が未定義のデータを扱う機能を本番反映しない（MUST NOT）。
**Gate**: シークレットスキャン合格。AI 入力境界（standards/security-standards.md・ai-governance.md）に照合済みか。

### V. 変更分類と人間承認（Change Classification & Human Approval）

保護対象ブランチへの全変更は反映前に Class A/B/C/D へ分類する（MUST）。未確定なら Class A（MUST）。
Class A/B は人間承認なしに反映しない（MUST NOT）。
**Gate**: 変更クラスが判定済みか。クラスに応じた承認（承認マトリクス）が揃っているか。

### VI. AI 自律境界と HITL（Human-in-the-Loop）

AI は起案・準備を自律実施してよい（MAY）が、保護対象ブランチへの反映は承認に従う。
原則競合・機密区分未確定・権限/統治への影響・憲章/ADR/実装の矛盾を検出した時点で停止し人間に諮る（MUST）。
AI は自らが関与した権限拡大を承認・自己マージしない（MUST NOT）。
**Gate**: 停止必須チェックポイント（本体「6.」）に該当しないか。作成者≠承認者か。

### VII. 機械検証可能なゲート（Machine-Verifiable Gates）

MUST/MUST NOT は可能な限り機械強制を優先する。機械強制と定義したルールは実際に CI で強制されていること（MUST）。
未整備の強制手段を整備済みであるかのように扱わない（MUST NOT。ブートストラップ規定）。
**Gate**: 本体「8.」の必須ゲート（ビルド・型・テスト・カバレッジ・シークレット・脆弱性・md lint・link）を通過したか。

### VIII. 監査証跡と可逆性（Auditability & Reversibility）

重要な意思決定は作成者・承認者・根拠を追跡可能にする（SHOULD）。
AI 生成・起案の変更は AI 由来と識別可能にする（SHOULD）。本番影響変更はロールバック手段を備える（SHOULD）。
**Gate**: 監査証跡（コミットトレーラ/PR ラベル/ADR 起案者）が残るか。可逆性が確保されているか。追跡可能性は `metrics/`（DORA・AI 有効性）で観測できるか（SHOULD）。

### IX. 知識・記憶・プロンプトの単一情報源と段階導入（Knowledge/Memory SSoT & Tiered Adoption）

ドメイン知識・手順・プロンプトは指示文へ焼き込まず、`knowledge/` / `playbooks/` / `prompts/` に置き正本化する（SHOULD）。プロンプトはレビュー対象とし、ライフサイクル（status/owner/last_review）を持つ（SHOULD）。
エージェントの作業記憶は `memory/`（非規範）に置き、確定後は `adr/` 等の正本へ昇格させて滞留させない（SHOULD）。マルチエージェントの実行指示は `AGENTS.md` を共有正本とし、名簿・協調は `agents/` に置く。
統治の重さは段階導入プロファイル（Lite / Standard / Regulated）で調整してよい（MAY）が、絶対ルールと安全ゲートは緩和しない（MUST NOT。本体「4.」、development-process.md「8.」）。
**Gate**: 知識/プロンプト/記憶が正本に置かれ二重管理していないか。採用プロファイルが `governance/` に記録されているか。

## Constitution Check（/speckit.plan での使い方）

* `/speckit.plan` は Phase 0（research）の**前に必ず**本チェックを実施し、Phase 1（design）の**後に再実施**する。
* 各原則の **Gate** を満たさない場合は、plan.md の **Complexity Tracking** に違反内容・正当化・より単純な代替案の却下理由を記録する。正当化できない違反は設計をやり直す。
* クラス判定・対象パス・仕様の正本は [development-process.md](../../development-process.md) を参照する。

## Governance（統治・改正）

* 本ビューの正本は [/constitution.md](../../constitution.md)。本ビューと本体が矛盾する場合は本体が優先する。
* 本体の改正は **ガバナンス決定**（ADR ではない）として扱い、`governance/` に記録する（本体「7.」）。
  本ビューは本体改正の確定後に追従更新する（`/speckit.constitution` で保守）。
* バージョニングはセマンティックバージョニング 2.0.0（`MAJOR.MINOR.PATCH`）に従う。
  MAJOR=後方非互換な原則変更／MINOR=原則・ゲートの追加／PATCH=非規範的明確化。
* 初期開発期間（Status: Proposed）は `0.y.z`。正式批准（Status: Accepted）時に `1.0.0`。
