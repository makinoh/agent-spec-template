#!/usr/bin/env bash
# UI 再現性ゲート（constitution.md「10.1」/ 強制台帳 #23〜#26）。
#
# 実体は Taskfile.ui.yml（`task ui:verify` / `task ui:verify:fast`）。本スクリプトは
# 「1 チェック = 1 スクリプト」という Taskfile.yml の原則に合わせた入口であり、
# UI スタック未導入のリポジトリでは no-op（緑）を返す。
#
# 活性化条件: package.json と src/ の双方が存在すること（build.sh のスタック自動検出と同方針）。
# 未導入の状態で pnpm / Storybook / Playwright を起動すると必ず失敗し、ゲート全体が
# 「常に赤 → 無視される」状態に陥るため、構造的に休眠させる。
#
# 使い方: bash scripts/checks/ui.sh [fast|full]
set -eu
. scripts/lib/common.sh

mode="${1:-full}"
say "UI reproducibility gate (${mode})"

if [ ! -f package.json ] || [ ! -d src ]; then
  warn "UI スタック未導入（package.json / src/ が無い）— skipped（採用時に自動で活性化する）"
  ok "UI gate (skipped)"
  exit 0
fi

need task "https://taskfile.dev (or: task setup)" || exit 0

case "$mode" in
  fast) task ui:verify:fast ;;
  full) task ui:verify ;;
  *) err "unknown mode: $mode (expected: fast | full)"; exit 1 ;;
esac

ok "UI gate"
