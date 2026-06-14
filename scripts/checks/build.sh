#!/usr/bin/env bash
# Build / type-check / test with stack auto-detection.
# No-op (green) for a docs-only template; activates when a code manifest is added.
set -eu
. scripts/lib/common.sh
say "Build / type / test (stack auto-detect)"
ran=0
if [ -f package.json ]; then
  ran=1; say "node"; (npm ci || npm install)
  npm run build --if-present; npm run typecheck --if-present; npm test --if-present
fi
if [ -f go.mod ]; then ran=1; say "go"; go build ./...; go vet ./...; go test ./...; fi
if [ -f pom.xml ]; then ran=1; say "maven"; mvn -B verify; fi
if [ -f build.gradle ] || [ -f build.gradle.kts ]; then ran=1; say "gradle"; ./gradlew build; fi
if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ]; then
  ran=1; say "python"
  py -m pip install -e . 2>/dev/null || py -m pip install -r requirements.txt 2>/dev/null || true
  if have pytest; then pytest; else warn "pytest not configured"; fi
fi
[ "$ran" -eq 1 ] || warn "no code stack detected — build/test skipped (activates when a manifest is added)"
# TODO(adoption): カバレッジ閾値の強制は未実装（強制台帳 #15b / testing-standards.md「1.」）。
#   採用スタックで配線すること: pytest --cov-fail-under / jest coverageThreshold / go cover / JaCoCo。
#   配線するまで「カバレッジ MUST」は人間レビューで担保する（整備済みと扱わない＝憲章「1.1」MUST NOT）。
[ "${COVERAGE_ENFORCED:-}" = "1" ] || warn "coverage gate NOT enforced yet — wire a threshold in your stack (ledger #15b)"
ok "build/test"
