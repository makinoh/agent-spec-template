# AGENTS.md — AIエージェント実行指示（正本）

本ファイルは、本プロジェクトにおける **AIエージェント実行指示の正本** です
（constitution.md「6. AIエージェント統治と自律境界」）。
上位規範は **constitution.md（開発憲章）** であり、本ファイルが憲章と矛盾する場合は **憲章が優先** します。

> 本ファイルは統治・強制機構の一部であり、その変更は **Class A** として扱います
> （作成者≠承認者・CODEOWNERS・権限影響ラベル必須。constitution.md「4. 変更分類」「6.」参照）。

---

## 1. 参照順序（正本は constitution.md「2. 文書管理階層」）

AIエージェントは、判断の根拠を以下の優先順位で参照してください。

1. [constitution.md](constitution.md)（開発憲章）／ゲート用簡潔ビュー [.specify/memory/constitution.md](.specify/memory/constitution.md)
2. [governance/](governance/)（憲章改正の確定記録）
3. charter.md / vision.md / scope.md（基本方針。未整備の場合は「未定義」として扱う）
4. [adr-rules.md](adr-rules.md) → [adr/](adr/)（ADR 運用規則 → 個別 ADR）
5. [development-process.md](development-process.md)（開発プロセス・変更クラス判定）
6. architecture/ → [standards/](standards/)（設計・技術標準。`ai-governance.md` を除く）
7. [standards/ai-governance.md](standards/ai-governance.md)（AI 運用詳細方針）
8. 本ファイル（AGENTS.md）。ツール固有差分は [CLAUDE.md](CLAUDE.md) / [GEMINI.md](GEMINI.md) / [CODEX.md](CODEX.md) / [OPENHANDS.md](OPENHANDS.md) / [TAKT.md](TAKT.md) 等、名簿・協調は [agents/](agents/)、能力は [SKILLS.md](SKILLS.md)
9. [knowledge/](knowledge/) / [memory/](memory/) / [playbooks/](playbooks/) / [prompts/](prompts/)（知識・記憶・手順・プロンプト資産）／ 計測は [metrics/](metrics/)
10. [README.md](README.md) → ソースコードコメント

AI 運用規範は **憲章（原則）→ standards/ai-governance.md（詳細）→ AGENTS.md（実行指示）** の三層で詳細化されます。下位層は上位層と矛盾してはなりません（MUST NOT）。

---

## 2. 絶対ルール（抜粋。正本は constitution.md）

- クラスが確定しない変更は **Class A** として扱う（MUST）。
- 本番環境の個人データ・顧客機密・秘密情報を、AIエージェント・外部AIサービスに入力しない（MUST NOT）。
- 自らの変更で失敗した品質ゲート・統治機構を、回避目的で弱めない（MUST NOT）。原因側を修正する。
- 自身の権限・自律範囲、または統治・強制機構に影響する変更は、その旨を明示的に開示する（MUST）。単独で反映しない（MUST NOT）。
- 人間の認証情報・アカウントで行為しない（MUST NOT）。AIは識別可能な専用アイデンティティ（マシンアカウント）で行為する（MUST）。
- 判断に迷う局面では停止し、人間の判断を仰ぐ（HITL。constitution.md「6.」停止必須チェックポイント）。
- ADR と実装が矛盾する場合、自律的に修正せず人間へ確認する（MUST）。

---

## 3. 自律してよい行為 / 人間承認が必要な行為（要約）

| 区分 | AIの自律 | 反映（保護対象ブランチ） |
| --- | --- | --- |
| Class A（統治・セキュリティ・本番重大／不可逆） | 起案・準備のみ | 人間承認必須 ＋ CODEOWNERS ＋ 権限影響ラベル |
| Class B（アーキテクチャ・公開IF） | 起案・準備（ADR 起票含む） | 人間承認必須 |
| Class C（機能・不具合修正） | 起案・準備（PR・テスト） | 人間承認必須 |
| Class D（ドキュメント・整形、統治文書を除く） | 起案・準備 | 品質ゲート全通過時のみ自己反映可（standards/ai-governance.md の許可条件下） |

判定基準・対象パスの正本は [development-process.md](development-process.md)、自己反映の許可条件は [standards/ai-governance.md](standards/ai-governance.md)。

---

## 4. spec-kit フローでの振る舞い

