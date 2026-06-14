# TAKT.md — Takt 固有の指示（薄い委譲層）

本ファイルは、AIエージェント実行指示の正本である [AGENTS.md](AGENTS.md) への薄い委譲層です。
**規範の本体は AGENTS.md と constitution.md にあり、本ファイルは Takt 固有の差分のみを記載します。**
矛盾する場合は AGENTS.md → constitution.md が優先します。

## まず AGENTS.md を読み込む

本プロジェクトの実行指示は [AGENTS.md](AGENTS.md) を参照してください。そこから憲章・標準・ADR へ辿れます。

> 本ファイルおよび本ファイルからの参照により、利用エージェントによらず憲章（constitution.md）への
> 到達経路を保証します（constitution.md「6. エージェント指示ファイルの統治」）。

## Takt 固有の運用メモ

- ゲート判定には簡潔ビュー [.specify/memory/constitution.md](.specify/memory/constitution.md) を用い、詳細が必要な箇所のみ本体を参照してください。
- 変更着手前に Class A/B/C/D を判定してください（不明なら Class A）。正本は [development-process.md](development-process.md)。
- マルチエージェントでの作業分担・ハンドオフ・所有境界は [agents/README.md](agents/README.md) を参照してください。
- 統治・強制機構に触れる変更は権限影響ラベルを付与し、単独で反映しないでください（Class A）。
- 品質ゲートは `task verify`（コミット前は `task verify:fast`）。専用マシンアカウントで行為する（MUST）。
- 本ファイル（TAKT.md）自体の変更は Class A です。単独で反映しないでください。
