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
# 実在の waiver（governance/waivers/*.md、README.md を除く）は複製から除去する。
# 本物の有効な waiver が残っていると、find_active_waiver() のグロブが陰性テスト用に注入した
# 不正な waiver（失効・プレースホルダ・Class違い）より先に本物を見つけてしまい、ゲートが誤って
# 通過する（陰性テストの意図しないマスキング。governance/waivers/ が空である前提が waiver 登録の
# 実運用開始により崩れたため 2026-08-25 に是正）。waiver 関連ケースは各ケースが
# governance/waivers/wv-9999-*.md を個別に注入するため、実在の waiver は不要。
find governance/waivers -maxdepth 1 -name '*.md' ! -name 'README.md' -delete 2>/dev/null || true
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
for c in structure adr adr-content frontmatter prompts enforcement-ledger sast arch-boundaries pr_governance governance-metrics constitution-sync ratification-sync; do
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

# ratification-sync.sh は advisory（exit 0 のまま警告を出す設計。scripts/check_ratification.py）ため、
# 他のケースと違い「exit != 0 で検出」ではなく「警告文言が出力に含まれるか」で判定する。
name="ratification-sync.sh: constitution.md が governance/decisions/ の批准を追い越した場合に警告する"
restore
sed -i 's/^\* Version: [0-9.]*/* Version: 9.9.9/' constitution.md >/dev/null 2>&1 || true
set +e; out="$(bash scripts/checks/ratification-sync.sh 2>&1)"; rc=$?; set -e
restore
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q "Ratification lag"; then
  printf '    [検出] %s\n' "$name"; pass=$((pass + 1))
else
  err "見逃し: $name — advisory のはずが exit=$rc、または警告文言 'Ratification lag' が出力に含まれない"
  fail=$((fail + 1))
fi

run_case "structure.sh: 必須文書の欠落" "" \
  'rm -f README.md' \
  'bash scripts/checks/structure.sh'

run_case "adr-index.sh: 索引が陳腐化" "python3" \
  "sed -i '0,/^| ADR-0005 /s//| ADR-0005 | STALE | proposed | project | 2026-01-01 | [x](x) |\n| SKIP /' adr/INDEX.md" \
  'bash scripts/checks/adr-index.sh'

# pr_governance.sh: ロールバック手順欄・可逆性欄の存在検証
# （development-process.md「7.」「5.」／WU-10／台帳 #34-35・#47-48・#52-53）。
# フィクスチャは合成文字列ではなく .github/pull_request_template.md の**実物**から見出し以下を
# そのまま抽出して組み立てる（pr_governance.sh 本体と同じ awk 抽出）。合成の1行コメントで代用すると、
# 実物が複数行 HTML コメントであることに起因する fail-open（外部レビュー指摘・2026-08-21 再現確認）を
# 見逃す。実物同期にすることで、テンプレートの案内文が今後変わっても陰性テストが追従する。
# 各フィクスチャは対象外の欄（もう一方）を埋めておき、検証対象の欄だけが未記載であることに
# 失敗を切り分ける（isolate）。
extract_section() {
  awk -v re="$1" '$0 ~ ("^##[[:space:]]*" re) {print; f=1; next} /^##[[:space:]]/{f=0} f' .github/pull_request_template.md
}
rollback_section_raw="$(extract_section "ロールバック手順")"
reversibility_section_raw="$(extract_section "可逆性")"
rollback_section_filled="$(printf '%s' "$rollback_section_raw" | head -1)
実際のロールバック内容: revert via git revert."
reversibility_section_filled="$(printf '%s' "$reversibility_section_raw" | head -1)
feature flag: rollout_x_enabled で制御。"

pr_body_rollback_placeholder="$(printf '## ADR不要理由: セルフテスト用ダミー理由\n\n%s\n\n%s\n\n## 完了条件チェック\n\ndummy' \
  "$rollback_section_raw" "$reversibility_section_filled")"
pr_body_reversibility_placeholder="$(printf '## ADR不要理由: セルフテスト用ダミー理由\n\n%s\n\n%s\n\n## 完了条件チェック\n\ndummy' \
  "$rollback_section_filled" "$reversibility_section_raw")"

