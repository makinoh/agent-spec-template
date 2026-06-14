# データモデル: アカウントの削除

> Phase 1 設計成果物（plan.md）。削除単位・状態・保持を定義する。ドメイン知識は knowledge/domain/account-data.md。

## 削除対象と状態

| 項目 | 型 | 機密区分 | 削除時の扱い |
| --- | --- | --- | --- |
| user_id | string | Internal | ハード削除で物理消去（監査用ハッシュは別途保持し得る） |
| email | string | **Restricted（PII）** | ソフト削除でマスク、ハード削除で消去 |
| display_name | string | Confidential | 同上 |
| profile_* | - | 各区分 | feature 001 の data-model に準拠 |

## 削除要求（監査用・FR-5）

| 項目 | 型 | 用途 |
| --- | --- | --- |
| requested_by | string(user_id) | 要求者（＝対象者と一致すること。FR-2） |
| requested_at | datetime | 監査・猶予期間の起点 |
| state | enum(scheduled, cancelled, purged) | 削除状態 |
| purge_after | datetime | ハード削除予定（既定 requested_at + 30 日） |

## 不変条件

- `requested_by` は認証済み主体かつ対象の所有者と一致しなければならない（FR-2／Class A 認可）。
- ハード削除（`state = purged`）は不可逆（Class A）。実行前に猶予期間の満了を確認する。
- 法的保持対象は purge から除外し、別途の保持期間に従う（FR-6）。
- 本モデルに PII（Restricted）が含まれるため、本番データを AI／外部 AI に入力しない（standards/security-standards.md「2.」）。
