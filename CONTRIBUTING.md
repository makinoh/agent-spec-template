# コントリビューションガイド

本テンプレートへの貢献を歓迎します。本プロジェクトは **AI エージェントと人間が共同で開発する**ことを前提に、ルール（憲章）・変更分類・品質ゲートで安全性と追跡可能性を担保しています。

## はじめに読むもの

- [AGENTS.md](AGENTS.md) — エージェント実行指示の入口
- [development-process.md](development-process.md) — 変更クラス（A/B/C/D）・承認・開発フロー
- [constitution.md](constitution.md) — 最上位ルール（簡潔版: [.specify/memory/constitution.md](.specify/memory/constitution.md)）

## 変更の進め方

1. Issue で目的を共有する（推奨）。
2. ブランチを切る（`main` への直接 push は不可）。
3. 機能は spec-kit フローで進める: `/speckit.specify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.implement`。
4. 変更クラス（A/B/C/D）を判定する（不明なら Class A）。Class A/B は ADR 参照または「ADR不要理由」を PR に記載する。
5. PR を作成する（[プルリクエストテンプレート](.github/pull_request_template.md) に従う）。

## レビューとマージ

- すべての変更は PR ＋ レビュー承認（作成者≠承認者）を経てマージします。
- 品質ゲート（Markdown Lint / Link Check / シークレット / 依存脆弱性 / build・test）に合格する必要があります。
- 統治・強制機構（constitution / standards / .github / エージェント指示ファイル）への変更は **Class A** です。

## ローカル検証

- Markdown: `markdownlint-cli2 "**/*.md"`
- ADR 索引: `python scripts/generate_adr_index.py --check`

## その他

- セキュリティ上の問題は [SECURITY.md](SECURITY.md) に従って報告してください（公開 Issue にしない）。
- テンプレートを採用する側の初期設定は [ADOPTION.md](ADOPTION.md) を参照してください。
