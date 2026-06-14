# 開発プロセス（Development Process）

* Version: 0.1.0（Proposed / ドラフト）
* Date: 2026-04-01
* 上位規範: constitution.md（開発憲章）

本書は、constitution.md が下位文書へ委譲する運用詳細の正本（SSoT）です。本書が未整備の事項は「未定義」として扱われ、AIエージェントは自律判断せず人間に諮らなければなりません（憲章「8. ブートストラップ規定」）。本書は憲章に従属し、矛盾する場合は憲章が優先します（MUST）。

---

## 1. 変更クラスの判定基準（憲章「4. 変更分類」の正本委譲先）

すべての変更は、保護対象ブランチへの反映前にクラスを確定しなければなりません（MUST）。クラスが確定しない場合は **Class A** として扱います（MUST）。判定は次の「対象パス対応表」を一次基準とし、複数に該当する場合は**最も厳格なクラス**を採用します。

### 対象パスとクラスの対応表

| 対象パス / 変更種別 | クラス | 補足 |
| --- | --- | --- |
| `constitution.md`、`.specify/memory/constitution.md`、`governance/**`、`standards/**`、`.github/**`（CI/CD・CODEOWNERS・workflows・PRテンプレート）、`AGENTS.md`、`CLAUDE.md`、`GEMINI.md`、`CODEX.md`、`OPENHANDS.md`、`TAKT.md`、`agents/**`、`SKILLS.md`、`adr-rules.md`、`adr-template.md`、`adr-template-minimal.md`、`Taskfile.yml`、`lefthook.yml`、`.mise.toml`、`scripts/**`（`scripts/dev/**` を除く） | **A** | 統治・強制機構（エージェント指示ファイル・品質ゲート実体を含む）。CODEOWNERS＋権限影響ラベル必須 |
| ADR の Status を `accepted` へ遷移 | **A** | 承認は人間必須（憲章「6.」） |
| 認証・認可・秘密情報、DBスキーマ／マイグレーション、インフラ構成、リリース、本番データ操作・不可逆操作、依存の新規追加・メジャー更新・ライセンス変更 | **A** | |
| `architecture/**`、公開API/公開インターフェースの変更（破壊的・後方互換追加とも）、フレームワーク／DB選定、フォルダ構成変更 | **B** | 原則 ADR 化（adr-rules.md） |
| `src/**` の後方互換な機能追加・不具合修正・内部リファクタリング、依存のパッチ／マイナー更新（重大更新を除く）、`tests/**` | **C** | AI は起案・準備を自律可。マージは人間承認 |
| `skills/**`、`playbooks/**`、`prompts/**`、`scripts/dev/**`（非ゲートの開発補助） | **C** | エージェントの挙動に影響。人間承認必須・ADR 原則不要。ツール境界は standards/ai-governance.md「6.」 |
| `knowledge/**`、`memory/**`、`metrics/**`、`glossary.md`、`**/*.md`（統治文書を除く）、コメント、フォーマット、`README.md` | **D** | 品質ゲート全通過時に自己反映可（standards/ai-governance.md の許可条件下）。`knowledge/**`・`memory/**` が他文書の依拠する規範的知識となった場合はレビューアが昇格先のクラスへ引き上げる |

