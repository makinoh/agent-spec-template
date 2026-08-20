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
for c in structure adr adr-content frontmatter prompts enforcement-ledger sast pr_governance governance-metrics constitution-sync; do
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

run_case "constitution-sync.sh: 簡潔ビューのバージョンが正本から乖離" "" \
  "sed -i 's/^\* Version: [0-9.]*/* Version: 0.0.1/' .specify/memory/constitution.md" \
  'bash scripts/checks/constitution-sync.sh'

run_case "structure.sh: 必須文書の欠落" "" \
  'rm -f README.md' \
  'bash scripts/checks/structure.sh'

run_case "adr-index.sh: 索引が陳腐化" "python3" \
  "sed -i '0,/^| ADR-0005 /s//| ADR-0005 | STALE | proposed | project | 2026-01-01 | [x](x) |\n| SKIP /' adr/INDEX.md" \
  'bash scripts/checks/adr-index.sh'

# pr_governance.sh: ロールバック手順欄の存在検証（development-process.md「7.」／WU-10／台帳 #34-35）。
# PR_BODY を模した文字列は ANSI-C クォート（$'...'）で改行付きの複数行文字列として組み立て、
# run_case の check（eval される）から参照できるようスクリプトのグローバル変数に置く。
# ADR不要理由も併記し、本ケースが検証したい対象（ロールバック手順欄）以外で先に落ちないようにする。
pr_body_rollback_placeholder=$'## 概要\n\ndummy\n\n## ADR不要理由: セルフテスト用ダミー理由\n\n## ロールバック手順（Class A の場合は必須。development-process.md「7.」）\n\n<!-- 本変更が本番へ反映された後、問題発生時にどう復旧するかを記載する -->\n\n## 完了条件チェック\n\ndummy'

run_case "pr_governance.sh: class:A PR のロールバック手順欄が未記載（プレースホルダのみ）" "" \
  'printf "dummy change\n" >> README.md && git add -A && git -c user.email=s@l -c user.name=s commit -qm dummy_rollback_case' \
  'CI=true PR_LABELS="class:A" PR_BODY="$pr_body_rollback_placeholder" bash scripts/checks/pr_governance.sh'

run_case "markdown.sh: Markdown Lint 違反" "markdownlint-cli2" \
  "printf '\n\`\`\`\nno language\n\`\`\`\n' >> glossary.md" \
  'bash scripts/checks/markdown.sh'

run_case "enforcement-ledger.sh: 人間ゲート（不可避）の理由区分欠落" "python3" \
  "sed -i 's/構造的強制（接続権限不付与）＋人間ゲート（不可避） | (a) |/構造的強制（接続権限不付与）＋人間ゲート（不可避） | — |/' governance/enforcement-ledger.md" \
  'bash scripts/checks/enforcement-ledger.sh'

run_case "enforcement-ledger.sh: 人間ゲート（暫定）の失効期限超過" "python3" \
  "sed -i 's/機械強制（シークレットスキャン） | — | 整備済み（CI で実効。ローカルは gitleaks 不在時スキップ） | — | — | — |/機械強制（シークレットスキャン）＋人間ゲート（暫定） | — | 整備済み（CI で実効。ローカルは gitleaks 不在時スキップ） | 2020-01-01 | TBD-HUMAN | TBD-HUMAN |/' governance/enforcement-ledger.md" \
  'bash scripts/checks/enforcement-ledger.sh'

# ---------- sast.sh: 休眠・活性化の両方向を確認する（WU04-02。台帳 #40） ----------
# run_case は「違反注入 → 非ゼロ終了で検出」の二値判定用のため、休眠/活性化メッセージの
# 内容確認はここで個別に行う（陰性テストではなく、切り替えロジック自体の動作確認）。
restore
set +e; out_dormant="$(bash scripts/checks/sast.sh 2>&1)"; rc_dormant=$?; set -e
if [ "$rc_dormant" -eq 0 ] && printf '%s' "$out_dormant" | grep -q "dormant"; then
  printf '    [検出] sast.sh: 休眠時（manifest 無し）に exit 0 かつ休眠メッセージを出す\n'
  pass=$((pass + 1))
else
  err "見逃し: sast.sh が休眠時に正しく振る舞わなかった（exit=$rc_dormant）"
  fail=$((fail + 1))
fi

