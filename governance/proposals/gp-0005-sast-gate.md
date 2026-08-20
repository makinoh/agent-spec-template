---
id: GP-0005
title: "第一者コードの静的解析（SAST）ゲートの新設"
status: Proposed              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-20
last_updated: 2026-08-20
proposer: "claude-code (Sonnet 5)"
approvers: []                 # 承認待ち。Lite プロファイル（GD-0001）により定足数 1 名（オーナー）
target_version: 0.5.0         # 憲章のバージョン増分（提案: MINOR）。standards/security-standards.md は 0.2.0 → 0.3.0、governance/enforcement-ledger.md は 0.5.0 → 0.6.0（いずれも提案・MINOR）
supersedes: []
superseded_by: []
relates_to: [GP-0002, GP-0003]
---

# GP-0005: 第一者コードの静的解析（SAST）ゲートの新設

> ガバナンス決定（憲章「7. 変更管理」）。統治改訂プロンプト（Machine-First Verification 導入）WU-04。
> WU-01（[GP-0002](gp-0002-machine-first-verification.md)。PR #22、マージ済み）・WU-02（[GP-0003](gp-0003-enforcement-ledger-schema.md)。PR #23、マージ済み）に依存する。

## 1. 提案の要旨

憲章「8. 機械的に検証可能なルール」の現行コード品質・セキュリティゲートは、ビルド／型チェック／自動テスト／カバレッジ／シークレットスキャン／**依存関係**の脆弱性スキャンの6項目であり、**AIエージェントが生成した第一者コードそのものに内在する脆弱性クラス（インジェクション・XSS・安全でない暗号利用等）を検査するゲートが存在しない**。一方、承認マトリクス（6章）は Class A に「認証・認可・秘密情報に関わる変更」を含めているが、その領域を担保する強制手段は現状「人間ゲート（不可避）＋シークレットスキャン」のみであり、コードの構文・データフローに現れる脆弱性パターンに対する機械強制が欠落している。

本提案は、この欠落を埋める SAST ゲートを新設する。ただし、以下の2点を明確に分離して扱う。

1. **機械強制できる部分**（対象スタックの検出とゲートの休眠/活性化、ツールの合否伝播）は、本 PR で実装し、動作確認済みの `scripts/checks/sast.sh` として提供する。
2. **機械強制がまだできていない部分**（実際の SAST ツールによる脆弱性検出そのもの）は、「整備済み」を偽装せず、強制台帳へ人間ゲート（暫定）として正直に登録する（`TBD-HUMAN`）。

さらに、SAST には構造的な検出限界（認可欠落・IDOR・ビジネスロジック不備は検出できない）があり、これらは恒久的に人間ゲート（不可避）(a) 意味的判断の対象であることを standards/security-standards.md に明記する。SAST の導入を「網羅的なセキュリティ検証」と表現しないことを、本提案自体が明示的に約束する。

## 2. 変更内容

### 2.1 constitution.md — Class A

| 対象 | 変更 |
| --- | --- |
| 「8. 機械的に検証可能なルール」コード品質・セキュリティの MUST | 「依存関係の脆弱性スキャンに合格すること」の直後に「第一者コードの静的解析（SAST）に合格すること」を新設。重大度基準の正本は standards/security-standards.md とし、依存脆弱性の重大度基準（同章の既存項目）とは**別項目として**定義する旨を括弧書きで明記。standards/coding-standards.md「1. 整形・静的解析」（フォーマッタ／リンタ／型チェック）とは検出対象が異なる旨も明記し、読者が両者を混同しないようにした。 |
| 「13. 改正履歴」 | `[0.5.0]` エントリを追加（本提案の確定を条件とする）。 |
| バージョン | 0.4.0 → **0.5.0（提案。MINOR）**。根拠は本提案「4. バージョン増分の判定」。 |

**SAST 製品名は本文に一切記載していない**（NG-05 / WU04-03）。能力要件のみを規定し、ツール選定は ADR で行う対象として明記した。

