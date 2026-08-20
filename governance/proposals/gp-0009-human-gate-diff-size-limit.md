---
id: GP-0009
title: "人間ゲートの実質化（差分規模の上限）"
status: Proposed              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-20
last_updated: 2026-08-20
proposer: "claude-code (Sonnet 5)"
approvers: []                 # 承認待ち。Lite プロファイル（GD-0001）により定足数 1 名（オーナー）
target_version: null          # constitution.md は不変更。development-process.md は 0.2.1 → 0.3.0、governance/enforcement-ledger.md は 0.6.0 → 0.7.0（ともに提案・MINOR）
supersedes: []
superseded_by: []
relates_to: [GP-0002, GP-0003, GP-0006]
---

# GP-0009: 人間ゲートの実質化（差分規模の上限）

> ガバナンス決定（憲章「7. 変更管理」）。統治改訂プロンプト（Machine-First Verification 導入）WU-08 の成果物。
> WU-01（[GP-0002](gp-0002-machine-first-verification.md)。PR #22、マージ済み）・WU-02（[GP-0003](gp-0003-enforcement-ledger-schema.md)。PR #23、マージ済み）に依存する。
> 起票時点で `governance/gp-0003-enforcement-ledger-schema`（本改訂の統合ブランチ）は WU-05（[GP-0006](gp-0006-test-quality-gates.md)。PR #24、マージ済み）まで進んでおり、本 PR はその最新状態へ rebase 済みである（台帳行 #40 は rebase 後の実際の次番号）。

## 1. 提案の要旨

承認は development-process.md「5. 承認者・定足数」で「作成者以外の人間 1 名以上」と定義されているが、AI 駆動で PR の生成量が増えると、レビュアが実質的に精査できない規模の差分に対しても形式的な承認だけが行われ、人間ゲートが形骸化するおそれがある。対策は承認者を増やすことではなく、**人間ゲートが機能する条件（レビュー可能な差分規模）を機械的に強制すること**である（constitution.md「3. 基本原則」検証手段の選択）。

本提案は、Class A / Class B の PR に対して変更行数の上限を課す MUST NOT を development-process.md へ新設し、その計測・分類・除外・（将来の）hard-fail 判定を行うスクリプトを実装する。**上限の具体的な数値は本提案では確定しない**（WU08-01。数値の発明を禁止）。数値が確定するまでの間は `governance/enforcement-ledger.md` に人間ゲート（暫定）として登録し、advisory（助言のみ）運用とする。

## 2. 変更内容

### 2.1 development-process.md — Class A

* 「5. 承認者・定足数」に新規サブセクション「差分規模の上限（人間ゲートの実質化）」を追加。
  * Class A/B の PR は変更行数の上限を超えてはならない（MUST NOT）。超過時は分割するか `governance/waivers/` の適用除外を要する。
  * 変更行数の算定方式（追加行数＋削除行数、生成物・ロックファイル除外）を明記。
  * 上限値は `TBD-HUMAN`（未確定）であることを明記し、確定までの運用（advisory → 閾値設定で hard-fail へ移行）を記載。
* バージョン: 0.2.1 → **0.3.0（提案・MINOR）**。新規 MUST NOT の追加であり、既存規範の反転はない。

### 2.2 governance/enforcement-ledger.md — Class A

* 新規行 **#40** を追加: 「Class A/B の PR は変更行数の上限を超えてはならない」を人間ゲート（暫定）として登録。理由区分は不要（人間ゲート（不可避）ではないため）。失効期限・担当は `TBD-HUMAN`。移行先ゲートには、閾値確定後に hard-fail 化する具体的な手段（`DIFF_SIZE_LIMIT_CLASS_A` / `DIFF_SIZE_LIMIT_CLASS_B` 環境変数の設定先）を明記。
* バージョン: 0.6.0 → **0.7.0（提案・MINOR）**。新規行の追加であり、既存行の意味の反転はない。
* **行番号に関する注記**: 本 WU-08 は起票にあたり `origin/governance/gp-0003-enforcement-ledger-schema`（WU-05／PR #24 マージ後、台帳は #1〜#39・Version 0.6.0）へ rebase 済みである。#40 はその時点での実際の次行番号であり、#36〜#39（WU-05）とは衝突しない。ただし本 PR のレビュー中に他の作業単位が先にマージされた場合、#40 が重複して採番される可能性は残る。マージ順序に応じた再採番は人間が調整する。

