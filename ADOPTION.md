# ADOPTION.md — 採用セットアップ手順

* Version: 0.3.0（Proposed / ドラフト）
* Date: 2026-04-01
* Last amended: 2026-08-22
* 上位規範: constitution.md（開発憲章）

本書は、本テンプレートを実プロジェクトへ採用する際の手順書です。統治文書は完成していても、
**ブランチ保護・必須チェック・チーム・マシンアカウントはリポジトリ／組織側の設定**であり、本手順で結線して初めて強制が効きます
（強制台帳 governance/enforcement-ledger.md の「未整備」項目を解消します）。

---

## ステップ 0. 段階導入プロファイルを選ぶ（最初に決める）

規模・規制要件に応じて Lite / Standard / Regulated を選択します。正本・詳細は
[development-process.md](development-process.md)「8. 段階導入プロファイル」を参照し、選択結果をガバナンス決定として
`governance/decisions/` に記録します。

| プロファイル | 想定 | 最初の重さ |
| --- | --- | --- |
| Lite | 個人〜小規模・非規制 | 承認者1名・ADRは重要決定のみ・skills/knowledge 任意 |
| Standard | 通常チーム | 既定（本テンプレートの標準設定） |
| Regulated | 規制・監査対象 | 憲章承認者2名・ADR full・skills/knowledge 必須 |

> 絶対ルール（本番 PII を AI に入力しない／作成者≠承認者／統治機構の自己反映禁止／品質ゲート未通過のマージ禁止）は
> 全プロファイル共通で緩和できません（MUST）。

---

## ステップ 1. 基本方針を埋める（Day-0）

- [ ] [charter.md](charter.md)（目的）・[vision.md](vision.md)・[scope.md](scope.md) のプレースホルダを記入
- [ ] [glossary.md](glossary.md) にドメイン用語を起こす

## ステップ 2. プレースホルダを実体に置換

- [ ] [.github/CODEOWNERS](.github/CODEOWNERS) の `@org/...` を実在チーム／個人に置換
- [ ] [agents/README.md](agents/README.md) のマシンID `@bot/...` を実在の専用アカウントに置換
- [ ] [development-process.md](development-process.md)「5.」の承認者グループ・定足数を確定
- [ ] [development-process.md](development-process.md)「7.」の緊急承認者を確定
- [ ] `task verify:pr`（または `bash scripts/checks/adoption.sh`）で未置換プレースホルダ・配線漏れを点検

## ステップ 3. ブランチ保護（強制台帳 #12 / #19 / #50）

- [ ] `main` と `release/*` にブランチ保護を有効化
- [ ] 作成者以外による承認・**include administrators**・force-push 禁止を有効化
- [ ] 必須ステータスチェックに **`verify`**（`.github/workflows/verify.yml`）と **`governance-gate`**（`.github/workflows/governance-gate.yml`）の**両方**を登録する。`verify` はコード品質・統治文書の整合性を検証し、`governance-gate` は ADR参照／permission-impact／ai-generated／ロールバック手順を、PR 自身が改変できない base ref のロジックで検証する（自己参照の禁止。強制台帳 #50）。`verify` だけ登録すると PR が自分自身の統治ゲートを無効化できてしまう

## ステップ 4. マシンアイデンティティ（強制台帳 #13）

- [ ] AIエージェント用の専用マシンアカウントを発行（人間の認証情報で行為させない）
- [ ] [agents/README.md](agents/README.md) の名簿（roster）に各エージェントと専用マシンID を記録
- [ ] コミットトレーラ／PR ラベル（`ai-generated` / `class:A|B|C|D` / `permission-impact`）の運用を周知

## ステップ 5. CI シークレット・スキャン設定

- [ ] 組織利用時は `GITLEAKS_LICENSE` を設定
- [ ] 依存自動更新（Renovate / Dependabot）を有効化
- [ ] カバレッジ閾値（[standards/testing-standards.md](standards/testing-standards.md)）を各スタックの CI 設定へ反映

## ステップ 6. ADR 運用の発効

- [ ] [adr/adr-0000-adr-format-and-governance.md](adr/adr-0000-adr-format-and-governance.md) を記入し、**最初に Accepted 化**して運用規則を発効
- [ ] `python scripts/generate_adr_index.py` を実行し索引を生成

## ステップ 7. ローカル開発環境（`task setup`）

- [ ] `task setup` を実行し、[.mise.toml](.mise.toml) に固定された `task` / `lefthook` / `node` / `markdownlint-cli2` 等のツールチェーンを導入する
- [ ] `task hooks` を実行し lefthook（pre-commit フック）を有効化する（コミット前に `task verify:fast` が自動で走る）

## ステップ 8. 未配線ゲートの活性化（強制台帳の「整備中」項目）

本テンプレートは、しきい値や実ツールを AI が勝手に発明しないという方針（憲章「10.1.3 推測の禁止」／development-process.md「5.」差分規模の上限）に従い、**複数のゲートを意図的に「計測・分類ロジックのみ実装／実ツール未配線」の advisory 状態のまま出荷**しています。採用後、実際に hard-fail ゲートとして機能させるには以下の配線が必要です。放置すると「整備済み」に見えて実は何も強制していない状態のまま気づかず運用することになります（強制台帳の「整備中」欄がまさにこの状態を正直に記載しています）。