run_case "pr_governance.sh: class:A PR のロールバック手順欄が未記載（テンプレート実物・未編集のプレースホルダのみ）" "" \
  'printf "dummy change\n" >> README.md && git add -A && git -c user.email=s@l -c user.name=s commit -qm dummy_rollback_case' \
  'CI=true PR_LABELS="class:A" PR_BODY="$pr_body_rollback_placeholder" bash scripts/checks/pr_governance.sh'

run_case "pr_governance.sh: class:A PR の可逆性欄が未記載（テンプレート実物・未編集のプレースホルダのみ。外部レビュー指摘）" "" \
  'printf "dummy change\n" >> README.md && git add -A && git -c user.email=s@l -c user.name=s commit -qm dummy_reversibility_case' \
  'CI=true PR_LABELS="class:A" PR_BODY="$pr_body_reversibility_placeholder" bash scripts/checks/pr_governance.sh'

# ---------- 統治パス分類の網羅性（development-process.md「1.」対象パス表 ↔ $gov / $ab の同期） ----------
# 2026-08-24 の外部レビューで、対象パス表に Class A として明記されている
#   CODEX.md / OPENHANDS.md / TAKT.md / agents/** / development-process.md
# が pr_governance.sh の $gov / $ab と check_diff_size.py の GOV_RE / AB_RE の**双方から欠落**しており、
# これらだけを変更する PR が permission-impact ラベルも ADR 参照も要求されずに exit 0 で通ることが
# 隔離環境で再現された（AI エージェント指示ファイルを無審査で書き換えられる経路）。
# 表と実装の乖離は「赤くならない」ため最も気づきにくい。ここで各パスを 1 件ずつ陰性テストし、
# 将来の追加・改名で再び乖離したら selftest が落ちるようにする。
# 注: 検査は git diff ベースのため、各ケースは対象ファイルのみを変更したコミットを作る。
for gov_path in CODEX.md OPENHANDS.md TAKT.md agents/README.md development-process.md; do
  run_case "pr_governance.sh: 統治パス '$gov_path' の変更に permission-impact ラベルが無い（対象パス表との同期）" "" \
    "printf '\n<!-- selftest probe -->\n' >> '$gov_path' && git add -A && git -c user.email=s@l -c user.name=s commit -qm 'selftest: gov path probe'" \
    'CI=true PR_AUTHOR=human PR_LABELS="" PR_BODY="" bash scripts/checks/pr_governance.sh'
done

# ---------- UI統治表（development-process.md「1.」UI・デザイン領域のクラス）との同期 ----------
# 2026-08-26 の外部レビュー指摘: development-process.md の**UI統治表**が Class A と明記する
#   .stylelintrc.json / tokens/build.mjs / Taskfile.ui.yml
# が pr_governance.sh の $gov/$ab・check_diff_size.py の GOV_RE/AB_RE・.github/CODEOWNERS の
# いずれからも欠落しており、これらだけを変更する PR がすべての統治ゲートを素通りしていた
# （scripts/check-*.mjs・scripts/checks/ui.sh は scripts/ プレフィクスで既にマッチしていたため
# 気づかれにくかった）。上の主表ループと同じ手法で、UI 表の3ファイルを個別に検査する。
for gov_path in .stylelintrc.json tokens/build.mjs Taskfile.ui.yml; do
  run_case "pr_governance.sh: UI統治パス '$gov_path' の変更に permission-impact ラベルが無い（UI統治表との同期）" "" \
    "printf '\n/* selftest probe */\n' >> '$gov_path' && git add -A && git -c user.email=s@l -c user.name=s commit -qm 'selftest: ui gov path probe'" \
    'CI=true PR_AUTHOR=human PR_LABELS="" PR_BODY="" bash scripts/checks/pr_governance.sh'
done

