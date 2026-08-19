#!/usr/bin/env bash
# PR-context governance: Class A/B changes need an ADR reference (or stated reason),
# and changes to governance/enforcement paths need the 'permission-impact' label.
# In CI: enforced using PR_AUTHOR / PR_BODY / PR_LABELS / BASE_SHA / HEAD_SHA. Locally: advisory.
set -eu
. scripts/lib/common.sh
say "PR governance (ADR reference / permission-impact)"

# --- AI 生成識別: 既知の AI エージェント・マシンアカウントが PR 作成者なら ai-generated ラベルを要求 ---
# 根拠: development-process.md「6. 監査証跡の記録方式」（WU07-01）。6章は既に「AI は専用マシンアカウントで
# 行為する（MUST。憲章「権限・統治への変更」）」を定めており、マシンアカウントが実在すれば PR 作成者から
# AI 起案かどうかを機械判定できる。これは自己申告（ai-generated ラベル／Assisted-by: トレーラの手動付与）
# への依存を減らすための実装であり、下の permission-impact チェックと同一パターンを踏む。
#
# 現状の注意（誠実な開示。強制台帳 #13・#36）: 本リポジトリには実在の専用マシンアカウントがまだ発行されて
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
ok "PR governance"
