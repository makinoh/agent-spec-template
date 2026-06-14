---
title: トラブルシューティング
description: 導入・品質ゲート・ADR・spec・PR・spec-kit・ドキュメントサイトでよくある32のつまずきを、症状・原因・解決方法の形式で解説。
---

# トラブルシューティング

つまずきを **症状 / 原因 / 解決方法** の形でまとめました。
解決しないときは [FAQ](faq.md) と [用語集](reference/glossary.md) も参照してください。

## 環境・ツール

### `task: command not found`

- **症状:** `task verify` で command not found。
- **原因:** Task（taskfile）が未導入。
- **解決方法:** 公式手順で `task` を導入する。導入できない場合は `bash scripts/checks/*.sh` を個別に実行。Windows は WSL/Git Bash で。

### `task setup` が失敗する

- **症状:** ツール導入が途中で止まる。
- **原因:** `mise` が未導入、またはネットワーク制限。
- **解決方法:** `mise` を先に導入してから `task setup`。`task doctor` で何が不足しているか確認する。

### `python: command not found`（または `python3`）

- **症状:** `scripts/generate_adr_index.py` が動かない。
- **原因:** Python が未導入、または `python` / `python3` の名前差。
- **解決方法:** Python 3 を導入。環境に合わせて `python` か `python3` を使い分ける（`task fix` は両方を試行）。

### Windows でスクリプトが動かない

- **症状:** `.sh` が実行できない／改行コードで失敗。
- **原因:** チェックは bash 前提。PowerShell では動かない。
- **解決方法:** **WSL2** か **Git Bash** で実行する。リポジトリは WSL 側に置くのが確実。

### `markdownlint-cli2` / `lychee` が無いと言われる

- **症状:** markdown / link チェックがスキップまたは失敗。
- **原因:** 対応ツールが未導入。
- **解決方法:** `task setup` で導入、または `npm i -g markdownlint-cli2`。lychee は公式手順で導入。未導入時は `need` ガードによりローカルでスキップされる（CI では実行）。

## 品質ゲート（markdown / links / frontmatter / structure）

### Markdown Lint が赤になる

- **症状:** `check:markdown` でルール違反（例: MD046）。
- **原因:** 見出し前後の空行不足、コードブロックのスタイル混在、インデントの誤認など。
- **解決方法:** `task fix`（`markdownlint-cli2 --fix`）で自動修正。`!!!` 注記の直後に空行を置くと indented code 扱いになるため、blockquote を使うか空行を入れない。

### Link Check（lychee）が赤になる

- **症状:** リンク切れで `check:links` が失敗。
- **原因:** 相対パスの誤り、移動した見出し、到達不能な外部 URL。
- **解決方法:** 相対パスを実ファイルに合わせる。外部 URL は実在・到達可能なものに。`.lycheecache` は再生成されるので消してよい。

### front matter のキーが無いと言われる

- **症状:** `check:frontmatter` が ADR / spec で失敗。
- **原因:** 必須キー不足（ADR: `id`/`title`/`status`/`date`/`profile`、spec: `feature_id`/`title`/`status`）。
- **解決方法:** テンプレート（`adr-template*.md` / `.specify/templates/spec-template.md`）からコピーしてキーを揃える。

### 構造チェック（structure）が赤

- **症状:** `check:structure` が失敗。
- **原因:** 必須文書の欠落、または `CLAUDE.md` 等が `AGENTS.md` を、`AGENTS.md` が `constitution.md` を参照していない。
- **解決方法:** 必須文書（README/AGENTS/constitution、`adr/`）を揃え、相互参照を復元する。

## ADR

### ADR 命名でゲートが赤

- **症状:** `check:adr` がファイル名で失敗。
- **原因:** 命名規則違反。
- **解決方法:** `^adr-[0-9]{4}-[a-z0-9]+(-[a-z0-9]+)*\.md$` に合わせる（小文字・4桁連番・ハイフン）。`0000` は予約。

### ADR の Status が無効と言われる

- **症状:** Status 検証で失敗。
- **原因:** フロントマターの `status` が大文字、または語彙外。
- **解決方法:** 小文字で `proposed` / `accepted` / `rejected` / `deprecated` / `superseded` のいずれかにする。

### `review_after` / `decision-makers` で失敗

- **症状:** accepted の ADR で検証エラー。
- **原因:** accepted なのに `review_after`（日付）や `decision-makers` が空。
- **解決方法:** accepted 化時に `review_after` を `YYYY-MM-DD`、`decision-makers` を非空にする。Proposed 段階は空でよい。

### ADR 索引に差分があると言われる

- **症状:** `check:adr-index` が差分を検出。
- **原因:** `adr/INDEX.md` を手編集した、または再生成し忘れ。
- **解決方法:** `python scripts/generate_adr_index.py` を実行してコミット。INDEX は手編集しない。

### Accepted の ADR を変更したら不変性チェックで赤

- **症状:** `check:adr-immutability` が失敗。
- **原因:** Accepted 後に本文を実質変更した。
- **解決方法:** 新しい ADR を起案して旧 ADR を Superseded にする。誤記修正は変更履歴に記録した上で行う。

## spec / spec-kit