restore
printf '{"name":"selftest","private":true}\n' > package.json
set +e; out_active="$(bash scripts/checks/sast.sh 2>&1)"; rc_active=$?; set -e
if [ "$rc_active" -eq 0 ] && printf '%s' "$out_active" | grep -q "no SAST tool is wired" \
   && ! printf '%s' "$out_active" | grep -q "dormant"; then
  printf '    [検出] sast.sh: 活性化時（package.json 検出）は休眠メッセージを出さず、未配線を正直に警告して exit 0\n'
  pass=$((pass + 1))
else
  err "見逃し: sast.sh が活性化を検出できなかった（exit=$rc_active）"
  fail=$((fail + 1))
fi
restore

run_case "sast.sh: SAST_CMD が設定され失敗を報告した場合は exit 0 にしない（合否伝播の確認）" "" \
  'printf "{\"name\":\"selftest\",\"private\":true}\n" > package.json' \
  'SAST_CMD=false bash scripts/checks/sast.sh'

restore
printf '{"name":"selftest","private":true}\n' > package.json
set +e; SAST_CMD=true bash scripts/checks/sast.sh >/dev/null 2>&1; rc_tool_ok=$?; set -e
restore
if [ "$rc_tool_ok" -eq 0 ]; then
  printf '    [検出] sast.sh: SAST_CMD が成功を報告した場合は exit 0（過検知しない）\n'
  pass=$((pass + 1))
else
  err "見逃し: sast.sh が SAST_CMD 成功時に誤って失敗した（exit=$rc_tool_ok）"
  fail=$((fail + 1))
fi

# pr_governance.sh: AI 生成識別（WU07-01）。既知の AI エージェント・マシンアカウントが PR 作成者なのに
# ai-generated ラベルが無い場合、CI では非ゼロ終了しなければならない（development-process.md「6.」MUST）。
# ファイル変更を伴わない検査（PR 作成者の属性のみで判定）のため、注入（mutate）は no-op。
run_case "pr_governance.sh: 既知AIエージェント識別のPR作成者にai-generatedラベル欠落" "" \
  ':' \
  'CI=true PR_AUTHOR=claude-code-bot PR_LABELS=class:A bash scripts/checks/pr_governance.sh'

run_case "governance-metrics.sh: 機械強制率が baseline を下回る（waiver なし）" "python3" \
  'sed -i "s/\"mechanized_norms\": 34/\"mechanized_norms\": 40/" metrics/governance-health-snapshot.json' \
  'bash scripts/checks/governance-metrics.sh'

run_case "governance-metrics.sh: 失効済み waiver は低下を正当化しない（無条件バイパスの禁止）" "python3" \
  'sed -i "s/\"mechanized_norms\": 34/\"mechanized_norms\": 40/" metrics/governance-health-snapshot.json &&
   mkdir -p governance/waivers &&
   printf -- "---\ntarget_check: governance-metrics.mechanized-rate\nstatus: Active\nexpires: 2020-01-01\n---\n\n# selftest waiver (expired, negative-test fixture only)\n" > governance/waivers/wv-9999-selftest-expired.md' \
  'bash scripts/checks/governance-metrics.sh'

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

# diff-size.sh: 上限値は既定で未設定（TBD-HUMAN）のため advisory のみで hard-fail しない。
# selftest では一時的に低い閾値を環境変数で与え、hard-fail 化ロジック自体が正しく動作することを
# 確認する（実運用では Taskfile.yml / .github/workflows/verify.yml のどちらにも閾値を設定して
# いないため、この閾値注入は selftest 内に閉じる。git diff ベースの検査のため、他の陰性テストと
# 異なりコミットを作る＝UI ケースと同様に本ファイル末尾へ配置する）。
run_case "diff-size.sh: 閾値設定時に上限超過を検出する（synthetic diff）" "python3" \
  'yes "diff-size selftest synthetic line" | head -50 >> governance/waivers/README.md &&
   git add -A >/dev/null 2>&1 &&
   git -c user.email=s@l -c user.name=s commit -qm "selftest: synthetic diff-size violation" >/dev/null 2>&1' \
  'DIFF_SIZE_LIMIT_CLASS_A=10 bash scripts/checks/diff-size.sh'

# 対象外の明示（黙って落とさない）
warn "対象外: links.sh（lychee・ネットワーク依存）／deps.sh（trivy・脆弱性DB依存）／視覚回帰（ブラウザ必須）"

cd "$REPO_ROOT"
say "自己診断: 検出 ${pass} 件 / 見逃し ${fail} 件 / skip ${skipped} 件"
[ "$fail" -eq 0 ] || {
  err "ゲートが違反を検出できていません。原因側（当該チェック）を修正してください（憲章「8. ブートストラップ規定」）。"
  exit 1
}
ok "Gate self-test"
