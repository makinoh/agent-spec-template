# API標準（API Standards）

* Version: 0.2.0（Proposed / ドラフト）
* Date: 2026-07-05
* 上位規範: constitution.md（開発憲章「アーキテクチャの完全性」「SSoT」）

本書は、公開API／公開インターフェースの識別基準（変更クラス・自律境界の判定に用いる）の正本の一つです（architecture/* と併用。憲章「12. 補足事項」）。憲章と矛盾する場合は憲章が優先します（MUST）。

---

## 1. 公開インターフェースの識別（Class B 判定の基準）

* 外部に公開するエンドポイント・スキーマ・イベント・ライブラリの公開シンボルを「公開インターフェース」とします。
* 公開インターフェースの破壊的変更および後方互換な追加は、いずれも Class B とします（development-process.md「1.」）。識別が曖昧な場合は Class B 側に倒します。

---

## 2. 設計規約

* 契約は OpenAPI／AsyncAPI 等を正本とし、生成物（クライアント／サーバ雛形）を手編集してはなりません（MUST NOT。憲章「SSoT」）。
* バージョニングは URI（`/v1`）またはヘッダで表現し、後方互換を既定とします。破壊的変更は ADR 化します（SHOULD）。
* エラー表現・ページング・冪等性・廃止手順の規約は「3. 準拠標準（外部 RFC）」に従い統一します。

---

## 3. 準拠標準（外部 RFC）

公開 HTTP API の契約・実装は、以下の RFC への準拠を既定とします。準拠しない場合は、spec の非機能要求または ADR で逸脱理由を明記しなければなりません（MUST）。曖昧さの余地を仕様側で消すことが目的であり、独自規約の再発明を禁じます（SSoT）。

| 領域 | 準拠標準 | 要求 |
| --- | --- | --- |
| HTTP 意味論 | RFC 9110（HTTP Semantics）／ RFC 9111（HTTP Caching） | メソッドの安全性・冪等性・ステータスコード・キャッシュの意味は RFC 9110/9111 の定義に従う（MUST）。旧 RFC 7231 系を新規参照しない（SHOULD NOT） |
| エラー表現 | RFC 9457（Problem Details for HTTP APIs。RFC 7807 の後継） | 機械可読エラーは `application/problem+json` で統一する（MUST）。`type` は安定した文書化済み URI とし、フィールド追加は拡張メンバで行う（SHOULD） |
| 日時 | RFC 3339 | API 境界の日時は RFC 3339 形式（原則 UTC、オフセット明示）とする（MUST。coding-standards.md「3.」） |
| JSON | RFC 8259 ＋ RFC 7493（I-JSON） | 交換用 JSON は I-JSON 制約（UTF-8・重複メンバ禁止・IEEE 754 倍精度で安全な数値）を満たす（SHOULD）。64bit 整数等は文字列で運ぶ（SHOULD） |
| 部分更新 | RFC 6902（JSON Patch）／ RFC 7396（JSON Merge Patch） | `PATCH` を提供する場合、どちらの意味論かを契約（OpenAPI）に明記する（MUST） |
| ページング・関連リンク | RFC 8288（Web Linking） | コレクションのページングは `Link` ヘッダ（`rel="next"` 等）または契約に明記した同等規約で統一する（SHOULD） |
| 廃止ライフサイクル | RFC 9745（Deprecation ヘッダ）／ RFC 8594（Sunset ヘッダ） | 公開インターフェースの廃止・破壊的変更（Class B。ADR 必須）は、Deprecation / Sunset ヘッダで機械可読に事前告知する（SHOULD） |
| 識別子 | RFC 9562（UUID。RFC 4122 の後継） | リソース ID に UUID を用いる場合の版選定・表記は coding-standards.md「3.」に従う |

* 参考文献: RFC 9110 https://www.rfc-editor.org/rfc/rfc9110 ／ RFC 9457 https://www.rfc-editor.org/rfc/rfc9457 ／ RFC 3339 https://www.rfc-editor.org/rfc/rfc3339 ／ RFC 7493 https://www.rfc-editor.org/rfc/rfc7493 ／ RFC 8288 https://www.rfc-editor.org/rfc/rfc8288 ／ RFC 9745 https://www.rfc-editor.org/rfc/rfc9745 ／ RFC 8594 https://www.rfc-editor.org/rfc/rfc8594

> **冪等性キー**: `Idempotency-Key` ヘッダは IETF ドラフト（draft-ietf-httpapi-idempotency-key-header）段階であり、本書は準拠を義務付けません。採用する場合はドラフト版数と挙動を契約に明記します（MAY）。RFC 化された時点で本書を改正します。

---

## 4. 改正履歴

* 0.2.0（2026-07-05）: 「3. 準拠標準（外部 RFC）」を新設（HTTP 意味論・Problem Details・日時・I-JSON・PATCH・ページング・廃止ライフサイクル）。
* 0.1.0（2026-04-01）: 初版ドラフト。
