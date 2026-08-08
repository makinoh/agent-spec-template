---
id: GD-0002
title: "憲章 0.2.0（UI 再現性）の承認、および ADR-0005 / ADR-0006 の Accepted 化"
status: Accepted              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-08
last_updated: 2026-08-08
proposer: "makinoh"
approvers: ["makinoh"]        # Lite プロファイル: 憲章改正の定足数 1 名（GD-0001）
target_version: 0.2.0
supersedes: []
superseded_by: []
relates_to: [GP-0001, GD-0001, ADR-0005, ADR-0006]
---

# GD-0002: 憲章 0.2.0（UI 再現性）の承認、および ADR-0005 / ADR-0006 の Accepted 化

> ガバナンス決定の**確定記録**（憲章「7. 変更管理」）。提案の正本は [GP-0001](../proposals/gp-0001-ui-reproducibility.md) です。
> 本書は憲章「13. 改正履歴」の正本にあたります。

## 1. 決定

以下を **承認（Accepted）** します。

| 対象 | 内容 | 遷移 |
| --- | --- | --- |
| [GP-0001](../proposals/gp-0001-ui-reproducibility.md) | UI 再現性レイヤの導入（憲章「10.1」新設） | Proposed → **Accepted** |
| [constitution.md](../../constitution.md) | Version 0.1.0 → **0.2.0**（MINOR） | 確定 |
| [ADR-0005](../../adr/adr-0005-css-token-enforcement.md) | CSS の記述方式とデザイントークン強制の手段 | proposed → **accepted** |
| [ADR-0006](../../adr/adr-0006-dependabot-governance-carveout.md) | dependabot の Actions 版数更新に関する ADR 記載要件のカーブアウト | proposed → **accepted** |

## 2. 定足数の充足

[GD-0001](gd-0001-adoption-profile-lite.md) により本リポジトリは **Lite プロファイル**を採用しており、
憲章改正の定足数は **1 名（オーナー）**です（[development-process.md](../../development-process.md)「8.」）。

| 項目 | 内容 |
| --- | --- |
| 承認者 | `makinoh`（リポジトリオーナー） |
| 承認日 | 2026-08-08 |
| 定足数 | 1 名 — **充足** |

> **職務分掌に関する注記**: 本承認は作成者と承認者が同一人物です。これは
> [RISK-0001](../risk-register/risk-0001-single-maintainer-separation-of-duties.md)（単独メンテナのため職務分掌が構造的に成立しない）
> として受容・追跡されている既知の未達事項です。隠さず記録します。
>
> なお、変更内容そのものは AI エージェント（Claude Code / Opus 5）が起案しました。
> **AI は承認していません**（憲章「7.」: AI エージェントは本書改正を単独で承認・反映してはならない（MUST NOT））。
> 承認と反映（マージ）は人間である `makinoh` が行いました。

## 3. 承認対象の実装状況（確認済み）

| 確認項目 | 結果 |
| --- | --- |
| `task verify` | 緑（`main` @ `5341d28`） |
| 憲章本体と簡潔ビュー（`.specify/memory/constitution.md`）の同期 | 実施済み（原則 X を追加） |
| 強制台帳への反映 | #23〜#28 を追加（0.2.0）、#10 / #11 にカーブアウト注記（0.2.1） |
| ADR-0006 のカーブアウト動作 | **本番 CI で実証済み**。dependabot の PR が ADR 記載なしで `✓ PR governance` を通過（免除メッセージをログで確認） |
| UI ゲートの休眠 | `package.json` / `src/` が無いため `scripts/checks/ui.sh` が skip（緑） |

## 4. 承認にともなう反映

1. [GP-0001](../proposals/gp-0001-ui-reproducibility.md) の `status` を `Accepted`、`approvers` を `["makinoh"]` に更新。
2. [constitution.md](../../constitution.md)「13. 改正履歴」`[0.2.0]` から「承認待ち」注記を削除し、本記録へリンク。
3. [development-process.md](../../development-process.md)「9.」および [強制台帳](../enforcement-ledger.md)「改正履歴」から「承認待ち」注記を削除。
4. ADR-0005 / ADR-0006 を `accepted` へ遷移（`decision-makers` / `review_after` を同時更新。変更履歴に記録）。

## 5. 未承認のまま残す事項

| 対象 | 理由 |
| --- | --- |
| [ADR-0003](../../adr/adr-0003-storybook-astro-rendering.md)（Storybook × Astro の描画方式） | 本リポジトリは UI スタックを持たないテンプレートであり、採用プロジェクトが実装着手前に確定すべき事項。テンプレート側で技術を固定しない |
| [ADR-0004](../../adr/adr-0004-cloudflare-deployment-target.md)（Cloudflare のデプロイ先） | 同上 |
| 憲章の正式批准（Status: Accepted / Version 1.0.0） | 本決定の対象外。批准は別途のガバナンス決定とする |

## 6. 見直し

- ADR-0005 / ADR-0006 の `review_after`: **2027-02-08**
- 本決定の見直しは上記 ADR の見直しに合わせて行います。

## 7. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-08 | makinoh | 初版作成、Accepted | GP-0001 の確定記録として |
