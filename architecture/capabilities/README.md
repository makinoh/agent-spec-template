# architecture/capabilities/ — ケイパビリティ・マップ

* 上位規範: [constitution.md](../../constitution.md)／ [architecture/README.md](../README.md)（Architecture Repository）
* 変更クラス: **B**（アーキテクチャ。原則 ADR 化）

ビジネス／技術**ケイパビリティ**（「組織が何を**できる**か」）を構造化し、
スコープ（[scope.md](../../scope.md)）・機能（[specs/](../../specs/)）・ドメインモデル（[../domain-models/](../domain-models/)）と対応づけます。

> ケイパビリティは「機能（feature）」より粗い**安定した能力単位**です。TOGAF のケイパビリティ・ベース計画に対応します。

## 記述の目安（採用組織が記入）

- L1/L2 ケイパビリティ階層（例: 「ユーザ管理 > 認証 / プロフィール / データ移植」）。
- 各ケイパビリティ → 関連 spec・所有チーム（Team Topologies）・成熟度。
- ケイパビリティ × スコープ（In/Out）の対応で、過不足を検出します。
