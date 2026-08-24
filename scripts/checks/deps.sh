#!/usr/bin/env bash
# Dependency scan: (1) 既知脆弱性（CVE）／(2) ライセンス互換性。
#
# 両者は目的も判定根拠も異なるため別項目として扱う（standards/security-standards.md「5.」「6.1」）。
# 脆弱性は CVSS という公開スケールで機械判定できるが、ライセンスの受容可否は採用組織の
# 法務・契約判断（憲章「6.」承認マトリクスの理由区分 (c) 法令・契約・規制要求）であり、
# しきい値を AI が発明してはならない（憲章「10.1.3 推測の禁止」）。
set -eu
. scripts/lib/common.sh
say "Dependency scan (vulnerability / license)"

trivy_available=0
if need trivy "https://github.com/aquasecurity/trivy (or: task setup)"; then
  trivy_available=1
fi

# --- 1) 既知脆弱性（CVE）。強制台帳 #2 / security-standards.md「5.」 ---
#
# --ignore-unfixed の適用範囲（2026-08-24 に明示。外部レビュー指摘）:
#   本コマンドは**修正版が存在する**脆弱性のみを失敗条件とする。上流に修正が無い脆弱性で
#   恒久的に赤くなるとゲートごと外される力学が働くため運用上の選択だが、これは
#   security-standards.md「5.」の MUST NOT を実装側で狭めていることを意味する。
#   規範側（同「5.」）に同一の条件を明記し、規範と実装を一致させた。強制台帳 #2 にも開示する。
#   修正版の無い High/Critical は本ゲートでは検出されない（人間ゲートで担保する）。
if [ "$trivy_available" -eq 1 ]; then
  trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 --ignore-unfixed --no-progress .
  ok "Dependency vulnerability scan"
else
  warn "trivy 不在のため脆弱性スキャンを実行できません（CI では need() が fatal にする）"
fi

# --- 2) ライセンス互換性。強制台帳 #55 / security-standards.md「6.1」 ---
#
# 背景: constitution.md「6.」承認マトリクスと development-process.md「1.」は、依存のライセンス変更を
# Class A・理由区分 (c) として人間承認必須に置いているが、2026-08-24 まで強制台帳にライセンスの行が
# 一行も無く、機械検知の主体も存在しなかった（trivy は --scanners vuln のみで起動し、
# scripts/audit_deps.py の照会先 4 系統にもライセンス照会は無い）。脆弱性側が #2・#30 で二重に
# 配線されているのと対照的に、規範だけがあって強制も開示も無い唯一の項目だった（外部レビュー指摘）。
#
# 休眠・活性化パターン（sast.sh / arch-boundaries.sh と同一。ツールを固定しない）:
#   1. 環境変数 LICENSE_SCAN_CMD（採用スタックのライセンスチェッカを直接指定）
#   2. 実行可能な scripts/dev/license-tool.sh
#   3. 環境変数 LICENSE_FAIL_SEVERITY が設定されていれば trivy の license スキャナを使う
#      （値の例は security-standards.md「6.1」を参照。既定値は同梱しない＝TBD-HUMAN）
#   いずれも無い場合、これは「不合格」ではなく「未配線」である。サイレントに合格させない
#   （憲章「8. ブートストラップ規定」）。
lic_stack=0
for m in package.json go.mod pom.xml build.gradle build.gradle.kts pyproject.toml requirements.txt setup.py Gemfile Cargo.toml composer.json; do
  [ -f "$m" ] && lic_stack=1
done

if [ "$lic_stack" -ne 1 ]; then
  warn "no dependency manifest detected — license scan skipped (dormant; activates when a manifest is added)"
  ok "Dependency scan (license: dormant)"
  exit 0
fi

LICENSE_TOOL_CMD="${LICENSE_SCAN_CMD:-}"
if [ -z "$LICENSE_TOOL_CMD" ] && [ -x "scripts/dev/license-tool.sh" ]; then
  LICENSE_TOOL_CMD="scripts/dev/license-tool.sh"
fi

if [ -n "$LICENSE_TOOL_CMD" ]; then
  say "running configured license scanner: $LICENSE_TOOL_CMD"
  # shellcheck disable=SC2086
  eval "$LICENSE_TOOL_CMD"
  ok "Dependency license scan"
elif [ -n "${LICENSE_FAIL_SEVERITY:-}" ]; then
  if [ "$trivy_available" -ne 1 ]; then
    warn "LICENSE_FAIL_SEVERITY は設定されていますが trivy がありません（CI では need() が fatal にする）"
  else
    say "running trivy license scanner (fail severity: ${LICENSE_FAIL_SEVERITY})"
    trivy fs --scanners license --severity "${LICENSE_FAIL_SEVERITY}" --exit-code 1 --no-progress .
    ok "Dependency license scan"
  fi
else
  warn "dependency manifest detected but no license policy is wired yet."
  warn "set \$LICENSE_SCAN_CMD, add an executable scripts/dev/license-tool.sh, or set \$LICENSE_FAIL_SEVERITY."
  warn "which licenses are acceptable is a legal/contractual decision for the adopting org"
  warn "(constitution.md「6.」承認マトリクス 理由区分 (c)) — this template ships no default on purpose."
  warn "this is a tracked bootstrap gap — see governance/enforcement-ledger.md #55 and"
  warn "standards/security-standards.md「6.1」."
  ok "Dependency scan (license: bootstrap gap — activation-detection verified, no policy wired yet)"
fi
