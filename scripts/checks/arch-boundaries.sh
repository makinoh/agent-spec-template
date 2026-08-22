#!/usr/bin/env bash
# アーキテクチャ境界（依存方向・循環依存）の機械検証ゲート。
#
# 対象: architecture/boundaries.md「依存規則」の「循環依存を導入してはならない（MUST NOT）」
# （architecture-standards.md「1.」／constitution.md「アーキテクチャの完全性」）。
#
# なぜ必要か（外部レビュー指摘・2026-08-22）:
#   本テンプレートは統治・規範レイヤ（constitution / enforcement-ledger / development-process 等）
#   には厚く投資している一方、「読まなくていい範囲を作る」局所性（アーキテクチャ境界）には
#   機械検証が一切なく、architecture/boundaries.md のレイヤ構成も「（例: presentation →
#   application → domain ← infrastructure）」という置換前のプレースホルダのまま放置されていた。
#   レビューコストを下げる3方向（量を減らす／機械に移す／代償を下げる）のうち「機械に移す」
#   が最も手薄な領域だった、という指摘は妥当である。
#
# 休眠・活性化パターン（sast.sh / build.sh と同一の設計）:
#   対象スタックが無ければ休眠し exit 0（skip）。コードを含まない採用で
#   task verify を失敗させてはならない（MUST NOT）。
#
# ツール選定はスタック検出後に確定する（本スクリプトはツールを固定しない）:
#   採用スタックにより適切なツールが異なる（import-linter / dependency-cruiser /
#   ArchUnit / go-arch-lint 等）。統治文書に特定製品名を書かない方針（sast.sh と同じ
#   NG-05 の趣旨）に合わせ、次の**汎用・差し替え可能な**機構でのみ解決する。
#     1. 環境変数 ARCH_BOUNDARY_CMD（例: "npx dependency-cruiser --validate"）
#     2. scripts/dev/arch-boundary-tool.sh が存在し実行可能なら、それを使う
#   いずれも見つからない場合、これは「不合格」ではなく「未配線」である。
#   サイレントに合格したことにはせず、追跡可能な形で正直に警告する
#   （governance/enforcement-ledger.md の当該行を参照）。
#
# 本スクリプトは自前の依存グラフ解析器ではない（検出能力を偽装しないため。NG-05 と同趣旨）。
# 実ツールが配線されるまで、このゲートは「休眠/活性化の切り替えが正しく動くこと」のみを保証する。
set -eu
. scripts/lib/common.sh
say "Architecture boundaries / circular dependency (stack auto-detect)"

# --- スタック検出（sast.sh / build.sh と同一の判定条件） ---
ran=0
if [ -f package.json ]; then ran=1; fi
if [ -f go.mod ]; then ran=1; fi
if [ -f pom.xml ]; then ran=1; fi
if [ -f build.gradle ] || [ -f build.gradle.kts ]; then ran=1; fi
if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ]; then ran=1; fi

if [ "$ran" -ne 1 ]; then
  warn "no code stack detected — architecture boundary check skipped (dormant; activates when a manifest is added)"
  ok "Architecture boundaries (dormant)"
  exit 0
fi

# --- 活性化: 第一者コードスタックを検出。境界検査ツールを汎用機構で解決する ---
ARCH_TOOL_CMD="${ARCH_BOUNDARY_CMD:-}"
if [ -z "$ARCH_TOOL_CMD" ] && [ -x "scripts/dev/arch-boundary-tool.sh" ]; then
  ARCH_TOOL_CMD="scripts/dev/arch-boundary-tool.sh"
fi

if [ -z "$ARCH_TOOL_CMD" ]; then
  warn "code stack detected but no architecture boundary tool is wired yet."
  warn "set \$ARCH_BOUNDARY_CMD, or add an executable scripts/dev/arch-boundary-tool.sh, to activate real detection."
  warn "this is a tracked bootstrap gap (NOT a substitute for real dependency-direction checking) — see"
  warn "governance/enforcement-ledger.md and architecture/boundaries.md「依存規則」."
  ok "Architecture boundaries (bootstrap gap — activation-detection verified, no tool wired yet)"
  exit 0
fi

say "running configured architecture boundary tool: $ARCH_TOOL_CMD"
# shellcheck disable=SC2086
eval "$ARCH_TOOL_CMD"
ok "Architecture boundaries"
