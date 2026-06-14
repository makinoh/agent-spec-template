#!/usr/bin/env bash
# PR-context governance: Class A/B changes need an ADR reference (or stated reason),
# and changes to governance/enforcement paths need the 'permission-impact' label.
# In CI: enforced using PR_BODY / PR_LABELS / BASE_SHA / HEAD_SHA. Locally: advisory.
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

if echo "$changed" | grep -Eq "$ab"; then
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