### `/speckit.*` コマンドが使えない

- **症状:** エージェントでスラッシュコマンドが認識されない。
- **原因:** spec-kit が未導入、または対応していないエージェント。
- **解決方法:** 公式 <https://github.com/github/spec-kit> で導入。手動なら `.specify/templates/` を複製して同じ成果物を作る。

### AI が spec を無視していきなり実装する

- **症状:** 仕様前にコードが出てくる。
- **原因:** 指示が曖昧、または spec フェーズを飛ばしている。
- **解決方法:** 先に `/speckit.specify` → `/speckit.plan` を求める。spec を受け入れ基準として明示する。

### AI が `AGENTS.md` のルールに従わない

- **症状:** ルール無視の出力。
- **原因:** ツール固有ファイル（`CLAUDE.md` 等）が `AGENTS.md` を参照していない／自動読込されていない。
- **解決方法:** 委譲ファイルがルート直下にあり `AGENTS.md` を参照しているか確認（[マルチエージェント](concepts/multi-agent.md)）。

## PR・ガバナンス

### 重大変更なのに「ADR 参照が無い」で CI が赤

- **症状:** `check:pr-governance` が失敗。
- **原因:** Class A/B の PR に ADR 参照も「不要理由」も無い。
- **解決方法:** PR 本文に ADR 番号、または「ADR 不要理由」を明記する。

### `permission-impact` ラベルや CODEOWNERS 承認が要ると言われる

- **症状:** 統治パスの変更がマージできない。
- **原因:** 統治・強制機構（`.github/`、`constitution.md`、`standards/` 等）に触れている。
- **解決方法:** `permission-impact` ラベルを付け、CODEOWNERS の承認を得る。これは Class A。

### 自分の PR を自分でマージできない

- **症状:** 承認・マージがブロックされる。
- **原因:** 作成者≠承認者（職務分掌）の機械強制。
- **解決方法:** 作成者以外の人間にレビュー・承認してもらう。AI は自己承認・自己マージ不可。

### AI がゲートを緩めて通そうとした

- **症状:** ゲート定義の変更 PR が止まる。
- **原因:** ゲート/統治パスの変更は目的を問わず Class A。
- **解決方法:** 原因側（失敗したコード/文書）を直す。ゲート見直しが必要なら失敗との関連を開示し人間承認を得る。

### クラスの付け方が分からず止まる

- **症状:** どのクラスか判断できない。
- **原因:** 対象パス・内容トリガの確認不足。
- **解決方法:** `development-process.md`「1.」の対応表で一次判定。迷ったら **Class A**（[ガバナンス](concepts/governance.md)）。

## ビルド・セキュリティ

### secret スキャンが赤

- **症状:** `check:secrets` が秘密情報を検出。
- **原因:** API キー等のハードコード。
- **解決方法:** 環境変数に移す。`.env` は `.gitignore` 済み。誤検知なら許可リストを検討（人間承認）。

### 依存の脆弱性スキャンが赤

- **症状:** `check:deps` が失敗。
- **原因:** 重大度基準以上の既知脆弱性を含む依存。
- **解決方法:** 依存を更新。重大度基準は `standards/security-standards.md`。新規追加・メジャー更新は Class A。

### ビルド/テスト/カバレッジが赤

- **症状:** `check:build` が失敗。
- **原因:** 型エラー・テスト失敗・カバレッジ不足。
- **解決方法:** 原因を修正。カバレッジ閾値は `standards/testing-standards.md`。テストは合成データで。

## ドキュメントサイト（MkDocs）

### `mkdocs build --strict` が失敗する

- **症状:** ビルドがエラーで止まる。
- **原因:** nav 未登録のページ、docs 外への相対リンク、未解決リンク。
- **解決方法:** すべての `.md` を `mkdocs.yml` の `nav` に登録。リポジトリ本体のファイルへは相対リンクせず、コード表記か該当解説ページへリンクする。

### ページがサイドバーに出ない

- **症状:** 作ったページが表示されない。
- **原因:** `nav` への登録漏れ。
- **解決方法:** `mkdocs.yml` の `nav` に追記する。

### Mermaid 図が表示されない

- **症状:** 図がコードのまま表示。
- **原因:** `pymdownx.superfences` の mermaid カスタムフェンス設定が無い／古い Material。
- **解決方法:** `mkdocs.yml` の `markdown_extensions` に mermaid フェンス設定があるか確認し、`mkdocs-material` を更新する。

### 日本語の検索がうまく効かない

- **症状:** 検索ヒットが少ない。
- **原因:** 検索プラグインの言語設定。
- **解決方法:** `plugins.search.lang` に `ja` を含める（本テンプレートは設定済み）。

### Pages にデプロイされない

- **症状:** GitHub Pages が更新されない。
- **原因:** Pages の Source 未設定、またはワークフロー未承認（Class A）。
- **解決方法:** Settings → Pages → Source を **GitHub Actions** に。`deploy-docs.yml` は Class A なので人間レビュー後にマージ。

---

> それでも解決しないときは [FAQ](faq.md)、概念は [コンセプト](concepts/index.md)、用語は [用語集](reference/glossary.md) を確認してください。
