# CLAUDE.md — Claude Code 固有の指示（薄い委譲層）

本ファイルは、AIエージェント実行指示の正本である [AGENTS.md](AGENTS.md) への薄い委譲層です。
**規範の本体は AGENTS.md と constitution.md にあり、本ファイルは Claude 固有の差分のみを記載します。**
矛盾する場合は AGENTS.md → constitution.md が優先します。

## まず AGENTS.md を読み込む

@AGENTS.md

> Claude Code は `@パス` 記法で他ファイルを取り込みます。上記により、本プロジェクトの
> 実行指示（AGENTS.md）と、そこから辿る憲章・標準を必ず参照してください。

## Claude 固有の運用メモ

- 大規模な統治文書（[constitution.md](constitution.md)）を毎回全読みする必要はありません。
  ゲート判定には簡潔ビュー [.specify/memory/constitution.md](.specify/memory/constitution.md) を用い、
  詳細が必要な箇所のみ本体の該当章を参照してください。
- 変更着手前に、対象が Class A/B/C/D のいずれかを判定してください（不明なら Class A）。
  判定基準の正本は [development-process.md](development-process.md) です。
- 統治・強制機構（constitution / governance / standards / .github / AGENTS.md / 各エージェント指示ファイル（CLAUDE.md / GEMINI.md / CODEX.md / OPENHANDS.md / TAKT.md）/ agents/ / SKILLS.md）に
  触れる変更は、その旨を PR で開示してください（権限影響ラベル）。
- 再利用可能な手順は [SKILLS.md](SKILLS.md)（実体は `skills/`、Claude Code では `.claude/skills` も利用可）、
  知識・記憶・手順・プロンプトは [knowledge/](knowledge/) / [memory/](memory/) / [playbooks/](playbooks/) / [prompts/](prompts/) を参照し、
  指示文へ焼き込まないでください（SSoT・トークン効率）。作業記憶（申し送り・反省・却下案）は [memory/](memory/) に残し、確定後は正本へ昇格させます。
- 品質ゲートは `task verify`（コミット前は `task verify:fast`）。起案・反映の前に実行し緑を確認する（正本は AGENTS.md「7.」／Taskfile.yml）。Claude Code では `task hooks` で lefthook を有効化できます。
- 本ファイル（CLAUDE.md）自体の変更は Class A です。単独で反映しないでください。
