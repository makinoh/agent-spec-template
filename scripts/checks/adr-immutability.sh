#!/usr/bin/env bash
# Accepted ADR の不変性（constitution.md「8.」/ adr-rules.md「5. 遷移と不変性の規則」）。
# status: accepted の ADR は「変更履歴」以外の本文・フロントマター実体を変更してはならない（MUST NOT）。
# 変更が必要なら新しい ADR を起案し、当該 ADR を Superseded とする。
#
# 実装方針: 「変更前(base)に既に accepted だった ADR」に限り不変性を強制する。
#   - Proposed→Accepted の遷移 PR（base=proposed）では適用せず、承認時の本文確定を妨げない。
#   - 比較は base 版と head 版から「変更履歴」セクションと遷移で変わりうる FM キー
#     （status / last_updated / superseded_by / relates_to）を除去して正準化し、差分が残れば違反とする。
#     これにより「変更履歴以外の任意の表・本文」の改変を検出する（旧実装の全テーブル一律除外を廃止）。
# 保守的判断は引き続き人間レビューで担保する（CODEOWNERS）。
# git・PR diff を前提とするため、CI（pull_request）で実効化する。ローカル/非 git では安全にスキップ。
set -eu
. scripts/lib/common.sh
say "Accepted ADR immutability"

have git || { warn "git not found — skipped (CI で実効化)"; ok "Accepted ADR immutability (skipped)"; exit 0; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { warn "not a git repo — skipped"; ok "Accepted ADR immutability (skipped)"; exit 0; }

base="${BASE_SHA:-}"; head="${HEAD_SHA:-HEAD}"
if [ -z "$base" ]; then
  base="$(git merge-base origin/main HEAD 2>/dev/null || git rev-parse HEAD~1 2>/dev/null || true)"
fi
[ -n "$base" ] || { warn "no base ref — skipped"; ok "Accepted ADR immutability (skipped)"; exit 0; }

fail=0
changed="$(git diff --name-only "$base" "$head" -- 'adr/adr-*.md' 2>/dev/null || true)"

# 「変更履歴」セクションと、遷移で正当に変わりうる FM キーを除去して正準化する。
# 変更履歴セクションのみを除外対象とし（全テーブルではなく）、それ以外の表・本文の改変は検出する。
strip_volatile() {
  awk '
    /^#{1,6}[[:space:]]/ { in_hist = ($0 ~ /変更履歴/) }
    in_hist { next }
    /^(status|last_updated|superseded_by|relates_to):/ { next }
    { print }
  '
}

for f in $changed; do
  # 不変性は「変更前(base)に既に accepted だった ADR」にのみ適用する
  # （Proposed→Accepted 遷移 PR では base=proposed のため適用しない＝承認時の本文確定を妨げない）。
  base_status="$(git show "$base:$f" 2>/dev/null \
      | awk '/^---/{c++; next} c==1 && /^status:/{print $2; exit}' | tr -d "\"' ")"
  [ "$base_status" = "accepted" ] || continue
  [ -f "$f" ] || continue

  before="$(git show "$base:$f" 2>/dev/null | strip_volatile)"
  after="$(strip_volatile < "$f")"
  if [ "$before" != "$after" ]; then
    err "$f: Accepted ADR の本文・FM 実体（変更履歴以外）が変更されています。新 ADR を起案し本 ADR を Superseded にしてください。"
    fail=1
  fi
done
[ "$fail" -eq 0 ] || exit 1
ok "Accepted ADR immutability"
