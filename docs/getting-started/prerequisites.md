---
title: 前提環境を整える
description: AIエージェント開発テンプレートを使うために必要な環境（Git・GitHub・AIエージェント・spec-kit・品質ゲートのツールチェーン）と、OS別の注意点。
---

# 前提環境を整える

> **所要時間:** 約20分（すでに Git と AI エージェントがある人は 5 分）

このテンプレートは **実行アプリのコードを含まない「開発プロセスの雛形」** です。
そのため「重い開発環境」は不要で、**最低限は Git があれば読めます**。
体験を深めるために、以下を段階的にそろえます。

## 1. 必須（これだけで始められる）

| ツール | 用途 | 確認コマンド |
| --- | --- | --- |
| **Git** | テンプレートの取得・変更管理 | `git --version` |
| **GitHub アカウント** | 「Use this template」での複製・CI（品質ゲート）の実行 | — |
| **テキストエディタ** | Markdown を読む・書く（VS Code 推奨） | — |

> この 3 つがあれば、[実例で学ぶ](../examples/index.md) を読みながらテンプレートの考え方を理解できます。

## 2. 強く推奨（AI 駆動開発を体験するため）

| ツール | 用途 |
| --- | --- |
| **AI コーディングエージェント** | spec / plan / ADR / 実装の下書き。Claude Code・Codex・Gemini CLI など |
| **spec-kit** | `/speckit.specify` などの **スラッシュコマンド** を提供する SDD ツールキット |

- **AI エージェント**: 本テンプレートは特定ツール専用ではありません。ルールは `AGENTS.md` を共通正本とし、ツール固有の薄い設定（`CLAUDE.md` / `GEMINI.md` / `CODEX.md` / `OPENHANDS.md` / `TAKT.md`）を各ツールが自動読込します。詳しくは [マルチエージェントとClaude Code](../concepts/multi-agent.md)。
- **spec-kit**: 仕様駆動開発のためのコマンド群を AI エージェントに追加します。導入方法は公式リポジトリ <https://github.com/github/spec-kit> を参照してください。考え方は [spec-kit のコンセプト](../concepts/spec-kit.md) で解説します。

## 3. 任意（ローカルで品質ゲートを回すため）

「ローカル = AI = CI」で同じチェックを走らせたい場合にそろえます（[品質ゲート](../concepts/quality-gates.md)）。

| ツール | 用途 | 導入 |
| --- | --- | --- |
| **mise** | ツールチェーンの固定（`.mise.toml`） | `task setup` がまとめて導入 |
| **Task** | 品質ゲートの統一エントリ（`task verify`） | 公式手順で `task` を導入 |
| **lefthook** | Git フック（commit/push 時に自動チェック） | `task hooks` |

導入後、次の順で動作確認します。

```bash
task setup       # mise でツール一式を導入
task doctor      # どのチェックツールが使えるか表示
task verify:fast # 高速チェック（コミット前相当）が緑になるか確認
```

> **まだ何も入れたくない人へ:** 任意ツールは後からで構いません。[30分クイックスタート](quickstart.md) は
> AI エージェントさえあれば進められます。

## OS 別の注意点

- **macOS / Linux**: そのまま動きます。
- **Windows**: 品質ゲートのスクリプトは **bash** です（`scripts/checks/*.sh`）。
  **WSL2**（推奨）または **Git Bash** を使ってください。`task` は WSL/Git Bash 上で実行します。
  AI エージェント（Claude Code 等）も WSL 上のリポジトリに対して動かすのが確実です。

> **詳しい結線（ブランチ保護・マシンアカウント・CI シークレット）** は、実プロジェクト採用時に
> リポジトリ同梱の `ADOPTION.md` に従います。学習段階では不要です。

## 次へ

環境がそろったら → **[30分クイックスタート](quickstart.md)**
