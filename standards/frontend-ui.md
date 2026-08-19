---
status: Proposed
version: 0.2.0
class: A
---

# 技術標準: フロントエンド

[constitution.md](../constitution.md)「10.1 UI 再現性」の実装標準。変更は Class A（統治文書扱い）。

> **本書の構成**: 「1.〜7.」は**フレームワーク・クラウド基盤に依存しない要求**です。
> 特定技術に固有の記法・設定は「付録」に置き、**採用プロジェクトが ADR-0003 / ADR-0004 で
> 選定したものだけが有効**になります。付録は選定の参考であり、既定でも推奨でもありません。

---

## 1. 適用範囲と技術選定の順序

本テンプレートは**フロントエンド技術を固定しません**。選定は次の順序で行います。**順序に意味があります**。

| # | 決めること | 記録先 | 前提 |
| --- | --- | --- | --- |
| 0 | **開発の性質**（コンテンツ中心／業務アプリ／ハイブリッド） | `specs/<feature>/spec.md` ・ プロジェクト基本方針 | — |
| 1 | **コンポーネント層の技術**と、メタフレームワークからの分離方針 | [ADR-0003](../adr/adr-0003-storybook-astro-rendering.md) | 0 の確定 |
| 2 | **メタフレームワーク**（必要な場合） | ADR-0003 と同一 ADR または後続 ADR | 0 の確定 |
| 3 | **配信・実行基盤** | [ADR-0004](../adr/adr-0004-cloudflare-deployment-target.md) | 0 の確定 |

> **0 を飛ばして 1〜3 を決めてはなりません（MUST NOT）。** 「静的サイトか業務アプリか」で適合する
> 技術がまったく異なるため、性質未確定のまま技術を固定すると、後から全コンポーネントの書き直しが発生します。
> 未確定のまま実装に着手することは憲章「10.1.3 推測の禁止」に反します。

## 2. コンポーネント層の分離（フレームワーク非依存の要求）

1. UI プリミティブ（Button / Card / Input 等）は、**メタフレームワークに依存しない層**に置くべきです（SHOULD）。
   メタフレームワークはページ・レイアウト・データ取得を担当します。
2. 分離の目的は 2 つです。
   - **Storybook の公式サポート経路に載せる** — 視覚回帰・a11y・interaction テストの基盤が、
     コミュニティ製アダプタの追随待ちにならない（憲章「10.1.4」「10.1.5」の前提を守る）。
   - **メタフレームワークの差し替えコストを局所化する** — 基盤変更がページ層に限定される。
3. 分離しない選択（メタフレームワーク固有形式で全コンポーネントを書く）を採る場合、
   その理由と、視覚回帰・a11y の代替手段を ADR-0003 に記録しなければなりません（MUST）。

## 3. Story の設計（フレームワーク非依存）

```ts
// types.ts
export const BUTTON_VARIANTS = ['primary', 'secondary', 'ghost'] as const;
export type ButtonVariant = (typeof BUTTON_VARIANTS)[number];
```

- Story は `BUTTON_VARIANTS` から生成します。手書きで列挙しません（design-spec との drift を生むため）。
- 状態（hover / focus / active）は `play` 関数と `userEvent` で作ります。
  CSS クラスの手動付与で「それっぽく見せる」ことを禁止します（MUST NOT）。
- `argTypes.variant.options` に union を渡します。自由入力の `text` control を使いません。
- 網羅性テストを各コンポーネントに 1 つ置き、union の全要素に Story があることを検証します。

依存パッケージのバージョンは**固定**して `plan.md` に記録します（MUST）。

## 4. 視覚回帰（フレームワーク非依存）

- Storybook をビルドし、Playwright で各 Story のスクリーンショットを撮ります。
- タグ `@visual` を付け、`task ui:test:visual` で実行します。
- 閾値は `maxDiffPixelRatio: 0.001`。緩めません（MUST NOT）。
- **基準画像の更新は Class B。AI エージェントは実行しません**（憲章「10.1.5」・強制台帳 #27）。
- フォント読み込み完了を待ちます。待たないと恒常的に不安定になります。

```ts
await page.evaluate(() => document.fonts.ready);
await expect(page).toHaveScreenshot({ maxDiffPixelRatio: 0.001 });
```

コンポーネント層を分離した場合、**ページ層は Storybook に載らない**ため、
ページ単位の Playwright スクリーンショットで補完しなければなりません（MUST）。

## 5. フォント

CLS と LCP の主要因です。次を必須とします（MUST）。

- self-host（外部 CDN からの読み込み禁止）
- サブセット化（日本語は特に必須）
- `font-display: swap`
- 本文フォントのみ `<link rel="preload">`
- `size-adjust` / `ascent-override` によるフォールバックとのメトリクス合わせ

