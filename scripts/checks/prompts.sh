#!/usr/bin/env bash
# Prompt asset lifecycle check (prompts/README.md): プロンプト資産のフロントマター規約を機械点検する。
# 各プロンプト資産（prompts/ 配下の .md。README・_TEMPLATE・サブディレクトリの README を除く）は
# status / owner / last_review を持つべき（SHOULD）。資産が無い間は no-op（緑）。
set -eu
. scripts/lib/common.sh
say "Prompt asset lifecycle (status/owner/last_review)"
fail=0
found=0
fm_has() { awk -v k="$1" '/^---/{c++; next} c==1 && index($0, k":")==1 {f=1} END{exit f?0:1}' "$2"; }

shopt -s nullglob globstar 2>/dev/null || true
for f in prompts/**/*.md prompts/*.md; do
  case "$f" in
    */README.md|prompts/_TEMPLATE.md) continue ;;
  esac
  [ -f "$f" ] || continue
  found=1
  for k in status owner last_review; do
    fm_has "$k" "$f" || { err "$f: プロンプト資産に front-matter '$k' がありません（prompts/README.md ライフサイクル規約）"; fail=1; }
  done
done

[ "$found" -eq 1 ] || warn "no prompt assets yet — lifecycle check skipped (activates when prompts are added)"
[ "$fail" -eq 0 ] || exit 1
ok "Prompt asset lifecycle"
