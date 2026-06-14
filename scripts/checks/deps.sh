#!/usr/bin/env bash
# Dependency vulnerability scan (trivy fs). Fails on HIGH/CRITICAL (CVSS >= 7.0).
set -eu
. scripts/lib/common.sh
say "Dependency vulnerability scan"
need trivy "https://github.com/aquasecurity/trivy (or: task setup)" || exit 0
trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 --ignore-unfixed --no-progress .
ok "Dependency scan"
