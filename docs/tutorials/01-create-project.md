---
title: チュートリアル1 — テンプレートからプロジェクト作成
description: 「Use this template」での複製、段階導入プロファイルの選択、charter/scope/glossaryの記入、プレースホルダ置換、品質ゲートが緑になることの確認までを実践。
---

# チュートリアル1 — テンプレートからプロジェクト作成

> **学習目標:** テンプレートを自分のリポジトリとして立ち上げ、最低限の初期設定（結線）まで終える。
> **読了後にできること:** プロファイルを選び、基本方針を埋め、`task verify:fast` を緑にできる。
> **前提知識:** [はじめに](../getting-started/index.md) を一読。Git の基本操作。

## ステップ 1 — テンプレートを複製する

GitHub のテンプレート本体で **「Use this template」→ Create a new repository** を選び、自分のリポジトリを作成してクローンします。

```bash
git clone https://github.com/<your-account>/<your-repo>.git
cd <your-repo>
```

## ステップ 2 — 段階導入プロファイルを選ぶ

最初に「統治の重さ」を決めます。迷ったら **Standard**、個人なら **Lite**。

| プロファイル | こんなとき |
| --- | --- |
| Lite | 個人〜小規模・非規制・PoC |
| Standard（既定） | 通常のチーム開発 |
| Regulated | 規制・監査対象・大組織 |

選択は **ガバナンス決定** として記録します（`governance/decisions/` にメモを 1 本）。
詳細は [ガバナンス詳説](../governance/index.md) と `development-process.md`「8.」。

## ステップ 3 — 基本方針を埋める

プレースホルダになっている基本方針に、自分のプロジェクトの情報を書きます。

- `charter.md` … プロジェクトの目的
- `vision.md` … ありたい姿
- `scope.md` … やること・やらないこと
- `glossary.md` … ドメイン用語（今回の題材なら「メモ」「タグ」など）

> **ヒント:** ここは AI に下書きさせて構いません（Class D の文書作業）。ただし内容の妥当性は人間が確認します。

## ステップ 4 — プレースホルダを実体に置換する

「採用して初めて強制が効く」項目を実体に置き換えます（学習段階では最小限で OK）。

- `.github/CODEOWNERS` の `@org/...` を実在チーム/個人へ
- `agents/README.md` のマシンID `@bot/...` を実在の専用アカウントへ
- `development-process.md`「5.」の承認者・定足数を確定

> 本格運用の全手順は、リポジトリ同梱の `ADOPTION.md` が正本です。

## ステップ 5 — 品質ゲートが緑になることを確認する

任意ツールを入れている場合、高速チェックを走らせます。

```bash
task setup        # 初回のみ
task verify:fast
```

緑（成功）になれば、土台は完成です。赤の場合は [トラブルシューティング](../troubleshooting.md) を参照。

## 確認

- [ ] 自分のリポジトリとして clone できた
- [ ] プロファイルを選び、`governance/decisions/` に記録した
- [ ] `charter.md` / `scope.md` / `glossary.md` に自分の言葉が入った
- [ ] `task verify:fast` が緑（任意ツール導入時）

## よくあるつまずき

- **`task` が見つからない** → [前提環境](../getting-started/prerequisites.md) の「任意」を導入、または Windows は WSL/Git Bash を使用。
- **CODEOWNERS の `@org/...` で警告** → 実在のチーム/個人名に置換。学習段階では自分のユーザー名で可。

## 次へ

土台ができたら、設計判断を記録する → [チュートリアル2「ADRを作成する」](02-write-adr.md)