# diff-size.sh（check_diff_size.py の GOV_RE）も UI統治表と同期していること。
run_case "diff-size.sh: UI統治パス（tokens/build.mjs）を Class A として分類し上限を適用する" "python3" \
  'yes "diff-size selftest synthetic line" | head -50 >> tokens/build.mjs &&
   git add -A >/dev/null 2>&1 &&
   git -c user.email=s@l -c user.name=s commit -qm "selftest: ui governance file diff" >/dev/null 2>&1' \
  'DIFF_SIZE_LIMIT_CLASS_A=10 bash scripts/checks/diff-size.sh'

# ---------- scripts/dev/** の Class C カーブアウト（development-process.md「1.」但し書き） ----------
# 2026-08-26 の外部レビュー指摘: $gov/$ab・GOV_RE/AB_RE は `scripts/` を無条件にマッチしており、
# 「ゲート・統治に関与しない開発補助のみ scripts/dev/** として Class C に置ける」という対象パス表の
# 但し書きが実装上機能していなかった（scripts/dev/ 配下を変更しても常に Class A 扱いになっていた）。
# fail-open ではなく安全側（過剰ゲート）の乖離だが、対象パス表と実装を一致させた。
# ここは「違反を注入して落ちる」run_case とは逆に「Class C 相当の変更が誤って Class A 扱いされない
# こと」を確認する陽性方向のテストのため、個別に判定する。
restore
mkdir -p scripts/dev
printf '#!/bin/sh\necho selftest probe\n' > scripts/dev/selftest-probe.sh
git add -A >/dev/null 2>&1
git -c user.email=s@l -c user.name=s commit -qm "selftest: scripts/dev carve-out probe" >/dev/null 2>&1
set +e
out_dev_carveout="$(CI=true PR_AUTHOR=human PR_LABELS="" PR_BODY="" bash scripts/checks/pr_governance.sh 2>&1)"
rc_dev_carveout=$?
set -e
restore
if [ "$rc_dev_carveout" -eq 0 ] && ! printf '%s' "$out_dev_carveout" | grep -q "governance path changed"; then
  printf '    [検出] pr_governance.sh: scripts/dev/** の変更は permission-impact を要求しない（Class C カーブアウトが機能する）\n'
  pass=$((pass + 1))
else
  err "見逃し: pr_governance.sh が scripts/dev/** を誤って Class A 扱いした（exit=$rc_dev_carveout）— 対象パス表の但し書きと不一致"
  fail=$((fail + 1))
fi

restore
mkdir -p scripts/dev
yes "diff-size selftest synthetic line" | head -50 > scripts/dev/selftest-probe-diffsize.sh
git add -A >/dev/null 2>&1
git -c user.email=s@l -c user.name=s commit -qm "selftest: scripts/dev diff-size carve-out probe" >/dev/null 2>&1
set +e
out_dev_diffsize="$(DIFF_SIZE_LIMIT_CLASS_A=1 bash scripts/checks/diff-size.sh 2>&1)"
rc_dev_diffsize=$?
set -e
restore
if [ "$rc_dev_diffsize" -eq 0 ]; then
  printf '    [検出] diff-size.sh: scripts/dev/** の変更行数は Class A 上限に計上しない（Class C カーブアウトが機能する）\n'
  pass=$((pass + 1))
else
  err "見逃し: diff-size.sh が scripts/dev/** を誤って Class A 上限に計上した（exit=$rc_dev_diffsize）— 対象パス表の但し書きと不一致"
  fail=$((fail + 1))
fi

# ---------- prompts.sh（台帳 #21）: キーの存在しか見ていなかった旧実装の回帰防止 ----------
# 2026-08-24 の外部レビュー指摘: 旧実装は行が「キー:」で始まるかだけを検査しており、値を空にしても
# status を管理語彙の外にしても last_review を 1999 年にしても合格した（再現確認済み）。
# 「陳腐化検知に用いる」と自ら書いた項目が日付として解釈すらされていなかった。
PROMPT_FIXTURE=prompts/workflows/ui-01-claude-design.md

run_case "prompts.sh: front-matter の値が空（キーの存在だけでは通さない）" "python3" \
  "sed -i 's/^owner: .*/owner:/' $PROMPT_FIXTURE" \
  'bash scripts/checks/prompts.sh'

