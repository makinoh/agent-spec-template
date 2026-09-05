# prompts/ — プロンプト資産とライフサイクル統治

本ディレクトリは、再利用する**プロンプト**を版管理可能な資産として格納し、その**ライフサイクル**を統治します。
プロンプトはエージェントの挙動に影響するため、コードと同等にレビュー対象とします（憲章「Documentation as Code」）。

## 構成

```text
prompts/
├─ system/       システム／ロール定義プロンプト（エージェントの土台）
├─ workflows/    タスク手順プロンプト（spec 起票・レビュー等の定型作業）
├─ evaluations/  プロンプト回帰テスト（入力→期待出力／既知の失敗例）
└─ _TEMPLATE.md  プロンプト資産の記入様式（フロントマター規約）
```

## ライフサイクル（フロントマター規約）

各プロンプト資産は冒頭にフロントマターを持つべきです（SHOULD）。`status` は次の語彙を用います。

```text
draft → active → deprecated（→ superseded_by）
```

| キー | 内容 |
| --- | --- |
| `id` / `title` | 識別子・表題 |
| `status` | `draft` / `active` / `deprecated` / `superseded` |
| `owner` | 保守責任者（採用時に確定） |
| `last_review` | 最終レビュー日（`YYYY-MM-DD`。陳腐化検知に用いる） |
| `inputs` / `outputs` | 期待する入力・出力 |
| `known_failures` | 既知の失敗例（回帰の起点） |
| `eval` | 対応する [evaluations/](evaluations/) のテスト（任意） |

## 規約

- 本番の個人データ・顧客機密・秘密情報をプロンプト例に含めてはなりません（MUST NOT。[standards/security-standards.md](../standards/security-standards.md)「2.」）。合成データを用います。
- ツール／外部送信を伴うプロンプトは [standards/ai-governance.md](../standards/ai-governance.md)「6. ツール／MCP 実行境界」に従います。間接的プロンプトインジェクション（外部文書・ツール出力経由）を脅威として扱い、[governance/risk-register/](../governance/risk-register/) に登録します（SHOULD）。
- 変更クラス: `prompts/**` は Class C（人間承認必須・挙動に影響。[development-process.md](../development-process.md)「1.」）。
- プロンプトの改廃は `last_review` を更新し、重要なものは [evaluations/](evaluations/) に回帰テストを置きます（SHOULD）。検査は [scripts/checks/prompts.sh](../scripts/checks/prompts.sh) が `status` / `owner` / `last_review` の**有無・値の非空・`status` の語彙・`last_review` の日付妥当性（未来日を含む）**を機械点検します（資産追加時に活性化）。2026-08-24 まではキーの存在しか見ておらず、値が空でも `last_review` が 1999 年でも合格していました（外部レビュー指摘）。**陳腐化の上限日数は採用組織が確定します（`TBD-HUMAN`）**——環境変数 `PROMPT_REVIEW_MAX_AGE_DAYS`（整数）を設定した場合のみ超過を hard-fail し、未設定時は最古の経過日数を表示するに留めます（強制台帳 #21）。

## 収録資産

### 図表記法・外部公開統治の導入（`workflows/doc-diagram-and-external-publication-governance.md`）

図表記法（論理図＝Mermaid／物理構成図＝CI レンダリング）と、外部ドキュメントツールへの複製統治
（SSoT は Git、複製は opt-in の派生コピー）を standards/ADR/playbooks/強制台帳へ導入するための
起票プロンプトです。詳細は [workflows/doc-diagram-and-external-publication-governance.md](workflows/doc-diagram-and-external-publication-governance.md) を参照してください。

### UI 再現性シーケンス（`workflows/ui-*`）

憲章「10.1 UI 再現性」を実運用するためのプロンプト列です。**順序に意味があります**。

| 順 | ファイル | 実行先 | 目的 |
| --- | --- | --- | --- |
| 0 | [ui-00-tokens-bootstrap.md](workflows/ui-00-tokens-bootstrap.md) | Claude Code | トークンとガードレールを先に立てる |
| 1 | [ui-01-claude-design.md](workflows/ui-01-claude-design.md) | Claude Design | トークン制約下でデザインし `design-spec.md` を出す |
| — | （人間）Open Questions を全て解消する | — | ここを飛ばすと推測が始まる |
| 2 | [ui-02-speckit-ui-flow.md](workflows/ui-02-speckit-ui-flow.md) | Claude Code | spec → plan → tasks |
| 3 | [ui-03-storybook-spec.md](workflows/ui-03-storybook-spec.md) | Claude Code | 型定義と Story 設計 |
| 4 | [ui-04-implement.md](workflows/ui-04-implement.md) | Claude Code | 実装（タスク単位） |

> **1 と 2 の間の人間の作業を省略しないこと。** Open Questions が残ったまま `/speckit.specify` に進むと
> `[NEEDS CLARIFICATION]` として持ち越されますが、実装フェーズで AI がそれを「一般的な解」で埋める誘因が生まれます
> （憲章「10.1.3 推測の禁止」）。
