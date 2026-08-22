#!/usr/bin/env bash
# PR-context governance: Class A/B changes need an ADR reference (or stated reason),
# and changes to governance/enforcement paths need the 'permission-impact' label.
# In CI: enforced using PR_AUTHOR / PR_BODY / PR_LABELS / BASE_SHA / HEAD_SHA. Locally: advisory.
set -eu
. scripts/lib/common.sh
say "PR governance (ADR reference / permission-impact)"

# section_has_content <見出し正規表現>: PR_BODY のうち、指定した "## 見出し" 行から次の
# "## " 見出しまでの本文を取り出し、HTML コメントを除去した残りが非空白かどうかを判定する。
# 見出しの存在ではなく実体（非プレースホルダ）の存在を検査する共通の技術（ADR不要理由の
# 抽出・ロールバック手順チェックと同一。可逆性チェックでも使うため関数化した）。
# HTML コメントは複数行にまたがりうる（.github/pull_request_template.md の案内文は3行）。
# sed の `<!--.*-->` は行単位でしか照合しないため、開始行と終了行が異なるコメントを除去できず
# 未編集テンプレートがそのまま「実体あり」と誤判定されていた（外部レビュー指摘・再現確認済み）。
# 複数行対応のため Python の re.DOTALL で除去する。
section_has_content() {
  heading_re="$1"
  body="$(printf '%s\n' "${PR_BODY:-}" | awk -v re="$heading_re" '$0 ~ ("^##[[:space:]]*" re) {f=1; next} /^##[[:space:]]/{f=0} f')"
  stripped="$(printf '%s' "$body" | py -c "import re,sys; sys.stdout.write(re.sub(r'<!--.*?-->', '', sys.stdin.read(), flags=re.S))")"
  printf '%s' "$stripped" | grep -Eq '[^[:space:]]'
}

# --- AI 生成識別: 既知の AI エージェント・マシンアカウントが PR 作成者なら ai-generated ラベルを要求 ---
# 根拠: development-process.md「6. 監査証跡の記録方式」（WU07-01）。6章は既に「AI は専用マシンアカウントで
# 行為する（MUST。憲章「権限・統治への変更」）」を定めており、マシンアカウントが実在すれば PR 作成者から
# AI 起案かどうかを機械判定できる。これは自己申告（ai-generated ラベル／Assisted-by: トレーラの手動付与）
# への依存を減らすための実装であり、下の permission-impact チェックと同一パターンを踏む。
#
# 現状の注意（誠実な開示。強制台帳 #13・#40）: 本リポジトリには実在の専用マシンアカウントがまだ発行されて
# いない。agents/README.md「1.」の `@bot/*` は採用時に置換される意図的なプレースホルダである。したがって
# 本チェックは「メカニズムとして正しく動作する」が「本リポジトリでは実行機会がない（未行使）」。
# 許容パターンは agents/README.md「1.」の名簿（claude/codex/gemini/openhands/takt）の命名に由来する。
# dependabot[bot] 等の依存自動更新ボットは対象外とする（「AI が起案・生成した変更」の定義に該当せず、
# ADR-0006 のカーブアウトとは無関係の別理由による除外）。実アカウント発行後は本許容リストを実名へ更新する。
#
# diff の有無に関係なく判定する（PR 作成者の属性はファイル差分と独立のため、下の「diff なしは skip」より前に置く）。
ai_bot_author_pattern='^(claude|codex|gemini|openhands|takt)([-_](code|cli|agent|bot))*(\[bot\])?$'
if printf '%s' "${PR_AUTHOR:-}" | grep -Eiq "$ai_bot_author_pattern"; then
  if echo "${PR_LABELS:-}" | grep -q "ai-generated"; then
    :
  elif [ "${CI:-}" = "true" ]; then
    err "PR author '${PR_AUTHOR:-}' matches a known AI-agent machine identity: PR requires the 'ai-generated' label (development-process.md「6.」MUST)"
    exit 1
  else
    warn "PR author '${PR_AUTHOR:-}' looks like a known AI-agent machine identity — ensure the PR has the 'ai-generated' label"
  fi
