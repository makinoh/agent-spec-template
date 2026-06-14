# ドメイン知識: アカウント／プロフィールデータ

> サンプル（テンプレートの実演用）。採用時は実プロジェクトのドメインに置換する。
> 正本リンク: 物理定義は [specs/001 data-model](../../specs/001-user-profile-export/data-model.md)、機密区分は [security-standards.md](../../standards/security-standards.md)「1.」。
> 最終確認日: 2026-04-01

本書は、利用者アカウント／プロフィールに関するドメイン知識（エンティティ・機密区分・規制マッピング・保存方針）を集約する。spec・ADR は本書を参照し、知識を各文書へ焼き込まない（憲章「SSoT」・原則 IX）。

## エンティティと機密区分

| 項目 | 機密区分 | 備考 |
| --- | --- | --- |
| user_id | Internal | 内部ID（外部公開IDがあればそちらを使用） |
| display_name | Confidential | |
| email | Restricted（PII） | 本人のみ |
| locale / created_at | Internal | |
| avatar_url | Confidential | |

> 本番の Confidential / Restricted を AI／外部 AI に入力してはならない（MUST NOT。security-standards.md「2.」）。

## 規制マッピング（GDPR）

| 権利 | 条文 | 対応機能 |
| --- | --- | --- |
| データポータビリティ | Art.20 | feature 001（エクスポート） |
| 消去権（忘れられる権利） | Art.17 | feature 002（アカウント削除） |
| アクセス権 | Art.15 | （将来の機能） |

## 保存・削除方針

- PII（Restricted）の保存は、利用目的の範囲・期間に限定する（security-standards.md「4.」）。
- 削除はハード削除が不可逆操作（Class A）。可逆性確保のため猶予期間（ソフト削除）を設ける（[ADR-0002](../../adr/adr-0002-deletion-strategy.md)）。
- 法的保持義務（legal hold）のある項目は、猶予期間後も定義された期間保持し得る。

## 関連

- 機能: [specs/001 エクスポート](../../specs/001-user-profile-export/spec.md)／[specs/002 削除](../../specs/002-account-deletion/spec.md)
- 決定: [ADR-0001 形式選定](../../adr/adr-0001-export-format-selection.md)／[ADR-0002 削除戦略](../../adr/adr-0002-deletion-strategy.md)
