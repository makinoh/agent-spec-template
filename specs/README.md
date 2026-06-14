# specs/ — 機能仕様（Spec-Driven Development）

本ディレクトリは、spec-kit の SDD フローで生成される **機能単位の成果物** を格納します。  
1 機能 = 1 サブディレクトリ（`NNN-feature-name/`、3桁連番）です。

## 構成

```text
specs/
└─ 001-example-feature/
   ├─ spec.md          # 何を・なぜ（What/Why）。/speckit.specify, /speckit.clarify
   ├─ plan.md          # どう作るか（How）＋ Constitution Check。/speckit.plan
   ├─ research.md      # Phase 0 調査（任意）
   ├─ data-model.md    # Phase 1 データモデル（任意）
   ├─ contracts/       # Phase 1 API/イベント/スキーマ契約（任意）
   ├─ quickstart.md    # 動作確認手順（任意）
   └─ tasks.md         # 実行可能タスク。/speckit.tasks
```

## テンプレートと正本

- 様式の正本: [.specify/templates/](../.specify/templates/)（`spec-template.md` / `plan-template.md` / `tasks-template.md`）
- 仕様の正本の所在・粒度・命名規則: [development-process.md](../development-process.md)
- 判断根拠（なぜこの設計か）は **ADR**（[adr/](../adr/)）に記録し、spec と重複させない。

## ライフサイクル

```text
/speckit.specify → /speckit.clarify → /speckit.plan → /speckit.tasks → /speckit.analyze → /speckit.implement
```

各段の責務・成果物・憲章との接続は [constitution.md「2.1 spec-kit との接続」](../constitution.md) を参照してください。