## 6. 画像

- ビルド時に最適化し、`width` / `height` または `aspect-ratio` を必ず指定します（MUST。CLS 対策）。
- フォーマットは AVIF を第一候補、WebP をフォールバックとします。
- LCP 対象画像のみ `loading="eager"` ＋ `fetchpriority="high"`。他は `lazy`。
- 配信元とパス命名は `design-spec.md` の Asset Spec に従います。

## 7. 配信・実行基盤に対する要求（基盤非依存）

基盤の**選定**は ADR-0004 で行います。どの基盤を選ぶ場合でも、次を満たさなければなりません（MUST）。

| 要求 | 内容 |
| --- | --- |
| キャッシュ制御 | 内容ハッシュ付きアセットは長期 immutable、HTML は再検証必須 |
| セキュリティヘッダ | HSTS / `Referrer-Policy` / `Permissions-Policy` / `X-Content-Type-Options` / CSP |
| CSP | インラインスクリプトを既定で許可しない。必要な場合はハッシュ方式を採用し ADR に記録する |
| 再現性 | デプロイ成果物がビルドから再現可能であること（憲章「監査証跡」） |
| ロールバック | 直前のデプロイへ戻せること（憲章「変更の可逆性」） |

設定の**書き方**（ファイル名・構文）は基盤に依存します。付録 B を参考に、採用基盤の方式へ読み替えます。

## 8. Lighthouse

| 指標 | 閾値 | 扱い |
| --- | --- | --- |
| Accessibility | 100 | hard fail |
| Best Practices | 100 | hard fail |
| SEO | 100 | hard fail |
| Performance | 95 | 3 回実行の中央値。95 未満 90 以上は warn、90 未満で fail |

Performance を hard fail にしないのは、CI ランナーの負荷変動で偽陽性が頻発し、結果としてゲート全体が
無視されるようになるためです。

---

## 付録: 技術別の実装例

> **以下は選定の参考であり、既定でも推奨でもありません。** 採用プロジェクトが ADR-0003 / ADR-0004 で
> 選定した技術の節のみが有効になります。他の技術を選ぶ場合、本付録に相当する内容を当該 ADR または
> 本書の改訂で追加します（Class A）。

### 付録 A: Astro を採用する場合

- 既定は静的コンポーネント。ハイドレーションは `client:*` ディレクティブで明示します（憲章「10.1.6」）。
- スタイルは CSS Modules（`<Name>.module.css`）。グローバル CSS は `src/styles/global.css` の
  リセットとタイポグラフィ基礎のみ。
- Props は型必須。`Astro.props` の分割代入時に `interface Props` を宣言します。
- 画像は `astro:assets` を使用します。
- **Storybook は標準では `.astro` を描画できません。** ADR-0003 で次のいずれかを決めます。

  | 方式 | 内容 | トレードオフ |
  | --- | --- | --- |
  | 直接描画 | コミュニティ製フレームワークで `.astro` を Storybook に載せる | 実装＝検証対象が一致。保守がコミュニティ依存 |
  | 層分離 | UI プリミティブを Preact 等で書き、Astro はページ・レイアウトに限定 | 公式サポート経路で安定。「2. コンポーネント層の分離」に合致 |

- 型検査は `astro check` ＋ `tsc --noEmit`（`Taskfile.ui.yml` の `typecheck` に追加）。

### 付録 B: Cloudflare を採用する場合

- デプロイ先は ADR-0004 で決めます（Workers + Static Assets / Pages）。
- `_headers` でキャッシュとセキュリティヘッダを定義します（「7.」の要求を満たす一例）。

```text
/_astro/*
  Cache-Control: public, max-age=31536000, immutable

/*
  Cache-Control: public, max-age=0, must-revalidate
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  X-Content-Type-Options: nosniff
  Content-Security-Policy: default-src 'self'; img-src 'self' data: https://<media-domain>; style-src 'self'; script-src 'self'
```

- Workers + Static Assets を選ぶ場合、`wrangler.jsonc` の `compatibility_date` を採用日で固定し、
  `.assetsignore` で `node_modules` 等の除外を明示します。

### 付録 C: その他の基盤

Netlify / Vercel / AWS（S3 + CloudFront）／ Azure Static Web Apps ／ 社内 PaaS 等を採用する場合も、
「7.」の要求（キャッシュ制御・セキュリティヘッダ・CSP・再現性・ロールバック）は同一です。
設定の書き方のみが異なります。採用時に ADR-0004 へ記録し、必要なら本付録へ節を追加します。
