---
id: GD-0004
title: "憲章 0.3.0（UI 統治のフレームワーク非依存化）"
status: Accepted              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-09
last_updated: 2026-08-09
proposer: "makinoh"
approvers: ["makinoh"]        # Lite プロファイル（GD-0001）により定足数 1 名
target_version: 0.3.0
supersedes: []
superseded_by: []
relates_to: [GD-0001, GD-0002, GD-0003, ADR-0003, ADR-0004]
---

# GD-0004: 憲章 0.3.0（UI 統治のフレームワーク非依存化）

> ガバナンス決定の確定記録（憲章「7. 変更管理」）。

## 1. 決定

憲章「10.1 UI 再現性」および関連する統治文書から、**特定のフレームワーク・メタフレームワーク・
クラウド基盤への依存を除去**します。バージョンを **0.2.1 → 0.3.0（MINOR）** とします。

## 2. 理由

0.2.0 で導入した「10.1」は、UI 再現性の原則としては妥当でしたが、**製品名を規範に焼き込んで**いました。

| 焼き込まれていた箇所 | 内容 |
| --- | --- |
| `constitution.md` §10.1.6 | 見出しが「Server First（**Astro**）」 |
| `constitution.md` §10.1.6-2 | `client:*` ディレクティブ（Astro 固有記法）を MUST の条件に使用 |
| `constitution.md` §10.1.4 | 必須ファイル構成が `<Name>.astro`（または `.tsx` 等）と Astro 先頭 |
| `.specify/memory/constitution.md` | `client:*` |
| `development-process.md`「1.」 | 変更クラス表に `client:*` の新規付与 |
| `AGENTS.md`「8.1」 | Island 判定の選択肢が `client:visible` / `client:load` |
| `standards/design-tokens.md`「4.」 | 設定例が `astro.config.mjs` 固定 |
| `standards/frontend-ui.md` | 文書全体が Astro / Storybook / Cloudflare 前提 |
| `Taskfile.ui.yml` | `typecheck` が `astro check` を無条件実行 |

本テンプレートの成果物は「**どの組織・どの技術スタックでも使える統治の器**」です。最高位の統治文書が
特定製品に依存していると、Enterprise 採用（既存クラウド契約・データ所在地・組織のフレームワーク方針が
先に決まっている案件）で**憲章そのものを書き換えなければ採用できません**。これは統治文書としての
致命的な欠陥です。

## 3. 変更内容

### 3.1 憲章（constitution.md）— 0.2.1 → 0.3.0

- 「10.1」前文に、**特定のフレームワーク・メタフレームワーク・クラウド基盤を前提としない**旨、
  および選定は ADR-0003 / ADR-0004 で採用プロジェクトが**開発の性質を確認したうえで**行う旨を明記。
- 「10.1.6」の見出しから製品名を削除（`Server First（既定はクライアント JavaScript を送らない）`）。
  `client:*` を「クライアント側ハイドレーション」に一般化し、具体的記法の正本を standards へ委譲。
- 「10.1.4」の必須ファイル構成を、拡張子が採用フレームワークに従う形へ一般化。

**増分の根拠**: 既存の義務（既定はサーバ完結／ハイドレーションは design-spec の Island 判定に従う／
新規付与は Class B／Story 必須）は**撤廃も反転もしていません**。適用範囲を特定フレームワークから
全フレームワークへ**拡大**する実質的拡張のため **MINOR**（「7. 変更管理」バージョニング方針）。

### 3.2 その他の統治・強制機構 — Class A

| 対象 | 変更 |
| --- | --- |
| [.specify/memory/constitution.md](../../.specify/memory/constitution.md) | 原則 X を追従（0.3.0）。フレームワーク非依存である旨を明記 |
| [development-process.md](../../development-process.md) | 変更クラス表の `client:*` を一般化。**技術選定（ADR-0003/0004）を Class A として明示** |
| [AGENTS.md](../../AGENTS.md) | 「8.1」の Island 判定を記法非依存に |
| [standards/frontend-ui.md](../../standards/frontend-ui.md) | **再構成**（0.1.0 → 0.2.0）。「1.〜7.」を基盤非依存の要求とし、Astro / Cloudflare は**付録の実装例**へ降格。「1.」に技術選定の順序（性質確認 → コンポーネント層 → メタフレームワーク → 基盤）を新設 |
| [standards/design-tokens.md](../../standards/design-tokens.md) | PostCSS 設定例を「設定ファイル名は採用フレームワークに依存」と明示 |
| [Taskfile.ui.yml](../../Taskfile.ui.yml) | `typecheck` を `tsc --noEmit` のみに。フレームワーク固有の型検査は採用時に追加 |

