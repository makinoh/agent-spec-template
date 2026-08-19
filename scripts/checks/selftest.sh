#!/usr/bin/env bash
# ゲート自己診断（陰性テスト）。憲章「8. ブートストラップ規定」の実装。
#
# なぜ必要か:
#   「整備済み」と台帳に書かれていても、実際には違反を検出できないゲートが繰り返し見つかった。
#     - lychee のレート制限で偽陽性（誤検出）→ ゲートが信用されなくなる
#     - adoption.sh が CI の権限不足で常に警告 → 本当の未設定と区別できない
#     - ui:tokens:check が Task の増分判定で再生成をスキップ → 生成物の手編集を見逃す
#   いずれも「通っている」ことは確認できても「落ちるべき時に落ちる」ことは確認していなかった。
#
# 本スクリプトは各ゲートに**違反を注入して落ちること**を確認する（陰性テスト）。
# あわせて無傷の複製が通ること（陽性対照）も確認し、ハーネス自体の故障を検出する。
#
# 方針:
#   - 作業ツリーの追跡ファイルを一時ディレクトリへ複製して実施する。実リポジトリは一切変更しない。
#   - ネットワークに依存しない（オフラインで完結する）ケースのみを対象とする。
#     リンク検査（lychee）・依存脆弱性（trivy）は外部依存のため対象外とし、その旨を表示する。
#   - 検査対象のツールが無い環境では、そのケースを skip する（誤って「検出できた」と報告しない）。
set -eu
. scripts/lib/common.sh
say "Gate self-test (negative tests)"