### 2.3 scripts/ — Class A

| ファイル | 内容 |
| --- | --- |
| `scripts/check_diff_size.py`（新設） | `BASE_SHA`/`HEAD_SHA`（未設定時は `pr_governance.sh` と同じフォールバック: `origin/main` → 失敗時 `HEAD~1`）間の `git diff --numstat` を取得し、(1) `scripts/checks/pr_governance.sh` の `$gov`/`$ab` 正規表現を概念的に移植した分類で Class A / Class B を判定、(2) 生成物・ロックファイルの除外リストを適用、(3) 追加行数＋削除行数を Class 別に集計、(4) 環境変数 `DIFF_SIZE_LIMIT_CLASS_A` / `DIFF_SIZE_LIMIT_CLASS_B` が整数として設定されている場合のみ上限比較して非ゼロ終了、未設定（既定）なら advisory 出力のみで exit 0。 |
| `scripts/checks/diff-size.sh`（新設） | 上記 Python の薄いラッパー（`enforcement-ledger.sh`/`adr-content.sh` と同じパターン）。 |
| `scripts/checks/selftest.sh`（変更） | 陰性テストを1件追加: 一時的に低い閾値（`DIFF_SIZE_LIMIT_CLASS_A=10`）を設定し、synthetic diff（`governance/waivers/README.md` へ50行追加してコミット）に対して `diff-size.sh` が正しく hard-fail することを確認する。git diff ベースの検査のため、UI ケースと同様にコミットを伴う（本ファイル末尾に配置）。 |

### 2.4 Taskfile.yml — Class A

`check:diff-size` タスクを新設し、`verify:pr`（PR コンテキストの統治チェック群。`pr_governance.sh` と同じ枠）に追加。`.github/workflows/verify.yml` の変更は不要（`BASE_SHA`/`HEAD_SHA` は既に `verify:pr` ステージへ配線済み。CON/IMP-02 準拠）。

## 3. WU-08 のタスク定義との対応、および実装上の判断

### WU08-01（上限値の非発明）

上限の具体的な数値は一切記載していない。development-process.md・governance/enforcement-ledger.md・`scripts/check_diff_size.py` のいずれにおいても、数値が必要な箇所は `TBD-HUMAN` とした。本提案の「7. 未解決事項」**OUT-03** に、人間が決定すべき事項として明示する。

### WU08-02（除外算定方式・除外リストの Class 扱い）

生成物・ロックファイル等、レビュー対象外の差分を除外する算定方式を定義した（`scripts/check_diff_size.py` の `EXCLUDE_EXACT` / `EXCLUDE_BASENAME`）。実例のみを列挙し、仮説上のパターンは含めていない。

* `adr/INDEX.md` — `scripts/generate_adr_index.py` が生成する派生サマリ（adr-rules.md「4. 索引」。手編集禁止）。
* `src/styles/tokens.css` / `media.css` / `tokens.d.ts` — `tokens/build.mjs` が `tokens/tokens.json` から生成（standards/design-tokens.md「6.」）。本リポジトリは UI スタック未採用のため現時点では存在しないが、活性化後に備えてあらかじめ除外した。
* `package-lock.json` / `pnpm-lock.yaml` / `yarn.lock`（任意階層、ファイル名一致） — 将来のパッケージマネージャ採用に備えた汎用パターン。現時点では未採用のため空振りする。

**除外リストの変更自体は Class A として扱う**。これは新たなルールの新設を要さない。除外リストの実体は `scripts/check_diff_size.py` にあり、development-process.md「1.」対象パス表により `scripts/**` は既定で Class A（品質ゲートの実体）であるため、除外リストの追加・変更は自動的に Class A として扱われる。同様に、適用除外の記録先である `governance/waivers/` もそれ自体が Class A（`governance/waivers/README.md`「変更クラス: A」）である。両者とも既存の分類規則から自動的に導かれるため、development-process.md 側に重複した規定を追加していない。

