# ADOPTION-EXISTING.md — 既存プロジェクトへの導入手順（brownfield）

* Version: 0.1.0（Proposed / ドラフト）
* Date: 2026-08-24
* 上位規範: constitution.md（開発憲章）
* 併読: [ADOPTION.md](ADOPTION.md)（採用セットアップ手順の正本。本書は差分のみを扱う）

本書は、**すでにリリース済みの処理・稼働中のプロジェクト**へ本テンプレートを後から重ねる場合の手順書です。
[ADOPTION.md](ADOPTION.md) は「Use this template で新しいリポジトリを作る」経路（greenfield）を前提にしています。
既存リポジトリへの導入では前提が変わり、**そのまま適用すると初日に品質ゲートが全面的に赤になります**。

> 本書は ADOPTION.md を置き換えません。ステップ 1〜9 は共通です。本書は
> 「既存リポジトリだから追加で必要なこと」「そのままでは壊れること」だけを扱います。

---

## 0. なぜ新規採用と手順が違うのか

本テンプレートのゲートは「**コードがまだ無いリポジトリに、これからコードを足す**」ことを前提に設計されています
（`scripts/checks/*.sh` の休眠／活性化パターン。マニフェストが現れた時点でゲートが有効になる）。

既存プロジェクトでは、この前提が導入初日に一斉に崩れます。**コードも履歴も既にあり、そのすべてが
本テンプレートのルールが存在しなかった時代に書かれている**からです。

| ゲート | 新規採用 | 既存リポジトリで起きること |
| --- | --- | --- |
| 秘密情報スキャン（gitleaks） | 履歴が短く緑 | **全 git 履歴**を走査し、過去に混入した資格情報を必ず検出する。履歴を書き換えない限り恒久的に赤 |
| Markdown Lint / Link Check | 統治文書のみで緑 | 既存の全 `**/*.md` が対象。数百件の指摘とリンク腐敗で赤 |
| ビルド・テスト（`build.sh`） | マニフェスト検出で活性化 | リポジトリ直下で `npm ci` / `pytest` を素で実行する。monorepo・Makefile・tox 等の実際の入口と一致せず、`npm ci` は既存の `node_modules` を作り直す |
| 依存脆弱性（trivy） | 依存ゼロで緑 | 既存依存の HIGH/CRITICAL を検出。多くは即時解消できない |
| 差分規模の上限（Class A=200行） | 小さな PR のみ | **導入 PR 自体**が数千行の Class A 変更になり、上限を必ず超える |
| ADR 参照（`pr_governance.sh`） | 決定と同時に ADR を書く | 既存システムの設計判断は**すべて ADR が無い**状態から始まる |

ここで起きがちな失敗は、ゲートを外す・上限を引き上げる・`verify` を必須チェックから降ろす、という対応です。
これは憲章「6.」の **MUST NOT（自らの変更で失敗した品質ゲート・統治機構を、回避目的で弱めない）** に該当します。
本書は、その代わりに使える**統治下に置かれた段階適用**の手順を示します。

---

## 1. 前提の読み替え（着手前に確認する）

### 1.1 保護対象ブランチ名

本テンプレートは保護対象ブランチを `main` / `release/*` としています（[development-process.md](development-process.md)「4.」）。
既定ブランチが `master` / `develop` 等の場合、**CI が一度も起動せず、沈黙して強制が働きません**（fail-open）。
`bash scripts/checks/adoption.sh` が既定ブランチの不一致を検出して警告します。次をすべて実リポジトリの名前へ揃えてください。

- [ ] [.github/workflows/verify.yml](.github/workflows/verify.yml) の `on.push.branches` / `on.pull_request.branches`
- [ ] [.github/workflows/governance-gate.yml](.github/workflows/governance-gate.yml) の `on.pull_request_target.branches`
- [ ] [development-process.md](development-process.md)「4.」の保護対象ブランチ定義
- [ ] `scripts/checks/pr_governance.sh` と `scripts/check_diff_size.py` の `BASE_SHA` 既定値（`origin/main`）

### 1.2 既存ファイルとの衝突

テンプレートは「複製」を前提とするため、既存リポジトリでは**上書きしてはいけないファイル**があります。

