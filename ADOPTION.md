# ADOPTION.md — 採用セットアップ手順

* Version: 0.1.0（Proposed / ドラフト）
* Date: 2026-04-01
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

## ステップ 3. ブランチ保護（強制台帳 #12 / #19）

- [ ] `main` と `release/*` にブランチ保護を有効化
- [ ] 作成者以外による承認・**include administrators**・force-push 禁止を有効化
- [ ] 必須ステータスチェックに `verify` ジョブを登録（`.github/workflows/verify.yml` が定義する唯一のジョブ名。README「品質ゲート」と一致）

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

---

## 改正履歴

（初版ドラフトのため履歴なし）
