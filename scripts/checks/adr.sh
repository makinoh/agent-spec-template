#!/usr/bin/env bash
# ADR filename convention and Status vocabulary (adr-rules.md「1.」「5.」/ constitution「8.」).
set -eu
. scripts/lib/common.sh
say "ADR naming & status"
fail=0
shopt -s nullglob 2>/dev/null || true
found=0
for f in adr/adr-*.md; do
  found=1
  base="$(basename "$f")"
  echo "$base" | grep -Eq '^adr-[0-9]{4}-[a-z0-9]+(-[a-z0-9]+)*\.md$' \
    || { err "ADR filename violates naming rule: $base"; fail=1; }
  status="$(awk '/^---/{c++; next} c==1 && /^status:/{print $2; exit}' "$f" | tr -d "\"' ")"
  case "$status" in
    proposed|accepted|rejected|deprecated|superseded) : ;;
    *) err "$base: status not in vocabulary: '$status'"; fail=1 ;;
  esac
done
[ "$found" -eq 1 ] || warn "no ADR files found under adr/"
[ "$fail" -eq 0 ] || exit 1
ok "ADR naming & status"
