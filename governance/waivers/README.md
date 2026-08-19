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

## 機械可読な紐付け（gate-linked waiver）

`task verify` / `task verify:fast` 配下の自動ゲートが「正当な低下・逸脱は waiver で通過させる」設計
（例: 統治健全性メトリクス（[metrics/governance-health-snapshot.json](../../metrics/governance-health-snapshot.json)）の
機械強制率非減少制約。正本: [GP-0004](../proposals/gp-0004-governance-health-metrics.md)）を持つ場合、
対象の waiver ファイルは上記「記録項目」の内容を本文に記載することに加え、ファイル先頭に次のフロントマターを
備えなければなりません（MUST。ゲート側スクリプトが機械的に照合するため）。

| キー | 内容 |
| --- | --- |
| `id` | `WV-NNNN`（連番） |
| `status` | `Active` / `Expired` / `Superseded` / `Withdrawn` |
| `target_check` | 対象ゲートの識別子（ゲート側スクリプトのコメント・docstring に記載される固定文字列。例: `governance-metrics.mechanized-rate`） |
| `expires` | `YYYY-MM-DD`（実日付）。上表の「有効期限」と同一実体とする |

`status` が `Active` かつ `expires` が本日以降の実日付である waiver のみを、ゲート側は「有効」として扱います。
`expires` にプレースホルダ（例: `TBD-HUMAN`）や空欄・「—」を記載した waiver は、対象ゲートから常に「無効」と
みなされ、低下・逸脱の通過には使用できません（無条件のバイパスを防ぐ設計。強制台帳の理由区分・失効期限欄で
プレースホルダを「非空」として許容する規約（本書冒頭「凡例」）とは別の規約であることに注意してください。台帳の
プレースホルダは「未確定である事実の記録」を許すものであり、waiver の `expires` プレースホルダのように
「恒久的な例外」を成立させる用途では使えません）。

この MUST は独立のバリデータを設けず、対象ゲートのスクリプト自身が上記フロントマターを持たない waiver を
認識しない（＝機能しない）ことによって構造的に強制されます。フロントマターの型式が本規約に沿わない waiver は、
ファイルとして存在していても対象ゲートを通過させる効果を持ちません。
