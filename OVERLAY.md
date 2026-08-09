# UI 再現性レイヤ（UI Reproducibility Overlay）

本書は、`agent-spec-template` に **UI 再現性**（デザインと実装の値の一致）を機械的に保証するレイヤを
追加した経緯と、その構成要素の索引です。

* 規範の正本: [constitution.md](constitution.md)「10.1 UI 再現性」
* 実装標準の正本: [standards/design-tokens.md](standards/design-tokens.md) / [standards/frontend-ui.md](standards/frontend-ui.md)
* 判断根拠の正本: [ADR-0003](adr/adr-0003-storybook-astro-rendering.md) / [ADR-0004](adr/adr-0004-cloudflare-deployment-target.md) / [ADR-0005](adr/adr-0005-css-token-enforcement.md)
* 導入のガバナンス決定: [governance/proposals/gp-0001-ui-reproducibility.md](governance/proposals/gp-0001-ui-reproducibility.md)

> 本書は上記の**索引と背景説明**であり、規範ではありません。矛盾する場合は上記の正本が優先します
> （憲章「2. 文書管理階層」）。

---

## なぜこのレイヤが要るのか

テンプレート本体が解決するのは**追跡可能性と承認統制**であって、**デザイン再現度**ではありません。
既存の CI が見るのは秘密情報・依存脆弱性・テスト・ADR 記載・統治設定の無断変更であり、いずれも
「`padding` が `24px` ではなく `20px` になっている」を検出できません。

一方でテンプレートの骨格は、この問題を解くのに適した形をしています。

| テンプレートの仕組み | このレイヤでの使い方 |
| --- | --- |
| `task verify` の一元化（Local = AI = CI） | ここに視覚回帰と Stylelint を接続すれば、CI 側の変更なしにゲート化できる |
| ブランチ保護の Required Status Check | 検証を「任意」から「必須」に変える最後のピース |
| 変更クラス A/B/C/D | **視覚回帰の基準画像更新を Class B にして AI から取り上げる** |
| ADR | 「Storybook で `.astro` を描画するか」等、先送りすると必ず破綻する決定を残す |
| AGENTS.md 集約 | ルールの追記先が一箇所で済む |
| `standards/` | トークン規約の置き場所として既に用意されている |

つまり**器はテンプレート、中身がこのレイヤ**です。

---

## 中核となる 4 つの機構

自然言語の「禁止事項」ではなく、この 4 つがデザイン差分を実際に止めています。

### 1. primitive を CSS に出力しない

[tokens/tokens.json](tokens/tokens.json) は `primitive`（生の値）と `semantic`（用途名）の 2 層。
CSS に出力するのは `semantic` のみです。**存在しない変数は使えない**ため、
「本来 semantic を使うべき場所で primitive を直接使う」誤りが構造的に起きません。

### 2. Stylelint が「トークン外の値 0 件」を証明する

`scale-unlimited/declaration-strict-value` により、色・余白・タイポ・角丸・影・
z-index・トランジションで `var(--...)` 以外を error にします。
`task ui:lint:css` が通ることが、そのまま「値の逸脱がない」ことの証明になります。

### 3. `@custom-media` でレスポンシブの抜け道を塞ぐ

CSS カスタムプロパティはメディアクエリの条件部で評価されません。
このため `@media (min-width: 768px)` と直書きされやすく、これが
「レスポンシブがデザインと違う」の最頻出原因になります。
`tokens.json` の `breakpoint` から `@custom-media --bp-*` を生成し、
生の値の直書きを [scripts/check-media-queries.mjs](scripts/check-media-queries.mjs) が検出します。

### 4. 基準画像の更新権限を AI から取り上げる

視覚回帰は差分検出の本体ですが、`--update-snapshots` を自由に実行できる状態では
検出器として機能しません。これを **Class B** に指定し、AI エージェントの実行を禁止しています
（憲章「10.1.5-4」・[development-process.md](development-process.md)「1.」・[AGENTS.md](AGENTS.md)「8.5」・強制台帳 #27）。
**この 1 行が無いと、他の 3 つがすべて空回りします。**

