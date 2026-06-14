# データモデル: ユーザプロフィールのエクスポート

> Phase 1 設計成果物（plan.md）。エクスポート対象項目と機密区分を定義する。

## エクスポート対象項目

| 項目 | 型 | 機密区分 | CSV 含む | 備考 |
| --- | --- | --- | --- | --- |
| user_id | string | Internal | yes | 内部ID（外部公開IDがあればそちらを使用） |
| display_name | string | Confidential | yes | |
| email | string | **Restricted（PII）** | yes | 本人のみ |
| locale | string | Internal | yes | |
| created_at | datetime | Internal | yes | |
| avatar_url | string | Confidential | no | JSON のみ |

## エクスポート要求（監査用・FR-4）

| 項目 | 型 | 用途 |
| --- | --- | --- |
| requested_by | string(user_id) | 要求者（＝対象者と一致すること。FR-3） |
| requested_at | datetime | 監査 |
| format | enum(json, csv) | 要求形式 |

## 不変条件

- `requested_by` は認証済み主体と一致し、返却データの所有者と一致しなければならない（FR-3／Class A 認可）。
- 本モデルにPII（Restricted）が含まれるため、本番データを AI／外部 AI に入力しない（standards/security-standards.md「2.」）。
