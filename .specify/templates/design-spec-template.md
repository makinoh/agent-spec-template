---
feature: <NNN-feature-name>
status: draft            # draft | reviewed | approved
tokens_version: <tokens/tokens.json のコミットハッシュ短縮形>
owner: <承認者>
---

# Design Spec: <機能名>

> **記述規則（constitution.md「10.1.1」「10.1.3」）**
>
> - 生の値（HEX / px / rem / ms）を書かない。必ずトークン名で参照する。
>   悪い例: `padding: 24px` / 良い例: `padding: var(--space-5)`
> - `tokens/tokens.json` に無い値が必要な場合、ここで値を決めず「9. 追加が必要なトークン」に列挙する。
> - 判断できなかった点は推測で埋めず「10. Open Questions」に書く。
>   Open Questions が残っている項目は実装に着手されない。

## 1. Design Intent

このページ／機能が誰に何を伝えるか。3 行以内。

## 2. Page Inventory

| ページ | パス | セクション構成（上から順に） |
|---|---|---|
| トップ | `/` | Hero → 特徴 → 料金 → FAQ → CTA → Footer |

## 3. Layout System

- コンテナ: 本文 `var(--container-content)` / 全幅 `var(--container-wide)`
- 画面端の余白: `var(--container-gutter)`
- セクション間: Desktop `var(--space-8)` / Mobile `var(--space-section-gap-mobile)`
- グリッド: <列数・gap をトークン名で>

## 4. Component Inventory

コンポーネントごとに以下の表を繰り返す。**空欄を残さない。**
該当しない項目は「該当なし」と明記する（空欄は推測の余地を生む）。

### 4.1 `<ComponentName>`

| 項目 | 内容 |
|---|---|
| 責務 | 1 行 |
| Variants | `primary` / `secondary` / `ghost` — **これ以外は存在しない** |
| Sizes | `sm` / `md` / `lg` |
| States | default / hover / active / focus-visible / disabled / loading |
| Props | `label: string`（必須） / `variant: ButtonVariant`（既定 `primary`） … |
| Slots | 有無と用途 |
| Island 判定 | サーバ完結 ／ ハイドレーションあり（**必ず選ぶ**）。ハイドレーションありの場合は読み込み条件（初期表示時 / 可視時 / 操作時）も記す。記法は採用フレームワークに従う（ADR-0003） |
| 空状態 | 表示内容。該当しない場合は「該当なし」 |
| 読込状態 | 表示内容。該当しない場合は「該当なし」 |
| エラー状態 | 表示内容。該当しない場合は「該当なし」 |
| a11y | role / 必須 ARIA / キーボード操作 / フォーカス順序 |

**状態 × プロパティ マトリクス**（すべてトークン名で）

| 状態 | 背景 | 文字 | 枠線 | 影 | 変化 |
|---|---|---|---|---|---|
| default | `--color-action-primary` | `--color-text-inverse` | `none` | `--shadow-sm` | — |
| hover | `--color-action-primary-hover` | `--color-text-inverse` | `none` | `--shadow-md` | `--duration-fast` / `--easing-standard` |
| active | `--color-action-primary-active` | `--color-text-inverse` | `none` | `none` | `--duration-fast` |
| focus-visible | default と同じ | — | `--color-focus-ring`（太さ・オフセットのトークンが無ければ「9.」で提案する） | — | なし |
| disabled | `--color-surface-raised` | `--color-text-disabled` | `none` | `none` | なし |
| loading | default と同じ | — | — | — | スピナー：`--duration-slow` 反復 |

## 5. Responsive Rules

構造の変化を文章で記述する。値ではなく**何が起きるか**を書く。

| ブレークポイント | 変化 |
|---|---|
| `--bp-md` 未満 | ナビは Drawer に置換。料金表は横スクロールから縦積みへ。Hero の画像は本文の下へ移動 |
| `--bp-md` 以上 | ナビは水平表示。料金表は 3 カラム |
| `--bp-lg` 以上 | 本文カラムを `--container-content` に固定し、中央寄せ |

## 6. Semantic HTML 構造

ページごとに、`header` / `nav` / `main` / `section` / `article` / `aside` / `footer` の
配置と見出しレベル（h1–h3）を記述する。h1 はページに 1 つ。

## 7. Motion Spec

| 対象 | トリガー | duration | easing | reduced-motion 時 |
|---|---|---|---|---|
| Hero テキスト | 初回表示 | `--duration-normal` | `--easing-decelerate` | 即時表示（遷移なし） |

## 8. Asset Spec

| 用途 | 表示サイズ | aspect-ratio | art direction | alt | R2 パス |
|---|---|---|---|---|---|
| Hero 背景 | 全幅 | 16/9 | Mobile は 4/3 に差し替え | 装飾のため空 | `assets/hero/<slug>.avif` |

## 9. 追加が必要なトークン

`tokens/tokens.json` に不足していたもの。**ここで値を決めず、必要性のみ記述する。**
採否と値の決定は Class B 変更として ADR で行う。

| 提案名 | 用途 | 必要な理由 |
|---|---|---|
| （なければ「なし」） | | |

## 10. Open Questions

**推測で埋めないこと。** ここが空になるまで実装に着手しない。

| # | 内容 | 決める人 | 状態 |
|---|---|---|---|
| 1 | 料金表の年額割引の表記を「20% OFF」とするか「2ヶ月無料」とするか | マーケ | 未決 |

## 11. Copy

実際に使用する文言。未確定分は `[TBD: 誰が決めるか]` と明示する。
プレースホルダ（Lorem ipsum、「ここに説明」等）を残さない。