> 公開インターフェースの識別基準は standards/api-standards.md または architecture/* を正本とします（未整備時は Class B 側に倒す）。
> `scripts/**` は既定で Class A（品質ゲートの実体）。**ゲート・統治に関与しない**開発補助のみ `scripts/dev/**` として Class C に置けます（過剰ゲートの回避）。ゲート・CI・統治に少しでも関与するスクリプトは `scripts/dev/` に置かず Class A とします（強制を弱めない。憲章「自己修正ループの防止」）。

### ADR が必要となるトリガ（内容ベース）

対象パスが `src/**`（Class C）であっても、変更**内容**が次に該当する場合は Class B 以上として扱い、ADR を起票する（または「ADR不要理由」を PR に記載する）。CI はパスと記載の有無を機械検証するが、内容トリガの該当判定は人間または PR ラベル（`adr-required`）で行う（憲章「5.」注：機械検証できるのは記載の有無のみ）。

- 公開 API／公開インターフェースの追加・変更（破壊的・後方互換とも）
- データベーススキーマ変更／マイグレーション
- 認証・認可の方式変更
- 外部サービス／依存の新規追加
- 永続データの不可逆操作（削除・マスキング方針等）

> 迷う場合は ADR を作成してよい（憲章「5.」MAY）。

### クラスが影響する事項

ADR の要否（憲章5章）／承認の要否（6章 承認マトリクス）／完了条件の品質ゲート（9章）／AI の自律範囲（6章）。

---

## 2. 仕様の正本・粒度・テンプレート（憲章「仕様ファースト」の委譲先）

* 仕様の正本: `specs/<NNN-feature-name>/spec.md`（What/Why）。設計（How）は `plan.md`、判断根拠は ADR。
* ディレクトリ命名: 3桁連番 + kebab-case（例: `specs/001-user-login/`）。
* 様式の正本: `.specify/templates/{spec-template,plan-template,tasks-template}.md`。
* 粒度: 1 機能（ユーザに価値を届ける最小単位）= 1 spec ディレクトリ。横断的関心事は ADR または standards へ。
* spec と実装が乖離した場合、実装の修正または spec 更新のいずれかで解消する。どちらかは人間が判断する（憲章3章）。

---

## 3. spec-kit コマンドフローの写像（憲章「2.1」と整合）

```text
/speckit.constitution → .specify/memory/constitution.md（簡潔ビュー）
/speckit.specify      → specs/<f>/spec.md          （What/Why）
/speckit.clarify      → spec.md の [NEEDS CLARIFICATION] 解消
/speckit.plan         → specs/<f>/plan.md ＋ Constitution Check ＋ Class A/B 時の ADR 起票
/speckit.tasks        → specs/<f>/tasks.md          （クラス・承認要否を付す）
/speckit.analyze      → 憲章8章＋ spec/plan/constitution 整合の点検
/speckit.implement    → 実装（完了条件＝憲章9章）
```

---

## 4. 保護対象ブランチ（憲章 用語定義の委譲先）

* 保護対象ブランチ: `main`、`release/*`。
* ブランチ保護で次を有効化する（MUST。憲章8章）: 作成者以外による承認、管理者へも保護適用（include administrators）、force-push 禁止、必須ステータスチェック（CI）の通過。

---

## 5. 承認者・定足数（憲章「7. 変更管理」の委譲先）

> 以下のグループ名・人数は本テンプレート採用組織が確定する（プレースホルダ）。

| 対象 | 必要承認 | 定足数 |
| --- | --- | --- |
| 憲章（constitution.md）の改正 | 指名された憲章承認者グループ（`@org/governance-approvers`） | **2 名以上**。AI は単独承認不可（MUST NOT） |
| 基本方針・統治機構・adr-rules.md の改正 | 同上 | 2 名以上 |
| Class A（コード・インフラ等） | 作成者以外の人間 1 名以上 ＋ CODEOWNERS | 1 名以上 |
| Class B | 作成者以外の人間 1 名以上 | 1 名以上 |
| Class C / D | 作成者以外の人間 1 名以上（D の自律反映例外は standards/ai-governance.md） | 1 名以上 |

却下された改正提案も `governance/decisions/` に記録する（憲章7章）。

---

## 6. 監査証跡の記録方式（憲章「監査証跡」の委譲先）

* **AI 生成の識別**: AI が起案・生成した変更は、コミットトレーラ（例: `Assisted-by: <agent-id>` / `Co-Authored-By:`）と PR ラベル `ai-generated` で識別する（SHOULD）。
* **変更クラス**: PR ラベル `class:A|B|C|D` を付与する。
* **権限影響**: 統治・強制機構に触れる PR は `permission-impact` ラベルを付与し CODEOWNERS 承認を得る（MUST。憲章6章）。
* **マシンアイデンティティ**: AI は人間の認証情報で行為してはならない（MUST NOT）。専用のマシンアカウントで行為する（MUST）。
* **承認記録**: 承認は PR レビュー記録として保持し、後から追跡可能にする（SHOULD）。

---

## 7. 緊急時例外（Break-glass）とインシデント対応（憲章「7.」「変更の可逆性」の委譲先）

* 緊急承認者: 指名されたグループ（`@org/incident-commanders`、プレースホルダ）。
* 手順: 緊急時は事前検証を事後検証へ切り替えてよい（MAY）が、人間（緊急承認者）の承認は免除されない（MUST NOT 免除）。適用の事実・理由・範囲・承認者を記録し、**72時間以内**に事後レビュー（スキップしたゲートの事後実行を含む）を完了する（MUST。憲章7章）。
* ロールバック/インシデント手順の詳細は本書付録または `standards/` で管理する（整備までは人間判断）。

---

## 8. 段階導入プロファイル（Lite / Standard / Regulated）

統治の重さは画一ではなく、プロジェクトの規模・規制要件に応じて選択します。これは「常に最大構成」による過剰負荷（AI 開発速度の不要な低下・人間レビュー過多）を避け、緩和の範囲を統治下に置くためです。**プロファイルの選択自体をガバナンス決定として `governance/decisions/` に記録します（MUST）。**

### プロファイル比較

| 項目 | Lite | Standard（既定） | Regulated |
| --- | --- | --- | --- |
| 想定 | 個人〜小規模・非規制・PoC | 通常のチーム開発 | 規制・監査対象・大組織 |
| 憲章改正の定足数 | 1 名（オーナー） | 2 名以上（§5） | 2 名以上＋記名監査 |
| Class A 承認 | 作成者以外1名 | 作成者以外1名＋CODEOWNERS | 同左＋セキュリティ承認 |
| Class B の ADR | 重要決定のみ（最小プロファイル可） | 原則 ADR 化 | ADR 化（full プロファイル） |
| Class C/D | 既定どおり | 既定どおり | 既定どおり |
| skills/knowledge/playbooks/prompts | 任意 | 推奨 | 必須（監査対象） |
| カバレッジ初期値（testing-standards.md） | 全体40% 等に緩和可 | 全体60%／差分80% | 差分80%＋全体引き上げ |
| ADR テンプレート | adr-template-minimal.md 既定 | minimal/full を選択 | full 既定 |

### 全プロファイル共通で緩和できない絶対ルール（MUST）

プロファイルは**人間プロセスの重さ**を調整するものであり、安全・統治の核は緩和しません。以下は Lite でも維持します。

* 本番の個人データ・顧客機密・秘密情報を AI／外部 AI に入力しない（MUST NOT）。
* 変更の作成者と承認者を分離する（職務分掌）。AI は自らが関与した権限拡大を承認・自己マージしない（MUST NOT）。
* 統治・強制機構の自己反映禁止、および失敗ゲートの回避目的の弱体化禁止（MUST NOT）。
* 品質ゲート（secret/dependency スキャン・ビルド・テスト）未通過の変更を保護対象ブランチへ反映しない（MUST NOT）。
* クラス未確定の変更は Class A として扱う（MUST）。

### プロファイルの選択・昇格

* 既定は **Standard** です。明示選択がない場合は Standard を適用します。
* 規模拡大・規制適用が生じた場合、上位プロファイルへ昇格します（ガバナンス決定として記録）。**降格は慎重に判断し、その理由を記録します（SHOULD）。**
* CI の安全ゲート（`verify` ジョブ＝`task verify`／pull_request 時は `task verify:pr`）はプロファイルに依らず常時稼働します。プロファイルが調整するのは主に承認者数・ADR 要否の範囲・カバレッジ初期値・skills/knowledge の必須性です。

---

## 9. 改正履歴

（初版ドラフトのため履歴なし）
