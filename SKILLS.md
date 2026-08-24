# SKILLS.md — エージェント能力カタログ（AGENTS.md への委譲層）

本ファイルは、AIエージェントが利用する再利用可能な「スキル（手順化された能力）」の索引です。
実行指示の正本は [AGENTS.md](AGENTS.md)、上位規範は [constitution.md](constitution.md) です。矛盾する場合は上位が優先します。

> 本ファイルは統治・強制機構の一部（エージェント指示ファイル）であり、その変更は **Class A** です
> （CODEOWNERS ＋ 権限影響ラベル。development-process.md「1.」対応表に登録）。

> **本カタログの適用範囲（2026-08-24 追記）**: 「2. 標準スキル」に並ぶスキルは、いずれも
> **本テンプレート自身の統治手順**（spec / plan / ADR / verify / 移行 / 導入）を手順化したものです。
> ドメイン設計判断・トレードオフ分析・アーキテクチャ選定といった**実務・設計の力量そのものを
> 育成・代替するスキルは含まれていません**。スキルを揃えても、その成果物の妥当性を評価できる
> 人間が必要です（development-process.md「5.1 力量要件」）。体裁の整った成果物が生成される
> ことと、その内容が正しいことは別です。カタログの充実を「実務を任せられる状態」と読み替えては
> なりません（MUST NOT）。

---

## 1. スキルの置き場と規約

* 各スキルは `skills/<skill-name>/SKILL.md` に置き、用途・入力・出力・**使用ツール境界**・参照する knowledge/standards を明記します（SHOULD）。
* 各スキルは成熟度メタデータ（フロントマター `status` / `owner` / `last_review`）を持つべきです（SHOULD）。`status` は `active` / `experimental` / `deprecated`。陳腐化はレビューで補完します。
* スキルは [standards/ai-governance.md](standards/ai-governance.md)「6. ツール／MCP 実行境界」に従います。破壊的操作・外部送信は承認対象です。
* スキルが知識を要する場合、本文に焼き込まず [knowledge/](knowledge/) を参照します（憲章「SSoT」・トークン効率）。
* `skills/**` の変更クラスは Class C（人間承認必須・ADR 原則不要。development-process.md「1.」）。

---

## 2. 標準スキル（初期セット・採用組織が拡張）

| スキル | 目的 | 主な Class |
| --- | --- | --- |
| [spec-author](skills/spec-author/SKILL.md) | `spec.md` 起票（What/Why） | C/D |
| [plan-and-check](skills/plan-and-check/SKILL.md) | `plan.md` ＋ Constitution Check | B/C |
| [adr-draft](skills/adr-draft/SKILL.md) | ADR ドラフト（Proposed）の起票 | B（起案のみ） |
| [review-and-verify](skills/review-and-verify/SKILL.md) | 変更の自己レビュー・DoD 検査 | C |
| [migrate](skills/migrate/SKILL.md) | 大規模変換・移行（worktree 隔離） | B/C |
| [adopt-existing](skills/adopt-existing/SKILL.md) | 既存リポジトリへの本テンプレート導入（brownfield） | A（起案のみ） |

---

## 3. マルチエージェント運用

複数エージェント（Claude Code / Codex / Gemini CLI / OpenHands / Takt 等）での作業分担・ハンドオフ・所有境界は
[AGENTS.md](AGENTS.md)「6. マルチエージェント運用」を正本とします。スキルはエージェント非依存に記述し、特定ツール固有の差分は各ツール固有ファイル（CLAUDE.md / GEMINI.md 等）に置きます。

---

## 4. 改正履歴

### [0.2.0] - 2026-08-24

* `adopt-existing`（既存リポジトリへの導入）を標準スキルへ追加。手順の正本は
  [ADOPTION-EXISTING.md](ADOPTION-EXISTING.md) とし、本カタログには索引のみを置く（SSoT）。
