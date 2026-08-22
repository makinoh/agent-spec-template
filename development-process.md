# 開発プロセス（Development Process）

* Version: 0.5.0（Proposed / ドラフト）
* Date: 2026-04-01
* Last amended: 2026-08-22
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

> **dependabot による GitHub Actions の版数更新**: `.github/workflows/**` の `uses:` 行のみを書き換える dependabot の PR は、**Class A のまま**（`permission-impact` ラベル ＋ CODEOWNERS 承認は必須）ですが、「ADR 参照または ADR不要理由」の**記載要件のみ**を免除します（[ADR-0006](adr/adr-0006-dependabot-governance-carveout.md)）。本表が依存のパッチ／マイナー更新を Class C（ADR 原則不要）としていることとの整合であり、人間レビューは免除しません。免除条件（作成者・パス・差分行の三重）は `scripts/checks/pr_governance.sh` が機械判定します。
>
> 公開インターフェースの識別基準は standards/api-standards.md または architecture/* を正本とします（未整備時は Class B 側に倒す）。
> `scripts/**` は既定で Class A（品質ゲートの実体）。**ゲート・統治に関与しない**開発補助のみ `scripts/dev/**` として Class C に置けます（過剰ゲートの回避）。ゲート・CI・統治に少しでも関与するスクリプトは `scripts/dev/` に置かず Class A とします（強制を弱めない。憲章「自己修正ループの防止」）。

### UI・デザイン領域のクラス（憲章「10.1 UI 再現性」）

UI を含むプロジェクトでは、上表に加えて次を適用します。上表と重複する場合は**最も厳格なクラス**を採用します。

| 対象 | クラス | 理由 | AI の権限 |
| --- | --- | --- | --- |
| `.stylelintrc.json`、`scripts/check-*.mjs`、`scripts/checks/ui.sh`、`tokens/build.mjs`、`Taskfile.ui.yml` | **A** | 強制機構そのもの。ここを緩めれば全ゲートが無効化される | 起案のみ |
| `constitution.md`「10.1」、`standards/design-tokens.md`、`standards/frontend-ui.md` | **A** | 統治文書 | 起案のみ |
| UI フレームワーク／メタフレームワーク／配信基盤の選定・変更（ADR-0003 / ADR-0004） | **A** | 全コンポーネントと配信構成に波及する不可逆に近い決定 | 起案＋ADR。**開発の性質を確認してから確定する** |
| `tokens/tokens.json` の追加・変更 | **B** | 値の真実源。無秩序な追加はトークン設計を崩壊させる | 起案＋ADR 起票 |
| **視覚回帰の基準画像更新（`--update-snapshots` / `task ui:approve:visual`）** | **B** | 基準を自由に書き換えられると検出器として機能しない | **実行禁止**（人間のみ。強制台帳 #27） |
| `specs/<feature>/design-spec.md` の変更 | **B** | UI 実装の正本 | 起案＋人間承認 |
| コンポーネントの新規追加 / variant 追加 | **B** | `design-spec.md` の更新が先行する必要がある | 起案 |
| クライアント側ハイドレーションの新規付与（island 化。記法は採用フレームワークに従う） | **B** | バンドルサイズと Server First 原則に影響 | 起案＋ADR |
| 既存コンポーネントの実装・CSS（design-spec の範囲内） | **C** | 通常の実装 | 実装まで |
| Story の追加（既存 variant の状態網羅） | **C** | 検証の充実であり仕様変更ではない | 実装まで |
| トークン参照の置換（生値 → `var()` へのリファクタ） | **C** | 挙動不変。視覚回帰が守る | 実装まで |

> 生成物（`src/styles/tokens.css` / `media.css` / `tokens.d.ts`）は手編集の対象外です（憲章「10.1.1」）。`tokens/tokens.json` の変更にともなう再生成結果としてのみコミットします。

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

### 差分規模の上限（人間ゲートの実質化）

承認は「作成者以外の人間 1 名以上」（本節冒頭の表）で定義されていますが、AI 駆動で PR の生成量が増えると、レビュアが実質的に精査できない規模の差分に対しても形式的な承認だけが行われ、人間ゲートが形骸化するおそれがあります。対策は承認者を増やすことではなく、**人間ゲートが機能する条件（レビュー可能な差分規模）を機械的に強制すること**です（constitution.md「3. 基本原則」検証手段の選択）。

* Class A および Class B に分類される PR は、変更行数が上限を超えてはなりません（MUST NOT）。上限を超える場合は、変更を分割するか、[governance/waivers/](governance/waivers/README.md) に登録された時限的な適用除外を要します。
* 変更行数は、追加行数＋削除行数の合計から、生成物・ロックファイル等のレビュー対象外の差分（`adr/INDEX.md`、`src/styles/tokens.css` 等。除外リストの正本は `scripts/check_diff_size.py`）を除いて算定します。除外リストの追加・変更自体は `scripts/**` に該当するため Class A として扱います（本書「1.」対象パス表）。
* **上限は人間が確定しました（2026-08-22）**: Class A = **200行**、Class B = **400行**（変更行数＝追加＋削除の合計）。`.github/workflows/governance-gate.yml` の `DIFF_SIZE_LIMIT_CLASS_A` / `DIFF_SIZE_LIMIT_CLASS_B` に設定済みで、`scripts/checks/diff-size.sh`（`scripts/check_diff_size.py`）が同一スクリプトのまま advisory から hard-fail ゲートへ移行しています（新たな配線の追加は不要だった。数値のみが人間判断の対象だった設計どおり）。数値の根拠は複数の実証研究（コードレビューの実効性は概ね200〜400行を境に急落するという知見）に基づく（外部レビュー指摘への対応）。
* 正本記録: [governance/proposals/gp-0009-human-gate-diff-size-limit.md](governance/proposals/gp-0009-human-gate-diff-size-limit.md)（GP-0009）。上限値の確定自体は本書「9. 改正履歴」に記録する。

---

## 6. 監査証跡の記録方式（憲章「監査証跡」の委譲先）

* **AI 生成の識別**: AI が起案・生成した変更は、コミットトレーラ（例: `Assisted-by: <agent-id>` / `Co-Authored-By:`）と PR ラベル `ai-generated` で識別しなければなりません（**MUST**。WU07-01。旧 SHOULD から引き上げ）。自己申告への依存を減らすため、次の二経路で担保します。

  1. **PR 作成者が既知の AI エージェント・マシンアカウントである場合**: `ai-generated` ラベルの付与を機械検証します（`scripts/checks/pr_governance.sh`。強制台帳 #40）。開示を自己申告のみに依存させません（本章「権限・統治への変更」に整合。standards/ai-governance.md「4.」）。
     **現状の注意**: 本テンプレートには実在の専用マシンアカウントがまだ発行されていません（`agents/README.md`「1.」の `@bot/*` は採用時に置換される意図的なプレースホルダ。強制台帳 #13）。したがって本メカニズムは**正しく実装されているが、本リポジトリでは実行機会がない（未行使）**状態です。「整備済み」を「本リポジトリで実際に機能している」の意味だと誤読しないでください。
  2. **PR 作成者が人間アカウントである場合**（AI が支援したが人間が committer である現状の大半のケースを含む）: 機械検証できる著者情報の手がかりがないため、自己申告（トレーラ・ラベルの手動付与）と PR レビュー時の人間確認に依存します（人間ゲート（暫定）。強制台帳 #40。失効期限・担当・移行先ゲートは同台帳の当該行を参照）。専用マシンアカウントの発行（強制台帳 #13 の解消）によって、この経路も機械検証可能な範囲へ段階的に移行します。

* **AI 識別トレーラの内容**: コミットトレーラ（`Assisted-by:` 等）には、使用したモデルの識別子とバージョンを含めるべきです（**SHOULD**）。**Regulated プロファイル（「8. 段階導入プロファイル」）採用時は MUST** とします（WU07-02）。トレーラの記載内容（識別子・バージョンの正確性）を機械検証することは、自己申告の真正性という意味的判断を要し、本書の対象外とします。機械化の可否・実装は強制台帳 #41 で追跡します。
* **変更クラス**: PR ラベル `class:A|B|C|D` を付与する。
* **権限影響**: 統治・強制機構に触れる PR は `permission-impact` ラベルを付与し CODEOWNERS 承認を得る（MUST。憲章6章）。
* **マシンアイデンティティ**: AI は人間の認証情報で行為してはならない（MUST NOT）。専用のマシンアカウントで行為する（MUST）。
* **承認記録**: 承認は PR レビュー記録として保持し、後から追跡可能にする（SHOULD）。
* **エスケープ欠陥の分類記録**: 本番障害の事後レビュー時の欠陥分類・記録方式は [governance/escape-analysis/README.md](governance/escape-analysis/README.md) を正本とします（WU07-03〜05。強制台帳 #42）。

---

## 7. 緊急時例外（Break-glass）とインシデント対応（憲章「7.」「変更の可逆性」の委譲先）

* 緊急承認者: 指名されたグループ（`@org/incident-commanders`、プレースホルダ）。
* 手順: 緊急時は事前検証を事後検証へ切り替えてよい（MAY）が、人間（緊急承認者）の承認は免除されない（MUST NOT 免除）。適用の事実・理由・範囲・承認者を記録し、**72時間以内**に事後レビュー（スキップしたゲートの事後実行を含む）を完了する（MUST。憲章7章）。
* インシデント対応の手順（検知・初動・収束・事後）は [playbooks/incident-response.md](playbooks/incident-response.md) で、ロールバックの可否判断・実行手順は [playbooks/rollback.md](playbooks/rollback.md) で管理する。いずれも雛形であり、採用組織が自スタック・SLA に合わせて具体化する（MUST。具体化そのものは各採用組織の判断）。
* Class A の PR は、本番反映後に問題が発生した場合の復旧手順（ロールバック手順）を PR 本文に記載しなければならない（MUST。`.github/pull_request_template.md`「ロールバック手順」欄）。記載の**有無**（非プレースホルダの実体を伴うか）は機械検証する（`task verify:pr` → `scripts/checks/pr_governance.sh`）。記載**内容の妥当性**（復旧手順として十分か）は機械検証できないため、恒久的な人間ゲート（不可避）(b) 責任の引受として、レビュアが判断する（constitution.md「3. 基本原則」検証手段の選択／governance/enforcement-ledger.md #34・#35）。
* Class A の PR は、変更そのものを「間違いだった場合に安く戻せる」設計にしているか（フィーチャーフラグの有無、DB migration を含む場合の down 定義の有無、段階的リリースの適用有無）を PR 本文に記載しなければならない（MUST。`.github/pull_request_template.md`「可逆性」欄。architecture/principles.md「5. 可逆性・観測性を既定に」の実質化）。ロールバック手順（本番反映**後**の復旧手順）とは別の関心事であり、こちらは変更**そのもの**の設計を対象とする。記載の有無は機械検証し（`scripts/checks/pr_governance.sh`。ロールバック手順欄と同一技術）、内容の妥当性は同じく人間ゲート（不可避）(b) とする（governance/enforcement-ledger.md #52・#53。外部レビュー指摘: 可逆性がレビューコストを最も下げる手段のひとつであるにもかかわらず、従来 SHOULD の宣言（playbooks/rollback.md）にとどまり、機械検証もPRテンプレートの必須欄も無かった）。

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

### [0.5.0] - 2026-08-22（Proposed）

正本記録: 外部レビュー（2026-08-22付）「AI統制能力」と「レビューが安く済むシステムを設計する能力」の指摘への対応

* 「7.」に、Class A PR の可逆性欄（フィーチャーフラグ／migration の down 定義／段階公開の記載要件。機械検証は有無のみ、内容の妥当性は人間ゲート（不可避）(b)）を追記。ロールバック手順（事後の復旧）とは別に、変更そのものの可逆な設計を要求する。
* 「差分規模の上限」の上限値を人間が確定（Class A=200行／Class B=400行）。従来 advisory だった `scripts/checks/diff-size.sh` を hard-fail ゲートへ移行した（値の投入のみ。配線変更は不要）。
* **増分の根拠**: 既存の MUST/MUST NOT を撤廃・反転せず、新規の記載要件を1件追加し（可逆性欄）、既存 MUST NOT（差分規模の上限）の未確定パラメータを確定した後方互換な拡張のため **MINOR**（「7. 変更管理」バージョニング方針の MINOR 例示「第8章相当のルール追加」に準じる。本書自体は同方針を準用する）。

### [0.4.1] - 2026-08-20（Proposed）

正本記録: [governance/proposals/gp-0011-incident-rollback-playbooks.md](governance/proposals/gp-0011-incident-rollback-playbooks.md)（WU-10）

* 「7.」の「ロールバック/インシデント手順の詳細は…（整備までは人間判断）」を、実在する2文書（[playbooks/incident-response.md](playbooks/incident-response.md) / [playbooks/rollback.md](playbooks/rollback.md)）への参照へ置換し、「整備までは」の hedge を除去（両文書とも「雛形」であることは維持）。
* 「7.」に、Class A PR のロールバック手順欄の記載要件（機械検証は有無のみ、内容の妥当性は人間ゲート（不可避）(b)）を追記。
* **増分の根拠**: 既存の MUST/MUST NOT を撤廃・反転せず、空白だった参照先を実体で埋め、新規の記載要件を1件追加した追記的更新のため **PATCH**（「7. 変更管理」に相当する憲章のバージョニング方針に準拠。本書自体は同方針を準用する）。
* **注（並行 WU との衝突・番号調整）**: 本エントリはもともと 0.3.1 として起案したが、base ブランチへ先にマージされた WU-08（0.4.0。[GP-0009](governance/proposals/gp-0009-human-gate-diff-size-limit.md)）が既にその番号帯を採番していたため、本コンフリクト解消時に 0.4.1 へ繰り下げた。

### [0.4.0] - 2026-08-20（Proposed / ドラフト）

* 「5.」に**差分規模の上限（人間ゲートの実質化）**を新設。Class A/B の PR は変更行数の上限を超えてはならない（MUST NOT）とし、超過時は分割または `governance/waivers/` の適用除外を要求。上限の具体的数値は未確定（`TBD-HUMAN`）であり、確定までは `scripts/checks/diff-size.sh` を advisory（助言のみ）で `verify:pr` に配線して実測値を可視化する。
* 正本記録: [governance/proposals/gp-0009-human-gate-diff-size-limit.md](governance/proposals/gp-0009-human-gate-diff-size-limit.md)（GP-0009）。
* **注（並行 WU との衝突・番号調整）**: 本エントリはもともと 0.3.0 として起案したが、base ブランチへ先にマージされた WU-07（0.3.0。[GP-0008](governance/proposals/gp-0008-auditability-and-escape-analysis.md)）が同番号を採番していたため、本コンフリクト解消時に 0.4.0 へ繰り下げた。

### [0.3.0] - 2026-08-20（Proposed）

正本記録: [governance/proposals/gp-0008-auditability-and-escape-analysis.md](governance/proposals/gp-0008-auditability-and-escape-analysis.md)（WU-07）

* 「6.」の「AI 生成の識別」を **SHOULD → MUST** に引き上げ、既知の AI エージェント・マシンアカウントが PR 作成者の場合の `ai-generated` ラベル自動要求（機械強制。`scripts/checks/pr_governance.sh`）と、人間アカウント作成者の場合の自己申告依存（人間ゲート（暫定））の二経路を明記した（WU07-01）。実在の専用マシンアカウントは本テンプレートに未発行であり、機械強制経路は「正しく実装されているが未行使」であることを明記した（強制台帳 #13・#40）。
* 「6.」に AI 識別トレーラの内容規定（モデル識別子・バージョンの記載）を新設。Regulated プロファイル限定で MUST、他プロファイルは SHOULD とした（WU07-02。強制台帳 #41）。
* **増分の根拠**: 既存の SHOULD を MUST へ引き上げる変更であり義務を強める後方互換な拡張、かつ新規 MUST（トレーラ内容規定）の追加であるため **MINOR**（「7. 変更管理」に相当する憲章のバージョニング方針に準拠。本書自体は同方針を準用する）。

### [0.2.1] - 2026-08-07（Accepted / 2026-08-08 承認）

* 「1.」に dependabot による Actions 版数更新のカーブアウト注記を追加（[ADR-0006](adr/adr-0006-dependabot-governance-carveout.md)）。クラスは A のまま、ADR の記載要件のみ免除。

### [0.2.0] - 2026-08-06（Accepted / 2026-08-08 承認）

* 「1.」に **UI・デザイン領域のクラス**表を追加（憲章「10.1 UI 再現性」の新設に対応）。視覚回帰の基準画像更新を Class B とし AI の実行を禁止。
* 正本記録: [governance/proposals/gp-0001-ui-reproducibility.md](governance/proposals/gp-0001-ui-reproducibility.md)

### [0.1.0] - 2026-04-01

* 初版ドラフト。
