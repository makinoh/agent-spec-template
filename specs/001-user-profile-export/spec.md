---
feature_id: "001-user-profile-export"
title: "ユーザプロフィールのエクスポート"
status: planned                # draft | clarified | planned | implemented | superseded
created: 2026-04-01
last_updated: 2026-04-01
scope: project
change_class_hint: "B"         # 公開API追加を含むため B（最終判定は development-process.md「1.」）
related_adrs: [ADR-0001]
---

# 仕様（Specification）: ユーザプロフィールのエクスポート

> 本書は「何を・なぜ（What/Why）」の正本。実装方法（How）は plan.md、判断根拠は ADR-0001。

## 1. 概要 / 問題

- 背景・課題: 利用者が自分のプロフィールデータを自身で取得・持ち出す手段がなく、データポータビリティ要求（GDPR 第20条等）に応えられない。
- ゴール: 認証済み利用者が、**自分自身の**プロフィールデータを機械可読形式でエクスポートできる。
- 非ゴール: 他ユーザのデータ取得／管理者による一括エクスポート／アカウント削除（別機能）。

## 2. ユーザシナリオ

- **US-1**: 登録利用者として、自分のプロフィールを JSON で出力できる。
  - Given ログイン済み / When エクスポートを JSON 指定で要求 / Then 自分のプロフィールが JSON で返る。
- **US-2**: 登録利用者として、表計算で扱うため CSV で出力できる。
  - Given ログイン済み / When CSV 指定で要求 / Then 主要項目が CSV で返る。
- **US-3**: 利用者として、**他人のデータは取得できない**。
  - Given 利用者 A / When 任意の操作 / Then 返るのは A 自身のデータのみ。

## 3. 機能要求（Functional Requirements）

- **FR-1**: システムは、認証済み利用者の要求に対し、当該利用者のプロフィールを JSON で返さなければならない（MUST）。
- **FR-2**: システムは、`format=csv` 指定時、主要項目を CSV（UTF-8, RFC 4180）で返さなければならない（MUST）。
- **FR-3**: システムは、要求者**自身**のデータのみを返し、他ユーザのデータを返してはならない（MUST NOT）。
- **FR-4**: システムは、エクスポート要求（要求者・日時・形式）を監査ログに記録するべきである（SHOULD）。
- **FR-5**: システムは、対応しない `format` 値に対し 400 を返さなければならない（MUST）。

## 4. 非機能要求・制約（NFR / Constraints）

- **データ機密区分**: プロフィールは個人データ（PII）= **Restricted**（standards/security-standards.md「1.」）。
  - 本番 PII を AI／外部 AI に入力してはならない（MUST NOT）。開発・テストは合成データを用いる（SHOULD）。
- **認可**: 自己データのみ。認可判定は機能の中核（development-process.md「1.」で **Class A** 相当）。
- **性能**: 同期応答は 1 プロフィール想定で p95 < 1s（standards/performance-standards.md に従い確定）。
- **可逆性**: 読み取り専用機能であり、本番データを変更しない。

## 5. 主要エンティティ / データ

- 概念は data-model.md を参照。エクスポート対象項目と PII 区分は同ファイルの表で定義。

## 6. Constitution Alignment（自己点検）

- [x] What/Why に限定（How は plan.md）
- [x] 機密区分を特定（PII=Restricted）し AI 入力境界に照合（原則 IV）
- [x] 暫定クラス B を設定（公開API追加。認可部分は A。原則 V）
- [x] Class B の設計判断（提供形式）は ADR 化が必要と認識 → ADR-0001（原則 II）

## 7. レビュー・チェックリスト

- [x] `[NEEDS CLARIFICATION]` 解消済み
- [x] 各 FR がテスト可能で曖昧語なし
- [x] ユーザシナリオが受け入れ基準として機能
- [x] 非ゴールを明記

## 8. 未解決の問い

- なし（初版で解消）。非同期化（大規模データ時のジョブ化）は将来の別 spec で扱う。
