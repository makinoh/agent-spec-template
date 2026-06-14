---
feature_id: "001-user-profile-export"
title: "ユーザプロフィールのエクスポート"
status: tasks-ready            # draft | constitution-checked | designed | tasks-ready
created: 2026-04-01
last_updated: 2026-04-01
change_class: "B"              # 公開API追加を含む。認可実装タスクは A（tasks.md 参照）
related_adrs: [ADR-0001]
---

# 実装計画（Plan）: ユーザプロフィールのエクスポート

> 本書は「どう作るか（How）」の正本。要求は spec.md、形式選定の根拠は ADR-0001。

## 0. 技術コンテキスト

- 対象 spec: [spec.md](spec.md)
- 言語/ランタイム: [プロジェクトのスタックに合わせる。例: TypeScript / Node.js]
- データストア: 既存のユーザストア（読み取りのみ）
- 変更クラス（確定）: **B**（`GET /v1/users/me/profile/export` の公開API追加）。認可判定の実装は **A**（認可は Class A）。
- 公開インターフェース変更: あり（新規エンドポイント）→ contracts/ に契約を定義

## 1. Constitution Check（Phase 0 前）

> 正本: [.specify/memory/constitution.md](../../.specify/memory/constitution.md)

| 原則 | Gate | 判定 | 備考 |
| --- | --- | --- | --- |
| I 仕様ファースト | spec が存在し整合 | ✅ | spec.md（planned） |
| II ADRファースト | Class A/B なら ADR 参照/不要理由 | ✅ | **ADR-0001（提供形式の選定）を起票** |
| III SSoT & DaC | 生成物の手編集・新規二重管理なし | ✅ | API は contracts/export-api.yaml（OpenAPI）を正本に |
| IV 既定で安全 | 機密区分・AI入力境界に照合 | ✅ | PII=Restricted。自己データのみ。本番 PII を AI に入力しない |
| V 変更分類と承認 | クラス確定・承認経路の特定 | ✅ | B＝アーキテクトレビュー。認可タスクは A＝CODEOWNERS |
| VI AI自律とHITL | 停止必須点なし・作成者≠承認者 | ✅ | 停止必須に該当せず。マージは人間承認 |
| VII 機械検証ゲート | 必須ゲート通過見込み | ✅ | build/test/coverage/secret/dep を verify ジョブ（`task verify`）で |
| VIII 監査・可逆性 | 監査証跡・ロールバック設計 | ✅ | エクスポート要求を監査ログ化。読み取り専用で可逆 |

**ADR トリガ判定**: 本計画は Class B（公開API）を含むため、提供形式の決定を **ADR-0001** に起票した（adr/adr-0001-export-format-selection.md）。`related_adrs` に反映済み。

## 2. プロジェクト構成（変更/追加）

```text
src/
├─ api/profile-export.controller.*   # 新規: エンドポイント（Class B）
├─ services/profile-export.service.* # 新規: JSON/CSV シリアライズ（Class C）
├─ services/serializers/{json,csv}.* # 新規（Class C）
└─ authz/self-access.guard.*         # 新規/改修: 自己データのみ（Class A）
tests/profile-export/                # 新規: 契約・単体・認可テスト
specs/001-user-profile-export/contracts/export-api.yaml  # 公開API契約（正本）
```

## 3. Phase 0 — 調査（research.md）

- 形式選定の調査は ADR-0001 に統合（JSON/CSV のエコシステム・要件適合）。本機能に追加調査なし。

## 4. Phase 1 — 設計

- データモデル → [data-model.md](data-model.md)
- 契約（API） → [contracts/export-api.yaml](contracts/export-api.yaml)
- 動作確認手順 → quickstart は本機能では省略（契約テストで代替）

> 設計後の Constitution Check 再実施: 変更なし（上表のとおり全 Gate 充足）。

## 5. テスト戦略（DoD 連動）

- 契約テスト（OpenAPI 準拠）、単体（JSON/CSV シリアライズ）、認可テスト（FR-3：他人データ不可）。
- カバレッジは standards/testing-standards.md の最低基準に従う。合成 PII データのみ使用。

## 6. Complexity Tracking（Constitution 違反の正当化）

> 違反なし（記入不要）。

| 違反した原則/Gate | なぜ必要か | より単純な代替案を却下した理由 |
| --- | --- | --- |
| （なし） | | |
