# knowledge/ — エージェント参照用の永続知識（SSoT リンク付き）

本ディレクトリは、ドメイン知識・運用知識・連携先仕様を、**正本へのリンク付き**で集約します。  
知識を AGENTS.md / CLAUDE.md 等の本文へ焼き込まず本ディレクトリに置くことで、トークン効率と単一情報源（憲章「SSoT」）を両立します。

## 構成

```text
knowledge/
├─ domain/         業務知識・ユビキタス言語（glossary.md と相互リンク）
├─ business-rules/ 業務ルール・不変条件・ポリシー（spec の FR の根拠）
├─ examples/       AI 向けの良質な例（few-shot。spec/コードの模範）
├─ ops/            運用知識（手順そのものは playbooks/）
└─ integrations/   外部API・連携先の仕様メモ（正本は各提供元）

> API 契約は機能ごとの `specs/<feature>/contracts/` と横断規約 `standards/api-standards.md`、
> アーキテクチャは `architecture/` を正本とする（knowledge/ で重複管理しない）。
```

## 規約

- 各ファイルは先頭に「正本リンク」と「最終確認日」を持つべきです（SHOULD）。陳腐化はリンクチェックで補完します。
- 確定前の暫定知見・反省・申し送りは [memory/](../memory/)（非規範のステージング）に置き、確定したら本ディレクトリへ昇格します（二重管理を避ける。憲章「SSoT」）。
- 知識は事実とその出所を記し、判断（なぜこの設計か）は ADR、要求（何を作るか）は spec に置きます（重複させない）。
- 変更クラス: `knowledge/**` は既定 Class D（品質ゲート通過時に自己反映可）。他文書が依拠する規範的知識となった場合はレビューアが Class B へ引き上げます（development-process.md「1.」）。
