---
id: GP-0004
title: "統治健全性メトリクスの追加（機械強制率の非減少制約）"
status: Proposed              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-20
last_updated: 2026-08-20
proposer: "claude-code (Sonnet 5)"
approvers: []                 # 承認待ち。Lite プロファイル（GD-0001）により定足数 1 名（オーナー）
target_version: "constitution.md: 0.4.0 → 0.5.0（提案・MINOR）／ governance/enforcement-ledger.md: 0.5.0 → 0.6.0（提案・MINOR）"
supersedes: []
superseded_by: []
relates_to: [GP-0002, GP-0003]
---

# GP-0004: 統治健全性メトリクスの追加（機械強制率の非減少制約）

> ガバナンス決定（憲章「7. 変更管理」）。統治改訂プロンプト（Machine-First Verification 導入）WU-03。
> WU-01（[GP-0002](gp-0002-machine-first-verification.md)。PR #22、マージ済み）・
> WU-02（[GP-0003](gp-0003-enforcement-ledger-schema.md)。PR #23、マージ済み）に依存する。

**ベースブランチについて**: WU-01・WU-02 と同じ理由（無関係な差分の混入回避）で、本提案は
`governance/gp-0003-enforcement-ledger-schema`（WU-02 の作業ブランチ。本提案の起票時点で
`refactor/framework-neutral-ui-governance` へマージ済み）を土台にしている。`main` を直接の base にすると
WU-01・WU-02 の差分（強制手段の新分類・強制台帳のスキーマ拡張）まで本 PR の diff に含まれてしまうため。

## 1. 提案の要旨

WU-01・WU-02 は「人間ゲートを選んでよい条件」を定義し、既存の全「人間」関与行を (a)/(b)/(c) で再分類した。
本提案（WU-03）はその先として、**強制台帳から自動導出する統治健全性メトリクス**を追加し、
「機械強制の範囲が広がっているか、狭まっていないか」を継続的に機械観測できるようにする。

指標は3つ。

* **機械強制率** = (構造的強制または機械強制を含む台帳行の件数) ÷ (台帳の全行数)
* **暫定人間ゲート残数** = 「人間ゲート（暫定）」を強制手段に含む台帳行の件数
* **期限超過件数** = 上記のうち失効期限（実日付）を過ぎている件数（常に 0 であることは
  `scripts/check_enforcement_ledger.py`（WU-02・台帳 #34）が既に機械強制している。本提案は
  この値を**観測・報告するのみ**で、重複した exit 1 は追加しない）

3指標のうち **機械強制率のみ**に非減少制約を課す（WU03-01）。低下する PR は `task verify:fast` を失敗させる。
低下が正当な場合（新規 MUST 追加に伴う一時的低下等）は `governance/waivers/` への登録で通過できる経路を設けるが、
無条件のバイパスにはしない（WU03-02）。あわせて憲章「7. 変更管理」定期見直しの確認項目に、
両指標（機械強制率・暫定人間ゲート残数）の推移確認を追加する（WU03-03）。

## 2. 変更内容

### 2.1 constitution.md — Class A

| 対象 | 変更 |
| --- | --- |
| 「7. 変更管理」定期見直し | 確認項目に「統治健全性メトリクス（機械強制率の推移、人間ゲート（暫定）残数の推移）」を追加（SHOULD レベル。既存節の voice に合わせた）。算出方法・基準値の正本を governance/enforcement-ledger.md と metrics/governance-health-snapshot.json とし、機械強制率の低下は waiver がない限り機械強制で防ぐ旨を記述（強制台帳 #36・#37 への参照）。 |
| 「13. 改正履歴」 | `[0.5.0]` エントリを追加（本提案の確定を条件とする）。 |
| バージョン | 0.4.0 → **0.5.0（提案。MINOR）**。根拠は本提案「5. バージョン増分の判定」。 |

**設計判断（MUST を憲章本文に増設しなかった理由）**: WU03-01/02 が要求する「非減少制約」「waiver 経路」「無条件バイパスの禁止」自体は、
constitution.md 本体に新たな MUST 文として書き下ろさず、強制台帳（8章が定める SSoT）側の新規行（#36・#37）として登録した。
理由は、既存の台帳エントリ（例: #29 ゲート自己診断、#33/#34 台帳スキーマ検証）も同様に「8章の一般規定
（『本章に登録した MUST は CI/CD または自動検証によって実際に強制されていなければならない』）から導出される
個別の機械検証ルール」として台帳のみに登録され、本文には重複記載していないという既存パターンに倣うためである。
「7. 変更管理」定期見直しへの追記は SHOULD レベルの記述にとどめ、既存節の全体が SHOULD で統一されている voice を崩さなかった。

