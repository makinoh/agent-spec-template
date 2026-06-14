---
feature_id: "002-account-deletion"
title: "アカウントの削除（忘れられる権利）"
status: tasks-ready           # draft | constitution-checked | designed | tasks-ready
created: 2026-04-01
last_updated: 2026-04-01
change_class: "B"             # 公開API追加。ハード削除・認可タスクは A
related_adrs: [ADR-0002]
---

# 実装計画（Plan）: アカウントの削除（忘れられる権利）

> 本書は「どう作るか（How）」の正本。要求は spec.md、削除戦略の根拠は ADR-0002。

## 0. 技術コンテキスト

- 対象 spec: [spec.md](spec.md)
- 言語/ランタイム: [プロジェクトのスタックに合わせる]
- データストア: 既存のユーザストア（ソフト削除フラグ＋スケジュールジョブ）
- 変更クラス（確定）: **B**（公開API `DELETE /v1/users/me` 追加）。**ハード削除の実行と認可判定は A**（不可逆操作・認可）。
- 公開インターフェース変更: あり（新規エンドポイント）

## 1. Constitution Check（Phase 0 前）

> 正本: [.specify/memory/constitution.md](../../.specify/memory/constitution.md)

| 原則 | Gate | 判定 | 備考 |
| --- | --- | --- | --- |
| I 仕様ファースト | spec が存在し整合 | ✅ | spec.md（planned） |
| II ADRファースト | Class A/B なら ADR 参照/不要理由 | ✅ | **ADR-0002（削除戦略）を起票** |
| III SSoT & DaC | 生成物の手編集・新規二重管理なし | ✅ | API は contracts/ の OpenAPI を正本に |
| IV 既定で安全 | 機密区分・AI入力境界に照合 | ✅ | PII=Restricted。自己データのみ。本番 PII を AI に入力しない |
| V 変更分類と承認 | クラス確定・承認経路の特定 | ✅ | B＝アーキレビュー。ハード削除・認可は A＝CODEOWNERS |
| VI AI自律とHITL | 停止必須点なし・作成者≠承認者 | ✅ | 不可逆操作の実行は人間承認 |
| VII 機械検証ゲート | 必須ゲート通過見込み | ✅ | build/test/coverage/secret/dep |
| VIII 監査・可逆性 | 監査証跡・ロールバック設計 | ✅ | 猶予期間で可逆。各事象を監査ログ化 |

**ADR トリガ判定**: Class B（公開API）＋不可逆操作（Class A）を含むため、削除戦略を **ADR-0002** に起票した（[../../adr/adr-0002-deletion-strategy.md](../../adr/adr-0002-deletion-strategy.md)）。

## 2. プロジェクト構成（変更/追加）

```text
src/
├─ api/account-deletion.controller.*   # 新規: エンドポイント（Class B）
├─ services/account-deletion.service.* # 新規: ソフト削除・取消・スケジュール（Class C）
├─ jobs/hard-delete.job.*              # 新規: 猶予期間後のハード削除（Class A 不可逆）
└─ authz/self-access.guard.*           # 既存/改修: 自己データのみ（Class A）
tests/account-deletion/               # 新規: 契約・単体・認可・猶予期間テスト
```

## 3. Phase 0 — 調査

- 削除戦略の比較は ADR-0002 に統合。ドメイン知識は [../../knowledge/domain/account-data.md](../../knowledge/domain/account-data.md) を参照。

## 4. Phase 1 — 設計

- データモデル → [data-model.md](data-model.md)
- 契約（API） → contracts/（OpenAPI。本サンプルでは契約テストで代替）

> 設計後の Constitution Check 再実施: 変更なし（全 Gate 充足）。

## 5. テスト戦略（DoD 連動）

- 契約テスト、単体（ソフト削除・取消）、認可（FR-2）、時間経過（猶予期間→ハード削除）テスト。
- カバレッジは standards/testing-standards.md の最低基準に従う。合成 PII データのみ使用。

## 6. Complexity Tracking（Constitution 違反の正当化）

> 違反なし（記入不要）。

| 違反した原則/Gate | なぜ必要か | より単純な代替案を却下した理由 |
| --- | --- | --- |
| （なし） | | |
