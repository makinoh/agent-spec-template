#!/usr/bin/env bash
# Lint / build / type-check / test.
#
# 解決順序（sast.sh / arch-boundaries.sh と同一の「ツールを固定しない」設計）:
#   1. 環境変数 BUILD_CMD（例: "make ci" / "pnpm -r test" / "tox -e py312"）
#   2. scripts/dev/build-tool.sh が存在し実行可能なら、それを使う
#   3. いずれも無ければスタック自動検出（既定。新規プロジェクト向け）
#
# なぜ差し替え機構が要るか（既存リポジトリへの導入。ADOPTION-EXISTING.md）:
#   自動検出は「まだコードが無いリポジトリにこれからコードを足す」新規採用を前提にしている。
#   既にリリース済みのプロジェクトへ本テンプレートを重ねる場合、ビルド・テストの入口は
#   すでに存在し（Makefile / monorepo のワークスペース / tox / Gradle ラッパ＋引数 / 専用CI
#   ジョブ等）、リポジトリ直下で `npm ci` や `pytest` を素で叩く自動検出とは一致しない。
#   - `npm ci` は node_modules を削除して作り直すため、既存の開発環境を壊し得る
#   - monorepo ではルートに package.json があってもルートでのテスト実行は正しくない
#   - 複数スタックの同居（例: アプリは Go、補助ツールが Python）で無関係な実行が走る
#   これらを理由にゲートごと外されるくらいなら、入口を差し替えられるようにして
#   「実際に走るテスト」をゲートに接続する方がよい（憲章「8. ブートストラップ規定」:
#   整備済みに見えて機能していない状態を作らない）。
#
# 差し替えはゲートの緩和ではない: BUILD_CMD の終了コードはそのまま伝播する（失敗は失敗）。
# 何を実行したかは常に出力し、黙って別物を実行したように見えないようにする。
set -eu
. scripts/lib/common.sh
say "Lint / build / type / test"

BUILD_TOOL_CMD="${BUILD_CMD:-}"
if [ -z "$BUILD_TOOL_CMD" ] && [ -x "scripts/dev/build-tool.sh" ]; then
  BUILD_TOOL_CMD="scripts/dev/build-tool.sh"
fi

if [ -n "$BUILD_TOOL_CMD" ]; then
  say "running configured build command: $BUILD_TOOL_CMD"
  # shellcheck disable=SC2086
  eval "$BUILD_TOOL_CMD"
else
  say "no BUILD_CMD configured — falling back to stack auto-detect"
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
fi

# --- フォーマッタ／リンタ／型チェック（強制台帳 #56 / standards/coding-standards.md「1.」） ---
#
# 背景（2026-08-24 新設。外部レビュー指摘）: coding-standards.md「1.」は
# 「スタックごとにフォーマッタ／リンタを採用し CI で強制するべき（SHOULD）」と委譲しているが、
# 本テンプレートは lint の雛形（.eslintrc / ruff.toml / .golangci.yml 等）を一切同梱しておらず、
# 本スクリプトにも lint の実行経路が無かった（`npm run typecheck --if-present` は採用者が
# スクリプトを定義しなければ何も起きない）。さらにこの配線漏れは ADOPTION.md「ステップ 8」の
# 未配線ゲート一覧にも強制台帳にも登録されておらず、**誠実な開示リストの唯一の穴**だった。
# 命名規則・エラー処理の一貫性はレビュー負荷に直結するため、SAST（#40）・アーキ境界（#52）と
# 同じ「休眠/活性化＋差し替え可能なツール解決」で配線できるようにする。
#
# なぜ既定のリンタ設定を同梱しないか: 採用スタックにより適切なツールも規則も異なり、
# 統治文書に特定製品名を書かない方針（security-standards.md「8.」と同じ NG-05）に従う。
# 解決順序:
#   1. 環境変数 LINT_CMD（例: "npm run lint" / "ruff check . && ruff format --check ." / "golangci-lint run"）
#   2. 実行可能な scripts/dev/lint-tool.sh
# どちらも無く、かつコードスタックを検出した場合は「不合格」ではなく「未配線」である。
# サイレントに合格させない（憲章「8. ブートストラップ規定」）。
LINT_TOOL_CMD="${LINT_CMD:-}"
if [ -z "$LINT_TOOL_CMD" ] && [ -x "scripts/dev/lint-tool.sh" ]; then
  LINT_TOOL_CMD="scripts/dev/lint-tool.sh"
fi

lint_stack=0
if [ -f package.json ]; then lint_stack=1; fi
if [ -f go.mod ]; then lint_stack=1; fi
if [ -f pom.xml ]; then lint_stack=1; fi
if [ -f build.gradle ] || [ -f build.gradle.kts ]; then lint_stack=1; fi
if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ]; then lint_stack=1; fi

if [ -n "$LINT_TOOL_CMD" ]; then
  say "running configured lint command: $LINT_TOOL_CMD"
  # shellcheck disable=SC2086
  eval "$LINT_TOOL_CMD"
  ok "lint"
elif [ "$lint_stack" -eq 1 ]; then
  warn "code stack detected but no linter/formatter is wired yet."
  warn "set \$LINT_CMD, or add an executable scripts/dev/lint-tool.sh, to activate style/type enforcement."
  warn "this is a tracked bootstrap gap — see governance/enforcement-ledger.md #56 and"
  warn "standards/coding-standards.md「1.」（ADOPTION.md「ステップ 8」も参照）."
else
  warn "no code stack detected — lint skipped (dormant; activates when a manifest is added)"
fi

# TODO(adoption): カバレッジ閾値の強制は未実装（強制台帳 #15b / testing-standards.md「1.」）。
#   採用スタックで配線すること: pytest --cov-fail-under / jest coverageThreshold / go cover / JaCoCo。
#   配線するまで「カバレッジ MUST」は人間レビューで担保する（整備済みと扱わない＝憲章「1.1」MUST NOT）。
[ "${COVERAGE_ENFORCED:-}" = "1" ] || warn "coverage gate NOT enforced yet — wire a threshold in your stack (ledger #15b)"
ok "build/test"
