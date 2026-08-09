#!/usr/bin/env bash
# 依存・ツールチェーンの版数と既知脆弱性の監査（standards/security-standards.md「6.」）。
#
# trivy（scripts/checks/deps.sh）はマニフェストのあるプロジェクトを対象とするため、
# `package.json` / lockfile を持たない段階では実質的に空振りする。本チェックはその空白を埋め、
# `.mise.toml` / `requirements-docs.txt` / `package.ui.json` / ワークフローの `uses:` を対象に
# LTS 追随と既知脆弱性を確認する。
#
# ネットワークに依存するため `task verify` には**含めない**（CI を外部 API の可用性に依存させない）。
# 定期実行は .github/workflows/audit.yml、手動実行は `task audit:deps`。
set -eu
. scripts/lib/common.sh
say "Dependency & toolchain audit (versions / LTS / OSV)"
have python3 || have python || { need python "install python3 (or: task setup)" && true || exit 0; }
py scripts/audit_deps.py "$@"
ok "Dependency & toolchain audit"