### 2.2 standards/security-standards.md — Class A

* 新設「8. 第一者コードの静的解析（SAST）」を、既存「5. 脆弱性の重大度基準」（依存関係・CVSS ベース）とは**別項目として**追加した（統合しない。マスタープロンプトの明示的要求）。
  * SAST 製品名を記載しない（MUST NOT）。実行コマンドの解決は「環境変数、または `scripts/dev/` 配下の差し替え可能なラッパースクリプト」という汎用機構に限定する旨を規定した。
  * 具体的な重大度カットオフ値・スコアリング方式は `TBD-HUMAN`（本提案「5. 未解決事項」）とし、依存脆弱性基準（CVSS 7.0 以上）と構造的に対称な設計を**提案の形**として示すにとどめた。数値を発明していない（CON-05 / IMP-05）。
  * standards/coding-standards.md「1. 整形・静的解析」との違いを一文で明記し、既存文書は改変していない（要求どおり、フォーマッタ／リンタ／型チェックとセキュリティ脆弱性クラス検出を混同しない）。
* 新設「8.1 SAST が構造的に検出できない欠陥クラス（検出限界の開示）」で、**認可欠落・IDOR・ビジネスロジック不備**の3クラスを列挙し、これらが constitution.md「3. 基本原則」検証手段の選択が定める**人間ゲート（不可避）(a) 意味的判断**に該当する旨を明記（WU04-04）。「SAST 導入をもって網羅的なセキュリティ検証が完了したと表現してはならない（MUST NOT）」を明記した。
* バージョン: 0.2.0 → **0.3.0（提案・MINOR）**。

### 2.3 scripts/checks/sast.sh（新設） — Class A

`scripts/checks/build.sh` と同一のスタック検出条件（`package.json` / `go.mod` / `pom.xml` / `build.gradle(.kts)` / `pyproject.toml`・`requirements.txt`・`setup.py`）で休眠・活性化を判定する。

**ツール解決の設計（差し替え可能・製品非依存。NG-05 への対応）**:

1. 対象スタックが無ければ **休眠**し、`warn` + `exit 0`（コードを含まない採用で `task verify` を落とさない。WU04-02 MUST NOT）。
2. 対象スタックがあれば **活性化**し、次の順で SAST 実行コマンドを解決する。
   1. 環境変数 `SAST_CMD`（例: `"npx <tool> scan --severity=high"`）
   2. `scripts/dev/sast-tool.sh` が存在し実行可能ならそれを使う
3. どちらも見つからない場合、**サイレントに合格させない**。「SAST ツールが未配線である」ことを明示的に `warn` し、強制台帳（#36）を参照する形で `exit 0`（＝この状態を「不合格」ではなく「追跡された未配線」として扱う。ハード失敗にしない設計は master prompt の NG-05 の指示どおり）。
4. ツールが配線されている場合はそれを実行し、**終了コードをそのまま伝播する**（ツールが検出を報告すれば `task verify` は失敗する）。

正規表現・grep のみで自作の「SAST」を偽装することはしていない（NG-05 が明示的に禁止する行為）。本スクリプトが保証するのは「休眠/活性化の切り替えロジックと、配線されたツールの合否伝播」であり、脆弱性検出能力そのものではない。

### 2.4 Taskfile.yml — Class A

`check:sast`（`bash scripts/checks/sast.sh`）を新設し、`verify`（`check:deps` の直後、`check:build` の直前）に追加した。`verify:fast` には追加しない（`deps.sh`・`build.sh` と同じ位置づけ＝外部ツール依存になり得るチェック）。

### 2.5 governance/enforcement-ledger.md — Class A

新規行 **#36** を追加した。