### 2.2 governance/enforcement-ledger.md — Class A

* 新規行 #36（機械強制率の非減少制約。MUST・機械強制・整備済み）、#37（waiver 未該当時の無条件バイパス禁止。MUST NOT・機械強制・整備済み）を追加。
* バージョン: 0.5.0 → **0.6.0（提案・MINOR）**。

### 2.3 metrics/ — Class A（例外。metrics/README.md 自身が定める昇格規約の適用）

| ファイル | 変更 |
| --- | --- |
| `metrics/governance-health-snapshot.json`（新設） | 機械強制率の baseline スナップショット。本 WU 実施時点の強制台帳（38行）から実測した値をそのまま初期シード値として記録（数値の発明ではなく実測。IMP-05 に整合）。 |
| `metrics/README.md`（変更） | 「位置づけ」に例外節を追加。`metrics/` は本来 Class D・観測専用だが、機械強制率は `task verify:fast` が実際に強制する閾値であるため、README 自身の規約（「ある指標を強制閾値にする場合は standards/ へ移し Class A 化する」）が適用される旨を明記。本 WU では独立の `standards/*.md` は新設せず、`scripts/checks/` への新規チェック追加（それ自体がリポジトリ規約上 Class A）と強制台帳登録（#36・#37）で同じ効果（Class A・機械強制・監査可能）を達成したことを説明する。他の指標（dora.md・ai-metrics.md）は引き続き観測専用で本例外の対象外であることも明記。 |

### 2.4 scripts/ — Class A

| ファイル | 内容 |
| --- | --- |
| `scripts/check_governance_metrics.py`（新設） | 3指標を算出し、機械強制率の非減少制約を検査する。台帳の読み込みは `scripts/check_enforcement_ledger.py` の `load_rows` / `DATE_RE` / `GATE_BOOTSTRAP` を**そのまま import して再利用**し、`ROW_RE` を分岐させていない（プロンプトの指示どおり、独自の表パーサを新設しなかった）。waiver フロントマターの読み取りは `scripts/generate_adr_index.py` の既存ヘルパ `parse_frontmatter`（`check_adr_content.py` が既に採用している再利用パターン）をそのまま流用した。`--write-baseline` フラグで baseline の意図的な引き上げができるが、通常の `verify` / `verify:fast` 実行では呼ばれない（CI がこっそり基準を動かせないようにする設計）。 |
| `scripts/checks/governance-metrics.sh`（新設） | 上記 Python の薄いラッパー（`adr-content.sh` / `enforcement-ledger.sh` と同じパターン）。 |
| `scripts/checks/selftest.sh`（変更） | 陽性対照リストへ `governance-metrics` を追加。陰性テストを2件追加（baseline 割れ＝waiver なし／失効済み waiver では正当化されない＝無条件バイパスの禁止の実証）。 |

### 2.5 Taskfile.yml — Class A

`check:governance-metrics` タスクを新設し、`verify:fast` の `check:enforcement-ledger` の直後に追加（オフライン・決定論的なチェックのため）。

### 2.6 governance/waivers/README.md — Class A

「機械可読な紐付け（gate-linked waiver）」節を新設。自動ゲートの escape hatch として使う waiver に限り、
既存の記録項目（対象規範／理由・代替統制／範囲／承認者・承認日／有効期限／関連）に加えて、
機械照合用のフロントマター（`id` / `status` / `target_check` / `expires`）を備えることを MUST 化した。
この MUST は独立のバリデータを設けておらず、**対象ゲート（本提案では `governance-metrics.sh`）が
当該フロントマターを持たない waiver を認識しない（機能しない）という構造そのもの**によって強制される
（IMP-01 (i) の「実際に動く機械検証」に相当。詳細は下記「3.3」）。

## 3. 設計判断（WU-03 が実施者に委ねた4つの判断の記録）

### 3.1 複数手段併記行のカウント方法（inclusive 採用）

台帳の「強制手段」列は「＋」で複数手段を併記できる（例: `機械強制（...)＋人間ゲート（不可避）`）。
機械強制率の分子にこれをどう算入するか、2案を比較した。

