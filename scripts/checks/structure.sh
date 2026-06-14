#!/usr/bin/env bash
# Required documents exist and agent-instruction files reference the constitution/AGENTS.
# (constitution.md「8. 機械的に検証可能なルール／ドキュメント構造」)
set -eu
. scripts/lib/common.sh
say "Required documents & references"
fail=0
for f in README.md AGENTS.md constitution.md; do
  [ -f "$f" ] || { err "$f is missing"; fail=1; }
done
[ -d adr ] || { err "adr/ directory is missing"; fail=1; }
[ -f AGENTS.md ] && { grep -q "constitution.md" AGENTS.md || { err "AGENTS.md must reference constitution.md"; fail=1; }; }
for f in CLAUDE.md GEMINI.md CODEX.md OPENHANDS.md TAKT.md SKILLS.md; do
  if [ -f "$f" ]; then grep -q "AGENTS.md" "$f" || { err "$f must reference AGENTS.md"; fail=1; }; fi
done
[ "$fail" -eq 0 ] || exit 1
ok "structure"
