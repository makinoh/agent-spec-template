#!/usr/bin/env bash
# Secret scan (gitleaks). Fails if credentials/keys are detected.
set -eu
. scripts/lib/common.sh
say "Secret scan"
need gitleaks "https://github.com/gitleaks/gitleaks (or: task setup)" || exit 0
gitleaks detect --source . --no-banner --redact
ok "Secret scan"
