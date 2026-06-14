---
name: migrate
description: 大規模で反復的なコード／ドキュメント変換（一括リネーム、API 移行、フレームワーク移行）に使う。対象を洗い出し、隔離して個別変換し、各々を検証する。
class: B/C（公開IF変更を含む場合は B）
status: active
owner: ""                     # 採用時に確定
last_review: "2026-04-01"
tool_boundary: ファイル編集。本番操作・破壊的操作・外部送信は承認対象（ai-governance「6.」）。並行編集は worktree 隔離。
references:
  - standards/architecture-standards.md
  - standards/api-standards.md
  - development-process.md
---

# スキル: migrate

> 本スキルは [SKILLS.md](../../SKILLS.md) の規約に従う。実行指示の正本は [AGENTS.md](../../AGENTS.md)。

## 用途

多数箇所にわたる機械的変換を、安全に・検証可能に実施する。

## 入力

- 変換ルール（before → after）・対象範囲

## 手順

1. 対象箇所を網羅的に洗い出す（探索）。件数・除外を記録する（黙って打ち切らない）。
2. 公開IF を変更する場合は Class B。[api-standards.md](../../standards/api-standards.md) に従い後方互換を既定とし、破壊的変更は ADR 化する。
3. 各対象を個別に変換し、変換ごとにビルド・テストで検証する。並行編集は worktree 隔離で衝突を避ける。
4. 循環依存を導入しない（[architecture-standards.md](../../standards/architecture-standards.md)「1.」）。

## 出力

- 変換済みコード／ドキュメント＋各検証結果（緑）

## ツール／MCP 境界

ファイル編集は可。本番データ操作・不可逆操作・依存の新規追加は承認対象（Class A）。

## 停止必須（HITL）

変換が公開IF・スキーマ・統治機構に波及する場合は人間承認を得る。
