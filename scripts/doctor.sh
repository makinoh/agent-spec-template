#!/usr/bin/env bash
# Report which quality-gate tools are available in the current environment.
set -eu
. scripts/lib/common.sh
say "Quality-gate toolchain"
for t in task lefthook node npm npx python3 markdownlint-cli2 lychee gitleaks trivy git; do
  if have "$t"; then printf '  %b✓%b %-18s %s\n' "$GRN" "$RST" "$t" "$("$t" --version 2>/dev/null | head -1)";
  else printf '  %b–%b %-18s (missing)\n' "$YEL" "$RST" "$t"; fi
done
echo "Run 'task setup' (mise) to install missing tools."
