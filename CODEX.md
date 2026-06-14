# CODEX.md — Codex 固有の指示（薄い委譲層）

本ファイルは、AIエージェント実行指示の正本である [AGENTS.md](AGENTS.md) への薄い委譲層です。
**規範の本体は AGENTS.md と constitution.md にあり、本ファイルは Codex 固有の差分のみを記載します。**
矛盾する場合は AGENTS.md → constitution.md が優先します。

## まず AGENTS.md を読み込む

本プロジェクトの実行指示は [AGENTS.md](AGENTS.md) を参照してください。そこから憲章・標準・ADR へ辿れます。

> Codex は `AGENTS.md` を直接参照する設計です。本ファイルは名簿（[agents/README.md](agents/README.md)）との整合と、
> 憲章（constitution.md）への到達経路の保証のために置きます（constitution.md「6. エージェント指示ファイルの統治」）。

## Codex 固有の運用メモ

- ゲート判定には簡潔ビュー [.specify/memory/constitution.md](.specify/memory/constitution.md) を用い、詳細が必要な箇所のみ本体を参照してください。
- 変更着手前に Class A/B/C/D を判定してください（不明なら Class A）。正本は [development-process.md](development-process.md)。
- 統治・強制機構（constitution / governance / standards / .github / AGENTS.md / 各エージェント指示ファイル / agents/ / Taskfile.yml / scripts/）に触れる変更は、その旨を PR で開示してください（権限影響ラベル）。
- 品質ゲートは `task verify`（コミット前は `task verify:fast`）。起案・反映の前に実行し緑を確認する（正本は AGENTS.md「7.」／Taskfile.yml）。
- 専用マシンアカウントで行為し、人間の認証情報を用いないでください（MUST NOT。[agents/README.md](agents/README.md)）。
- 本ファイル（CODEX.md）自体の変更は Class A です。単独で反映しないでください。
