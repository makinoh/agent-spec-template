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
- プロンプトの改廃は `last_review` を更新し、重要なものは [evaluations/](evaluations/) に回帰テストを置きます（SHOULD）。検査は [scripts/checks/prompts.sh](../scripts/checks/prompts.sh) が `status`/`owner` の有無を機械点検します（資産追加時に活性化）。