| 既存にあるもの | 扱い |
| --- | --- |
| `README.md` / `CONTRIBUTING.md` / `LICENSE` | **既存を優先**。テンプレート版は参照として捨てるか別名で退避する |
| `.github/workflows/*` | 既存 CI は**残す**。本テンプレートの `verify.yml` / `governance-gate.yml` を**追加**する（置換しない） |
| `.gitignore` / `.editorconfig` | 既存へ**追記マージ**（テンプレート版で上書きしない） |
| `.github/CODEOWNERS` | 既存があれば統治文書のパスを**追記**する |
| `docs/` | 既存の `docs/` があるなら、テンプレートの MkDocs サイトは導入しない（別ディレクトリか、丸ごと省略） |

### 1.3 プロファイルの選択

既存プロジェクトは、たいてい既に運用ルール・レビュー慣行を持っています。
[development-process.md](development-process.md)「8.」の **Lite から始めて昇格する**ことを推奨します。
最初から Standard/Regulated を適用すると、既存の開発速度との落差が大きく、
「守られないルール」が残って統治全体の信頼を損ないます。選択は `governance/decisions/` に記録します（MUST）。

---

## 2. 導入 PR の差分規模（bootstrap paradox の解消）

統治文書一式（`constitution.md` / `standards/**` / `.github/**` / `scripts/**`）の導入は、
それ自体が数千行の **Class A** 変更です。Class A の上限 200 行に収めることは、分割しても不可能です
（統治文書一式は不可分な単位であり、半分だけマージした状態は整合しない）。

上限を引き上げてはいけません。代わりに [governance/waivers/](governance/waivers/README.md) の
**時限的な適用除外（gate-linked waiver）** を使います。これは統治文書が案内する正規の逃げ道であり、
`scripts/check_diff_size.py` が機械的に照合します。

```markdown
---
id: WV-0001
target_check: diff-size.class-a
status: Active
expires: 2026-12-31
---

# WV-0001: 既存リポジトリへの初期導入 PR の差分規模
（記録項目は governance/waivers/README.md「記録項目」に従う）
```

規約:

- `expires` は**必須**で実日付（`TBD-HUMAN` 等のプレースホルダは常に無効）。無期限の除外は作れません。
- 有効期限内に、waiver を必要としない状態（＝導入完了）へ到達させます。満了時は解消か再承認が必須です。
- 承認は Class A に準じます（**作成者 ≠ 承認者**）。この分掌は waiver では緩和できません（MUST NOT）。
- Class ごとに識別子が分かれています（`diff-size.class-a` / `diff-size.class-b`）。
  Class B 向けの waiver は Class A の超過を通過させません。

---

## 3. ゲートの段階適用（ratchet）

**原則: 既存の違反を「無かったこと」にせず、基準線として記録し、そこから悪化させない。**
新規に持ち込まれた違反だけを失敗させる（ratchet）ことで、ゲートは初日から検出器として機能します。

### 3.1 秘密情報スキャン（最優先・最重要）

既存リポジトリの履歴に残る資格情報は、**履歴から消せません**。しかし本質的な是正は履歴の消去ではなく
**ローテーション（無効化）** です。無効化された資格情報の検出は、以後は誤検知として扱えます。

```bash
# 1. まず何が検出されるかを見る（この時点では何も変えない）
gitleaks detect --source . --report-path .gitleaks-baseline.json

# 2. 検出されたすべての資格情報をローテーションする ← ここが本体
#    （baseline を作ることは是正ではない）

# 3. baseline をコミットする（監査対象の記録。.gitignore しない）
git add .gitleaks-baseline.json
```

`scripts/checks/secrets.sh` はリポジトリ直下の `.gitleaks-baseline.json` を自動で検出し、
以後は**新規に混入した秘密のみ**を失敗させます。baseline 適用中は毎回、記録件数とともに警告が出続けます
（黙って緑にしません。憲章「8. ブートストラップ規定」）。

- [ ] baseline に含まれる資格情報を**すべてローテーションした**ことを確認する
- [ ] baseline の存在と根拠を [governance/exceptions/](governance/exceptions/README.md) に登録する（Class A）

### 3.2 ビルド・テスト

