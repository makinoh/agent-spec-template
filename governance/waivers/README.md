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

### 登録済みの `target_check` 識別子

`target_check` は「どのゲートに対する適用除外か」を機械的に紐付ける固定文字列です。誤記した waiver は
**どのゲートからも認識されません**（無効）。新しいゲートに waiver 連携を追加する場合、識別子を本表へ登録します（MUST）。

| `target_check` | 対象ゲート | 意味 |
| --- | --- | --- |
| `governance-metrics.mechanized-rate` | [scripts/checks/governance-metrics.sh](../../scripts/checks/governance-metrics.sh) | 機械強制率が baseline を下回ることを時限的に許容する（強制台帳 #44/#45） |
| `diff-size.class-a` | [scripts/checks/diff-size.sh](../../scripts/checks/diff-size.sh) | Class A の変更行数上限の超過を時限的に許容する（強制台帳 #46） |
| `diff-size.class-b` | 同上 | Class B の変更行数上限の超過を時限的に許容する（強制台帳 #46） |

差分規模の上限は Class ごとに識別子を分けています。Class B 向けに発行した waiver が Class A の超過まで
通過させることを防ぐためです（統治文書の変更ほど厳しい上限が課される設計を、waiver の取り違えで崩さない）。

照合ロジックの実体は [scripts/waivers.py](../../scripts/waivers.py) に集約されています（複数ゲートで
規約の解釈が分岐することを防ぐ。SSoT）。

### 記述例

```markdown
---
id: WV-0001
target_check: diff-size.class-a
status: Active
expires: 2026-12-31
---

# WV-0001: 既存リポジトリへの初期導入 PR の差分規模

| 項目 | 内容 |
| --- | --- |
| 対象規範 | development-process.md「5.」差分規模の上限（Class A = 200行） |
| 理由・代替統制 | 統治文書一式の初期導入は不可分な単位であり分割できない。代替統制として…… |
| 範囲 | 導入 PR 1件のみ（#123） |
| 承認者・承認日 | （作成者以外）／YYYY-MM-DD |
| 有効期限 | 2026-12-31 |
| 関連 | ADOPTION-EXISTING.md、RISK-XXXX |
```

`status` が `Active` かつ `expires` が本日以降の実日付である waiver のみを、ゲート側は「有効」として扱います。
`expires` にプレースホルダ（例: `TBD-HUMAN`）や空欄・「—」を記載した waiver は、対象ゲートから常に「無効」と
みなされ、低下・逸脱の通過には使用できません（無条件のバイパスを防ぐ設計。強制台帳の理由区分・失効期限欄で
プレースホルダを「非空」として許容する規約（本書冒頭「凡例」）とは別の規約であることに注意してください。台帳の
プレースホルダは「未確定である事実の記録」を許すものであり、waiver の `expires` プレースホルダのように
「恒久的な例外」を成立させる用途では使えません）。

この MUST は独立のバリデータを設けず、対象ゲートのスクリプト自身が上記フロントマターを持たない waiver を
認識しない（＝機能しない）ことによって構造的に強制されます。フロントマターの型式が本規約に沿わない waiver は、
ファイルとして存在していても対象ゲートを通過させる効果を持ちません。
