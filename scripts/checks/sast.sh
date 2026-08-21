#!/usr/bin/env bash
# First-party SAST (Static Application Security Testing) gate.
#
# 対象: 第一者コード（自組織・AIエージェントが記述したソースコード）に内在する
# 脆弱性クラス（インジェクション・XSS・安全でない暗号利用等）。依存関係の
# 既知脆弱性は対象外（そちらは scripts/checks/deps.sh。重大度基準は別項目
# として standards/security-standards.md「5.」と「8.」に分離して定義する）。
#
# 休眠・活性化パターン（build.sh と同一の検出ロジック）:
#   対象スタック（package.json / go.mod / pom.xml / build.gradle(.kts) /
#   pyproject.toml・requirements.txt・setup.py）が無ければ休眠し exit 0（skip）。
#   コードを含まない採用で task verify を失敗させてはならない（MUST NOT。
#   constitution.md「8.」WU04-02／governance/proposals/gp-0005-sast-gate.md）。
#
# ツール選定はスタック検出後に確定する（本スクリプトはツールを固定しない）:
#   実行する SAST ツールは、統治文書（constitution.md / standards/security-
#   standards.md）に特定製品名を書かない方針（NG-05）に合わせ、次の**汎用・
#   差し替え可能な**機構でのみ解決する。
#     1. 環境変数 SAST_CMD（例: "npx @tool/cli scan --severity=high"）
#     2. scripts/dev/sast-tool.sh が存在し実行可能なら、それを使う
#   いずれも見つからない場合、これは「不合格」ではなく「未配線」である。
#   サイレントに合格したことにはせず、追跡可能な形で正直に警告する
#   （governance/enforcement-ledger.md の当該行を参照）。
#
# 本スクリプトは正規表現・grep だけで作られた自前の脆弱性検出器ではない
# （検出能力を偽装しないため。NG-05）。実ツールが配線されるまで、この
# ゲートは「休眠/活性化の切り替えが正しく動くこと」のみを保証する。
set -eu
. scripts/lib/common.sh
say "First-party SAST (stack auto-detect)"

# --- スタック検出（build.sh と同一の判定条件） ---
ran=0
if [ -f package.json ]; then ran=1; fi
if [ -f go.mod ]; then ran=1; fi
if [ -f pom.xml ]; then ran=1; fi
if [ -f build.gradle ] || [ -f build.gradle.kts ]; then ran=1; fi
if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ]; then ran=1; fi

if [ "$ran" -ne 1 ]; then
  warn "no code stack detected — SAST skipped (dormant; activates when a manifest is added)"
  ok "SAST (dormant)"
  exit 0
fi

# --- 活性化: 第一者コードスタックを検出。SAST ツールを汎用機構で解決する ---
SAST_TOOL_CMD="${SAST_CMD:-}"
if [ -z "$SAST_TOOL_CMD" ] && [ -x "scripts/dev/sast-tool.sh" ]; then
  SAST_TOOL_CMD="scripts/dev/sast-tool.sh"
fi

if [ -z "$SAST_TOOL_CMD" ]; then
  warn "code stack detected but no SAST tool is wired yet."
  warn "set \$SAST_CMD, or add an executable scripts/dev/sast-tool.sh, to activate real detection."
  warn "this is a tracked bootstrap gap (NOT a substitute for real scanning) — see"
  warn "governance/enforcement-ledger.md and standards/security-standards.md「8.」."
  ok "SAST (bootstrap gap — activation-detection verified, no tool wired yet)"
  exit 0
fi

say "running configured SAST tool: $SAST_TOOL_CMD"
# shellcheck disable=SC2086
eval "$SAST_TOOL_CMD"
ok "SAST"
