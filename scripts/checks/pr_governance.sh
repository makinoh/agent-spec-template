#!/usr/bin/env bash
# PR-context governance: Class A/B changes need an ADR reference (or stated reason),
# and changes to governance/enforcement paths need the 'permission-impact' label.
# In CI: enforced using PR_AUTHOR / PR_BODY / PR_LABELS / BASE_SHA / HEAD_SHA. Locally: advisory.
set -eu
. scripts/lib/common.sh
say "PR governance (ADR reference / permission-impact)"

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
