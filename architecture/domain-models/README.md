# architecture/domain-models/ — ドメインモデル

* 上位規範: [constitution.md](../../constitution.md)／ [glossary.md](../../glossary.md)（ユビキタス言語）
* 変更クラス: **B**（アーキテクチャ。原則 ADR 化）

横断的・永続的な**ドメインモデル**（集約・エンティティ・不変条件・関係）を記述します。
用語は [glossary.md](../../glossary.md) と一致させ、機能個別のデータ構造は各機能の `specs/<feature>/data-model.md` を正本とします。

> **二重管理の回避**: 機能固有のデータモデルは specs 側が正本です。本ディレクトリは**機能横断で共有する**概念モデルのみを扱います（SSoT）。

## 記述の目安

- 集約境界とトランザクション整合性の単位。
- 不変条件・ビジネスルールの根拠は [knowledge/business-rules/](../../knowledge/business-rules/) と相互参照。
- スキーマ等のコード生成物は生成元を正本とし手編集しない（憲章「SSoT」）。