### WU08-03（本改訂 PR 自身の粒度）

本 PR（WU-08）自身の Class A 変更行数を、`scripts/check_diff_size.py` を用いて実測した（下記「6. 実行した検証」参照）。上限値が `TBD-HUMAN`（未確定）である以上、本 PR がその上限に「適合するかどうか」を判定すること自体が原理的に不可能である。これは WU-08 プロンプト本文が想定する状況そのものであり、矛盾ではない——**上限が存在しない間は、上限適合性の判定自体が意味を持たない**。

WU-08 プロンプトの WU08-03 は、統治改訂プロンプト全体（WU-01〜WU-10）の当初計画段階での WU 粒度調整を指す注記であり、本 PR が事後的に WU-01〜WU-07・WU-09・WU-10 の粒度を再調整することを要求するものではない（タスク文の「Note on WU08-03」に明記）。本提案でも同様に、他 WU の粒度には触れない。

### IMP-01（advisory 運用の必然性）

「差分規模の上限」という MUST NOT を、閾値が存在しない状態で hard-fail するゲートとして実装することはできない（比較対象がないため）。これは `governance/enforcement-ledger.md` の「人間ゲート（暫定）」区分が正当に扱うべきケースである（(a)(b)(c) のいずれにも該当しない、機械強制未整備の一時的な人間依存）。したがって #40 として登録し、失効期限・担当を `TBD-HUMAN` とした。

一方で、**計測・分類・除外・比較のロジック自体は実際に動作する実装とした**（advisory-only モード）。閾値が未設定の間は常に advisory 出力のみを行い hard-fail しないが、閾値を環境変数で与えれば即座に hard-fail ゲートとして機能することを selftest で確認済みである（「6. 実行した検証」参照）。これにより、人間が上限値を決定した時点で新たな実装作業を要さず、環境変数の設定のみで移行できる。

### 正規表現の再利用（重複の許容）

`scripts/checks/pr_governance.sh` の `$gov` / `$ab` 正規表現（bash）を `scripts/check_diff_size.py` へ Python として概念的に移植した（文字列としての二重管理であり、SSoT 原則には反する）。完全な一本化（例: 両スクリプトが共通のパス分類設定ファイルを参照する）も検討したが、本 PR の範囲では `pr_governance.sh` の既存動作を一切変更しないという制約（タスク指示 IMP: 「既存チェックの挙動はバイト単位で不変に保つ」）を優先し、重複を許容した。一本化は「7. 未解決事項」**OUT-01** として明示する。

### 変更行数の算定方式（追加のみ vs 追加+削除）

**追加行数＋削除行数の合計**を採用した。追加のみを数える設計も検討したが、削除もレビュアの検証コスト（既存動作を壊していないかの確認）を要するため、レビュー負荷への近似としては追加+削除の方が実態に近いと判断した。この判断の妥当性は「7. 未解決事項」**OUT-02** として人間の確認を求める。

## 4. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転なし**。新規 MUST NOT の追加（development-process.md「5.」）と、対応する台帳行の新設（#40）が中心 |
| `task verify:pr` | 新規チェック（`diff-size`）が追加される。閾値未設定のため常に advisory で exit 0（hard-fail しない） |
| 既存 PR（#22・#23 相当の規模） | 上限が確定するまでは影響なし。上限確定後は、同等規模の PR が上限を超える場合、分割または waiver が必要になる可能性がある（下記「5. 実測データ」参照） |
| コードを含まない採用 | 影響なし（スクリプトはコードスタック非依存で動作） |
| AI エージェントの権限 | 変更なし。ただし将来 hard-fail 化された場合、AI が起案する大規模 PR は分割を強制されるようになる（意図した効果） |

## 5. 実測データ（既存 WU の差分規模。人間の閾値判断のための参考値）

