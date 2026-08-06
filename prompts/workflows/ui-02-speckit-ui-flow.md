---
id: PR-UI-002
title: "spec-kit フロー（UI 向け）"
status: active                # draft | active | deprecated | superseded
owner: "（採用時に確定）"        # 保守責任者（prompts/README.md ライフサイクル規約）
last_review: 2026-08-06       # 最終レビュー日（陳腐化検知に用いる）
version: 1.0.0
target: Claude Code (spec-kit)
eval: ''                      # 対応する prompts/evaluations/ のテスト（任意）
---

# spec-kit フロー（UI 向け）

コマンド名はバージョンにより `/speckit.*` と `/*` の両形式がある。
`.claude/commands/` の実ファイル名を確認して使い分けること。

## /speckit.specify

```text
specs/<feature>/design-spec.md と tokens/tokens.json を読み、spec.md を作成してください。

含めること:
- ユーザーが達成したいこと（技術詳細は書かない）
- 受入基準は Gherkin 形式

  Feature: Button コンポーネント
    Scenario: primary variant のフォーカス表示
      Given ユーザーがキーボード操作でページを閲覧している
      When Tab キーで primary Button にフォーカスが移動する
      Then --color-focus-ring のアウトラインが表示される
      And フォーカスリングのコントラスト比が 3:1 以上である

- 各受入基準に検証手段を付す
  [verified-by: storybook-interaction | axe | playwright-e2e | visual-regression | lighthouse]

制約:
- design-spec.md に無い要件を追加しない
- design-spec.md の Open Questions は [NEEDS CLARIFICATION] として持ち越す。
  勝手に解決しない
```

## /speckit.plan

```text
spec.md と constitution.md をもとに plan.md を作成してください。

決めきること（「必要に応じて選択」を書かない）:
- Storybook の Astro 対応方式（ADR-0003 の決定に従う。パッケージとバージョンを固定）
- Cloudflare のデプロイ先（ADR-0004 の決定に従う）
- フォント: self-host / サブセット / font-display / preload 対象 / メトリクス合わせ
- 画像: R2 のバケット構成・パス命名・astro:assets 連携・srcset・aspect-ratio
- _headers のキャッシュとセキュリティヘッダ
- CSP のインラインスクリプト方針
- 視覚回帰の基準画像の保存先と更新手順（更新は Class B である旨を明記）

決められない場合は [NEEDS CLARIFICATION] を残すこと。
未決のまま「適宜判断」と書かないこと。
```

## /speckit.tasks

```text
plan.md から tasks.md を生成してください。

粒度: 1 タスク = 1 コンポーネント、または 1 つの横断的関心事

各タスクに必ず含める:
- 依存タスク
- 完了判定に使うコマンド（例: task ui:lint:css）
- 対応する spec.md の Scenario ID

順序（ガードレールを先に立てる）:
1. トークン生成 + Stylelint + guards の配線
2. Storybook セットアップ + 型定義
3. コンポーネント: 型定義 → Story → 実装 → CSS
4. Layout / Page 組み立て
5. 参照 HTML から視覚回帰の基準画像を撮影
6. Cloudflare デプロイ設定
7. Lighthouse CI 設定

各タスクは、対応コマンドが exit 0 になることをもって完了とする。
```