| 列 | 値 |
| --- | --- |
| 規範 | 第一者コードの SAST に合格すること（8章。WU-04 で新設） |
| レベル | MUST |
| 強制手段 | 機械強制（休眠/活性化のスタック検出とゲート配線）＋人間ゲート（暫定）（実ツールによる脆弱性検出ロジックは未配線） |
| 理由区分 | — |
| 整備状況 | 整備中（休眠/活性化の切り替えとツール合否伝播は実装・動作確認済み。実ツールによる検出は SAST_CMD 未設定のため未整備） |
| 失効期限 | `TBD-HUMAN` |
| 担当 | `TBD-HUMAN` |
| 移行先ゲート | ADR で SAST ツールを選定し `SAST_CMD`（または `scripts/dev/sast-tool.sh`）として配線。CI に実ツールを導入し、standards/security-standards.md「8.」の重大度カットオフを確定した上で hard-fail 化する |
| 検証箇所 | verify ジョブ → scripts/checks/sast.sh ＋ standards/security-standards.md「8.」「8.1」 |

これは本台帳で**初めて実際に使用される人間ゲート（暫定）行**である（GP-0003 の再分類では、既存の「人間」を要する行はすべて人間ゲート（不可避）に分類され、人間ゲート（暫定）は0件だった）。IMP-01(ii) の要求どおり、「実際の脆弱性検出は未整備」と正直に記載し、活性化検出ロジックのみを「整備済み」と主張している（過大な整備状況の主張をしない。憲章「8. ブートストラップ規定」）。

**行番号の衝突可能性**: 本提案作成時点で本台帳の最終行は #35 である。同じベース（`governance/gp-0003-enforcement-ledger-schema`）から複数の作業単位（WU-03、WU-06〜09 等）が並行して行を追加している可能性があり、#36 は他の WU と衝突しうる。マージ時に人間が採番を調整することを前提とする。

バージョン: 0.5.0 → **0.6.0（提案・MINOR）**。

### 2.6 scripts/checks/selftest.sh — Class A

sast.sh の休眠/活性化の切り替えロジックが実際に動作することを4ケースで確認する（WU04-02 の実証）。

1. 休眠時（manifest 無し）: `exit 0` かつ「dormant」を含むメッセージ。
2. 活性化時（`package.json` を一時生成）・`SAST_CMD` 未設定: `exit 0` だが「no SAST tool is wired」を含み、休眠メッセージは出さない（休眠と活性化を文言で区別できることの確認）。
3. 活性化時・`SAST_CMD=false`（失敗を模擬）: `exit` が非ゼロ（`run_case` の陰性テストとして実装。ツールの失敗を隠蔽しないことの確認）。
4. 活性化時・`SAST_CMD=true`（成功を模擬）: `exit 0`（過検知しないことの確認）。

いずれも `mktemp -d` で作成した一時複製上で実施し、実リポジトリを変更しない（既存 selftest.sh の方針を踏襲）。ケース1・2は `run_case` の「違反注入→非ゼロで検出」という二値判定に馴染まないため、専用のアサーションとして実装した（ケース3のみ厳密な `run_case` の陰性テスト）。

## 3. WU-04 のタスク定義との対応

| ID | 対応 |
| --- | --- |
| WU04-01 | constitution.md「8.」に MUST を追加。重大度基準は standards/security-standards.md「8.」を正本とし、依存脆弱性基準「5.」とは別項目とした。 |
| WU04-02 | `scripts/checks/sast.sh` が build.sh と同一ロジックで休眠/活性化を判定。コードを含まない採用（本リポジトリ自身を含む）で `task verify` は失敗しない（実測: 本 PR 適用後もリポジトリ自身は package.json 等を持たないため sast.sh は休眠・`exit 0`）。 |
| WU04-03 | SAST 製品名は constitution.md にも standards/security-standards.md にも記載していない。`SAST_CMD` という汎用環境変数、または差し替え可能な `scripts/dev/sast-tool.sh` フックのみを規定。 |
| WU04-04 | standards/security-standards.md「8.1」に、認可欠落・IDOR・ビジネスロジック不備の3クラスを列挙し、人間ゲート（不可避）(a) に該当する旨を明記。「網羅的」という表現の使用を明示的に禁止する一文を含めた。 |

