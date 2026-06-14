#!/usr/bin/env bash
# ADR index (adr/INDEX.md) is up-to-date: regenerate and assert no diff (SSoT).
set -eu
. scripts/lib/common.sh
say "ADR index up-to-date"
have python3 || have python || { need python "install python3 (or: task setup)" && true || exit 0; }
py scripts/generate_adr_index.py --check
ok "ADR index"
