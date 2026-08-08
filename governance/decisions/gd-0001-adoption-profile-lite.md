---
id: GD-0001
title: "本リポジトリ自身の段階導入プロファイルを Lite とする"
status: Accepted              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-08
last_updated: 2026-08-08
proposer: "makinoh"
approvers: ["makinoh"]        # Lite プロファイル: 定足数 1 名（オーナー）
supersedes: []
superseded_by: []
relates_to: [RISK-0001]
---

# GD-0001: 本リポジトリ自身の段階導入プロファイルを Lite とする

> ガバナンス決定（憲章「7. 変更管理」）。[ADOPTION.md](../../ADOPTION.md)「ステップ 0」が求める記録です。

## 1. 決定

**本リポジトリ（`makinoh/agent-spec-template`）自身の運用**に、段階導入プロファイル **Lite** を適用します
（[development-process.md](../../development-process.md)「8. 段階導入プロファイル」）。

### 適用範囲の限定（重要）

本決定が定めるのは**本リポジトリ自身の運用**のみです。**テンプレートとして配布する内容の既定（Standard）は変更しません**。

- `development-process.md`「8.」の「既定は Standard」という記述は、**採用者に対する推奨**として維持します。
- 採用者は自身のプロファイルを選び、自身の `governance/decisions/` に記録します。

## 2. 理由

| 判定項目 | 実態 |
| --- | --- |
| 規模 | メンテナ 1 名（`makinoh`。コラボレータは本人のみ） |
| 規制要件 | なし（公開テンプレート。本番の個人データ・顧客機密を扱わない） |
| 監査要件 | なし |

Lite の想定「個人〜小規模・非規制」に合致します。実態が Standard を満たさないまま Standard を宣言することは、
憲章「8. ブートストラップ規定」の**未整備の強制手段を整備済みであるかのように扱わない（MUST NOT）**に反します。

## 3. Lite で調整される事項

| 項目 | 本リポジトリでの値 |
| --- | --- |
| 憲章改正の定足数 | **1 名（オーナー）** |
| Class A 承認 | 作成者以外 1 名 ＋ CODEOWNERS（※ 4. の制約を参照） |
| Class B の ADR | 重要決定のみ（最小プロファイル可） |
| skills / knowledge / playbooks / prompts | 任意 |
| カバレッジ初期値 | 緩和可（現状はコードスタック未追加のため休眠） |

## 4. Lite でも緩和されない事項と、その現状

[development-process.md](../../development-process.md)「8.」の**全プロファイル共通で緩和できない絶対ルール**は維持します。
そのうち、本リポジトリで**構造的に満たせていない**ものを以下に明示します（隠さないことが本節の目的です）。

| 絶対ルール | 現状 | 扱い |
| --- | --- | --- |
| 本番 PII を AI に入力しない | 遵守（本番データを持たない） | — |
| 品質ゲート未通過のマージ禁止 | **遵守**（`main` のブランチ保護で必須チェック `verify` を登録済み・strict・`enforce_admins` 有効） | — |
| クラス未確定は Class A | 遵守 | — |
| **作成者≠承認者（職務分掌）** | **未達**。コラボレータが 1 名のため、PR の承認者を作成者と分離できない | [RISK-0001](../risk-register/risk-0001-single-maintainer-separation-of-duties.md) として**受容・期限付き再評価**。強制台帳 #12 は「未整備」のまま |

### waiver / exception を用いない理由

[waivers/README.md](../waivers/README.md) および [exceptions/README.md](../exceptions/README.md) は、
**安全・統治の核（作成者≠承認者 を含む）に waiver / exception を適用してはならない（MUST NOT）**と定めています。
したがって本件は waiver では処理せず、**リスク登録簿での受容**と**強制台帳での「未整備」明示**によって扱います。
これは規範を緩めるのではなく、未達であることを追跡可能な形で保持する処置です。

## 5. プレースホルダを実体化しない判断（ADOPTION.md「ステップ 2」「ステップ 4」）

次のプレースホルダは**意図的に置換しません**。

| 対象 | 判断 |
| --- | --- |
| [.github/CODEOWNERS](../../.github/CODEOWNERS) の `@org/*` | **保持**。本リポジトリの成果物はテンプレートそのものであり、`@makinoh` へ置換すると採用者に誤ったコードオーナーが配布される。現在 `require_code_owner_reviews` は無効のため機能差はない |
| [agents/README.md](../../agents/README.md) の `@bot/*` | **保持**。専用マシンアカウントは未発行。同上の理由でテンプレートの忠実性を優先する |

この結果、`scripts/checks/adoption.sh` は当該プレースホルダについて **warn を出し続けます**。この警告は
「採用者が置換すべき箇所がある」という正しい通知であり、抑止しません（`adoption.sh` は助言であり `verify` を失敗させません）。

## 6. 見直し

- 見直し期日: **2027-02-08**（6 ヶ月後）
- 昇格条件: メンテナが 2 名以上になった時点で Standard への昇格を検討し、あわせて
  `required_approving_review_count` を 1 以上、`require_code_owner_reviews` を有効化し、CODEOWNERS を実体化する。
- 降格は行いません。

## 7. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-08 | makinoh | 初版作成、Accepted | ADOPTION.md「ステップ 0」の記録義務を充足するため |