fi

base="${BASE_SHA:-origin/main}"; head="${HEAD_SHA:-HEAD}"
changed="$(git diff --name-only "$base" "$head" 2>/dev/null || git diff --name-only HEAD~1 2>/dev/null || true)"
[ -n "$changed" ] || { warn "no diff detected — skipping"; ok "PR governance"; exit 0; }

gov='^(constitution\.md|adr-rules\.md|adr-template(-minimal)?\.md|\.specify/memory/constitution\.md|governance/|standards/|\.github/|AGENTS\.md|CLAUDE\.md|GEMINI\.md|SKILLS\.md|Taskfile\.yml|lefthook\.yml|\.mise\.toml|scripts/)'
ab='^(constitution\.md|adr-rules\.md|adr-template(-minimal)?\.md|governance/|standards/|\.github/|AGENTS\.md|CLAUDE\.md|GEMINI\.md|SKILLS\.md|architecture/|adr/|Taskfile\.yml|lefthook\.yml|\.mise\.toml|scripts/)'

if echo "$changed" | grep -Eq "$gov"; then
  if [ "${CI:-}" = "true" ]; then
    echo "${PR_LABELS:-}" | grep -q "permission-impact" \
      || { err "governance/enforcement path changed: PR requires the 'permission-impact' label (＋CODEOWNERS)"; exit 1; }
  else
    warn "governance path changed — ensure the PR has the 'permission-impact' label"
  fi
fi

# --- カーブアウト: dependabot による GitHub Actions の版数更新（ADR-0006） ---
# 免除するのは「ADR 参照 or ADR不要理由」の記載要件のみ。permission-impact ラベルと
# CODEOWNERS 承認（＝人間レビュー）は免除しない。
# 根拠: development-process.md「1.」は依存のパッチ／マイナー更新を Class C（ADR 原則不要）と
#   定めており、本カーブアウトはその分類への整合である（新たな緩和ではない）。
# 条件（すべて満たす場合のみ）:
#   1. PR 作成者が dependabot[bot]（イベントペイロード由来。利用者が詐称できない）
#   2. 変更ファイルが .github/workflows/*.yml のみ
#   3. 変更行が `uses: <owner>/<repo>@<ref>` の形だけ（ロジック・権限・トリガの変更を含まない）
is_dependabot_action_bump() {
  [ "${PR_AUTHOR:-}" = "dependabot[bot]" ] || return 1

  if printf '%s\n' "$changed" | grep -qvE '^\.github/workflows/[A-Za-z0-9._-]+\.ya?ml$'; then
    return 1
  fi

  diffbody="$(git diff -U0 "$base" "$head" -- '.github/workflows/' 2>/dev/null \
    | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' || true)"
  [ -n "$diffbody" ] || return 1

  # `uses: owner/repo@ref` 以外の追加・削除行が 1 行でもあれば対象外。
  if printf '%s\n' "$diffbody" \
    | grep -qvE '^[+-][[:space:]]*(- )?uses:[[:space:]]*[A-Za-z0-9._-]+/[A-Za-z0-9._/-]+@[A-Za-z0-9._-]+[[:space:]]*$'; then
    return 1
  fi
  return 0
}

if echo "$changed" | grep -Eq "$ab" && is_dependabot_action_bump; then
  warn "dependabot による Actions 版数更新のため ADR 記載要件を免除（ADR-0006。permission-impact ＋ CODEOWNERS は必須のまま）"
