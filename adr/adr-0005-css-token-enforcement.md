---
id: ADR-0005
title: "CSS の記述方式とデザイントークン強制の手段"
status: proposed              # proposed | accepted | rejected | deprecated | superseded
date: 2026-08-06
last_updated: 2026-08-06
profile: full                 # minimal | full
scope: project
proposer: "（起案者名）"
decision-makers: []           # proposed 段階は空（accepted 時に非空・adr-rules.md「4.」）
consulted: []
informed: []
tags: [frontend, css, design-tokens]
risk: medium
review_after: ""              # accepted 時に YYYY-MM-DD を記入
depends_on: []
supersedes: []
superseded_by: []
relates_to: [ADR-0003]
---

# ADR-0005: CSS の記述方式とデザイントークン強制の手段

> メタデータは冒頭フロントマターを唯一の正本とする（本文に再掲しない。adr-rules.md「3.」「4.」）。本ADRは完全プロファイル（Class A の決定のため。adr-rules.md「2.」）。
> 変更クラスは **A**（強制機構そのもの。development-process.md「1.」）。
> 関連標準: [standards/design-tokens.md](../standards/design-tokens.md) / [standards/frontend-ui.md](../standards/frontend-ui.md)。

## 変更履歴

| 日付 | 変更者 | 変更内容（ステータス遷移を含む） | 理由 |
|------|--------|----------------------------------|------|
| 2026-08-06 | （起案者） | 初版作成、Proposed に設定 | UI 再現性レイヤ（constitution.md「10.1」）の強制手段を確定するため起案 |

## 適用スコープ

- スコープ: project（本リポジトリを採用するプロジェクトの UI 実装）
- 対象: `src/**/*.css`（CSS Modules を含む）、`.stylelintrc.json`、`tokens/**`
- 対象外: 生成物（`src/styles/tokens.css` / `media.css`）、`dist/**`、`storybook-static/**`

### 階層型ガバナンスにおける位置づけ

本決定は constitution.md「10.1.1 Design Token 単一真実源」を実現する**強制手段**の選定である。原則の正本は憲章、実装標準の正本は [standards/design-tokens.md](../standards/design-tokens.md)、本 ADR は「なぜこの手段か」の正本である（AGENTS.md「4.」）。

## コンテキスト

### 背景

本テンプレートが解決していない失敗モードは「デザインと実装の値がずれる」ことである。既存の品質ゲートが検出するのは秘密情報・依存脆弱性・テスト・ADR 記載・統治設定の無断変更であり、いずれも「`padding` が `24px` ではなく `20px` になっている」を検出できない。

自然言語のルール（「色を変更しないこと」等）はレビュー時に疲労で漏れる。値を書ける場所を機械的に一箇所へ閉じる必要がある。

### 前提（Assumptions）

- 値の唯一の真実源は `tokens/tokens.json`（constitution.md「10.1.1」）。
- CSS 変数はメディアクエリの条件部では評価されない（CSS 仕様上の制約）。

### 制約（Constraints）

- 強制機構自体の変更は Class A（development-process.md「1.」）であり、緩和には人間承認を要する。
- CI・ローカル・AI エージェントは同一コマンド（`task verify`）を実行する（AGENTS.md「7.」）。

## 意思決定事項

- 決定の問い: CSS をどの方式で記述し、トークン外の値の混入をどう機械的に禁止するか。
- 含む: CSS の記述方式、値の強制手段、メディアクエリとフォーカスリングの抜け道の塞ぎ方。
- 含まない: トークンの命名体系そのもの（[standards/design-tokens.md](../standards/design-tokens.md)「2.」が正本）、視覚回帰ツールの選定（[standards/frontend-ui.md](../standards/frontend-ui.md)「4.」）。

## 決定要因

- 違反箇所が正確に特定できること（レビュー負荷を機械へ移せること）
- 抜け道が少ないこと（塞ぎ残しがあれば強制は形骸化する）
- design-spec の状態マトリクスと実装の対応が読み取れること
- 導入・保守コスト

## 評価観点

| # | 観点 | 重み | 判定基準 |
|---|------|------|----------|
| 1 | 逸脱検出の確実性 | 高 | トークン外の値を error として検出できるか |
| 2 | 抜け道の少なさ | 高 | 任意値記法・メディアクエリ・フォーカス消去を塞げるか |
| 3 | 可読性（spec との対応） | 中 | design-spec の状態マトリクスと実装が 1:1 で読めるか |
| 4 | 導入・保守コスト | 中 | 依存追加数と設定の維持コスト |

