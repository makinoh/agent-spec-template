# ADR 索引（自動生成 — 手動編集しない）

> 本ファイルは `scripts/generate_adr_index.py` が生成する派生サマリです。
> 正本は各 ADR のフロントマター（adr-rules.md「4. 索引」）。手動で編集しないでください。

| ID | タイトル | Status | Scope | 最終更新 | ファイル |
| --- | --- | --- | --- | --- | --- |
| ADR-0000 | アーキテクチャ決定記録（ADR）の導入とフォーマット標準の選定 | proposed |  | YYYY-MM-DD | [adr-0000-adr-format-and-governance.md](adr-0000-adr-format-and-governance.md) |
| ADR-0001 | ユーザプロフィールエクスポートの提供形式の選定 | proposed | project | 2026-04-01 | [adr-0001-export-format-selection.md](adr-0001-export-format-selection.md) |
| ADR-0002 | アカウント削除戦略（ソフト削除＋猶予期間）の選定 | proposed | project | 2026-04-01 | [adr-0002-deletion-strategy.md](adr-0002-deletion-strategy.md) |
| ADR-0003 | Storybook における Astro コンポーネントの描画方式 | proposed | project | 2026-08-06 | [adr-0003-storybook-astro-rendering.md](adr-0003-storybook-astro-rendering.md) |
| ADR-0004 | Cloudflare のデプロイ先（Workers + Static Assets / Pages） | proposed | project | 2026-08-06 | [adr-0004-cloudflare-deployment-target.md](adr-0004-cloudflare-deployment-target.md) |
| ADR-0005 | CSS の記述方式とデザイントークン強制の手段 | proposed | project | 2026-08-06 | [adr-0005-css-token-enforcement.md](adr-0005-css-token-enforcement.md) |
| ADR-0006 | dependabot による Actions 版数更新の統治要件（ADR 記載要件のカーブアウト） | proposed | project | 2026-08-07 | [adr-0006-dependabot-governance-carveout.md](adr-0006-dependabot-governance-carveout.md) |

## 関係グラフ

- `ADR-0002` —relates_to→ `ADR-0001`
- `ADR-0003` —relates_to→ `ADR-0005`
- `ADR-0005` —relates_to→ `ADR-0003`
