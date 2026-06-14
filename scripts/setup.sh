#!/usr/bin/env bash
# Provision the pinned toolchain. Prefers mise (.mise.toml) for Local = AI = CI parity.
set -eu
. scripts/lib/common.sh
if have mise; then
  say "Installing pinned tools via mise (.mise.toml)"
  mise trust >/dev/null 2>&1 || true
  mise install
  ok "Tools installed — run: task verify"
else
  warn "mise not found (recommended for reproducible tool versions)."
  echo "  Install mise:  https://mise.jdx.dev   then run:  mise install"
  echo "  Or install individually: task, lefthook, markdownlint-cli2 (npm),"
  echo "  lychee, gitleaks, trivy, python3, node."
fi