| 方式 | 定義 | 本 WU 時点の値（38行） |
| --- | --- | --- |
| **inclusive（採用）** | 構造的強制または機械強制を**含めば**算入する（人間ゲートが併記されていても減点しない） | 32/38 = 0.8421 |
| exclusive（不採用） | 構造的強制・機械強制の**みで構成される**行（人間ゲートを一切含まない）のみ算入する | 23/38 = 0.6053 |

**inclusive を採用した理由**: Machine-First Verification（GP-0002）の目的は、既存の人間ゲートを漸進的に
機械層で補強・代替していくことにある。台帳には「機械層を追加したが、人間ゲートは (a)/(b) の理由で
意図的に残す」健全な defense-in-depth の行が多数ある（例: 台帳 #8 ADR不変性＝機械強制＋最終判断は人間、
台帳 #10 ADR記載要件＝PR本文の機械検査＋理由の実質妥当性は人間、台帳 #21 プロンプト資産＝FM機械検査＋内容レビューは人間）。
exclusive カウントを採ると、これらの行に機械層を追加しても指標が一切動かない一方、
（多くの場合 (a)/(b) で恒久的に正当化される）人間ゲートを剥がすことだけが指標を動かす形になり、
「機械層を足す」という健全なインセンティブを指標が評価しない。inclusive はこれを避ける。

**この判断はAIによる設計選択であり、承認前の確認を要する**（下記「6. 未解決事項」Q-01）。
両方式の値を上表のとおり並記したので、人間承認者は exclusive 系列への切替を選択できる
（`scripts/check_governance_metrics.py` の `MECH_TOKENS` 判定を変更するのみで切替可能な設計にしてある）。

### 3.2 baseline スナップショットの形式と更新規約

`metrics/governance-health-snapshot.json` は単一の JSON オブジェクトとした（プロンプトの「シンプルでよい」との
指示に従う）。分子・分母を整数のまま保持し（`mechanized_norms` / `total_norms`）、比較は浮動小数点の丸め誤差を
避けるため整数の交差乗算で行う（`scripts/check_governance_metrics.py` 参照）。

baseline の更新（= 床の引き上げ）は、`task verify` の通常実行では発生しない設計にした。`--write-baseline` を
明示的に付けて実行した場合のみ上書きされる。これにより「CI が黙って基準を動かして常に緑にする」自己修正ループ
（憲章「6. 自己修正ループの防止」）を構造的に防ぐ。基準を引き上げたい場合は、機械強制率が実際に改善した PR の中で
人間またはエージェントが明示的に `--write-baseline` を実行し、その差分をレビュー対象にすることを想定している。

初期シード値（32/38）は、本 WU が強制台帳へ #36・#37 を追加し終えた**後**の状態から実測した（数値を発明していない。
IMP-05）。#36・#37 自身が機械強制のみの行であるため、この2行の追加は inclusive 分子を2ポイント押し上げる
（追加前 30/36=0.8333 → 追加後 32/38=0.8421）。

### 3.3 waiver 連携規約

`governance/waivers/README.md`「機械可読な紐付け」に定義したとおり、対象ゲート識別子は固定文字列
`governance-metrics.mechanized-rate`（`scripts/check_governance_metrics.py` の `TARGET_CHECK_ID` 定数と同一）とした。
waiver は `status: Active` かつ `expires` が実日付・本日以降でなければ「無効」として扱う。

強制台帳のスキーマ（WU-02）では `TBD-HUMAN` を「非空」として許容するが、waiver の `expires` に
`TBD-HUMAN` を書いても有効にはならない設計にした。台帳のプレースホルダは「未確定である事実の記録」を
許すものだが、waiver の `expires` は「その waiver がいつまで有効か」という**期限そのもの**であり、
プレースホルダを許すと事実上の無期限バイパス（waivers/README.md が禁止する「無期限禁止」に抵触）になるためである。
selftest.sh の陰性テスト「失効済み waiver は低下を正当化しない」は、この設計が実際に機能することを実証する。

### 3.4 期限超過件数を独立ゲート化しなかった理由

期限超過件数（人間ゲート（暫定）の失効期限超過）を 0 に強制する hard fail は、既に
`scripts/check_enforcement_ledger.py`（台帳 #34。WU-02）が実装済みである。本 WU の `check_governance_metrics.py` は
同じ値を**算出して表示するのみ**とし、独立した exit 1 を追加しなかった。理由は、同一の失敗条件に対して2つの
チェックスクリプトが別々に exit 1 する設計は、失敗時にどちらが本来の責任者か曖昧にし、片方だけを緩和して
「直った」ように見せる自己修正ループの隙を作りうるため。1つの規範には1つの強制点、という既存の台帳運用方針
（8章）に合わせた。

