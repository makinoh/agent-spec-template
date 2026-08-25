---
id: WV-0001
target_check: diff-size.class-a
status: Active
expires: 2026-09-08
---

# WV-0001: PR #43 の Class A 差分規模上限超過（stacked PR の再届け）

| 項目 | 内容 |
| --- | --- |
| 対象規範 | development-process.md「5.」差分規模の上限（Class A = 200行。scripts/checks/diff-size.sh） |
| 理由・代替統制 | PR #43（`stack/8-selftest-negative-coverage` → `main`）の Class A 差分のうち大半は、`stack/8` に直接マージ済みの PR #47（「承認者の力量要件と育成の空白を明示する」。既に PR レビューを経て 2026-08-24 にマージ済み）の内容が、stacked PR 構成の結果として `main` へ再度届く際に diff-size 計測へ再カウントされたものである。PR #43 自体の純粋な新規変更（陰性テストの適用漏れ是正）は37行のみで上限内。PR #47 の内容単体も約380行あり、これ自体がさらに分割しない限り上限を下回らないため、PR #43 の分割では解消しない。代替統制として、再カウント対象の内容は PR #47 として既に単独レビュー済みであり、本 waiver は「未レビューの大規模差分を無検証で通過させる」ケースには該当しない（diff-size ゲートが本来防ごうとするリスクとは異なる）。将来的な恒久対策は check_diff_size.py 側で「stacked PR の下位ブランチで既にレビュー済みの区間を除外する」計測方式への改善が望ましい（本 waiver の範囲外）。 |
| 範囲 | PR #43（`stack/8-selftest-negative-coverage` → `main`）1件のみ |
| 承認者・承認日 | Hiroyuki Makino（作成者本人が対話上で明示的に承認指示。本リポジトリは Lite プロファイル・単独メンテナ体制であり、GitHub 上のレビュー承認者を別途立てられないため、対話ログを承認記録として扱う） / 2026-08-25 |
| 有効期限 | 2026-09-08（PR #43 マージ後は不要となるため短期間に限定） |
| 関連 | PR #43、PR #47、governance/proposals/gp-0009-human-gate-diff-size-limit.md |
