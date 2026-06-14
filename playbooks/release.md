# Playbook: リリース（本番反映）

* 上位規範: constitution.md（「6.」承認マトリクス／「7.」緊急時例外）／ development-process.md「7.」
* 変更クラス: 本 Playbook 文書は Class C。**リリース行為そのものは Class A**（本番反映・人間承認必須）。

> 雛形です。採用組織が自スタック・環境に合わせて具体化してください。

## 前提

- 対象変更が完了条件（constitution.md「9.」）を満たし、CI が緑である。
- リリース承認者が指名されている（development-process.md「5.」）。

## 手順

1. リリース範囲・バージョン・変更履歴（Keep a Changelog 準拠）を確定する。
2. 保護対象ブランチ（`main` / `release/*`）で必須ステータスチェックの通過を確認する。
3. リリース承認（人間）を取得する。AI は単独でリリースしない（MUST NOT）。
4. デプロイを実行し、可観測性（standards/observability-standards.md）で健全性を確認する。
5. リリースタグ・成果物（必要に応じ SBOM）を記録する（standards/security-standards.md「6.」）。

## 確認

- [ ] SLO/エラーバジェット（standards/performance-standards.md）が悪化していない
- [ ] セキュリティゲート（secret/dependency スキャン）通過
- [ ] 監査証跡（承認者・日時・対象）が残っている

## ロールバック

- 異常時は直前の安定版へロールバックする（変更は可逆に設計：constitution.md「変更の可逆性」）。
- 緊急対応で事前検証を事後検証へ切り替えた場合（Break-glass）、72 時間以内に事後レビューを完了する（constitution.md「7.」、development-process.md「7.」）。
