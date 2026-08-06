---
id: PR-UI-003
title: "Storybook 仕様・型定義の生成"
status: active                # draft | active | deprecated | superseded
owner: "（採用時に確定）"        # 保守責任者（prompts/README.md ライフサイクル規約）
last_review: 2026-08-06       # 最終レビュー日（陳腐化検知に用いる）
version: 1.0.0
target: Claude Code
eval: ''                      # 対応する prompts/evaluations/ のテスト（任意）
---

# Storybook 仕様・型定義の生成

```text
design-spec.md の Component Inventory から、コンポーネントごとに以下を生成してください。

## 1. types.ts（先に書く）

export const BUTTON_VARIANTS = ['primary', 'secondary', 'ghost'] as const;
export type ButtonVariant = (typeof BUTTON_VARIANTS)[number];

variant / size / state をすべて as const 配列 + union で定義します。
この配列が「存在する variant の全て」であり、Story の網羅性検証に使います。

## 2. <Name>.stories.ts

- variant × size の Story は配列から生成する。手書きで列挙しない
- 状態（Hover / Focus / Active / Disabled / Loading）は play 関数と userEvent で作る。
  CSS クラスの手動付与で「それっぽく見せる」ことを禁止
- Empty / Error は design-spec に記載がある場合のみ作る
- Viewport（Mobile / Tablet）は parameters.viewport
- Dark は globals の data-theme 切替
- argTypes.variant.options に union を渡す。text control を使わない
- 視覚回帰対象の Story にはタグ @visual を付ける

## 3. 網羅性テスト

union の全要素に対応する Story が存在することを検証するテストを 1 つ置く。
Story が無い variant があればテスト失敗とする。

## 4. interaction test

design-spec.md の a11y 欄に書かれたキーボード操作をすべて play 関数で検証する。
（フォーカス移動 / Enter・Space の挙動 / Escape での閉じる動作 など）

## 5. a11y パラメータ

parameters.a11y で対象ルールを明示。無効化するルールは理由をコメントで残す。

## 禁止

- design-spec.md に無い variant / state の Story を作ること
- Story 内で CSS 値をハードコードすること
- 実装を先に書いてから Story を後付けすること
```