## 4. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転なし**。新規指標・新規ゲートの追加のみ |
| `task verify:fast` | 新規チェック（`governance-metrics`）が追加される。現状は baseline と現在値が一致（32/38）のため通過する |
| 既存の強制台帳行（#1〜#35） | 変更なし（新規2行の追加のみ） |
| `metrics/` の位置づけ | 例外を1件追加（機械強制率のみ）。他の指標（dora.md・ai-metrics.md）は無変更・観測専用のまま |
| コードを含まない採用 | 影響なし（台帳・スクリプトはコードスタック非依存で動作） |
| AI エージェントの権限 | 変更なし |
| 並行して起票されている他 WU（05〜09） | 同じベース（`governance/gp-0003-enforcement-ledger-schema`）から並行して強制台帳への行追加を提案している可能性がある。行番号（#36・#37）は本 PR 時点での見積りであり、複数 WU が並行してマージされる場合は**行番号の衝突が生じうる**（他 WU も #36 を名乗る可能性がある）。これは想定内であり、マージ時に人間が手動でリナンバリングすることを前提とする。本提案ではこれを解決しない。 |

## 5. バージョン増分の判定

**constitution.md: 0.4.0 → 0.5.0（提案・MINOR）**

根拠:

* 既存の MUST / MUST NOT の**撤廃・反転・意味変更はない**。「7. 変更管理」定期見直しへの確認項目追加は、
  既存の SHOULD レベルの見直し活動（少なくとも6ヶ月ごとの有効性・陳腐化レビュー）を具体化する後方互換な追加である。
* 憲章「7. 変更管理」バージョニング方針の MINOR 例示（「新しい原則の追加、第8章への MUST ルール追加、
  新たな standards の規定」）と同種（既存節への確認項目追加＋8章強制台帳への新規機械検証ルール追加）に該当する。
* MAJOR の例示（要件削除・原則の意味変更・Class 定義の再定義）には該当しない。

**governance/enforcement-ledger.md: 0.5.0 → 0.6.0（提案・MINOR）**

根拠: 新規行2件（#36・#37）の追加のみで、既存30〜35行の意味を変更していない。WU-02（0.4.0→0.5.0）と同じ性質
（新規列・新規行の追加中心）のため MINOR。

**両判定はAIによる提案であり、確定は人間承認者が行う**（憲章「7.」：AI は本書改正を単独で承認・反映してはならない MUST NOT）。

## 6. 実行した検証（生の出力）

`task` 本体が未導入のため、`Taskfile.yml` が呼び出す個別スクリプトを直接実行した（内容は同一）。
Node は `.mise.toml` が固定する v24 系（`~/.nvm/versions/node/v24.19.0/bin` を PATH 先頭に追加）を使用。

```text
== structure ==            ✓ structure
== adr ==                  ✓ ADR naming & status
== adr-content ==          ✓ ADR content & front-matter values (7 件)
== frontmatter ==          ✓ Front matter keys
== prompts ==               ✓ Prompt asset lifecycle
== enforcement-ledger ==
advisory: constitution.md 中の（MUST）/（MUST NOT）出現数 95 件 ／ 台帳行数 38 件
✓ Enforcement ledger schema (38 rows checked)
== governance-metrics ==   （新設。本 WU）
機械強制率: 32/38 = 0.8421（baseline: 32/38 = 0.8421, captured 2026-08-20）
暫定人間ゲート残数: 0 件
期限超過件数（観測。強制は check_enforcement_ledger.py が担う）: 0 件
✓ Governance health metrics（機械強制率は非減少）
== markdown ==              markdownlint-cli2 v0.22.1 — Linting: 139 file(s) — Summary: 0 error(s)
== adr-index ==             ✓ ADR index（adr/INDEX.md は最新）
== adr-immutability ==      ✓ Accepted ADR immutability
== pr-governance ==         ⚠ governance path changed — permission-impact ラベル要（PR で対応）
                            ⚠ Class A/B path changed — ADR参照 or ADR不要理由要（PR body で対応）
                            ✓ PR governance（警告のみ・想定内）
== build ==                 ⚠ no code stack detected — skip（ledger #15b: coverage gate 未配線の既知事項）
== ui full ==               ⚠ UI スタック未導入 — skip
== deps / secrets / links == ⚠ trivy / gitleaks / lychee 不在 — ローカルはskip、CIで実効
== adoption ==              ⚠ @org/* ・ @bot/* のプレースホルダ warn（GD-0001 により意図的・既知）
                            ✓ adoption wiring

== selftest ==
（陽性対照: structure / adr / adr-content / frontmatter / prompts / enforcement-ledger / governance-metrics すべて無傷の複製で合格）
[検出] adr.sh: ADR 命名規則違反
[検出] adr.sh: status が管理語彙の外
[検出] adr-content.sh: id とファイル名の不一致
[検出] adr-content.sh: accepted なのに決裁者が空
[検出] adr-content.sh: 必須セクションの欠落
[検出] frontmatter.sh: 必須キーの欠落
[検出] prompts.sh: last_review の欠落
[検出] structure.sh: AGENTS.md が憲章参照を失う
[検出] structure.sh: 必須文書の欠落
[検出] adr-index.sh: 索引が陳腐化
[検出] markdown.sh: Markdown Lint 違反
[検出] enforcement-ledger.sh: 人間ゲート（不可避）の理由区分欠落
[検出] enforcement-ledger.sh: 人間ゲート（暫定）の失効期限超過
[検出] governance-metrics.sh: 機械強制率が baseline を下回る（waiver なし）
[検出] governance-metrics.sh: 失効済み waiver は低下を正当化しない（無条件バイパスの禁止）
自己診断: 検出 15 件 / 見逃し 0 件 / skip 1 件（ui:tokens:check は task 本体が未導入のため skip）
✓ Gate self-test
```

