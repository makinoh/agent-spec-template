---
title: コマンド集
description: task（品質ゲート）、/speckit.*（spec-kit）、スクリプト、MkDocsドキュメントサイトの主要コマンドリファレンス。
---

# コマンド集

## 品質ゲート（task）

すべて同じ入口 `task` から実行します（開発者・AI・CI 共通）。

| コマンド | 用途 |
| --- | --- |
| `task verify` | 包括チェック（CI と同一）。push / PR 前に |
| `task verify:fast` | 高速チェック。コミット前に |
| `task verify:pr` | PR 文脈の統治チェック（pr-governance / adr-immutability / adoption） |
| `task setup` | ツールチェーン導入（mise / `.mise.toml`） |
| `task hooks` | Git フック有効化（lefthook） |
| `task fix` | markdownlint --fix ＋ ADR 索引再生成 |
| `task doctor` | 使えるチェックツールを表示 |
| `task --list` | タスク一覧 |

個別チェック（`task verify` がまとめて呼ぶ実体）:

```text
check:structure  check:adr        check:adr-content  check:frontmatter
check:prompts    check:markdown   check:adr-index    check:links
check:secrets    check:deps       check:build        check:pr-governance
check:adr-immutability            check:adoption
```

## spec-kit（AI エージェントのスラッシュコマンド）

| コマンド | 作るもの |
| --- | --- |
| `/speckit.constitution` | `.specify/memory/constitution.md`（簡潔ビュー） |
| `/speckit.specify` | `specs/<f>/spec.md`（What/Why） |
| `/speckit.clarify` | spec の `[NEEDS CLARIFICATION]` 解消 |
| `/speckit.plan` | `specs/<f>/plan.md` ＋ Constitution Check ＋（Class A/B）ADR 起票 |
| `/speckit.tasks` | `specs/<f>/tasks.md`（クラス・承認要否を付す） |
| `/speckit.analyze` | spec/plan/constitution の整合点検 |
| `/speckit.implement` | 実装（テスト含む） |

> 導入は公式 <https://github.com/github/spec-kit>。考え方は [spec-kit](../concepts/spec-kit.md)。

## スクリプト（直接実行する場合）

| コマンド | 用途 |
| --- | --- |
| `python scripts/generate_adr_index.py` | `adr/INDEX.md` を再生成 |
| `bash scripts/checks/adoption.sh` | 未置換プレースホルダ・結線漏れの点検 |
| `bash scripts/doctor.sh` | ツール可用性の確認 |

> `scripts/**` は既定で **Class A**（品質ゲートの実体）。ゲートに関与しない開発補助のみ `scripts/dev/**`（Class C）に置けます。

## ドキュメントサイト（MkDocs）

| コマンド | 用途 |
| --- | --- |
| `pip install -r requirements-docs.txt` | ビルド依存の導入 |
| `mkdocs serve` | ローカルプレビュー（既定 `http://127.0.0.1:8000`） |
| `mkdocs build --strict` | 本番ビルド（警告をエラー扱い） |

> 公開は GitHub Actions（`.github/workflows/deploy-docs.yml`）。このワークフローは **Class A**（`.github/**`）です。

## よく使う Git フロー（参考）

```bash
git switch -c feat/00X-search-notes-by-tag   # 作業ブランチ
# ... AI に spec/plan/tasks/実装を下書きさせる ...
task verify                                   # 緑を確認
git push -u origin feat/00X-search-notes-by-tag
# PR を作成 → ラベル付け（ai-generated / class:B）→ 人間レビュー → マージ
```

## 関連

- 品質ゲートの仕組み: [品質ゲート](../concepts/quality-gates.md)
- つまずき: [トラブルシューティング](../troubleshooting.md)