既存の入口をそのまま接続します。自動検出に合わせてプロジェクトを変形させないでください。

```bash
# 環境変数（CI 側で設定）
BUILD_CMD="make ci"

# または実行可能スクリプト（コミットして版管理する）
scripts/dev/build-tool.sh
```

終了コードはそのまま伝播します（差し替えは緩和ではありません）。詳細は [scripts/dev/README.md](scripts/dev/README.md)。

### 3.3 Markdown Lint / Link Check

既存ドキュメント全体を一度に緑にする必要はありません。対象を統治文書から広げていきます。

- `.markdownlint.jsonc` の `ignores`、または `scripts/checks/markdown.sh` の glob を、まず統治文書に絞る
- [.lycheeignore](.lycheeignore) に、恒久的にボット判定される URL を個別登録する
- 範囲を狭める場合は**その事実と拡大計画**を `governance/exceptions/` に記録する（黙って狭めない）

### 3.4 依存脆弱性・SAST・アーキテクチャ境界

- 依存脆弱性（`deps.sh`）: 即時解消できない HIGH/CRITICAL は、期限付き waiver ではなく
  **修正計画**を [governance/risk-register/](governance/risk-register/README.md) に登録して追跡します。
- SAST（`SAST_CMD`）・アーキテクチャ境界（`ARCH_BOUNDARY_CMD`）: 既存コードでは初回に大量検出されます。
  ツール側の baseline 機能（多くの SAST が持つ）を使い、新規混入のみを失敗させます。
  配線までは「未配線」として正直に警告され続けます（[ADOPTION.md](ADOPTION.md)「ステップ8」）。

### 3.5 段階適用の記録

範囲を狭めた／baseline を敷いたゲートは、**すべて期限と担当付きで記録します**。
記録しないまま狭めた範囲は、時間が経つと「もともとそういう設計だった」ことになり、二度と戻りません。

| 手段 | 使う場面 | 期限 |
| --- | --- | --- |
| [governance/waivers/](governance/waivers/README.md) | 規範を**時限的に満たせない**（差分規模・機械強制率） | 必須（無期限禁止） |
| [governance/exceptions/](governance/exceptions/README.md) | 特定文脈で**意図的に別解を採る**（baseline の採用・lint 範囲の限定） | 是正計画を必須とする |
| [governance/risk-register/](governance/risk-register/README.md) | 解消に時間を要するリスクの受容 | 再評価期日を必須とする |

---

## 4. 既存の設計判断を ADR にする（as-built ADR）

既存システムには、**すでに効力を持っているが記録されていない決定**が多数あります（DB 選定・認証方式・
デプロイ構成・外部連携）。ADR が 1 件も無い状態では、Class A/B の PR で毎回「ADR不要理由」を書くことになり、
ゲートが形骸化します。

### 4.1 やらないこと

- **全部を遡って ADR にしない。** 網羅は目的ではありません。doc-churn を生むだけです。
- **承認記録を捏造しない。** 「当時これを承認した」という事実が無いのに `decision-makers` を埋めてはいけません。
  監査証跡の汚染は、本テンプレートが最も避けたい失敗です（[ADOPTION.md](ADOPTION.md)「ステップ9」と同じ問題）。

### 4.2 書く対象の決め方

次のいずれかに該当するものだけを書きます。

1. **これから変更しようとしている**領域の決定（変更 PR の根拠として必要になる）
2. 新規参画者が繰り返し質問する決定
3. 「なぜこうなっているか分からないので触れない」と言われている決定

### 4.3 書き方（既存の様式のまま実現する）

[adr-rules.md](adr-rules.md) を改正する必要はありません。既存のフロントマター規約のままで表現できます。

| キー | 既存決定を記録する場合の値 |
| --- | --- |
| `status` | `accepted`（現に有効な決定であるため） |
| `date` | **決定が実際に効力を持ち始めた日**（分からなければ最も古い関連コミットの日付） |
| `last_updated` | ADR を書いた日 |
| `decision-makers` | **この ADR を「現状の記録」として承認した人**（当時の意思決定者ではない） |
| `tags` | `as-built` を付ける（遡及記録であることを機械的に識別できるようにする） |
| `review_after` | 必須（`accepted` のため）。既存決定ほど見直し期日を明示する価値がある |