`scripts/check_diff_size.py` を、GitHub 上で確定している PR #22（WU-01）・PR #23（WU-02）の実際の base/head SHA に対して実行した結果（`BASE_SHA`/`HEAD_SHA` は GitHub API `pulls/{n}` の `base.sha`/`head.sha`。CI が `.github/workflows/verify.yml` で設定する値と同一種類）。

### PR #22（WU-01。base `fb887ed`→head `8003dcc`）

```text
diff-size: Class A 対象変更行数（追加+削除、除外適用後） = 195 行
diff-size: Class B 対象変更行数（追加+削除、除外適用後） = 0 行
diff-size: 除外（生成物/ロックファイル）行数 = 0 行（計上対象外）
  [A]    94  governance/proposals/gp-0002-machine-first-verification.md
  [A]    89  constitution.md
  [A]    12  governance/enforcement-ledger.md
```

GitHub API が報告する `additions=163, deletions=32`（計195）と完全に一致（3ファイルすべてが Class A、除外0件）。

### PR #23（WU-02。base `b686c64`→head `d61bffc`）

```text
diff-size: Class A 対象変更行数（追加+削除、除外適用後） = 377 行
diff-size: Class B 対象変更行数（追加+削除、除外適用後） = 0 行
diff-size: 除外（生成物/ロックファイル）行数 = 0 行（計上対象外）
  [A]   128  scripts/check_enforcement_ledger.py
  [A]   114  governance/proposals/gp-0003-enforcement-ledger-schema.md
  [A]   108  governance/enforcement-ledger.md
  [A]    11  scripts/checks/enforcement-ledger.sh
  [A]    10  scripts/checks/selftest.sh
  [A]     6  Taskfile.yml
```

GitHub API が報告する `additions=331, deletions=46`（計377）と完全に一致（6ファイルすべてが Class A、除外0件）。

両実測値が GitHub 公式の additions/deletions 合計と完全一致したことは、計測ロジック（`git diff --numstat` の集計）自体の正しさを裏付ける一次的な検証結果である。

### 本 PR（WU-08）自身

本 PR 自身（rebase 後、base = `origin/governance/gp-0003-enforcement-ledger-schema`）の Class A 変更行数は、コミット直前の実測で **502 行**（追加498・削除4。対象7ファイル、すべて Class A、除外0件）だった。

```text
4    0    Taskfile.yml
16   2    development-process.md
15   2    governance/enforcement-ledger.md
215  0    governance/proposals/gp-0009-human-gate-diff-size-limit.md
224  0    scripts/check_diff_size.py
13   0    scripts/checks/diff-size.sh
11   0    scripts/checks/selftest.sh
```

（`git diff --numstat origin/governance/gp-0003-enforcement-ledger-schema` の実測。本文書自身への追記が最終行数を若干変動させる自己参照的な性質があるため、厳密な不動点ではなく実測時点のスナップショットとして扱う。以降の軽微な編集による数行のずれは許容する。）

これら3件（195行 / 377行 / 本PR502行）は、いずれも統治文書中心の PR であり、通常の Class C（`src/**` の機能追加等）とは性質が異なる差分であることに留意されたい。上限値の検討には、統治系 PR と実装系 PR の双方の実測データを蓄積する必要がある（「7. 未解決事項」OUT-03）。

## 6. バージョン増分の判定

* **development-process.md: 0.2.1 → 0.3.0（提案・MINOR）**。新規 MUST NOT の追加であり、既存規範の反転はない。
* **governance/enforcement-ledger.md: 0.6.0 → 0.7.0（提案・MINOR）**。新規行の追加であり、既存行の意味の反転はない。
* **constitution.md は本提案の対象外（無変更）**。

## 7. 実行した検証（生の出力）

`task` が未導入のため個別スクリプトを直接実行した。

