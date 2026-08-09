---
id: PR-UI-001
title: "デザイン生成（トークン制約下）"
status: active                # draft | active | deprecated | superseded
owner: "（採用時に確定）"        # 保守責任者（prompts/README.md ライフサイクル規約）
last_review: 2026-08-06       # 最終レビュー日（陳腐化検知に用いる）
version: 1.0.0
target: Claude Design
eval: ''                      # 対応する prompts/evaluations/ のテスト（任意）
---

# デザイン生成（トークン制約下）

**前提:** リポジトリを Claude Design に読み込ませるか、Claude Code 側の
`/design-sync` でデザインシステムを同期しておく。トークンを先に渡さずにデザインさせると、
その時点で差分が確定する。

```text
あなたは Senior Product Designer です。

目的は「美しいデザイン」ではなく、
Claude Code が推測なしで再現できる UI 定義を作ることです。

## 絶対制約

tokens/tokens.json の semantic トークンのみを使用してください。

- トークンに無い色・余白・フォントサイズ・角丸・影・モーション値は使用禁止
- 不足する場合は勝手に値を作らず、「追加が必要なトークン」として
  用途と必要性のみを列挙してください（値は決めない。採否は私が判断します）

## 出力（3 点）

### A. design-spec.md

.specify/templates/design-spec-template.md の構成に厳密に従ってください。

最重要ルール:
- 数値・HEX を直接書かない。すべてトークン名で参照する
  悪い例: padding: 24px / 良い例: padding: var(--space-5)
- 各コンポーネントに Island 判定（サーバ完結 / ハイドレーションあり）を必ず付ける
  ※ ハイドレーションの記法は採用フレームワークに依存する（ADR-0003 / standards/frontend-ui.md）
- 空状態・読込状態・エラー状態を必ず埋める。無い場合は「該当なし」と明記する
- 判断できなかった点は Open Questions に書く。推測で埋めない
- 文言はプレースホルダではなく実際に使うもの。未確定は [TBD: 誰が決めるか]

### B. design-spec.reference.html

全コンポーネントの 全 variant × 全 state を 1 枚に並べた静的 HTML。
スタイルは tokens.css の CSS 変数のみを参照。
これは実装物ではなく、視覚回帰の基準画像を撮るための参照実装です。

### C. tokens.additions.md

不足トークンの提案（用途と必要性のみ。値は書かない）。無ければ「なし」。

## 禁止

- トークンに無い値の使用
- design-spec.md への生の数値・HEX の記載
- Open Questions を推測で埋めること
- 「適宜」「必要に応じて」など、判断を実装者に委ねる表現
```
