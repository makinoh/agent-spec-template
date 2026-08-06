---
status: Proposed
version: 0.1.0
class: A
---

# 技術標準: フロントエンド（Astro / Storybook / Cloudflare）

## 1. Astro

- 既定は静的コンポーネント。`client:*` は design-spec.md の Island 判定に従う（憲章「10.1.6 Server First」）。
- スタイルは CSS Modules（`<Name>.module.css`）。グローバル CSS は
  `src/styles/global.css` のリセットとタイポグラフィ基礎のみ。
- Props は型必須。`Astro.props` の分割代入時に `interface Props` を宣言する。
- Slot を活用し、コンポーネントに文言を埋め込まない。

## 2. Storybook × Astro

**方式は [ADR-0003](../adr/adr-0003-storybook-astro-rendering.md) で決定する。** Storybook は標準では `.astro` を描画できないため、
次のいずれかを選ぶ必要がある。

| 方式 | 内容 | トレードオフ |
|---|---|---|
| A | コミュニティ製フレームワーク（`storybook-astro` 系）で `.astro` を直接描画 | 保守がコミュニティ依存。`astro:assets` 等に既知の制約 |
| B | UI プリミティブを Preact 等で実装し、Astro はページ・レイアウト層に限定 | 公式サポート経路で安定。Astro の島の粒度設計が必要 |

いずれの場合も、依存パッケージのバージョンを**固定**して `plan.md` に記録する。

## 3. Story の設計

```ts
// types.ts
export const BUTTON_VARIANTS = ['primary', 'secondary', 'ghost'] as const;
export type ButtonVariant = (typeof BUTTON_VARIANTS)[number];
```

- Story は `BUTTON_VARIANTS` から生成する。手書きで列挙しない
  （手書きは design-spec との drift を生む）。
- 状態（hover / focus / active）は `play` 関数と `userEvent` で作る。
  CSS クラスの手動付与で「それっぽく見せる」ことを禁止する。
- `argTypes.variant.options` に union を渡す。自由入力の `text` control を使わない。
- 網羅性テストを各コンポーネントに 1 つ置き、union の全要素に Story があることを検証する。

## 4. 視覚回帰

- Storybook をビルドし、Playwright で各 Story のスクリーンショットを撮る。
- タグ `@visual` を付け、`task ui:test:visual` で実行。
- 閾値は `maxDiffPixelRatio: 0.001`。緩めない。
- **基準画像の更新は Class B。AI エージェントは実行しない**（憲章「10.1.5-4」・強制台帳 #27）。
- フォント読み込み完了を待つこと。待たないと恒常的に不安定になる。

```ts
await page.evaluate(() => document.fonts.ready);
await expect(page).toHaveScreenshot({ maxDiffPixelRatio: 0.001 });
```

## 5. フォント

CLS と LCP の主要因。次を必須とする。

- self-host（外部 CDN からの読み込み禁止）
- サブセット化（日本語は特に必須）
- `font-display: swap`
- 本文フォントのみ `<link rel="preload">`
- `size-adjust` / `ascent-override` によるフォールバックとのメトリクス合わせ

## 6. 画像

- `astro:assets` を使い、`width` / `height` または `aspect-ratio` を必ず指定する。
- 配信元は R2。パス命名は design-spec.md の Asset Spec に従う。
- フォーマットは AVIF を第一候補、WebP をフォールバック。
- LCP 対象画像のみ `loading="eager"` + `fetchpriority="high"`。他は `lazy`。

## 7. Cloudflare

- デプロイ先は **[ADR-0004](../adr/adr-0004-cloudflare-deployment-target.md) で決定**（Workers + Static Assets を既定候補とする）。
- `_headers` でキャッシュとセキュリティヘッダを定義する。

```text
/_astro/*
  Cache-Control: public, max-age=31536000, immutable

/*
  Cache-Control: public, max-age=0, must-revalidate
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  X-Content-Type-Options: nosniff
  Content-Security-Policy: default-src 'self'; img-src 'self' data: https://<r2-domain>; style-src 'self'; script-src 'self'
```

CSP でインラインスクリプトを許可しない方針とするため、Astro の `<script>` は
必ず外部バンドルに出す（`is:inline` を使わない）。使う必要が生じた場合は
ハッシュ方式を採用し ADR に記録する。

## 8. Lighthouse

| 指標 | 閾値 | 扱い |
|---|---|---|
| Accessibility | 100 | hard fail |
| Best Practices | 100 | hard fail |
| SEO | 100 | hard fail |
| Performance | 95 | 3 回実行の中央値。95 未満 90 以上は warn、90 未満で fail |

Performance を hard fail にしないのは、CI ランナーの負荷変動で偽陽性が頻発し、
結果としてゲート全体が無視されるようになるため。
