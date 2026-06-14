# governance/waivers/ — 適用除外（時限）レジスタ

* 上位規範: [constitution.md](../../constitution.md)「7. 変更管理」「3. 原則の競合と裁定」
* 変更クラス: **A**（統治・強制機構。CODEOWNERS＋権限影響ラベル必須）

本ディレクトリは、規範（standards / 原則 / ゲート）への**時限的な適用除外（waiver）**を記録する正本（SSoT）です。
緊急時の事後切替（Break-glass。憲章「7.」）とは別に、**計画的・限定的にルールを満たせない**場合の統制手段です。

> waiver は規範そのものを変えません。**期限付き**で、満了時に「解消」か「再承認」を必須とします（MUST）。
> 恒久的な緩和が必要なら waiver ではなく**ガバナンス決定**（憲章「7.」）で規範を改正します。

## 記録項目（各 waiver ファイル）

| 項目 | 内容 |
| --- | --- |
| 対象規範 | 除外する MUST/SHOULD とその出所（例: testing-standards「1.」カバレッジ） |
| 理由・代替統制 | なぜ満たせないか／その間のリスク低減策 |
| 範囲 | 対象パス・機能・環境 |
| 承認者・承認日 | 作成者≠承認者（MUST）。Class A 承認に準ずる |
| 有効期限 | 必須（無期限禁止）。満了時に再評価 |
| 関連 | [risk-register/](../risk-register/) のリスク ID、関連 ADR |

## 規約

- waiver は安全・統治の核（本番 PII の AI 入力禁止／作成者≠承認者／品質ゲート未通過マージ禁止／クラス未確定は A）には適用できません（MUST NOT。[development-process.md](../../development-process.md)「8.」）。
- 発行・満了は [governance/decisions/](../decisions/) と整合させ、監査可能にします（SHOULD）。
