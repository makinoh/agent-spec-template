#!/usr/bin/env bash
# 強制台帳のスキーマ整合性検査（憲章「3. 基本原則」検証手段の選択／「8.」ブートストラップ規定の機械化）。
# governance/enforcement-ledger.md の「人間ゲート（不可避）」行に理由区分、
# 「人間ゲート（暫定）」行に失効期限・担当・移行先ゲートが記入されていること、
# および失効期限超過がゼロであることを検査する。
set -eu
. scripts/lib/common.sh
say "Enforcement ledger schema"
have python3 || have python || { need python "install python3 (or: task setup)" && true || exit 0; }
py scripts/check_enforcement_ledger.py
ok "Enforcement ledger schema"
