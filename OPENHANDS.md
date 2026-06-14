# OPENHANDS.md — OpenHands 固有の指示（薄い委譲層）

本ファイルは、AIエージェント実行指示の正本である [AGENTS.md](AGENTS.md) への薄い委譲層です。
**規範の本体は AGENTS.md と constitution.md にあり、本ファイルは OpenHands 固有の差分のみを記載します。**
矛盾する場合は AGENTS.md → constitution.md が優先します。

## まず AGENTS.md を読み込む

本プロジェクトの実行指示は [AGENTS.md](AGENTS.md) を参照してください。そこから憲章・標準・ADR へ辿れます。

> OpenHands はリポジトリのエージェント指示（`AGENTS.md` 等）を参照します。本ファイルおよび本ファイルからの参照により、
> 憲章（constitution.md）への到達経路を保証します（constitution.md「6. エージェント指示ファイルの統治」）。

## OpenHands 固有の運用メモ

- 自律実行型エージェントとして、複数ステップを継続実行しうる点に留意してください。**保護対象ブランチへの反映は人間承認が必須**です（Class 別。憲章「6.」）。起案・準備（作業ブランチ・ドラフト PR）は自律可。
- ゲート判定は簡潔ビュー [.specify/memory/constitution.md](.specify/memory/constitution.md)。変更クラスの正本は [development-process.md](development-process.md)（不明なら Class A）。
- 破壊的操作・外部送信・本番接続は承認対象です（[standards/ai-governance.md](standards/ai-governance.md)「6. ツール／MCP 実行境界」）。本番の個人データ・機密へ到達しうる権限を用いてはなりません（MUST NOT）。
- 停止必須チェックポイント（憲章「6.」）に該当したら自律実行を止め、人間に諮ってください（MUST）。
- 品質ゲートは `task verify`（コミット前は `task verify:fast`）。専用マシンアカウントで行為する（MUST）。
- 本ファイル（OPENHANDS.md）自体の変更は Class A です。単独で反映しないでください。