---

## 構成要素

### 統治文書への反映（Class A）

| 文書 | 追加内容 |
| --- | --- |
| [constitution.md](constitution.md) | 「10.1 UI 再現性」（10.1.1〜10.1.7）。バージョン 0.2.0 |
| [.specify/memory/constitution.md](.specify/memory/constitution.md) | 原則 X（ゲート用簡潔ビュー。本体と同期） |
| [AGENTS.md](AGENTS.md) | 「8. UI 実装のルール」 |
| [development-process.md](development-process.md) | 「1.」UI・デザイン領域のクラス表 |
| [governance/enforcement-ledger.md](governance/enforcement-ledger.md) | 規範 #23〜#28 |

### 新規ファイル

```text
tokens/tokens.json                              値の唯一の真実源
tokens/build.mjs                                依存ゼロの生成スクリプト
scripts/checks/ui.sh                            task verify への接続点（UI 未採用時は no-op）
scripts/check-spec-literals.mjs                 design-spec の生値検出
scripts/check-media-queries.mjs                 生ブレークポイント検出
scripts/check-component-stories.mjs             Story 欠落検出
standards/design-tokens.md                      トークン規約（Class A）
standards/frontend-ui.md                        Astro/Storybook/Cloudflare 標準（Class A）
.specify/templates/design-spec-template.md      design-spec の雛形
.stylelintrc.json                               強制機構（Class A）
lighthouserc.json                               Lighthouse 閾値
Taskfile.ui.yml                                 UI タスク定義
package.ui.json                                 devDependencies 抜粋（採用時に package.json へ統合）
prompts/workflows/ui-00〜04                     プロンプト資産
```

### 品質ゲートへの接続

`Taskfile.yml` から `Taskfile.ui.yml` を `includes`（`optional: true`）し、
`verify` / `verify:fast` に [scripts/checks/ui.sh](scripts/checks/ui.sh) 経由で接続しています。

```text
task verify:fast → check:ui-fast → scripts/checks/ui.sh fast → task ui:verify:fast
task verify      → check:ui      → scripts/checks/ui.sh full → task ui:verify
```

`scripts/checks/ui.sh` は `package.json` と `src/` の双方が存在するときにのみ UI ゲートを実行し、
未導入のリポジトリでは no-op（緑）を返します（[scripts/checks/build.sh](scripts/checks/build.sh) のスタック自動検出と同方針）。
これにより、UI を持たない採用でゲートが「常に赤 → 無視される」状態に陥ることを防ぎます。

**CI・lefthook・ブランチ保護の変更は不要です。** UI ゲートは `task verify` の内側に入るため、
`.github/workflows/verify.yml` は変更せず、必須ステータスチェックも `verify` のままで足ります。

---

## 採用手順（UI プロジェクトで有効化する）

1. **[ADR-0003](adr/adr-0003-storybook-astro-rendering.md) と [ADR-0004](adr/adr-0004-cloudflare-deployment-target.md) を決める。**
   特に ADR-0003（Storybook で `.astro` を直接描画するか、UI プリミティブを Preact 等で書くか）を
   保留したまま進むと、コンポーネントを作った後に「Storybook に載せられないので Story が書けない」ことが判明し、
   憲章「10.1.4」を満たせないまま実装だけが進みます。
2. `package.ui.json` の devDependencies を `package.json` へ統合し、バージョンを固定する。
3. `.github/workflows/verify.yml` の `task verify` の前に依存セットアップを追加する。

   ```yaml
   - uses: pnpm/action-setup@v4
   - uses: actions/setup-node@v4
     with: { node-version: '24', cache: 'pnpm' }
   - run: pnpm install --frozen-lockfile
   - run: pnpm exec playwright install --with-deps chromium
   ```