| コマンド | 成果物（正本） | エージェントの責務 |
| --- | --- | --- |
| `/speckit.constitution` | [.specify/memory/constitution.md](.specify/memory/constitution.md) | 本憲章の簡潔ビューを保守（本体改正はガバナンス決定） |
| `/speckit.specify` `/clarify` | `specs/<feature>/spec.md` | 「何を・なぜ」を記述。実装方法（How）は書かない |
| `/speckit.plan` | `specs/<feature>/plan.md` ほか | 「どう作るか」＋ **Constitution Check** ＋ Class A/B なら ADR 起票 |
| `/speckit.tasks` | `specs/<feature>/tasks.md` | タスク分解。各タスクに変更クラスと承認要否を付す |
| `/speckit.analyze` | （点検） | 憲章第8章 ＋ spec/plan/constitution の整合確認 |
| `/speckit.implement` | コード等 | 「9. 完了条件」を満たすまで実装・検証 |

ADR は「**なぜこの設計か**（判断・根拠）」の正本、spec は「**何を作るか**（要求・振る舞い）」の正本です。両者を重複させないでください。

> **doc-churn の回避**: spec/plan/tasks/ADR は目的ではなく手段です。`/speckit.implement` は実装とテストを前進させること。ドキュメント更新のみで反復を消費せず、各反復でコードまたはテストの前進を伴わせてください。

---

## 5. 能力と知識（skills / knowledge / playbooks / prompts）

- 再利用可能な手順化能力は [SKILLS.md](SKILLS.md)（実体は `skills/`）。スキルのツール実行は [standards/ai-governance.md](standards/ai-governance.md)「6. ツール／MCP 実行境界」に従う。
- ドメイン知識は [knowledge/](knowledge/)、運用手順は [playbooks/](playbooks/)、再利用プロンプトは [prompts/](prompts/) に置く。**指示文（本ファイル）へ知識を焼き込まない**（SSoT・トークン効率）。
- エージェントの作業記憶（セッション跨ぎの申し送り・反省・却下案）は [memory/](memory/) に置き、確定後は adr/・knowledge/ 等へ昇格させて滞留させない（SSoT）。
- プロンプトはレビュー対象資産でありライフサイクル（status/owner/last_review）を持つ。本番の個人データ・機密を含めない（MUST NOT）。
- 計測（DORA・AI 有効性指標）は [metrics/](metrics/) を参照する。

---

## 6. マルチエージェント運用

- 全エージェント（Claude Code / Codex / Gemini CLI / OpenHands / Takt 等）は AGENTS.md を共有の正本とし、ツール固有差分のみ各ファイル（CLAUDE.md / GEMINI.md / CODEX.md / OPENHANDS.md / TAKT.md 等）に置く。
- **名簿・協調の詳細**: エージェント名簿（roster）・自動読込パス・専用マシンID・協調プロトコルの詳細は [agents/README.md](agents/README.md) を正本とする（本節はその要約）。
- **作業分担**: 起案（spec/plan/ADR ドラフト・テスト・実装）は自律可。保護対象ブランチへの反映は人間承認に従う（Class 別）。
- **ハンドオフ**: エージェント間の引き継ぎは成果物（spec/plan/tasks/PR）とコミットトレーラ（`Assisted-by:` 等）で行い、会話履歴に依存しない（憲章「ドキュメントファースト」）。
- **所有境界**: Class A（統治・強制機構）は起案のみ。承認・自己マージは禁止（作成者≠承認者。憲章「6.」）。
- **アイデンティティ**: 各エージェントは識別可能な専用マシンアカウントで行為する（人間の認証情報を用いない。MUST NOT）。

---

## 7. 品質ゲート（Quality Gates）

品質チェックの実体は **`task verify`（Taskfile.yml ＋ scripts/checks/）に一元化**されています（Single Source of Truth）。Developer・AIエージェント・CI はすべて同一コマンドを実行します。

- **コミット前（高速）**: `task verify:fast`（structure / ADR命名 / front matter / markdown）。
- **Push前・PR・CI（包括）**: `task verify`（上記 ＋ ADR索引 / link / secret / 依存脆弱性 / build）。
- ツール導入は `task setup`（mise / .mise.toml）、Git hook 有効化は `task hooks`（lefthook）。
- **起案・反映の前に `task verify` を実行し、緑であることを確認する**（赤のまま PR を出さない）。
- 失敗したゲートを回避目的で弱めない（憲章「自己修正ループの防止」）。原因側を修正する。
- ゲートの実体（`Taskfile.yml` / `lefthook.yml` / `.mise.toml` / `scripts/**` / `.github/**`）への変更は Class A。