## 4. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転なし**。新設 MUST（第一者コードの SAST 合格）は既存ルールへの後方互換な追加拘束 |
| `task verify` | `check:sast` が新規に追加される。コードを含まない本リポジトリでは休眠・`exit 0` のため、現状の verify 結果は変化しない |
| コードを含まない採用 | 影響なし（休眠。WU04-02 の核心要求） |
| コードを含む採用（将来） | `SAST_CMD` 未配線の間は「未配線」警告つきで `exit 0`（合格）となる。**これは真の合格ではなく、追跡された未整備状態である**。ADR でツールを選定し配線するまでの間、実際の脆弱性検出は人間レビューに依存する（強制台帳 #36） |
| 強制台帳 | 新規1行（#36）を追加。本台帳で初めて人間ゲート（暫定）行が実際に使用される |
| AI エージェントの権限 | 変更なし |
| UI を持たない採用 | 影響なし（UI 固有の規定ではない） |
| standards/coding-standards.md | **変更していない**（既存内容の書き換えは行わず、security-standards.md 側から一文で区別を明記するにとどめた。要求どおり） |

## 5. バージョン増分の判定

| 文書 | 増分 |
| --- | --- |
| constitution.md | 0.4.0 → **0.5.0（提案・MINOR）** |
| standards/security-standards.md | 0.2.0 → **0.3.0（提案・MINOR）** |
| governance/enforcement-ledger.md | 0.5.0 → **0.6.0（提案・MINOR）** |

根拠: いずれも既存の MUST / MUST NOT の**撤廃・反転・意味変更はない**。新設した MUST（第一者コードの SAST 合格）・新設節（SAST 重大度基準・検出限界の開示）・新規台帳行は、既存ルールに対する**後方互換な追加拘束・追加情報**であり、既存の義務を弱めない。憲章「7. 変更管理」バージョニング方針の MINOR 例示（「新しい原則の追加、第8章への MUST ルール追加」）に該当する。**この判定は提案であり、確定は人間に委ねる**（CON-05 / 7章「増分種別の判定が曖昧な場合は確定前にその理由を提示する」）。

## 6. 実行した検証（生の出力）

```text
== structure / adr / adr-content / frontmatter / prompts ==
✓ structure
✓ ADR naming & status
ADR 本文・フロントマター値検査: OK（7 件）
✓ ADR content & front-matter values
✓ Front matter keys
✓ Prompt asset lifecycle

== markdown（Node 24） ==
markdownlint-cli2 v0.22.1 (markdownlint v0.40.0)
Finding: **/*.md
Linting: 140 file(s)
Summary: 0 error(s)
✓ Markdown lint

== adr-index / adr-immutability ==
adr/INDEX.md は最新です。
✓ ADR index
✓ Accepted ADR immutability

== enforcement-ledger ==
advisory: constitution.md 中の（MUST）/（MUST NOT）出現数 95 件 ／ 台帳行数 37 件
✓ Enforcement ledger schema (37 rows checked)

== sast（新設。休眠系） ==
⚠ no code stack detected — SAST skipped (dormant; activates when a manifest is added)
✓ SAST (dormant)

== build（コードスタック未検出のため skip） ==
⚠ no code stack detected — build/test skipped (activates when a manifest is added)
⚠ coverage gate NOT enforced yet — wire a threshold in your stack (ledger #15b)
✓ build/test

== ui.sh（full / fast、UI 未採用のため skip） ==
⚠ UI スタック未導入（package.json / src/ が無い）— skipped（採用時に自動で活性化する）
✓ UI gate (skipped)  ×2

== selftest（陽性対照 + 陰性テスト。sast を陽性対照に追加、sast 用ケースを4件追加） ==
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
[検出] sast.sh: 休眠時（manifest 無し）に exit 0 かつ休眠メッセージを出す
[検出] sast.sh: 活性化時（package.json 検出）は休眠メッセージを出さず、未配線を正直に警告して exit 0
[検出] sast.sh: SAST_CMD が設定され失敗を報告した場合は exit 0 にしない（合否伝播の確認）
[検出] sast.sh: SAST_CMD が成功を報告した場合は exit 0（過検知しない）
⚠ skip: ui: tokens:check が生成物の手編集を検出（task が無いため検出可否を判定できない）
自己診断: 検出 17 件 / 見逃し 0 件 / skip 1 件
✓ Gate self-test

== sast.sh 単体の手動確認（4状態。selftest とは別に個別実行して確認） ==
dormant（manifest 無し）                 → exit 0（"dormant" を含む警告）
active + SAST_CMD 未設定                 → exit 0（"no SAST tool is wired" を含む警告。dormant 文言は出ない）
active + SAST_CMD=true（ツール成功を模擬） → exit 0
active + SAST_CMD=false（ツール失敗を模擬）→ exit 1（合否を正しく伝播）

== links / secrets / deps（外部ツール不在のためローカルは skip。CI で実効） ==
⚠ lychee not found — skipped locally (CI runs it)
⚠ gitleaks not found — skipped locally (CI runs it)
⚠ trivy not found — skipped locally (CI runs it)

== pr_governance（ローカル実行・参考） ==
⚠ governance path changed — ensure the PR has the 'permission-impact' label
⚠ Class A/B path changed — PR body must reference ADR-#### or give a real 'ADR不要理由:'
✓ PR governance
```