```text
== enforcement-ledger ==
advisory: constitution.md 中の（MUST）/（MUST NOT）出現数 95 件 ／ 台帳行数 37 件
✓ Enforcement ledger schema (37 rows checked)

== diff-size（advisory。閾値未設定） ==
diff-size: Class A 対象変更行数（追加+削除、除外適用後） = 502 行（実測。本文書追記分を除く直前スナップショット）
diff-size: Class B 対象変更行数（追加+削除、除外適用後） = 0 行
diff-size: Class A 上限は未設定（TBD-HUMAN）— advisory のみ、hard-fail しない
✓ diff-size (advisory unless DIFF_SIZE_LIMIT_CLASS_A/B configured)

== diff-size（閾値設定時の hard-fail 確認。PR #23 相当の実測diffに対して DIFF_SIZE_LIMIT_CLASS_A=100 を設定） ==
diff-size: Class A 対象変更行数（追加+削除、除外適用後） = 377 行
diff-size: Class A 上限 = 100 行（設定済み・強制）
✗ Class A 変更行数 377 が上限 100 を超過。分割するか governance/waivers/ に適用除外を登録してください。
✗ diff-size limit exceeded: 1 件
（exit 1 — hard-fail ロジックが意図通り動作することを確認）

== selftest ==
（陽性対照: structure / adr / adr-content / frontmatter / prompts / enforcement-ledger すべて無傷で合格）
[検出] diff-size.sh: 閾値設定時に上限超過を検出する（synthetic diff）
自己診断: 検出 14 件 / 見逃し 0 件 / skip 1 件（ui:tokens:check は task 本体未導入のため skip）
```

その他の verify:fast / verify:pr 構成チェック（structure / adr / adr-content / frontmatter / prompts / markdown / adr-index / pr_governance / adr-immutability）はすべて合格。詳細な raw output は PR 本文に転記する。

## 8. 未解決事項

| ID | 種別 | 内容 | 必要な判断 |
| --- | --- | --- | --- |
| OUT-01 | 実装重複 | `scripts/checks/pr_governance.sh` の `$gov`/`$ab` 正規表現（bash）を `scripts/check_diff_size.py`（Python）へ概念的に移植したため、二重管理になっている。development-process.md「1.」対象パス表の全項目（`CODEX.md`/`OPENHANDS.md`/`TAKT.md`/`agents/**` 等）も両者とも未網羅 | 共通のパス分類設定への一本化を求めるか、現状の重複を許容するか |
| OUT-02 | 算定方式 | 変更行数を「追加行数＋削除行数」で算定した（追加のみ案は不採用） | この算定方式の妥当性 |
| **OUT-03** | **閾値の数値** | **上限の具体的な数値（Class A / Class B 別、または development-process.md「8.」の段階導入プロファイル別）を一切定義していない（`TBD-HUMAN`）。実測データ: PR #22=195行、PR #23=377行、本PR（WU-08）=502行（いずれも統治文書中心の Class A PR）** | **具体的な上限値の決定（AI は決定できない。数値の発明は MUST NOT）** |
| OUT-04 | 除外リストの拡張性 | 現時点では UI 生成物・ロックファイルのみを列挙している。将来 build 成果物等が追加された場合の更新手順は「Class A として都度追加」以上の定めがない | 除外リスト更新の運用ルール（申請フロー等）を development-process.md にさらに明文化するか |
| OUT-05 | 移行手順 | 閾値確定後、`DIFF_SIZE_LIMIT_CLASS_A`/`DIFF_SIZE_LIMIT_CLASS_B` を `.github/workflows/verify.yml` と `Taskfile.yml` のどちらに設定するか未確定。ローカル実行（`task verify:pr`）でも同じ閾値を適用するかも未確定 | 閾値確定時の具体的な配線先の決定 |

**OUT-01〜OUT-05（特に OUT-03）が未解決の間、本提案の hard-fail 化は行われない（advisory のまま）。**

## 9. 承認

| 項目 | 内容 |
| --- | --- |
| 起案者 | claude-code（Sonnet 5）。統治改訂プロンプト WU-08 |
| 承認者・承認日 | 未承認（本提案は Proposed） |
| 定足数の充足 | 未充足（承認待ち） |
| 確定結果 | 未確定 |

## 10. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-20 | claude-code (Sonnet 5) | 初版作成、Proposed に設定 | 統治改訂プロンプト WU-08 の起案 |
