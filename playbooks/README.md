# playbooks/ — 再利用可能なタスク手順

本ディレクトリは、繰り返し実行する運用・開発タスクの手順書（Runbook）を格納します。  
スキル（[SKILLS.md](../SKILLS.md)）が参照する具体的な実行ステップの置き場です。

## 例（採用組織が追加）

```text
playbooks/
├─ incident-response.md   インシデント対応・ロールバック
├─ release.md             リリース手順（承認・Break-glass を含む）
├─ migration.md           データ／スキーマ移行
└─ code-review.md         レビュー観点と手順
```

## 規約

- 手順は「前提・手順・確認・ロールバック」を含むべきです（SHOULD）。破壊的操作・本番操作は承認対象です（憲章「6.」承認マトリクス）。
- 手順が知識を要する場合は [knowledge/](../knowledge/) を参照します（焼き込まない）。
- 変更クラス: `playbooks/**` は Class C（人間承認必須・ADR 原則不要。development-process.md「1.」）。
