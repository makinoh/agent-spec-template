---
# ===== 機械可読メタデータ =====
feature_id: ""                # spec.md / plan.md と一致
title: ""
status: draft                 # draft | ready | in-progress | done
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
change_class: ""              # A | B | C | D（plan.md と一致）
---

# タスク（Tasks）: [機能名]

> **目的**: `plan.md` を実行可能な順序付きタスクへ分解する（`/speckit.tasks`）。
> 実装は `/speckit.implement` が本リストを上から実行する。`[P]` は並行実行可能なタスク。
> TDD を基本とし、**テストを実装より前**に置く。各タスクに変更クラスと承認要否を付す。

## 規約

- ID: `T001` から連番。
- `[P]`: 依存のない並行実行可能タスク（同一ファイルを編集するタスクは並行にしない）。
- 各タスクに **対象ファイルパス** と **変更クラス**（A/B/C/D）を明記する。
- Class A/B を含むタスクは、保護対象ブランチ反映前に人間承認が必要（constitution.md「6.」承認マトリクス）。

## セットアップ

- [ ] **T001** プロジェクト構成・依存の用意（対象: …／Class: C）
- [ ] **T002** [P] Lint/フォーマット/CI 雛形の用意（対象: …／Class: A ※統治・強制機構）

## テスト（実装より前）

- [ ] **T010** [P] FR-1 の失敗するテストを追加（対象: tests/…／Class: C）
- [ ] **T011** [P] FR-2 の失敗するテストを追加（対象: tests/…／Class: C）

## 実装

- [ ] **T020** FR-1 を満たす実装（対象: src/…／Class: C／依存: T010）
- [ ] **T021** 公開 API の変更（対象: src/…／**Class: B** → ADR 必要・人間承認）

## 統合・観測性・ドキュメント

- [ ] **T030** ログ/メトリクス/トレースの付与（standards/observability-standards.md／Class: C）
- [ ] **T031** [P] spec/plan/関連ドキュメントの更新（Class: D）

## 完了条件（Definition of Done — 各タスク/PR 共通）

> 正本: constitution.md「9. 完了条件」＋「8. 機械的に検証可能なルール」。

- [ ] ビルド・型チェック・自動テスト・カバレッジに合格
- [ ] シークレットスキャン・依存脆弱性スキャンに合格
- [ ] Class A/B を含む場合、ADR 参照または ADR 不要理由を PR に記載
- [ ] md lint / link check に合格（ドキュメント変更時）
- [ ] 監査証跡（作成者・承認者・根拠）が追跡可能
- [ ] 必要なレビュー・承認（承認マトリクス）が完了