have git || { warn "git not found — skipped"; ok "Gate self-test (skipped)"; exit 0; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { warn "not a git repo — skipped（追跡ファイルの複製に git を用いるため）"; ok "Gate self-test (skipped)"; exit 0; }

REPO_ROOT="$(pwd)"
WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# 追跡ファイルを「作業ツリーの内容で」複製する（HEAD ではない。未コミットの変更も検査対象にする）
git ls-files -z | tar -cf - --null -T - 2>/dev/null | tar -xf - -C "$WORK"
cd "$WORK"
git init -q .
git add -A >/dev/null 2>&1
git -c user.email=selftest@local -c user.name=selftest commit -qm baseline >/dev/null 2>&1

pass=0; fail=0; skipped=0

restore() { git checkout -q -- . 2>/dev/null || true; git clean -qfd 2>/dev/null || true; }

# run_case <名前> <前提コマンド|""> <違反注入> <検査コマンド>
run_case() {
  name="$1"; need_cmd="$2"; mutate="$3"; check="$4"
  if [ -n "$need_cmd" ] && ! command -v "$need_cmd" >/dev/null 2>&1; then
    warn "skip: $name（$need_cmd が無いため検出可否を判定できない）"
    skipped=$((skipped + 1)); return 0
  fi
  restore
  eval "$mutate" >/dev/null 2>&1 || true
  set +e; eval "$check" >/dev/null 2>&1; rc=$?; set -e
  restore
  if [ "$rc" -ne 0 ]; then
    printf '    [検出] %s\n' "$name"; pass=$((pass + 1))
  else
    err "見逃し: $name — 違反を注入したがゲートが合格した（exit 0）"
    fail=$((fail + 1))
  fi
}

# ---------- 陽性対照: 無傷の複製がすべて通ること ----------
# ここが落ちる場合はハーネスの故障であり、陰性テストの結果は信用できない。
for c in structure adr adr-content frontmatter prompts enforcement-ledger; do
  set +e; bash "scripts/checks/$c.sh" >/dev/null 2>&1; rc=$?; set -e
  [ "$rc" -eq 0 ] || { err "陽性対照の失敗: scripts/checks/$c.sh が無傷の複製で落ちた（ハーネス故障）"; exit 1; }
done

# ---------- 陰性テスト ----------
run_case "adr.sh: ADR 命名規則違反" "" \
  'cp adr/adr-0001-*.md adr/adr-1-bad.md' \
  'bash scripts/checks/adr.sh'

run_case "adr.sh: status が管理語彙の外" "" \
  "sed -i 's/^status: proposed/status: bogus/' adr/adr-0001-export-format-selection.md" \
  'bash scripts/checks/adr.sh'

run_case "adr-content.sh: id とファイル名の不一致" "python3" \
  "sed -i 's/^id: ADR-0001/id: ADR-0099/' adr/adr-0001-export-format-selection.md" \
  'bash scripts/checks/adr-content.sh'

run_case "adr-content.sh: accepted なのに決裁者が空" "python3" \
  "sed -i 's/^decision-makers: \[\"makinoh\"\].*/decision-makers: []/' adr/adr-0005-css-token-enforcement.md" \
  'bash scripts/checks/adr-content.sh'

run_case "adr-content.sh: 必須セクションの欠落" "python3" \
  "sed -i 's/^## 承認$/## 承認済み情報/' adr/adr-0005-css-token-enforcement.md" \
  'bash scripts/checks/adr-content.sh'

run_case "frontmatter.sh: 必須キーの欠落" "" \
  "sed -i '/^profile:/d' adr/adr-0001-export-format-selection.md" \
  'bash scripts/checks/frontmatter.sh'

run_case "prompts.sh: last_review の欠落" "" \
  "sed -i '/^last_review:/d' prompts/workflows/ui-00-tokens-bootstrap.md" \
  'bash scripts/checks/prompts.sh'

run_case "structure.sh: AGENTS.md が憲章参照を失う" "" \
  "sed -i 's/constitution\.md/CONST_REMOVED/g' AGENTS.md" \
  'bash scripts/checks/structure.sh'

run_case "structure.sh: 必須文書の欠落" "" \
  'rm -f README.md' \
  'bash scripts/checks/structure.sh'

run_case "adr-index.sh: 索引が陳腐化" "python3" \
  "sed -i '0,/^| ADR-0005 /s//| ADR-0005 | STALE | proposed | project | 2026-01-01 | [x](x) |\n| SKIP /' adr/INDEX.md" \
  'bash scripts/checks/adr-index.sh'

run_case "markdown.sh: Markdown Lint 違反" "markdownlint-cli2" \
  "printf '\n\`\`\`\nno language\n\`\`\`\n' >> glossary.md" \
  'bash scripts/checks/markdown.sh'

run_case "enforcement-ledger.sh: 人間ゲート（不可避）の理由区分欠落" "python3" \
  "sed -i 's/構造的強制（接続権限不付与）＋人間ゲート（不可避） | (a) |/構造的強制（接続権限不付与）＋人間ゲート（不可避） | — |/' governance/enforcement-ledger.md" \
  'bash scripts/checks/enforcement-ledger.sh'

run_case "enforcement-ledger.sh: 人間ゲート（暫定）の失効期限超過" "python3" \
  "sed -i 's/機械強制（シークレットスキャン） | — | 整備済み（CI で実効。ローカルは gitleaks 不在時スキップ） | — | — | — |/機械強制（シークレットスキャン）＋人間ゲート（暫定） | — | 整備済み（CI で実効。ローカルは gitleaks 不在時スキップ） | 2020-01-01 | TBD-HUMAN | TBD-HUMAN |/' governance/enforcement-ledger.md" \
  'bash scripts/checks/enforcement-ledger.sh'

# UI ゲート: 生成物の手編集検出（2026-08-08 に誤合格が判明した箇所。回帰を防ぐ）
run_case "ui: tokens:check が生成物の手編集を検出" "task" \
  'printf "{\"name\":\"selftest\",\"private\":true}\n" > package.json && mkdir -p src &&
   node tokens/build.mjs >/dev/null 2>&1 &&
   git add -A >/dev/null 2>&1 &&
   git -c user.email=s@l -c user.name=s commit -qm gen >/dev/null 2>&1 &&
   task ui:tokens >/dev/null 2>&1 &&
   sed -i "s/--color-text-primary: #151519;/--color-text-primary: #ff0000;/" src/styles/tokens.css &&
   git add -A >/dev/null 2>&1 &&
   git -c user.email=s@l -c user.name=s commit -qm edit >/dev/null 2>&1' \
  'task ui:tokens:check'

# 対象外の明示（黙って落とさない）
warn "対象外: links.sh（lychee・ネットワーク依存）／deps.sh（trivy・脆弱性DB依存）／視覚回帰（ブラウザ必須）"

cd "$REPO_ROOT"
say "自己診断: 検出 ${pass} 件 / 見逃し ${fail} 件 / skip ${skipped} 件"
[ "$fail" -eq 0 ] || {
  err "ゲートが違反を検出できていません。原因側（当該チェック）を修正してください（憲章「8. ブートストラップ規定」）。"
  exit 1
}
ok "Gate self-test"
