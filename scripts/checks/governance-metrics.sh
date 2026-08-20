#!/usr/bin/env bash
# 統治健全性メトリクス（憲章「7. 変更管理」定期見直し／強制台帳から機械的に導出）。
# 機械強制率・暫定人間ゲート残数・期限超過件数（観測）を算出し、機械強制率の非減少制約
# （governance/waivers/ の有効な waiver が無い限り低下を許容しない）を検査する。
# 正本記録: governance/proposals/gp-0004-governance-health-metrics.md（WU-03）。
set -eu
. scripts/lib/common.sh
say "Governance health metrics"
have python3 || have python || { need python "install python3 (or: task setup)" && true || exit 0; }
py scripts/check_governance_metrics.py
ok "Governance health metrics"
