---
status: Proposed
version: 0.1.0
class: A
---

# 技術標準: Design Token

[constitution.md](../constitution.md)「10.1.1 Design Token 単一真実源」の実装標準。判断根拠は [ADR-0005](../adr/adr-0005-css-token-enforcement.md)。変更は Class A（統治文書扱い）。

## 1. 2 層構造

| 層 | 例 | CSS 出力 | 参照元 |
|---|---|---|---|
| `primitive` | `color.brand.500` = `#2f5cff` | **しない** | `semantic` からのみ |
| `semantic` | `color.action-primary` = `{primitive.color.brand.500}` | する | コンポーネント |

primitive を CSS に出力しないことが要点。存在しない変数は使えないため、
「本来 semantic を使うべき場所で primitive を直接使う」という誤りが構造的に起きない。

## 2. 命名規則

CSS 変数名は `--<semantic 直下のグループ>-<以下のパスをハイフン連結>`。

```text
semantic.color.action-primary-hover  →  --color-action-primary-hover
semantic.space.5                     →  --space-5
semantic.duration.fast               →  --duration-fast
breakpoint.md                        →  @custom-media --bp-md
```

- 用途で命名する。`--color-blue` ではなく `--color-action-primary`。
- 状態を名前に含める。`--color-action-primary-hover` のように、
  hover 時の値をコンポーネント側で計算しない（`filter: brightness()` 等を禁止）。

## 3. ダークモード

`$extensions.mode.dark` に dark 時の値を書く。出力は 3 段構え。

```css
:root { ... }                                        /* light */
[data-theme="dark"] { ... }                          /* 明示指定が最優先 */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) { ... }            /* OS 追従 */
}
```

dark を定義しないトークン（space / radius / z 等）は自動的に共通値となる。

## 4. ブレークポイント

CSS カスタムプロパティはメディアクエリの条件部で評価されない。

```css
@media (min-width: var(--bp-md)) { }   /* 動かない */
@media (--bp-md) { }                   /* 正しい（postcss-custom-media） */
```

`tokens.json` の `breakpoint` から `src/styles/media.css` に `@custom-media` が生成される。
生の値の直書きは `scripts/check-media-queries.mjs` が検出する。

`astro.config.mjs`:

```js
import postcssCustomMedia from 'postcss-custom-media';
export default defineConfig({
  vite: { css: { postcss: { plugins: [postcssCustomMedia()] } } },
});
```

## 5. モーション

`duration` トークンは `prefers-reduced-motion: reduce` で自動的に `0ms` に潰れる。
コンポーネント側で個別に `@media (prefers-reduced-motion)` を書く必要はなく、
書いてはならない（対応漏れの温床になる）。

`transform` を伴う演出のみ、追加で無効化が必要な場合がある。その場合は
design-spec.md の Motion Spec に「reduced-motion 時」列を記載すること。

## 6. トークンの追加手順（Class B）

1. `design-spec.md` の「9. 追加が必要なトークン」に**用途と必要性**を書く（値は書かない）
2. ADR を起票し、値と命名を決定する
3. `tokens/tokens.json` を更新
4. `task ui:tokens` で再生成し、生成物もコミットする
5. `task ui:tokens:check` が通ることを確認

**やってはいけないこと:** 実装中に値が足りないからと CSS に直書きし、
「後でトークン化する」と TODO を残す。その TODO は回収されない。

## 7. カテゴリごとの上限

トークンが増えすぎると選択の一貫性が失われる。1 カテゴリ 12 件程度を上限の目安とし、
超える場合は semantic 設計の見直しを検討する。
