# agents/ — エージェント・レジストリと協調プロトコル

* 上位規範: [constitution.md](../constitution.md)「6. AIエージェント統治と自律境界」／ 実行指示の正本は [AGENTS.md](../AGENTS.md)
* 変更クラス: **A**（エージェント指示・統治機構。CODEOWNERS＋権限影響ラベル必須。[development-process.md](../development-process.md)「1.」）

本ディレクトリは、本プロジェクトで稼働する**全エージェントの名簿（roster）**と、
**マルチエージェント協調プロトコル**の正本（SSoT）です。
個々のエージェントの**実行指示**は [AGENTS.md](../AGENTS.md) を共有正本とし、
**ツール固有の差分**は各ツールがルートで自動読込する委譲ファイル（下表）に置きます。

> **なぜルート直下の `CLAUDE.md` / `GEMINI.md` 等を `agents/` へ移動しないのか**:
> これらは各 CLI が**リポジトリ直下の固定パスで自動読込**します。`agents/` へ移すと自動読込が壊れます。
> したがってツール固有ファイルはルートに残し、本ディレクトリは**名簿・協調・差分の詳細**を担います
> （SSoT は重複させない。役割分担：ルート＝自動読込の入口、`agents/`＝名簿と協調規約）。

---

## 1. エージェント名簿（roster）

| エージェント | 自動読込ファイル（ルート） | 詳細（任意） | 専用マシンID | 状態 |
| --- | --- | --- | --- | --- |
| Claude Code | [CLAUDE.md](../CLAUDE.md) | — | `@bot/claude` ※採用時に確定 | active |
| Codex | [CODEX.md](../CODEX.md)（Codex は [AGENTS.md](../AGENTS.md) も直接参照） | — | `@bot/codex` | active |
| Gemini CLI | [GEMINI.md](../GEMINI.md) | — | `@bot/gemini` | active |
| OpenHands | [OPENHANDS.md](../OPENHANDS.md) | — | `@bot/openhands` | active |
| Takt | [TAKT.md](../TAKT.md) | — | `@bot/takt` | active |

> マシンID は人間の認証情報を用いない専用アカウント（MUST。[standards/ai-governance.md](../standards/ai-governance.md)「4.」）。`@bot/*` は採用時に実在アカウントへ置換（[ADOPTION.md](../ADOPTION.md)「4.」）。

## 2. マルチエージェント協調プロトコル（AGENTS.md「6.」の詳細・正本）

- **共有正本**: 全エージェントは [AGENTS.md](../AGENTS.md) と [constitution.md](../constitution.md) を共有正本とする。ツール固有差分のみ各委譲ファイルに置く。
- **ハンドオフ**: 引き継ぎは**成果物**（spec / plan / tasks / PR）と**コミットトレーラ**（`Assisted-by:` 等）、必要なら [memory/handoff/](../memory/) を介して行い、会話履歴に依存しない（憲章「ドキュメントファースト」）。
- **所有境界**: Class A（統治・強制機構）は起案のみ。承認・自己マージは禁止（作成者≠承認者。憲章「6.」）。
- **同時実行・競合**: 同一ファイルの並行編集を避け、機能（`specs/<feature>/`）単位で作業を分割する（SHOULD）。大規模変換は worktree 隔離（[skills/migrate](../skills/migrate/SKILL.md)）。
- **競合裁定**: エージェント間で結論が割れた場合、自律解消せず人間に諮る（MUST。憲章「6.」HITL）。
- **アイデンティティ**: 各エージェントは識別可能な専用マシンアカウントで行為する（人間の認証情報を用いない。MUST NOT）。

## 3. 新しいエージェントの追加手順

1. ルートに `<TOOL>.md`（薄い委譲層。[AGENTS.md](../AGENTS.md) を参照）を追加する。
2. 本名簿（§1）に行を追加し、自動読込パスと専用マシンID を記す。
3. [.github/CODEOWNERS](../.github/CODEOWNERS) と [scripts/checks/structure.sh](../scripts/checks/structure.sh) の参照検査対象に加える（Class A・人間承認）。