4. 動作確認。

   ```bash
   task ui:setup
   task ui:tokens          # 生成
   task ui:tokens:check    # 生成物とコミット内容の一致
   task ui:guards          # 3 つのガードスクリプト
   ```

5. 参照 HTML から視覚回帰の基準画像を撮影し、**人間が**承認する。

> `scripts/check-*.mjs` は `node:fs` の `globSync` を使用するため **Node.js 22 以上**が必要です。
> [.mise.toml](.mise.toml) は Active LTS を追跡し `node = "24"` を採用しています
> （[standards/security-standards.md](standards/security-standards.md)「6.」ランタイムの LTS 追随）。

> **活性化直後の注意**: `package.json` と `src/` を追加した時点で UI ゲートが有効になり、
> `task ui:guards` が `specs/**/design-spec.md` を要求します（1 件も無いと fail）。
> ステップ 1〜2 と並行して、最初の `design-spec.md` を
> [.specify/templates/design-spec-template.md](.specify/templates/design-spec-template.md) から起こしてください。
> これは仕様（design-spec）を先に置くという憲章「10.1.3 推測の禁止」の設計意図どおりの挙動です。

---

## 実行順序（プロジェクト運用）

```text
0. prompts/workflows/ui-00  Claude Code    トークンとガードレールを先に立てる
1. prompts/workflows/ui-01  Claude Design  トークン制約下でデザイン → design-spec.md
   ★ 人間が Open Questions を全て解消する（ここを飛ばすと推測が始まる）
2. prompts/workflows/ui-02  Claude Code    /speckit.specify → clarify → plan → tasks
3. prompts/workflows/ui-03  Claude Code    型定義と Story 設計
4. prompts/workflows/ui-04  Claude Code    タスク単位で実装。各タスク後に task verify
5. 参照 HTML から視覚回帰の基準画像を撮影（人間が承認）
```

**1 と 2 の間の人間の作業を省略しないこと。** Open Questions が残ったまま
`/speckit.specify` に進むと `[NEEDS CLARIFICATION]` として持ち越されますが、
実装フェーズで AI がそれを「一般的な解」で埋める誘因が生まれます（憲章「10.1.3 推測の禁止」）。

---

## 差分検出がどこで起きるか（対応表）

| 逸脱の種類 | 検出する仕組み | コマンド |
| --- | --- | --- |
| 色・余白・タイポの値が違う | Stylelint strict-value | `task ui:lint:css` |
| ブレークポイントが違う | 生メディアクエリ検出 | `task ui:guards` |
| design-spec とトークンの二重管理 | 生値検出 | `task ui:guards` |
| トークン生成物の手編集 | git diff | `task ui:tokens:check` |
| 存在しない variant の追加 | union 型 | `task ui:typecheck` |
| Story の無いコンポーネント | 構成チェック | `task ui:guards` |
| 見た目の崩れ（上記で拾えない全て） | 視覚回帰 | `task ui:test:visual` |
| フォーカスリング消去・コントラスト不足 | Stylelint + axe | `task ui:lint:css` / `task ui:test:stories` |
| キーボード操作の不備 | interaction test | `task ui:test:stories` |
| CLS / LCP の悪化 | Lighthouse CI | `task ui:lighthouse` |

**「差分を列挙してください」と AI に頼む代わりに、この表の右列を実行します。**

---

## 段階導入について

UI レイヤは統治の重さを増やします。案件規模に応じた調整は
[development-process.md](development-process.md)「8. 段階導入プロファイル（Lite / Standard / Regulated）」に従ってください。
**絶対ルールと安全ゲートは、いずれのプロファイルでも緩和できません**（憲章「4.」）。

`knowledge/` / `playbooks/` / `memory/` 等を空のまま置くと、AI エージェントがそこを読みに行き、
何も無いために推測で補います。使わないディレクトリは採用時に削除するか、
各 README に「本プロジェクトでは未使用」と明記してください（憲章「8. ブートストラップ規定」：
未整備の強制手段を整備済みであるかのように扱わない）。
