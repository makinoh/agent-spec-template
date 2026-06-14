---
title: チュートリアル3 — 仕様（Spec）を作成する
description: /speckit.specify でタグ検索機能の仕様を起票し、ユーザーシナリオ・機能要求（FR）・非機能要求・Constitution Alignmentを書き、/speckit.clarify で曖昧さを解消するまでを実践。
---

# チュートリアル3 — 仕様（Spec）を作成する

> **学習目標:** 「何を・なぜ」を spec として、テスト可能な形で書ける。
> **読了後にできること:** FR/ユーザーシナリオ/非機能要求/機密区分を備えた spec を起票し、曖昧さを解消できる。
> **前提知識:** [SDD のコンセプト](../concepts/spec-driven-development.md) を読了。

## ステップ 1 — spec を起票する

AI エージェントで `/speckit.specify` を実行します。**How（実装方法）は書かず、What/Why に集中**します。

```text
/speckit.specify メモにタグを付けて検索する機能。
ログイン済みユーザーが、自分のメモを 1 つ以上のタグで絞り込んで一覧できる。
他人のメモは検索結果に含めない。タグは複数指定で AND 条件。
```

`specs/00X-search-notes-by-tag/spec.md` が下書きされます（手動なら `.specify/templates/spec-template.md` を複製）。

## ステップ 2 — 中身を整える

同梱サンプル `specs/001-user-profile-export/spec.md` を手本に、次を埋めます。

- **概要 / 問題**: 背景・ゴール・**非ゴール**（例: 他人のメモ検索はしない）
- **ユーザーシナリオ**: Given/When/Then で受け入れ基準になる形に
- **機能要求（FR）**: テスト可能・曖昧語なし

```text
US-1: ログイン中、タグ「work」で検索 → 自分の work タグ付きメモのみ一覧。
FR-1: システムは、認証済みユーザーの指定タグに一致する“自分の”メモを返さなければならない（MUST）。
FR-2: システムは、複数タグ指定時に AND 条件で絞り込まなければならない（MUST）。
FR-3: システムは、他ユーザーのメモを返してはならない（MUST NOT）。
```

- **非機能要求 / 制約**: 性能・**データ機密区分**（メモ本文が個人データなら Restricted）
- **Constitution Alignment**: What/Why に限定したか、機密区分を特定したか、暫定クラスを置いたか

## ステップ 3 — 曖昧さを解消する

書きながら未確定な点は `[NEEDS CLARIFICATION]` を残し、`/speckit.clarify` でつぶします。

```text
/speckit.clarify
```

例:「タグの大文字小文字を区別するか？」「1 回の検索でタグは最大何個か？」などを確定します。

## ステップ 4 — ADR との関係を確認する

[チュートリアル2](02-write-adr.md) で書いた `ADR-0001`（タグ検索の保存方式）を、spec のフロントマター
`related_adrs` で参照します。**spec は What、ADR は Why-this-design** で役割が分かれている点を再確認。

```yaml
---
feature_id: "00X-search-notes-by-tag"
title: "メモのタグ検索"
status: clarified
related_adrs: [ADR-0001]
change_class_hint: "B"   # 公開API追加を含むため B（最終判定は development-process.md）
---
```

## 確認

- [ ] `specs/00X-search-notes-by-tag/spec.md` ができた
- [ ] 各 FR がテスト可能で曖昧語がない
- [ ] 非ゴールと機密区分を明記した
- [ ] `[NEEDS CLARIFICATION]` を解消した
- [ ] `related_adrs` で ADR-0001 を参照した

## よくあるつまずき

- **設計を spec に書いてしまう** → How は plan、Why-this-design は ADR へ移す。
- **frontmatter 検査が赤** → `feature_id` / `title` / `status` は必須キー。
- **曖昧な FR**（「速く」「使いやすく」）→ 測定可能な条件に置き換える。

## 次へ

「何を」が決まったら、AI に作らせる → [チュートリアル4「Claude Codeで実装する」](04-implement.md)
