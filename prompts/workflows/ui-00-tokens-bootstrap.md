---
id: PR-UI-000
title: "トークンとガードレールの初期化"
status: active                # draft | active | deprecated | superseded
owner: "（採用時に確定）"        # 保守責任者（prompts/README.md ライフサイクル規約）
last_review: 2026-08-06       # 最終レビュー日（陳腐化検知に用いる）
version: 1.0.0
target: Claude Code
eval: ''                      # 対応する prompts/evaluations/ のテスト（任意）
---

# トークンとガードレールの初期化

```text
あなたは Design Systems Engineer です。
実装より先に、このプロジェクトの Design Token と強制機構を確定させます。

## 前提

- standards/design-tokens.md を読み、その規約に従ってください。
- constitution.md「10.1.1 Design Token 単一真実源」に違反する提案をしないでください。

## 作業

1. tokens/tokens.json の草案を作る
   - primitive / semantic の 2 層。primitive は CSS に出力しない
   - semantic の各トークンに $description で「どこで使うか」を 1 行
   - 色は $extensions.mode.dark で dark 時の値を持つ
   - breakpoint は別トップレベルキー（@custom-media として出力されるため）
   - カテゴリごとに 12 件を上限の目安とする。使わないトークンを作らない

2. 草案を提示し、私の承認を得る（ここで一度止まること）

3. 承認後、以下を配置して動作確認する
   - tokens/build.mjs（生成スクリプト）
   - .stylelintrc.json（scale-unlimited/declaration-strict-value）
   - scripts/check-spec-literals.mjs
   - scripts/check-media-queries.mjs
   - scripts/check-component-stories.mjs
   - Taskfile.ui.yml をルート Taskfile.yml から includes で読み込む
   - astro.config.mjs に postcss-custom-media を設定

4. 検証
   task ui:tokens
   task ui:tokens:check
   task ui:guards
   を実行し、生の出力を報告してください。

## 禁止

- 私の承認前に tokens.json 以外のファイルを作ること
- 「よくある値」でカテゴリを埋めること。用途が説明できないトークンは作らない
```