| ゲート | 現状 | 配線が必要な設定 | 強制台帳 |
| --- | --- | --- | --- |
| SAST（第一者コード静的解析） | スタック検出・配線ロジックのみ実装。実ツール未配線 | ADR でツールを選定し、環境変数 `SAST_CMD`（または実行可能な `scripts/dev/sast-tool.sh`）を CI に設定 | #40 |
| アーキテクチャ境界（循環依存の検出） | スタック検出・配線ロジックのみ実装。実ツール未配線 | `architecture/boundaries.md` のレイヤ構成を実体化した上で、採用スタックに応じたツール（import-linter / dependency-cruiser / ArchUnit / go-arch-lint 等）を選定し、環境変数 `ARCH_BOUNDARY_CMD`（または実行可能な `scripts/dev/arch-boundary-tool.sh`）を CI に設定 | #52 |
| 差分規模の上限（人間ゲートの実質化） | **本テンプレート自身は Class A=200行／Class B=400行で hard-fail 済み**（`governance-gate.yml`）。採用組織はこの値をそのまま使うか、自組織のレビュー体制に合わせて上書きする | 値を変更する場合は `.github/workflows/governance-gate.yml` の env `DIFF_SIZE_LIMIT_CLASS_A` / `DIFF_SIZE_LIMIT_CLASS_B`（整数）を編集する | #46 |
| ブランチ保護の点検（adoption.sh） | `GITHUB_TOKEN` では管理者読み取り権限が無く「確認不能」warn のまま | 管理者読み取り権限を持つ PAT をシークレット `ADMIN_READ_TOKEN` に設定（`.github/workflows/verify.yml` と `governance-gate.yml` の両方が参照） | #22 |
| 統治健全性メトリクス（機械強制率の非減少） | 実装済み・稼働中。基準値は `metrics/governance-health-snapshot.json` | 採用後の初回セットアップで `python3 scripts/check_governance_metrics.py --write-baseline` を実行し、自組織の初期状態を基準値として記録し直す（本テンプレート同梱の基準値のままだと自組織の追加変更を正しく評価できない） | #44/#45 |
| 機械強制率低下の正当な例外（waiver） | 実装済み・稼働中。現時点で該当 waiver は 0 件 | 正当な理由で機械強制率が一時的に下がる場合は [governance/waivers/README.md](governance/waivers/README.md)「機械可読な紐付け」に従って waiver を発行する（無期限は禁止） | #44/#45 |
| 憲章の批准状態 | constitution.md は v0.8.0 だが `governance/decisions/` の批准最高版は v0.3.0 のまま（advisory 警告が出る） | 0.4.0〜0.8.0 の内容を採用可否ごと点検し、採用する場合は `governance/decisions/` へ確定記録（gd-0005 等）を追加して批准する | #51 |

## ステップ 9. 本テンプレート自身の統治履歴を初期化する（重要）

`governance/decisions/` `governance/proposals/` `risk-register/` `adr/adr-0003`〜`adr-0006` は、**本テンプレート自身の開発・保守**に関する意思決定記録です（承認者はすべて本テンプレートの保守者 `makinoh` 個人）。「Use this template」で複製すると、これらの記録が採用組織の監査証跡としてそのまま相続されてしまいます。監査対応を主眼のひとつとするテンプレートである以上、他組織の承認記録が自組織の記録に混入したまま残ることは避けてください（外部レビュー指摘）。

- [ ] `governance/decisions/gd-0001`〜`gd-0004` と `governance/proposals/gp-0001`〜`gp-0011` を、自組織の意思決定として扱わない（削除するか、`governance/exceptions/`／README 等で「本テンプレート由来の記録であり自組織の決定ではない」旨を明示する）
- [ ] `risk-register/risk-0001-single-maintainer-separation-of-duties.md`（本テンプレートの単一メンテナ構成に起因するリスク）を、自組織の実態に合わせて再評価するか削除する
- [ ] `adr/adr-0003`〜`adr-0006`（本テンプレート自身の UI/CI 技術選定）を、自組織で採用しない場合は削除するか `superseded` にする。`adr/adr-0000`〜`adr-0002` は記入例（サンプル）なので同様に置換・削除する
- [ ] `specs/001-user-profile-export/` `specs/002-account-deletion/` はサンプル機能です（各 `spec.md` に明記）。実要求へ置換するか削除する
- [ ] `python scripts/generate_adr_index.py` を再実行し、`adr/INDEX.md` を実体に合わせて更新する

---

## 改正履歴

### [0.3.0] - 2026-08-22

* 外部レビュー指摘（「AI統制能力」と「レビューが安く済むシステムを設計する能力」）への対応。ステップ8にアーキテクチャ境界ゲート（`ARCH_BOUNDARY_CMD`）の配線手順を追加。差分規模の上限を、本テンプレート自身が Class A=200行／Class B=400行で hard-fail 済みであることを反映。

### [0.2.0] - 2026-08-21

* 外部レビュー指摘への対応。ステップ3を `verify` と `governance-gate`（新設）の両登録へ更新（強制台帳 #50）。
* ステップ7（`task setup`/`task hooks`）を新設（従来 README にしか記載がなかった）。
* ステップ8（未配線ゲートの活性化）を新設。SAST_CMD／DIFF_SIZE_LIMIT_CLASS_A・B／ADMIN_READ_TOKEN／governance-health baseline の再シード／waiver／批准状態の点検が、従来まったく本書に記載されていなかった（採用者が「整備済み」と誤認する原因になっていた）。
* ステップ9（本テンプレート自身の統治履歴の初期化）を新設。governance/decisions・governance/proposals・risk-register・adr-0003〜0006・specs/001-002 の相続を明示的な手順に格上げした（従来はどこにも初期化手順がなかった）。

### [0.1.0] - 2026-04-01

* 初版ドラフト。
