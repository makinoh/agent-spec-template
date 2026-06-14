#!/usr/bin/env bash
# ADR 本文の必須セクション＋フロントマター値制約（adr-rules.md「3.」「4.」/ constitution「8.」）。
# frontmatter.sh（キー存在）を補完し、値・本文構造・accepted 条件を検査する。
set -eu
. scripts/lib/common.sh
say "ADR content & front-matter values"
have python3 || have python || { need python "install python3 (or: task setup)" && true || exit 0; }
py scripts/check_adr_content.py
ok "ADR content & front-matter values"