## 検討項目

- メディアクエリの条件部で CSS 変数が使えないことへの対処（`@custom-media` の生成要否）
- `outline: none` によるフォーカスリング消去の禁止手段
- lint の無効化コメント（`/* stylelint-disable */`）の扱い
- Tailwind CSS を採用した場合の任意値記法 `[24px]` の封じ方

## 選択肢

### 選択肢 A：CSS Modules ＋ Stylelint（`declaration-strict-value`）

**メリット**: 対象プロパティで `var(--...)` 以外を error にでき、違反箇所が正確に特定できる。Astro のスコープ付き CSS と自然に併存する。
**デメリット**: Stylelint の設定自体が強制機構になるため、その変更を Class A で守る必要がある。

### 選択肢 B：Tailwind CSS（tokens から theme を生成し、任意値記法を lint で禁止）

**メリット**: ユーティリティ由来で値が自然に制限される。
**デメリット**: 任意値記法 `[24px]` の抜け道を別途塞ぐ必要がある。design-spec の状態マトリクスとクラス名の対応が読み取りにくくなる。

### 選択肢 C：規約のみ（レビューで担保。ベースライン）

**メリット**: 追加の依存・設定が不要。
**デメリット**: レビューは疲労する。機械が疲労しないことが本設計の要点であり、目的を達成できない。

## 評価

スコアは 1（劣る）〜 5（優れる）。重み: 高 = 3、中 = 2。

| 観点（重み） | A: CSS Modules + Stylelint | B: Tailwind | C: 規約のみ |
|---|---|---|---|
| 逸脱検出の確実性（3） | 5 | 4 | 1 |
| 抜け道の少なさ（3） | 4 | 3 | 1 |
| spec との対応の可読性（2） | 5 | 2 | 3 |
| 導入・保守コスト（2） | 4 | 3 | 5 |
| **加重合計** | **45** | **31** | **22** |

## 決定（案）

- 採用する選択肢（案）: **A（CSS Modules ＋ `stylelint-declaration-strict-value`）**
- 決定理由: 逸脱検出の確実性と違反箇所の特定精度が最も高く、design-spec の状態マトリクスと実装の対応も保てる。加えて、次の 2 つの抜け道を個別に塞ぐ。
  1. メディアクエリの条件部では CSS 変数が評価されないため、`@custom-media` を生成し、生の値の直書きを `scripts/check-media-queries.mjs` で検出する。
  2. `outline: none` によるフォーカスリング消去を `declaration-property-value-disallowed-list` で禁止する（constitution.md「10.1.2」）。
- 不採用案の理由: B は任意値記法の抜け道を別途塞ぐ必要があり、design-spec との対応も読み取りにくい。C は目的（機械による検出）を達成できない。

## 承認

> 承認者が記入。Accepted への遷移（変更履歴に記録）とフロントマター `status`/`decision-makers`/`review_after` の同時更新で確定する。承認は Class A・人間必須（constitution.md「6.」）。

| 項目 | 内容 |
|------|------|
| 確定した決定 | |
| 承認者・承認日 | |
| 見直し時期 | YYYY-MM-DD |

## 結果

> 承認後・見直し期日に記入。

- `.stylelintrc.json` は Class A 変更。`/* stylelint-disable */` の使用は [governance/exceptions/](../governance/exceptions/) の例外台帳へ登録する。
- `postcss-custom-media` が必須依存となる。
- Tailwind への将来的な移行を行う場合、本 ADR を Superseded とし新規 ADR を起票する。

## 関連ADR

| 関係 | ADR | 内容 |
|------|-----|------|
| relates_to | [ADR-0003](adr-0003-storybook-astro-rendering.md) | Storybook での描画方式。CSS Modules の適用先（`.astro` / `.tsx`）に影響する |

## 参考資料

- [standards/design-tokens.md](../standards/design-tokens.md) — トークンの 2 層構造と命名規則（実装標準の正本）
- [standards/frontend-ui.md](../standards/frontend-ui.md) — Astro / Storybook / Cloudflare の技術標準
- [standards/accessibility-standards.md](../standards/accessibility-standards.md) — フォーカス可視性を含むアクセシビリティ基準
- CSS Values and Units: メディアクエリ条件部での `var()` 非評価（W3C CSS 仕様）
