---
id: RISK-0001
title: "単独メンテナのため職務分掌（作成者≠承認者）が構造的に成立しない"
status: accepted              # open | mitigating | accepted | closed
date: 2026-08-08
last_updated: 2026-08-08
category: 運用                 # セキュリティ / アーキテクチャ / 運用 / AI
impact: 中
likelihood: 高
response: 受容                 # 低減 / 受容 / 移転 / 回避
owner: "makinoh"
review_after: 2027-02-08
relates_to: [GD-0001]
---

# RISK-0001: 単独メンテナのため職務分掌（作成者≠承認者）が構造的に成立しない

## 説明と発生条件

`makinoh/agent-spec-template` のコラボレータは `makinoh` 1 名です。GitHub では自身が作成した Pull Request を
自身で承認できないため、**「作成者≠承認者」を満たす承認経路が存在しません**。

このため `main` のブランチ保護で `required_approving_review_count` を 1 以上に設定すると、
オーナー自身がいかなる変更もマージできなくなります（実質的なロックアウト）。

発生条件: メンテナが 1 名である限り、すべての変更で恒常的に発生します。

## 影響 × 可能性

| 観点 | 評価 | 根拠 |
| --- | --- | --- |
| 影響 | **中** | 誤った変更が第三者レビューを経ずに `main` へ入りうる。ただし機械ゲート（`verify`）は全変更に強制適用される |
| 可能性 | **高** | 単独メンテナである限り常時 |

## 対応方針: 受容（期限付き再評価）

### 受容する理由

1. 規範を緩めずに解消する唯一の手段は「第二レビュアの追加」であり、これは技術的措置ではなく体制の問題である。
2. [waivers/](../waivers/) および [exceptions/](../exceptions/) は、**安全・統治の核（作成者≠承認者 を含む）を対象にできない**（MUST NOT）。
   したがって waiver・exception としては処理できず、リスクとして受容・追跡するのが規約に適合する唯一の経路である。
3. 未達であることを隠さず、強制台帳 #12 を「未整備」のまま維持する（憲章「8. ブートストラップ規定」）。

### その間の代替統制（実施済み）

| 統制 | 状態 |
| --- | --- |
| 必須ステータスチェック `verify`（`task verify` ＋ `task verify:pr`） | **有効**（strict） |
| `enforce_admins`（管理者にも保護を適用） | **有効** |
| force-push 禁止 / ブランチ削除禁止 / linear history | **有効** |
| 会話解決の必須化 | **有効** |
| すべての変更を PR 経由とする（`main` への直接 push 不可） | **有効** |
| Class A 変更の `permission-impact` ラベル要求 | **有効**（`scripts/checks/pr_governance.sh`） |
| AI 起案の識別（`ai-generated` ラベル ／ `Assisted-by:` トレーラ） | 運用中 |

機械で検証できる範囲は全面的に強制されており、欠けているのは**人間による第二の目**のみです。

## 解消条件

メンテナ（またはレビュア権限を持つコラボレータ）が **2 名以上**になること。解消時に以下を実施します。

1. `required_approving_review_count` を **1 以上**に設定
2. `require_code_owner_reviews` を**有効化**
3. [.github/CODEOWNERS](../../.github/CODEOWNERS) の `@org/*` を実在アカウント／チームへ置換
4. 強制台帳 #12 を「整備済み」へ更新し、本リスクを `closed` にする
5. [GD-0001](../decisions/gd-0001-adoption-profile-lite.md) の Standard 昇格を検討する

## オーナー・見直し期日

- オーナー: `makinoh`
- 見直し期日: **2027-02-08**（6 ヶ月後）。期日に解消していない場合は再評価し、受容の継続可否を記録する。

## 関連

- [GD-0001 段階導入プロファイル Lite](../decisions/gd-0001-adoption-profile-lite.md)
- [強制台帳](../enforcement-ledger.md) #12（作成者≠承認者・include administrators・force-push 禁止）／#19（必須チェック）／#22（採用配線）
- [development-process.md](../../development-process.md)「4. 保護対象ブランチ」「8. 全プロファイル共通で緩和できない絶対ルール」
- [constitution.md](../../constitution.md)「6. AIエージェント統治と自律境界」（作成者≠承認者）

## 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-08 | makinoh | 初版作成、受容として登録 | GD-0001（Lite プロファイル採用）にともなう未達事項の追跡 |
