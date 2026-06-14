# 可観測性標準（Observability Standards）

* Version: 0.1.0（Proposed / ドラフト）
* Date: 2026-04-01
* 上位規範: constitution.md（開発憲章「Observability by Default」）

本書は、憲章「Observability by Default」が委譲する詳細基準の正本（SSoT）です。憲章と矛盾する場合は憲章が優先します（MUST）。

---

## 1. 三本柱（ログ・メトリクス・トレース）

* 本番運用される機能は、ログ・メトリクス・トレースにより観測可能であるべきです（SHOULD）。
* ログは構造化（JSON 等）し、リクエストに相関 ID（`trace_id`）を付与するべきです（SHOULD）。
* ログ・メトリクス・トレースに PII・秘密情報を出力してはなりません（MUST NOT。security-standards.md「2.」「3.」）。
* メトリクスは RED（Rate / Errors / Duration）を基本とし、分散トレースは OpenTelemetry を推奨します（SHOULD）。

---

## 2. SLI / SLO

* 観測対象の SLI と目標値（SLO）は performance-standards.md と整合させるべきです（SHOULD）。
* 監査証跡（誰が・いつ・何を）に関わるログは、改ざん困難な形で保持するべきです（SHOULD。憲章「監査証跡」）。

---

## 3. 改正履歴

（初版ドラフトのため履歴なし）
