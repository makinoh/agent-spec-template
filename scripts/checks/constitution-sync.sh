#!/usr/bin/env bash
# 簡潔ビュー（.specify/memory/constitution.md）のバージョンヘッダが正本（constitution.md）と
# 一致していることを検証する（WU09-01 / GP-0010）。
#
# なぜ必要か:
#   簡潔ビューは spec-kit の Constitution Check（/speckit.plan、.specify/templates/plan-template.md
#   「1. Constitution Check」が正本として直接参照する）が読む派生サマリである。しかし追従は
#   SHOULD にとどまり（constitution.md「7. 変更管理」）、同期を機械検証する仕組みが無かった。
#   ここが陳腐化すると、Constitution Check が古い原則・ゲート定義で走ってしまう。
#   本チェックは最小対応として「バージョン番号が一致しているか」のみを機械検証する
#   （内容全体の同期は生成化が理想だが本 WU の対象外。scripts/sync_constitution_version.py 参照）。
#
# 自己参照的検証: 本チェック自身が「統治・強制機構への変更」を機械検証する MUST-worthy な仕組みであり、
# 台帳（governance/enforcement-ledger.md）に新規登録する。
set -eu
. scripts/lib/common.sh
say "Constitution concise-view version sync"

SRC="constitution.md"
VIEW=".specify/memory/constitution.md"

for f in "$SRC" "$VIEW"; do
  [ -f "$f" ] || { err "$f is missing"; exit 1; }
done

# 先頭付近の "* Version: X.Y.Z（...任意の注記...）" 行から semver のみを取り出す。
# constitution.md は "0.4.0（Proposed / ドラフト。本増分は提案であり...）" のように
# 括弧注記が続くため、注記以降は無視する。
extract_version() {
  grep -m1 -E '^\* Version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+' "$1" \
    | sed -E 's/^\* Version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
}

src_version="$(extract_version "$SRC")"
view_version="$(extract_version "$VIEW")"

if [ -z "$src_version" ]; then
  err "$SRC: '* Version: X.Y.Z' 形式のバージョン行が見つかりません"
  exit 1
fi
if [ -z "$view_version" ]; then
  err "$VIEW: '* Version: X.Y.Z' 形式のバージョン行が見つかりません"
  exit 1
fi

if [ "$src_version" != "$view_version" ]; then
  err "バージョン不一致: $SRC=$src_version ／ $VIEW=$view_version"
  err "  簡潔ビューは Constitution Check（/speckit.plan）が参照する派生サマリです（正本委譲: 7. 変更管理）。"
  err "  正本の改正に追従してください。同期コマンド: python3 scripts/sync_constitution_version.py"
  exit 1
fi

ok "constitution-sync (v${src_version})"