### 3.3 ADR — Class A

| ADR | 変更 |
| --- | --- |
| [ADR-0003](../../adr/adr-0003-storybook-astro-rendering.md) | 問いを「Storybook × Astro の描画方式」から「**コンポーネント層の技術選定とメタフレームワークからの分離方針**」へ再定義。評価軸・未確定事項・確定手順を追加。**推奨は選択肢 B（層の分離）**だが、具体的技術は未確定のまま `proposed` を維持 |
| [ADR-0004](../../adr/adr-0004-cloudflare-deployment-target.md) | 問いを「Cloudflare のデプロイ先」から「**配信・実行基盤の選定**」へ再定義。基盤共通の要求と評価軸を追加。**加重評価は行わない**（組織制約が支配的で、それを知らずにスコアを付けることは推測にあたるため）。`proposed` を維持 |

いずれも `proposed` のため、Accepted ADR の不変性（adr-rules.md「5.」）には抵触しません。

### 3.4 ファイル名を変更しない判断

ADR-0003 / ADR-0004 のファイル名（`adr-0003-storybook-astro-rendering.md` /
`adr-0004-cloudflare-deployment-target.md`）は、タイトルを再定義した後も**変更しません**。

理由: **accepted 済みの [ADR-0005](../../adr/adr-0005-css-token-enforcement.md) が
`adr-0003-storybook-astro-rendering.md` へリンクしている**ためです。リネームすると ADR-0005 の
本文修正が必要になりますが、Accepted ADR の本文改変は禁止されています（adr-rules.md「5. 遷移と
不変性の規則」）。番号（ADR-0003 / ADR-0004）は不変であり、参照の同一性は保たれます。

> これは不変性ルールが**実際に運用を拘束した**事例です。ルールを回避せず、制約を受け入れて
> 記録に残します（憲章「自己修正ループの防止」）。

## 4. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転なし**。適用範囲の拡大のみ（MINOR の根拠） |
| 既存の強制機構 | **変更なし**。`scripts/check-*.mjs` は元から拡張子非依存（`astro\|tsx\|jsx\|vue\|svelte`）、ADR-0005（CSS Modules + Stylelint）もフレームワーク非依存 |
| Astro / Cloudflare を採用する場合 | 影響なし。付録 A / B に実装例を維持 |
| Astro / Cloudflare 以外を採用する場合 | **憲章を書き換えずに採用できるようになった**（本決定の目的） |
| AI エージェントの権限 | 変更なし |

## 5. 検討した代替案

| 代替案 | 却下理由 |
| --- | --- |
| 憲章はそのままにし、standards のみ一般化する | 憲章「10.1.6」の見出しと MUST 条件に製品名が残る。最高位文書の依存が解消されない |
| Astro / Cloudflare を「既定」として残す | 既定は検討を経ずに採用される。組織制約が支配的な基盤選定で既定を置くことは有害（ADR-0004「評価」参照） |
| ADR-0003 / 0004 をここで確定する | 開発の性質が未確定。推測での確定は憲章「10.1.3 推測の禁止」に反する |
| ADR ファイル名をタイトルに合わせてリネームする | accepted 済み ADR-0005 のリンク修正が必要になり、不変性ルールに抵触する（3.4） |

## 6. 定足数

| 項目 | 内容 |
| --- | --- |
| 承認者 | `makinoh`（リポジトリオーナー） |
| 承認日 | 2026-08-09 |
| 定足数 | 1 名（Lite プロファイル・[GD-0001](gd-0001-adoption-profile-lite.md)） — 充足 |

> 起案は AI エージェント（Claude Code / Opus 5）。承認・反映は人間が行いました
> （憲章「7.」: AI エージェントは本書改正を単独で承認・反映してはならない MUST NOT）。
> 作成者＝承認者である点は [RISK-0001](../risk-register/risk-0001-single-maintainer-separation-of-duties.md) として受容済みの既知事項です。

## 7. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-09 | makinoh | 初版作成、Accepted | 統治文書のフレームワーク依存という設計欠陥の是正 |