run_case "prompts.sh: status が管理語彙の外" "python3" \
  "sed -i 's/^status: .*/status: bogus/' $PROMPT_FIXTURE" \
  'bash scripts/checks/prompts.sh'

run_case "prompts.sh: last_review が日付として解釈できない" "python3" \
  "sed -i 's/^last_review: .*/last_review: not-a-date/' $PROMPT_FIXTURE" \
  'bash scripts/checks/prompts.sh'

run_case "prompts.sh: last_review が未来日" "python3" \
  "sed -i 's/^last_review: .*/last_review: 2999-01-01/' $PROMPT_FIXTURE" \
  'bash scripts/checks/prompts.sh'

# 陳腐化の上限は既定で未設定（TBD-HUMAN）のため、diff-size と同じく selftest 内で閾値を注入し、
# 比較ロジック自体が動くことを確認する（実運用の値は採用組織が確定する）。
run_case "prompts.sh: 陳腐化の上限を設定したとき経過超過を検出する" "python3" \
  ':' \
  'PROMPT_REVIEW_MAX_AGE_DAYS=1 bash scripts/checks/prompts.sh'
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

# ---------- arch-boundaries.sh: 休眠・活性化の両方向を確認する（sast.sh と同一パターン。外部レビュー指摘） ----------
restore
set +e; out_dormant="$(bash scripts/checks/arch-boundaries.sh 2>&1)"; rc_dormant=$?; set -e
if [ "$rc_dormant" -eq 0 ] && printf '%s' "$out_dormant" | grep -q "dormant"; then
  printf '    [検出] arch-boundaries.sh: 休眠時（manifest 無し）に exit 0 かつ休眠メッセージを出す\n'
  pass=$((pass + 1))
else
  err "見逃し: arch-boundaries.sh が休眠時に正しく振る舞わなかった（exit=$rc_dormant）"
  fail=$((fail + 1))
fi

restore
printf '{"name":"selftest","private":true}\n' > package.json
set +e; out_active="$(bash scripts/checks/arch-boundaries.sh 2>&1)"; rc_active=$?; set -e
if [ "$rc_active" -eq 0 ] && printf '%s' "$out_active" | grep -q "no architecture boundary tool is wired" \
   && ! printf '%s' "$out_active" | grep -q "dormant"; then
  printf '    [検出] arch-boundaries.sh: 活性化時（package.json 検出）は休眠メッセージを出さず、未配線を正直に警告して exit 0\n'
  pass=$((pass + 1))
else
  err "見逃し: arch-boundaries.sh が活性化を検出できなかった（exit=$rc_active）"
  fail=$((fail + 1))
fi
restore

run_case "arch-boundaries.sh: ARCH_BOUNDARY_CMD が設定され失敗を報告した場合は exit 0 にしない（合否伝播の確認）" "" \
  'printf "{\"name\":\"selftest\",\"private\":true}\n" > package.json' \
  'ARCH_BOUNDARY_CMD=false bash scripts/checks/arch-boundaries.sh'

restore
printf '{"name":"selftest","private":true}\n' > package.json
set +e; ARCH_BOUNDARY_CMD=true bash scripts/checks/arch-boundaries.sh >/dev/null 2>&1; rc_arch_tool_ok=$?; set -e
restore
if [ "$rc_arch_tool_ok" -eq 0 ]; then
  printf '    [検出] arch-boundaries.sh: ARCH_BOUNDARY_CMD が成功を報告した場合は exit 0（過検知しない）\n'
  pass=$((pass + 1))
else
  err "見逃し: arch-boundaries.sh が ARCH_BOUNDARY_CMD 成功時に誤って失敗した（exit=$rc_arch_tool_ok）"
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

# check_diff_size.py の GOV_RE も対象パス表と同期していること（pr_governance.sh 側と対で欠落していた）。
# エージェント指示ファイルが Class A と分類されなければ差分規模上限が一切適用されない。
run_case "diff-size.sh: エージェント指示ファイル（CODEX.md）を Class A として分類し上限を適用する" "python3" \
  'yes "diff-size selftest synthetic line" | head -50 >> CODEX.md &&
   git add -A >/dev/null 2>&1 &&
   git -c user.email=s@l -c user.name=s commit -qm "selftest: agent instruction file diff" >/dev/null 2>&1' \
  'DIFF_SIZE_LIMIT_CLASS_A=10 bash scripts/checks/diff-size.sh'

