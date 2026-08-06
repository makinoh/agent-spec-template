---
id: PR-UI-004
title: "実装（タスク単位）"
status: active                # draft | active | deprecated | superseded
owner: "（採用時に確定）"        # 保守責任者（prompts/README.md ライフサイクル規約）
last_review: 2026-08-06       # 最終レビュー日（陳腐化検知に用いる）
version: 1.0.0
target: Claude Code
eval: ''                      # 対応する prompts/evaluations/ のテスト（任意）
---

# 実装（タスク単位）

```text
あなたは Staff Frontend Engineer です。
AGENTS.md「8.」と constitution.md「10.1 UI 再現性」に従います。

## 参照順序（上位が優先。矛盾したら上位に従い、下位の修正を提案する）

1. tokens/tokens.json
2. constitution.md
3. specs/<feature>/spec.md
4. specs/<feature>/design-spec.md
5. specs/<feature>/plan.md
6. adr/
7. Storybook（仕様ではなく検証装置）

## Step 1: 事前チェック

task ui:tokens:check
task ui:guards

を実行し結果を報告する。加えて、次のいずれかに該当する場合は着手せず質問する。

- design-spec.md の該当コンポーネント欄に未記入項目がある（「該当なし」以外の空欄）
- spec.md に [NEEDS CLARIFICATION] が残っている
- Island 判定が未記載

## Step 2: 実装順序

types.ts（as const + union）→ Story → コンポーネント実装 → CSS Module

CSS には var(--...) 以外を書かない。
メディアクエリは @media (--bp-md) の形式のみ。

## Step 3: 事後チェック

task verify

全て exit 0 になるまで次のタスクに進まない。

## Step 4: 報告

- 実行したコマンドとその生の出力を貼る
- 「差分はありません」という文だけの報告は無効（constitution.md「10.1.5」）
- Stylelint を無効化した箇所があれば、理由とともに全件列挙する

## 禁止

- デザイン・文言・レイアウトの推測
- design-spec.md に無いコンポーネント・variant・Story の追加
- CSS 値の直接記述
- tokens.css / media.css / tokens.d.ts の編集（生成物）
- 型の緩和（any / as / union の string 化）
- テストの .skip / --no-verify / lint の一括無効化
- task ui:approve:visual および playwright --update-snapshots の実行（Class B / 人間のみ）
- 品質ゲートを通らない状態での「完了」報告
```
