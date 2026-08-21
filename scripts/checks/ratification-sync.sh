#!/usr/bin/env bash
# constitution.md のバージョンが governance/decisions/ での批准（Accepted・target_version）を
# 追い越していないかを検証する（外部レビュー指摘・2026-08-21）。詳細: scripts/check_ratification.py。
# advisory（警告のみ・exit 0）。hard-fail 化の可否は人間が判断する（TBD-HUMAN）。
set -eu
. scripts/lib/common.sh
say "Constitution ratification sync (advisory)"
py scripts/check_ratification.py
ok "Ratification sync"
