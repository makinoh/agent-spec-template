---
name: adopt-existing
description: すでにリリース済み・稼働中のプロジェクトへ本テンプレートを後から重ねる（brownfield 導入）ときに使う。初日に全ゲートが赤になる問題を、統治下に置かれた段階適用で解消する。起案のみ。
class: A（統治・強制機構を導入するため。起案のみ）
status: active
owner: ""                     # 採用時に確定
last_review: "2026-08-24"
tool_boundary: ファイル編集・調査。ブランチ保護／必須チェック登録・waiver の承認・秘密情報のローテーションは人間（Class A）。git 履歴の書き換えは禁止（MUST NOT）。
references:
  - ADOPTION-EXISTING.md
  - ADOPTION.md
  - development-process.md
  - governance/waivers/README.md
  - governance/exceptions/README.md
---

# スキル: adopt-existing

> 本スキルは [SKILLS.md](../../SKILLS.md) の規約に従う。実行指示の正本は [AGENTS.md](../../AGENTS.md)。
> 手順の正本は [ADOPTION-EXISTING.md](../../ADOPTION-EXISTING.md)。本書に手順を再掲しない（SSoT）。

## 用途

既存リポジトリへ本テンプレートを導入する。新規採用（[ADOPTION.md](../../ADOPTION.md)）との違いは、
**コードも履歴も既に存在し、そのすべてがルール導入前に書かれている**点にある。

## 入力

- 対象リポジトリ（既定ブランチ名・スタック・ビルド/テストの入口・CI の現状）
- 採用プロファイル（Lite / Standard / Regulated。未定なら Lite を提案する）

## 手順

1. **調査（変更しない）**: 既定ブランチ名、既存 `.github/workflows/`、ビルド/テストの入口、
   `README.md` / `CONTRIBUTING.md` / `.gitignore` の有無を洗い出す。
   [ADOPTION-EXISTING.md](../../ADOPTION-EXISTING.md)「1. 前提の読み替え」の各項目に回答を埋める。
2. **影響の実測**: 導入前に、既存リポジトリで何件の違反が出るかを実測して報告する
   （秘密情報・markdown lint・依存脆弱性・差分規模）。**推測値を報告してはならない**（MUST NOT）。
3. **段階適用の設計**: 実測結果ごとに waiver / exception / risk-register のどれで扱うかを提案する
   （[ADOPTION-EXISTING.md](../../ADOPTION-EXISTING.md)「3.5」の対応表）。すべて期限と担当を伴わせる。
4. **導入 PR の分割**: 同「6. 導入の順序」の 1〜7 に沿って分割し、各段階で `task verify` の生出力を報告する。
5. **as-built ADR**: 同「4.」に従い、**これから変更する領域に限って**起票する。網羅しない。

## 出力

- 実測結果つきの導入計画（どのゲートが何件で赤になるか、どう段階適用するか）
- 段階ごとの PR ドラフト ＋ 各段階の `task verify` 生出力
- waiver / exception / risk のドラフト（承認は人間）

## ツール／MCP 境界

ファイル編集・調査は可。次は**実行してはならない**（MUST NOT）。

- `git filter-repo` / `git rebase` 等による**既存 git 履歴の書き換え**（不可逆・共有履歴の破壊）
- 秘密情報スキャンで検出した資格情報のローテーション（本番資格情報の操作。人間のみ）
- ブランチ保護・必須ステータスチェックの設定変更
- `DIFF_SIZE_LIMIT_CLASS_A/B` の引き上げ、ゲートの無効化・除外の追加
  （失敗したゲートを回避目的で弱めない。憲章「6.」MUST NOT。原因側または waiver で対処する）

## 停止必須（HITL）

- 実測の結果、既存リポジトリに**有効な**（未ローテーションの）秘密情報が見つかった場合は直ちに停止し、
  人間へ報告する。ADR・PR 本文・コミットメッセージに検出値そのものを書かない（MUST NOT）。
- 既存の CI・リリースフローを置換する必要があると判断した場合は停止する（Class A・ADR 対象）。
- 段階適用の範囲（何を waiver で通すか）は人間が決める。AI は選択肢と実測値を提示するにとどめる。