本文の「コンテキスト」冒頭に、次を明記します（**これが承認記録の捏造を防ぐ唯一の装置です**）。

```markdown
> 本 ADR は既に稼働中の決定を事後に記録したもの（as-built）です。
> 当時の検討経緯・却下案は一次資料が残っておらず、実装とヒアリングから再構成しています。
> 「承認」欄は、この記録が現状を正しく表していることの承認であり、当時の意思決定の承認ではありません。
```

「選択肢」には、再構成できた範囲だけを書き、**分からない部分は「記録が残っていない」と書きます**。
推測で埋めてはいけません（憲章「10.1.3 推測の禁止」と同じ趣旨）。

---

## 5. 既存機能の spec をどう扱うか

`specs/` も同様に、**遡って全機能の spec を書きません**。

- 原則: **これから変更する機能についてのみ** spec を起こす（変更の単位で spec 化していく）
- 既存の振る舞いは spec の「現状（As-Is）」として、変更差分と一緒に記述する
- テストが既存の振る舞いの正本になっている場合、それを spec から参照する（二重管理しない）

`specs/README.md` に、自プロジェクトの方針（どこから spec 化するか）を 1 段落で記録してください。

---

## 6. 導入の順序（推奨）

大きな 1 PR にせず、次の順で段階的に入れると、各段階で緑を確認しながら進められます。

| # | 内容 | クラス | 完了の目安 |
| --- | --- | --- | --- |
| 1 | `constitution.md` / `AGENTS.md` / `development-process.md` / `adr-rules.md` ほか統治文書一式 | A | `task verify:fast` が緑（waiver 必要） |
| 2 | `Taskfile.yml` / `scripts/**` / `.mise.toml` / `lefthook.yml` | A | `task verify` が緑（baseline・`BUILD_CMD` 配線後） |
| 3 | `.github/workflows/verify.yml` / `governance-gate.yml` / `CODEOWNERS` / PR テンプレート | A | CI が起動し緑 |
| 4 | ブランチ保護・必須チェック登録（[ADOPTION.md](ADOPTION.md)「ステップ3」） | 設定 | 保護が効いていることを確認 |
| 5 | テンプレート由来の統治履歴・サンプルの除去（[ADOPTION.md](ADOPTION.md)「ステップ9」） | A | `scripts/checks/adoption.sh` の該当 warn が消える |
| 6 | 最初の as-built ADR（1〜3 件） | A | `task verify` が緑 |
| 7 | 未配線ゲートの活性化（[ADOPTION.md](ADOPTION.md)「ステップ8」） | A | `SAST_CMD` 等が配線済み |

1〜3 の間、CI は必須チェックにせず**任意**で回します。緑になってから必須へ昇格させてください
（赤いまま必須にすると、開発が止まるか、ゲートが外されます）。

---

## 7. 完了条件（Definition of Done）

- [ ] `task verify` がローカルと CI の両方で緑
- [ ] `verify` と `governance-gate` の両方が必須ステータスチェックに登録されている（[ADOPTION.md](ADOPTION.md)「ステップ3」）
- [ ] `bash scripts/checks/adoption.sh` の警告が、**残っている理由を説明できるものだけ**になっている
- [ ] 発行した waiver / exception / risk がすべて期限・担当付きで登録されている
- [ ] `python3 scripts/check_governance_metrics.py --write-baseline` を実行し、自組織の基準値を記録した
- [ ] 秘密情報 baseline に含まれる資格情報を**すべてローテーションした**
- [ ] テンプレート由来の統治履歴・サンプルを除去または明示した（[ADOPTION.md](ADOPTION.md)「ステップ9」）

---

## 改正履歴

### [0.1.0] - 2026-08-24

* 初版ドラフト。既存リポジトリへの導入（brownfield）経路を新設。従来 ADOPTION.md は
  「Use this template で新規リポジトリを作る」経路のみを扱っており、既存リポジトリでは
  初日に全ゲートが赤になること、導入 PR 自体が Class A の差分規模上限を超えること、
  既存の設計判断に ADR が存在しないことへの手順がどこにも無かった。