elif echo "$changed" | grep -Eq "$ab"; then
  # 「ADR不要理由」は見出しの存在ではなく、プレースホルダでない実体（理由本文）を要求する。
  # PR テンプレートの未編集行（`（← …`）や空欄・`____` は不合格として扱う。
  reason="$(printf '%s\n' "${PR_BODY:-}" | sed -n 's/.*ADR不要理由[：:]//p' | head -1)"
  reason="$(printf '%s' "$reason" | sed -E 's/<!--.*-->//g; s/^[[:space:]*`]+//; s/[[:space:]]+$//')"
  reason_ok=0
  case "$reason" in
    ''|'____'*|'（←'*|'(←'*) reason_ok=0 ;;
    *) reason_ok=1 ;;
  esac
  has_ref=0
  if echo "${PR_BODY:-}" | grep -Eq 'ADR-[0-9]{4}'; then has_ref=1; fi
  if [ "$has_ref" = 1 ] || [ "$reason_ok" = 1 ]; then :
  elif [ "${CI:-}" = "true" ]; then
    err "Class A/B PR must reference ADR-#### or give a non-placeholder 'ADR不要理由:' in the body"; exit 1
  else
    warn "Class A/B path changed — PR body must reference ADR-#### or give a real 'ADR不要理由:'（プレースホルダ不可）"
  fi
fi

# --- ロールバック手順（development-process.md「7.」／governance/enforcement-ledger.md #34-35） ---
# Class A の PR は「## ロールバック手順」セクションに非プレースホルダの実体を記載しなければならない（MUST）。
# 本チェックは「記載の有無」のみを機械検証する（ADR不要理由の抽出と同じ技術：見出し以下の本文を取り出し、
# HTML コメントを除去し、残りが空であればプレースホルダ扱い）。記載**内容の妥当性**は機械検証できないため
# 人間ゲート（不可避）(b) 責任の引受として、レビュアが判断する（機械検証の対象外。台帳 #35）。
#
# トリガ条件は「class:A ラベル」だけでなく「統治パスの変更（$gov）」も OR で含める。ラベル単独に
# 依存すると、Class A に該当する変更でもラベルの付け忘れ・未付与だけで本チェックが丸ごと発火しない
# fail-open になる（permission-impact チェックはパス由来のため fail-close。非対称だった。外部レビュー指摘）。
if echo "${PR_LABELS:-}" | grep -q "class:A" || echo "$changed" | grep -Eq "$gov"; then
  if section_has_content "ロールバック手順"; then :
  elif [ "${CI:-}" = "true" ]; then
    err "class:A PR must include non-placeholder content under '## ロールバック手順' in the body（development-process.md「7.」）"; exit 1
  else
    warn "class:A PR — body should include non-placeholder content under '## ロールバック手順'（development-process.md「7.」。プレースホルダ不可）"
  fi
fi

# --- 可逆性（フィーチャーフラグ／migration の down 定義／段階公開。development-process.md「5.」／ ---
# --- architecture/principles.md「5.」／governance/enforcement-ledger.md #52） ---
# 「レビューコストを下げる」の柱のひとつは可逆性（間違いが安く戻せれば要求される厳密度が下がる）。
# これまでロールバック手順（本番反映後の復旧手順）は機械検証されていたが、変更そのものを可逆に
# 「設計」しているか（フィーチャーフラグ・段階公開・migration の down 定義）は playbooks/rollback.md
# の SHOULD 1行にとどまり、機械検証も PR テンプレートの必須欄も無かった（外部レビュー指摘）。
# ロールバック手順と同じ技術で「記載の有無」のみを検証する。記載内容の妥当性（設計として十分か）
# は機械検証できないため人間ゲート（不可避）(b) 責任の引受のまま（台帳 #53）。該当なしの場合も
# 「該当なし: 理由」を記載すればよい（ADR不要理由・ロールバック手順と同型のプレースホルダ判定）。
if echo "${PR_LABELS:-}" | grep -q "class:A" || echo "$changed" | grep -Eq "$gov"; then
  if section_has_content "可逆性"; then :
  elif [ "${CI:-}" = "true" ]; then
    err "class:A PR must include non-placeholder content under '## 可逆性' in the body（development-process.md「5.」／architecture/principles.md「5.」）"; exit 1
  else
    warn "class:A PR — body should include non-placeholder content under '## 可逆性'（development-process.md「5.」。該当なしの場合も理由を記載。プレースホルダ不可）"
  fi
fi

ok "PR governance"
