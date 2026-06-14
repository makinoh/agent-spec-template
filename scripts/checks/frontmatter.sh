#!/usr/bin/env bash
# Front-matter key presence for ADRs and spec documents (fast structural check).
set -eu
. scripts/lib/common.sh
say "Front matter keys"
fail=0
fm_has() { awk -v k="$1" '/^---/{c++; next} c==1 && index($0, k":")==1 {f=1} END{exit f?0:1}' "$2"; }
shopt -s nullglob 2>/dev/null || true
for f in adr/adr-*.md; do
  for k in id title status date profile; do
    fm_has "$k" "$f" || { err "$f: missing front-matter key '$k'"; fail=1; }
  done
done
for f in specs/*/spec.md specs/*/plan.md specs/*/tasks.md; do
  [ -f "$f" ] || continue
  for k in feature_id title status; do
    fm_has "$k" "$f" || { err "$f: missing front-matter key '$k'"; fail=1; }
  done
done
[ "$fail" -eq 0 ] || exit 1
ok "Front matter keys"