## 7. 未解決事項

| ID | 種別 | 内容 | 必要な判断 |
| --- | --- | --- | --- |
| Q-01 | 数値の未確定 | SAST の重大度カットオフ（Critical/High 相当でマージ不可、とする「形」は提案したが、実際の閾値・ツールのスコアリング方式は確定していない） | ツール選定 ADR で確定（`TBD-HUMAN`） |
| Q-02 | 台帳の担当・失効期限 | 強制台帳 #36 の「担当」「失効期限」を `TBD-HUMAN` とした | 実際の担当者・現実的な失効期限を人間が指定 |
| Q-03 | 行番号の衝突 | 強制台帳 #36 は、同一ベースから並行する他の作業単位（WU-03、WU-06〜09）と番号が衝突する可能性がある | マージ時に人間が採番を調整 |
| Q-04 | `scripts/dev/sast-tool.sh` の要否 | 本提案では「差し替え可能なフックの置き場所」として言及するのみで、実体（雛形スクリプト）は作成していない（マスタープロンプトが要求する範囲を超えるため） | 雛形を用意するか、ツール選定 ADR まで作成しないか |
| Q-05 | `.specify/memory/constitution.md`（簡潔ビュー） | 本提案の対象外（WU-01・WU-02 と同様の扱い。SHOULD 事項であり追従は別途） | 追従のタイミングを人間が指定 |

**上記が未解決の間、本提案の値を確定として扱いません**（OUT-03 対応。TBD-HUMAN を暫定値で埋めて先に進まない）。

## 8. ベースブランチについて

本 PR は `governance/gp-0003-enforcement-ledger-schema`（WU-02。マージ済み）を base にしている。WU-01・WU-02 は共通祖先 `refactor/framework-neutral-ui-governance` を base にしたが、本 WU-04 は WU-02 が導入した強制台帳の10列スキーマ（理由区分・失効期限・担当・移行先ゲート）と `scripts/checks/enforcement-ledger.sh` の機械検証に**依存して新規行 #36 を追加する**ため、WU-02 の内容が既に取り込まれているブランチを base にする必要がある。

## 9. 承認

| 項目 | 内容 |
| --- | --- |
| 起案者 | claude-code（Sonnet 5）。統治改訂プロンプト WU-04 |
| 承認者・承認日 | 未承認（本提案は Proposed） |
| 定足数の充足 | 未充足（承認待ち） |
| 確定結果 | 未確定 |

## 10. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-20 | claude-code (Sonnet 5) | 初版作成、Proposed に設定 | 統治改訂プロンプト WU-04 の起案 |
