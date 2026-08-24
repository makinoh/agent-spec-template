#!/usr/bin/env bash
# Secret scan (gitleaks). Fails if credentials/keys are detected.
#
# 既定は「リポジトリの全 git 履歴」を対象とする（gitleaks detect の既定動作）。新規採用では
# これが正しい: 履歴が短く、混入があれば直ちに直せる。
#
# 既存リポジトリへ導入する場合（ADOPTION-EXISTING.md）:
#   数年分の履歴を持つリポジトリでは、**過去に一度でもコミットされた秘密**を初回実行で必ず検出する。
#   その多くは既に無効化・ローテーション済みだが、履歴からは消えないため、履歴を書き換えない限り
#   このゲートは恒久的に赤のままになる。結果として起きるのは是正ではなく「ゲートを外す」ことである。
#
#   gitleaks 自身の baseline 機構（--baseline-path）でこれを扱う。baseline に記録済みの検出結果は
#   報告されず、**新規に混入した秘密だけ**が失敗になる（ratchet）。
#     baseline の作成: gitleaks detect --source . --report-path .gitleaks-baseline.json
#     以後は本スクリプトが自動で --baseline-path として渡す（パスは GITLEAKS_BASELINE_PATH で変更可）。
#
#   **baseline は是正ではない。** 記録された資格情報は、それが有効である限り漏洩したままである。
#   本スクリプトは baseline 適用時に毎回、件数とともに警告を出し続ける（黙って緑にしない。
#   憲章「8. ブートストラップ規定」: 未整備の強制手段を整備済みであるかのように扱わない）。
#   採用組織は次の両方を行うこと:
#     1. baseline に含まれる資格情報をすべてローテーション（無効化）する
#     2. baseline の存在と根拠を governance/exceptions/ に登録する（Class A・承認と追跡が必須）
#   baseline ファイル自体は監査対象の記録であり、コミットして版管理する（.gitignore しない）。
set -eu
. scripts/lib/common.sh
say "Secret scan"
need gitleaks "https://github.com/gitleaks/gitleaks (or: task setup)" || exit 0

BASELINE="${GITLEAKS_BASELINE_PATH:-.gitleaks-baseline.json}"

if [ -f "$BASELINE" ]; then
  count="$(py -c '
import json, sys
try:
    d = json.load(open(sys.argv[1], encoding="utf-8"))
    print(len(d) if isinstance(d, list) else "?")
except Exception:
    print("?")
' "$BASELINE" 2>/dev/null || echo '?')"
  warn "gitleaks baseline を適用しています: $BASELINE（記録済み検出 ${count} 件は報告されません）"
  warn "  → baseline は是正ではありません。記録済みの資格情報をすべてローテーションし、"
  warn "     baseline の存在と根拠を governance/exceptions/ に登録してください（ADOPTION-EXISTING.md）。"
  gitleaks detect --source . --no-banner --redact --baseline-path "$BASELINE"
else
  gitleaks detect --source . --no-banner --redact
fi
ok "Secret scan"