# ---------- diff-size.sh の gate-linked waiver（既存リポジトリ導入で使う逃げ道。scripts/waivers.py） ----------
# 統治文書（development-process.md「5.」／台帳 #46）が案内する「時限的な適用除外」が、
# (1) 有効な waiver でのみ通過し、(2) 失効・プレースホルダ・Class 違いでは通過しないことを両方向で確認する。
# governance-metrics 側と同じ規約を共有しているため、片側だけ壊れる回帰をここで捕まえる。
mk_diff_violation='yes "diff-size selftest synthetic line" | head -50 >> governance/waivers/README.md'
mk_waiver() { # $1=target_check $2=expires
  printf -- "---\nid: WV-9999\ntarget_check: %s\nstatus: Active\nexpires: %s\n---\n\n# selftest waiver (negative-test fixture only)\n" \
    "$1" "$2" > governance/waivers/wv-9999-selftest-diff-size.md
}
commit_all='git add -A >/dev/null 2>&1 && git -c user.email=s@l -c user.name=s commit -qm "selftest: diff-size waiver fixture" >/dev/null 2>&1'

run_case "diff-size.sh: 失効した waiver は上限超過を正当化しない（無条件バイパスの禁止）" "python3" \
  "$mk_diff_violation && mk_waiver diff-size.class-a 2020-01-01 && $commit_all" \
  'DIFF_SIZE_LIMIT_CLASS_A=10 bash scripts/checks/diff-size.sh'

run_case "diff-size.sh: expires がプレースホルダ（TBD-HUMAN）の waiver は無効" "python3" \
  "$mk_diff_violation && mk_waiver diff-size.class-a TBD-HUMAN && $commit_all" \
  'DIFF_SIZE_LIMIT_CLASS_A=10 bash scripts/checks/diff-size.sh'

run_case "diff-size.sh: Class B 向け waiver は Class A の超過を通過させない（対象ゲートの取り違え防止）" "python3" \
  "$mk_diff_violation && mk_waiver diff-size.class-b 2099-01-01 && $commit_all" \
  'DIFF_SIZE_LIMIT_CLASS_A=10 bash scripts/checks/diff-size.sh'

# 陽性方向: 有効な waiver では通過すること（逃げ道が実在することの確認。ここが落ちると
# 統治文書の案内どおりに waiver を書いても PR が通らず、採用者はゲートを外す方へ流れる）。
if command -v python3 >/dev/null 2>&1; then
  restore
  eval "$mk_diff_violation" >/dev/null 2>&1 || true
  mk_waiver diff-size.class-a 2099-01-01
  eval "$commit_all" || true
  set +e; DIFF_SIZE_LIMIT_CLASS_A=10 bash scripts/checks/diff-size.sh >/dev/null 2>&1; rc_waiver_ok=$?; set -e
  restore
  if [ "$rc_waiver_ok" -eq 0 ]; then
    printf '    [検出] diff-size.sh: 有効な waiver は上限超過を許容して exit 0（案内された逃げ道が実在する）\n'
    pass=$((pass + 1))
  else
    err "見逃し: diff-size.sh が有効な waiver を認識しなかった（exit=$rc_waiver_ok）— 統治文書の案内と実装が乖離している"
    fail=$((fail + 1))
  fi
else
  warn "skip: diff-size.sh の waiver 陽性確認（python3 が無いため判定できない）"
  skipped=$((skipped + 1))
fi

