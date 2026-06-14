# architecture/integrations/ — 連携・インターフェース・カタログ

* 上位規範: [constitution.md](../../constitution.md)「アーキテクチャの完全性」／ [standards/api-standards.md](../../standards/api-standards.md)
* 変更クラス: **B**（アーキテクチャ。公開インターフェースに関わる場合は ADR 化）

外部システム・サービスとの**連携点（インテグレーション）**を一覧化します。
公開 API 契約は機能ごとの `specs/<feature>/contracts/`、連携先仕様メモは `knowledge/integrations/`（採用時に作成）を正本とし、本ディレクトリは**全体像と境界**を担います。

## 記述の目安

- 連携先 × 方向（in/out）× プロトコル × 認証 × 機密区分（[standards/security-standards.md](../../standards/security-standards.md)「1.」）。
- 外部依存はアダプタで隔離し置換可能にする（[architecture/principles.md](../principles.md) 原則4）。
- 外部サービスへのデータ送信は AI 入力境界に照合する（MUST。security-standards「2.」）。
