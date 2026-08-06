---
id: ADR-0003
title: "Storybook における Astro コンポーネントの描画方式"
status: proposed              # proposed | accepted | rejected | deprecated | superseded
date: 2026-08-06
last_updated: 2026-08-06
profile: minimal              # minimal | full
scope: project
proposer: "（起案者名）"
decision-makers: []           # proposed 段階は空（accepted 時に非空・adr-rules.md「4.」）
consulted: []
informed: []
tags: [frontend, storybook, astro]
review_after: ""              # accepted 時に YYYY-MM-DD を記入
depends_on: []
supersedes: []
superseded_by: []
relates_to: [ADR-0005]
---

# ADR-0003: Storybook における Astro コンポーネントの描画方式

> メタデータは冒頭フロントマターを唯一の正本とする（本文に再掲しない。adr-rules.md「3.」「4.」）。本ADRは最小プロファイル。
> 変更クラスは **B**（フレームワーク選定・公開インターフェース相当。development-process.md「1.」）。
> 関連標準: [standards/frontend-ui.md](../standards/frontend-ui.md)「2.」。

## 変更履歴

| 日付 | 変更者 | 変更内容（ステータス遷移を含む） | 理由 |
|------|--------|----------------------------------|------|
| 2026-08-06 | （起案者） | 初版作成、Proposed に設定 | UI 再現性レイヤ導入にあたり、着手前に確定が必要な前提として起案 |

## コンテキスト

### 背景

Storybook は標準では `.astro` ファイルを描画できない。一方で本テンプレートは Storybook を「design-spec の実行形」と位置づけ、視覚回帰と a11y 検査の基盤としている（constitution.md「10.1.4」「10.1.5」）。したがって描画方式の決定は UI 品質ゲート全体の前提となる。

この判断を保留したまま実装を始めると、コンポーネントを作った後に「Storybook に載らないので Story が書けない」ことが判明し、「10.1.4 Story 無きコンポーネントの禁止」を満たせないまま実装だけが進む状態になる。

### 前提（Assumptions）

- UI 実装スタックとして Astro を採用する。
- 視覚回帰・a11y 検査は Storybook のビルド成果物に対して実行する。

### 制約（Constraints）

- 採用パッケージのバージョンは `plan.md` に固定して記録する（standards/frontend-ui.md「2.」）。
- Storybook / Astro のメジャー更新に追随できる保守体制が必要。

## 決定要因

- 実装対象と検証対象が一致すること（乖離があると視覚回帰の意味が薄れる）
- 依存の保守性（コミュニティ依存か公式サポート経路か）
- Astro の「既定は静的」という利点をどこまで維持できるか

## 意思決定事項

- 決定の問い: Storybook で UI プリミティブをどう描画するか。
- 含む: UI プリミティブの実装技術と Storybook 連携方式。
- 含まない: 視覚回帰ツールの選定（Playwright を既定とする。standards/frontend-ui.md「4.」）。

## 選択肢

### 選択肢 A：コミュニティ製 Storybook フレームワークで `.astro` を直接描画

Astro の Container API を用いてサーバサイド描画するコミュニティパッケージを使う。

**メリット**: Astro コンポーネントをそのまま Story にできる。実装と検証対象が完全一致する。
**デメリット**: 保守がコミュニティ依存。`astro:assets` やフォント仮想モジュールに既知の制約。Storybook / Astro のメジャー更新時に追随を待つ必要がある。

### 選択肢 B：UI プリミティブを Preact 等で実装し、Astro はページ・レイアウト層に限定

Button / Card / Input などを Preact で書き、Storybook は公式サポート経路を使う。Astro は Layout・Page・データ取得を担当する。

**メリット**: Storybook の公式サポート範囲内。更新追随のリスクが小さい。
**デメリット**: Astro の「既定は静的」の恩恵が薄れる。Preact コンポーネントを静的描画するには `client:` を付けないことを徹底する必要がある。

### 選択肢 C：Storybook を使わない（視覚回帰は独自ハーネスで行う。ベースライン）

**メリット**: 外部依存が減る。
**デメリット**: a11y（axe）・interaction test・controls を自作することになり、得られるものに対して保守コストが見合わない。

## 決定（案）

- 採用する選択肢（案）: **保留**（採用プロジェクトが実装着手前に A / B を確定する）
- 決定理由: 本テンプレートは UI スタックを未採用であり、Storybook / Astro の対応状況は採用時点で確認すべき事項のため、テンプレート側で先に固定しない。
- 不採用案の理由: C は a11y・interaction・controls の自作コストが便益に見合わない（テンプレート段階で却下する）。

> **着手条件**: 本 ADR が Accepted となるまで、UI プリミティブの実装に着手しない（constitution.md「10.1.3 推測の禁止」）。

## 承認

> 承認者が記入。Accepted への遷移（変更履歴に記録）とフロントマター `status`/`decision-makers`/`review_after` の同時更新で確定する。承認は Class A・人間必須（constitution.md「6.」）。

| 項目 | 内容 |
|------|------|
| 確定した決定 | |
| 承認者・承認日 | |
| 見直し時期 | YYYY-MM-DD |

## 結果

> 承認後・見直し期日に記入。

- 採用パッケージとバージョンを `plan.md` に固定して記録する。
- 「10.1.4」の必須ファイル構成（`<Name>.astro` または `.tsx`）を決定に合わせて [standards/frontend-ui.md](../standards/frontend-ui.md) に反映する。
- B を選んだ場合、Astro 層のコンポーネントは Story を持たないため、視覚回帰はページ単位の Playwright スクリーンショットで補う。