# ---------- deps.sh のライセンスゲート（台帳 #55。休眠/活性化とツール解決） ----------
# ライセンス検査は本テンプレートに一行も存在しなかった（外部レビュー指摘）。#40・#52 と同型に、
# 「実ポリシーは未配線でも、活性化検出とツール解決は正しく動く」ことをここで担保する。
# trivy は不要（LICENSE_SCAN_CMD 経路のみを検査する。非 CI では need() が warn して継続する）。
restore
printf '{"name":"selftest","private":true}\n' > package.json
set +e; out_lic_gap="$(bash scripts/checks/deps.sh 2>&1)"; rc_lic_gap=$?; set -e
restore
if [ "$rc_lic_gap" -eq 0 ] && printf '%s' "$out_lic_gap" | grep -q "no license policy is wired yet"; then
  printf '    [検出] deps.sh: 依存マニフェスト検出時にライセンス未配線を警告して exit 0（黙って緑にしない）\n'
  pass=$((pass + 1))
else
  err "見逃し: deps.sh のライセンス未配線警告が出ない（exit=$rc_lic_gap）— 整備済みに見えて何も検査しない状態"
  fail=$((fail + 1))
fi

run_case "deps.sh: 配線されたライセンススキャナの失敗を握り潰さない" "" \
  'printf "{\"name\":\"selftest\",\"private\":true}\n" > package.json' \
  'LICENSE_SCAN_CMD="exit 3" bash scripts/checks/deps.sh'

restore
printf '{"name":"selftest","private":true}\n' > package.json
set +e; LICENSE_SCAN_CMD="true" bash scripts/checks/deps.sh >/dev/null 2>&1; rc_lic_ok=$?; set -e
restore
if [ "$rc_lic_ok" -eq 0 ]; then
  printf '    [検出] deps.sh: ライセンススキャナ成功時に過検知しない（陽性対照）\n'
  pass=$((pass + 1))
else
  err "見逃し: deps.sh がライセンススキャナ成功時に落ちた（exit=$rc_lic_ok）— 偽陽性はゲート不信の原因になる"
  fail=$((fail + 1))
fi
# ---------- secrets.sh（台帳 #1）: 最も優先度の高い MUST NOT に陰性テストが無かった ----------
# 2026-08-24 の外部レビュー指摘: #29（機械強制と定義したルールは違反を検出できなければならない）自体に
# 適用漏れがあり、`secrets.sh` と `adr-immutability.sh` は陰性テストが無いうえ「対象外」の開示にも
# 含まれていなかった。除外理由として挙げていた「ネットワーク依存」は gitleaks には当てはまらない
# （正規表現ベースでオフライン動作する）ため、技術的制約ではなく単なる漏れだった。
#
# フィクスチャは実行時に組み立てる: 秘密の“形”をした文字列を本ファイルへ literal で書くと、
# 本リポジトリ自身の git 履歴が gitleaks に検出されてしまう（自傷）。printf の書式指定子で
# 分割し、`-----BEGIN ... PRIVATE KEY-----` が本ファイル内に連続して現れないようにする。
# gitleaks の private-key ルールは `-----BEGIN[ A-Z0-9_-]{0,100}PRIVATE KEY` を照合するため、
# `%s` を挟んだ本ファイルの記述は照合されない。
# gitleaks detect は既定で git 履歴を走査するため、注入はコミットまで行う。
#
# 拡張子は .txt を用いる（.pem/.key は .gitignore が除外するため、実際には committed 一次確認済み: 2026-08-24）:
# `.pem` 拡張子で作成した初版は `.gitignore`（`*.pem`/`*.key`）に無視され、`git add -A` が
# 無言で何もステージせず `git commit` が「nothing to commit」で失敗し、フィクスチャが一度も
# コミットされないまま gitleaks が「検出なし」を返す false green を引き起こしていた（CI で
# 再現。mutate の失敗は元々 `>/dev/null 2>&1` で握り潰され、selftest 自体は「見逃し」として
# 正しく報告していたが原因の特定に至らなかった）。
run_case "secrets.sh: 秘密情報（秘密鍵ブロック）の混入" "gitleaks" \
  'printf -- "-----BEGIN %s PRIVATE KEY-----\nMIIBOgIBAAJBAKj34selftestfixtureonlynotarealkey0000000000000000\n-----END %s PRIVATE KEY-----\n" RSA RSA > selftest-secret-fixture.txt &&
   git add -A &&
   git -c user.email=s@l -c user.name=s commit -qm "selftest: synthetic secret"' \
  'bash scripts/checks/secrets.sh'
