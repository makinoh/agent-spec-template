#!/usr/bin/env bash
# Class A/B PR の差分規模計測（development-process.md「1.」新設 MUST NOT／WU-08。
# governance/proposals/gp-0009-human-gate-diff-size-limit.md）。
# 上限値は未確定（TBD-HUMAN）のため既定は advisory のみ。DIFF_SIZE_LIMIT_CLASS_A/B が
# 整数として設定されている場合に限り hard-fail する。BASE_SHA/HEAD_SHA は
# .github/workflows/verify.yml が verify:pr ステージへ既に配線済みの値を再利用する
# （scripts/checks/pr_governance.sh と同じ。新規の env var は追加しない）。
set -eu
. scripts/lib/common.sh
say "Diff size (Class A/B; advisory until a threshold is configured)"
have python3 || have python || { need python "install python3 (or: task setup)" && true || exit 0; }
py scripts/check_diff_size.py
ok "Diff size"