## 7. 未解決事項

TBD-HUMAN の文字どおりのプレースホルダを要する箇所は本 WU では発生しなかった（新設した強制台帳 #36・#37 は
いずれも機械強制のみの行であり、人間ゲート（暫定）の必須項目＝失効期限／担当／移行先ゲートを要しないため）。
一方、以下は本 WU における AI の設計判断であり、人間の確認・確定を要する。

| ID | 内容 | 必要な判断 |
| --- | --- | --- |
| Q-01 | 機械強制率の分子カウント方式に inclusive（構造的強制/機械強制を含めば算入。32/38=0.8421）を採用した。exclusive（人間ゲートを一切含まない行のみ算入。23/38=0.6053）という選択肢も本文「3.1」に併記した | どちらの方式で機械強制率を運用するかの確定。inclusive を採る場合もこの判断自体の妥当性確認 |
| Q-02 | 機械強制率・暫定人間ゲート残数を「7. 変更管理」定期見直しの確認項目に追加したが、SHOULD レベルの記述にとどめ、独立した MUST 文は追加しなかった（本文「2.1」の設計判断参照） | この粒度（SHOULD 統合）で十分か、独立した MUST 節を追加すべきか |
| Q-03 | `metrics/README.md` の「ある指標を強制閾値にする場合は standards/ へ移し Class A 化する」という既存規約を、独立の `standards/*.md` を新設せず `scripts/checks/` ＋ 強制台帳登録で充足したとみなした（本文「2.3」） | この解釈（Class A 化の実質要件を満たせば standards/ 文書の新設は必須でない）を妥当とするか |
| Q-04 | 強制台帳の新規行番号を #36・#37 とした。並行して起票されている他 WU（05〜09）も同じベースブランチから独立に台帳へ行を追加している可能性があり、番号が衝突しうる（本文「4. 影響範囲」） | 各 WU のマージ順序決定後、行番号の手動リナンバリングをどのタイミング・誰が行うか |
| Q-05 | waiver の機械可読フロントマール規約（`target_check` / `status` / `expires`）を `governance/waivers/README.md` に新設したが、これは WU-03 が独自に設計した規約であり、他の自動ゲート（将来追加されるもの）が同じ規約に相乗りする前提を置いている | この規約を waiver 全体の標準形式として確定するか、governance-metrics 専用の暫定形式とするか |

**Q-01〜Q-05 が未解決の間、本提案の値（特にカウント方式）を確定として扱いません。**

## 8. 承認

| 項目 | 内容 |
| --- | --- |
| 起案者 | claude-code（Sonnet 5）。統治改訂プロンプト WU-03 |
| 承認者・承認日 | 未承認（本提案は Proposed） |
| 定足数の充足 | 未充足（承認待ち） |
| 確定結果 | 未確定 |

## 9. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-20 | claude-code (Sonnet 5) | 初版作成、Proposed に設定 | 統治改訂プロンプト WU-03 の起案 |