# ---------- adr-immutability.sh（台帳 #8）: Accepted ADR の不変性 ----------
# 「変更履歴」以外の本文を書き換えた場合に落ちること。base 側で既に accepted である ADR を選ぶ
# （adr-0005 / adr-0006 が accepted。proposed→accepted 遷移 PR には適用されない仕様のため）。
# base/head を明示して git 依存を確定させる（BASE_SHA が無いと merge-base origin/main に依存する）。
run_case "adr-immutability.sh: Accepted ADR の本文（変更履歴以外）の改変" "" \
  'printf "\n本文の不正な追記（selftest フィクスチャ）。\n" >> adr/adr-0005-css-token-enforcement.md &&
   git add -A >/dev/null 2>&1 &&
   git -c user.email=s@l -c user.name=s commit -qm "selftest: accepted ADR mutation" >/dev/null 2>&1' \
  'BASE_SHA=HEAD~1 bash scripts/checks/adr-immutability.sh'
# ---------- build.sh の lint 配線（台帳 #56。休眠/活性化とツール解決） ----------
# lint は本テンプレートに実行経路そのものが無かった（外部レビュー指摘）。#40・#52・#55 と同型に、
# 「実リンタは未配線でも、活性化検出とツール解決は正しく動く」ことを担保する。
# 注: BUILD_CMD を no-op に固定し、スタック自動検出（npm ci 等）が走らないようにする。
restore
printf '{"name":"selftest","private":true}\n' > package.json
set +e; out_lint_gap="$(BUILD_CMD=true bash scripts/checks/build.sh 2>&1)"; rc_lint_gap=$?; set -e
restore
if [ "$rc_lint_gap" -eq 0 ] && printf '%s' "$out_lint_gap" | grep -q "no linter/formatter is wired yet"; then
  printf '    [検出] build.sh: コードスタック検出時に lint 未配線を警告して exit 0（黙って緑にしない）\n'
  pass=$((pass + 1))
else
  err "見逃し: build.sh の lint 未配線警告が出ない（exit=$rc_lint_gap）— 整備済みに見えて何も検査しない状態"
  fail=$((fail + 1))
fi

run_case "build.sh: 配線されたリンタの失敗を握り潰さない" "" \
  'printf "{\"name\":\"selftest\",\"private\":true}\n" > package.json' \
  'BUILD_CMD=true LINT_CMD="exit 5" bash scripts/checks/build.sh'

restore
printf '{"name":"selftest","private":true}\n' > package.json
set +e; BUILD_CMD=true LINT_CMD="true" bash scripts/checks/build.sh >/dev/null 2>&1; rc_lint_ok=$?; set -e
restore
if [ "$rc_lint_ok" -eq 0 ]; then
  printf '    [検出] build.sh: リンタ成功時に過検知しない（陽性対照）\n'
  pass=$((pass + 1))
else
  err "見逃し: build.sh がリンタ成功時に落ちた（exit=$rc_lint_ok）— 偽陽性はゲート不信の原因になる"
  fail=$((fail + 1))
fi
# 対象外の明示（黙って落とさない）
warn "対象外: links.sh（lychee・ネットワーク依存）／deps.sh の脆弱性スキャン部分（trivy・脆弱性DB依存。ライセンス部分は検査済み）／視覚回帰（ブラウザ必須）／build.sh・deps-audit.sh（採用スタックまたは外部 API に依存し、本テンプレート単体では違反を注入できない）／adoption.sh（助言専用で verify を失敗させない設計のため陰性テストの対象にならない。設計上の除外）"

cd "$REPO_ROOT"
say "自己診断: 検出 ${pass} 件 / 見逃し ${fail} 件 / skip ${skipped} 件"
[ "$fail" -eq 0 ] || {
  err "ゲートが違反を検出できていません。原因側（当該チェック）を修正してください（憲章「8. ブートストラップ規定」）。"
  exit 1
}
ok "Gate self-test"
