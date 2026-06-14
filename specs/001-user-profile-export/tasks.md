---
feature_id: "001-user-profile-export"
title: "ユーザプロフィールのエクスポート"
status: ready                 # draft | ready | in-progress | done
created: 2026-04-01
last_updated: 2026-04-01
change_class: "B"             # 機能全体は B。タスク単位で A/B/C/D を付す
---

# タスク（Tasks）: ユーザプロフィールのエクスポート

> `plan.md` を実行可能タスクへ分解。TDD（テスト先行）。各タスクに対象パスと変更クラスを付す。
> `[P]` は並行可。**Class A/B タスクは保護対象ブランチ反映前に人間承認が必要**（constitution.md「6.」）。

## セットアップ

- [ ] **T001** エクスポート機能のモジュール雛形と DI 配線（対象: `src/api/`, `src/services/`／**Class C**）

## テスト（実装より前）

- [ ] **T010** [P] 契約テスト: `GET /v1/users/me/profile/export` が OpenAPI に準拠（対象: `tests/profile-export/contract.*`／**Class C**／契約: contracts/export-api.yaml）
- [ ] **T011** [P] 単体テスト（失敗）: FR-1 JSON 出力（対象: `tests/profile-export/json.*`／**Class C**）
- [ ] **T012** [P] 単体テスト（失敗）: FR-2 CSV 出力（RFC 4180）（対象: `tests/profile-export/csv.*`／**Class C**）
- [ ] **T013** [P] 認可テスト（失敗）: FR-3 他ユーザのデータを取得できない（対象: `tests/profile-export/authz.*`／**Class C**）

## 実装

- [ ] **T020** 公開エンドポイント追加 `GET /v1/users/me/profile/export?format=json|csv`（対象: `src/api/profile-export.controller.*`／**Class B** → ADR-0001 準拠・アーキテクトレビュー）
- [ ] **T021** [P] JSON シリアライザ（対象: `src/services/serializers/json.*`／**Class C**／依存: T011）
- [ ] **T022** [P] CSV シリアライザ（対象: `src/services/serializers/csv.*`／**Class C**／依存: T012）
- [ ] **T023** 認可ガード: 自己データのみ（FR-3）（対象: `src/authz/self-access.guard.*`／**Class A**（認可）→ CODEOWNERS 承認・シークレット/権限レビュー／依存: T013）
- [ ] **T024** 不正 `format` で 400（FR-5）（対象: `src/api/profile-export.controller.*`／**Class C**）

## 統合・観測性・ドキュメント

- [ ] **T030** エクスポート要求の監査ログ（FR-4）（対象: `src/services/profile-export.service.*`／**Class C**／standards/observability-standards.md）
- [ ] **T031** [P] spec/plan のステータス更新と README 追記（対象: `specs/001-*`, `README.md`／**Class D**）

## 完了条件（DoD — 正本: constitution.md「9.」/「8.」）

- [ ] ビルド・型・自動テスト・カバレッジ合格（verify ジョブ＝`task verify`）
- [ ] シークレットスキャン・依存脆弱性スキャン合格
- [ ] Class A/B（T020・T023）の PR に ADR-0001 参照を記載し、人間承認（CODEOWNERS/アーキテクト）を取得
- [ ] 合成 PII データのみでテスト（本番 PII を AI/外部AIに入力しない）
- [ ] 監査証跡（作成者・承認者・根拠）が追跡可能
