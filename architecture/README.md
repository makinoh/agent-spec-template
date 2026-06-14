# architecture/ — アーキテクチャ・リポジトリ（設計の正本）

本ディレクトリは、憲章・development-process.md が参照する**設計の内容層**（TOGAF でいう Architecture Repository）です。  
横断技術標準は [standards/architecture-standards.md](../standards/architecture-standards.md)、設計判断の根拠は [adr/](../adr/) を参照します。

## 構成

```text
architecture/
├─ principles.md      アーキテクチャ原則（疎結合・依存方向・境界）
├─ boundaries.md      モジュール境界・レイヤ構成・依存規則（循環依存禁止）
├─ capabilities/      ケイパビリティ・マップ（ビジネス/技術能力）
├─ context-maps/      コンテキスト図（C4・境界づけられたコンテキスト）
├─ domain-models/     機能横断のドメインモデル（機能個別は specs/<feature>/data-model.md）
├─ integrations/      連携・インターフェース・カタログ
└─ roadmaps/          アーキテクチャ・ロードマップ／進化（確定履歴は adr/）
```

## 位置づけ

- 公開インターフェースの識別基準は本ディレクトリと [standards/api-standards.md](../standards/api-standards.md) を正本とし、Class B 判定に用います（development-process.md「1.」）。
- `architecture/**` の変更は Class B（原則 ADR 化。constitution.md「4.」「5.」）。
