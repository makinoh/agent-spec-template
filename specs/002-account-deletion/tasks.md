---
feature_id: "002-account-deletion"
title: "アカウントの削除（忘れられる権利）"
status: ready                 # draft | ready | in-progress | done
created: 2026-04-01
last_updated: 2026-04-01
change_class: "B"             # 機能全体は B。タスク単位で A/B/C/D を付す
---

# タスク（Tasks）: アカウントの削除（忘れられる権利）

> plan.md を実行可能タスクへ分解。TDD（テスト先行）。各タスクに対象パスと変更クラスを付す。
> Class A/B タスクは保護対象ブランチ反映前に人間承認が必要（constitution.md「6.」）。

## セットアップ

- [ ] **T001** モジュール雛形と DI 配線（対象: `src/api/`, `src/services/`／**Class C**）

## テスト（実装より前）

- [ ] **T010** [P] 契約テスト: `DELETE /v1/users/me`（対象: `tests/account-deletion/contract.*`／**Class C**）
- [ ] **T011** [P] 単体（失敗）: FR-1 ソフト削除（対象: `tests/account-deletion/soft.*`／**Class C**）
- [ ] **T012** [P] 単体（失敗）: FR-3 猶予期間内の取消（対象: `tests/account-deletion/cancel.*`／**Class C**）
- [ ] **T013** [P] 認可（失敗）: FR-2 他ユーザを削除不可（対象: `tests/account-deletion/authz.*`／**Class C**）

## 実装

- [ ] **T020** 公開エンドポイント `DELETE /v1/users/me`（対象: `src/api/account-deletion.controller.*`／**Class B** → ADR-0002・アーキレビュー）
- [ ] **T021** ソフト削除・取消サービス（対象: `src/services/account-deletion.service.*`／**Class C**／依存: T011, T012）
- [ ] **T022** 認可ガード: 自己データのみ（FR-2）（対象: `src/authz/self-access.guard.*`／**Class A**（認可）→ CODEOWNERS／依存: T013）
- [ ] **T023** ハード削除ジョブ（猶予期間後・不可逆）（対象: `src/jobs/hard-delete.job.*`／**Class A**（不可逆操作）→ 人間承認・実行権限分離）

## 統合・観測性・ドキュメント

- [ ] **T030** 削除/取消/purge の監査ログ（FR-5）（対象: `src/services/account-deletion.service.*`／**Class C**／standards/observability-standards.md）
- [ ] **T031** [P] spec/plan の状態更新と knowledge/domain 追記（対象: `specs/002-*`, `knowledge/domain/`／**Class D**）

## 完了条件（DoD — 正本: constitution.md「9.」/「8.」）

- [ ] ビルド・型・自動テスト・カバレッジ合格（verify ジョブ＝`task verify`）
- [ ] シークレットスキャン・依存脆弱性スキャン合格
- [ ] Class A/B（T020・T022・T023）の PR に ADR-0002 参照を記載し人間承認（CODEOWNERS）取得
- [ ] 合成 PII データのみでテスト（本番 PII を AI/外部AIに入力しない）
- [ ] 不可逆操作（T023）の実行権限分離と監査証跡を確認
