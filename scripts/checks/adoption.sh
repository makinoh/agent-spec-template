#!/usr/bin/env bash
# Adoption wiring check (advisory): 採用配線の完遂を点検する。
# 統治文書は完成していても、CODEOWNERS の実体化・ブランチ保護・必須チェック登録は
# リポジトリ/組織側の設定であり、これらが未了だと強制が「休眠」する（強制台帳 #12/#13/#19）。
# 本チェックは助言（warn）であり、verify を失敗させない。CI/pull_request で実行する。
#
# 4) 以降は既存リポジトリへの導入（brownfield。ADOPTION-EXISTING.md）で頻出する配線漏れを扱う。
#    ADOPTION.md「ステップ9」（テンプレート自身の統治履歴の初期化）と「保護対象ブランチ名」は
#    従来まったく機械点検が無く、文書に書いてあるだけだった。監査証跡を主眼のひとつとする
#    テンプレートで、他組織の承認記録が自組織の記録に混入したまま残ることは避けたい。
#
#    注: 本テンプレート自身のリポジトリでは 4) は既定で検出される（サンプルと自身の統治履歴を
#    意図的に保持しているため）。これは `@org/*` / `@bot/*` プレースホルダの warn と同じ扱いで、
#    採用者向けの正しい通知として残す（強制台帳 #22 / GD-0001「5.」）。
set -eu
. scripts/lib/common.sh
say "Adoption wiring (CODEOWNERS / branch protection)"
warns=0

# 1) CODEOWNERS にプレースホルダ @org/* が残っていないか（残存＝統治文書が誰にも保護されない）
if [ -f .github/CODEOWNERS ] && grep -q '@org/' .github/CODEOWNERS; then
  warn "CODEOWNERS に未置換のプレースホルダ '@org/*' が残存（ADOPTION.md「2.」で実在チーム/個人へ置換）"
  warns=1
fi

# 2) エージェント名簿のマシンID プレースホルダ（@bot/*）が残っていないか
if [ -f agents/README.md ] && grep -q '@bot/' agents/README.md; then
  warn "agents/README.md にマシンID プレースホルダ '@bot/*' が残存（ADOPTION.md「4.」で専用アカウントへ置換）"
  warns=1
fi

# 3) ブランチ保護の点検（gh 利用可能時のみ・助言）
#
# 本チェックは「認証トークン」と「administration: read 権限」の双方を要する。どちらかが欠けると
# API は 401/403/404 を返すが、保護が本当に未設定でも 404 になるため、エラーを握り潰すと
# 「未設定」と「確認不能」を区別できない。旧実装は 2>/dev/null で理由を捨てていたため、
# CI（.github/workflows/verify.yml の permissions に administration が無く、verify:pr ステップに
# GITHUB_TOKEN も渡っていなかった）では保護が設定済みでも常に「未設定の可能性」を警告し続けていた。
# = 整備済みに見えて機能していないチェック（憲章「8. ブートストラップ規定」が禁じる状態）。
# そのため失敗理由を保持し、確認不能である旨を明示する。
if have gh; then
  if prot="$(gh api "repos/{owner}/{repo}/branches/main/protection" 2>&1)"; then
    printf '%s' "$prot" | grep -q '"contexts":\[[^]]*"verify"' || {
      warn "ブランチ保護に必須チェック 'verify' が見当たりません（ADOPTION.md「3.」）"; warns=1; }
    printf '%s' "$prot" | grep -q '"enforce_admins":{[^}]*"enabled":true' || {
      warn "ブランチ保護の include administrators（enforce_admins）が無効です（ADOPTION.md「3.」・強制台帳 #12）"; warns=1; }
  else
    detail="$(printf '%s' "$prot" | tr '\n' ' ' | cut -c1-160)"
    case "$prot" in
      *"Bad credentials"*|*"401"*)
        warn "main のブランチ保護を確認できません（認証されていません）: $detail" ;;
      *"Resource not accessible"*|*"admin rights"*|*"403"*)
        warn "main のブランチ保護を確認できません（トークンに管理者読み取り権限がありません）: $detail"
        warn "  → CI で実効化するには、管理者読み取り権限を持つ PAT をシークレット ADMIN_READ_TOKEN に設定する（GITHUB_TOKEN では読めない）" ;;
      *)
        warn "main のブランチ保護を確認できません（未設定、または権限不足。GitHub は両者を 404 で返すため区別できません）: $detail"
        warn "  → 未設定なら ADOPTION.md「3.」に従い設定する。設定済みなのに出る場合は ADMIN_READ_TOKEN を設定する" ;;
    esac
    warns=1
  fi
else
  warn "gh が見つからないためブランチ保護を確認できません（ローカルでは任意。CI では gh 同梱）"
  warns=1
fi

# 4) テンプレート由来の統治履歴・サンプル成果物の相続（ADOPTION.md「ステップ9」）
#    これらは本テンプレートの保守者による意思決定記録・記入例であり、採用組織の監査証跡ではない。
#    複製したまま残すと、他組織の承認記録が自組織の記録として監査に提示されてしまう。
inherited=""
for p in \
  "governance/decisions/gd-0001-adoption-profile-lite.md" \
  "governance/decisions/gd-0002-constitution-0-2-0-approval.md" \
  "governance/decisions/gd-0003-constitution-0-2-1.md" \
  "governance/decisions/gd-0004-framework-neutral-ui-governance.md" \
  "governance/risk-register/risk-0001-single-maintainer-separation-of-duties.md" \
  "specs/001-user-profile-export" \
  "specs/002-account-deletion"
do
  [ -e "$p" ] && inherited="$inherited $p"
done
# gp-*（テンプレート自身の改正提案）は件数のみ数える（個別列挙は冗長になるため）
gp_count="$(find governance/proposals -maxdepth 1 -name 'gp-0*.md' 2>/dev/null | wc -l | tr -d ' ')"
if [ -n "$inherited" ] || [ "${gp_count:-0}" -gt 0 ]; then
  warn "テンプレート由来の統治履歴・サンプルが残存（ADOPTION.md「ステップ9」で削除または「自組織の決定ではない」旨を明示）:"
  [ -n "$inherited" ] && warn "  ${inherited# }"
  [ "${gp_count:-0}" -gt 0 ] && warn "  governance/proposals/gp-*.md ${gp_count} 件"
  warn "  → 本テンプレート自身のリポジトリでは意図どおり検出されます（採用時のみ対応が必要）"
  warns=1
fi

# 5) 保護対象ブランチ名の不一致（既存リポジトリへの導入で最頻出の配線漏れ）
#    development-process.md「4.」は保護対象ブランチを main / release/* と定めており、
#    .github/workflows/*.yml のトリガと scripts の BASE_SHA 既定値（origin/main）もこれに揃えている。
#    既定ブランチが master / develop 等である既存リポジトリでは、CI が一度も起動しない・
#    差分の基点が解決できない、といった形で**沈黙して**強制が働かなくなる（fail-open）。
default_branch="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
if [ -n "$default_branch" ] && [ "$default_branch" != "main" ]; then
  warn "既定ブランチが 'main' ではありません（検出: '$default_branch'）。次を実リポジトリのブランチ名へ揃えてください:"
  warn "  .github/workflows/verify.yml / governance-gate.yml の on: branches、development-process.md「4.」、"
  warn "  scripts/checks/pr_governance.sh と scripts/check_diff_size.py の BASE_SHA 既定値（origin/main）"
  warn "  （ADOPTION-EXISTING.md「前提の読み替え」）"
  warns=1
fi

# 6) 未配線ゲートの活性化状況（ADOPTION.md「ステップ 8」の表と 1:1 で対応させる）
#
#    2026-08-24 の外部レビュー指摘: ADOPTION.md「ステップ 8」は配線が必要なゲートを表で列挙して
#    いるのに、本スクリプトはそのどれも点検していなかった（点検対象は CODEOWNERS・マシンID・
#    ブランチ保護・統治履歴・ブランチ名の 5 系統のみ）。「文書に書いたが点検していない」状態は、
#    採用者が配線を怠っても誰も気づかないことを意味する。表と点検項目を一致させる。
#
#    設計上の注意: 本スクリプトは助言（warn）であり verify を失敗させない（本ファイル冒頭）。
#    したがってここでの検出は「落とす機構」ではない。ゲート本体（sast.sh / arch-boundaries.sh /
#    build.sh / deps.sh）も未配線時は警告して exit 0 するため、配線漏れで CI が赤くなることは無い。
#    これは意図的な設計だが、その帰結は正直に述べる必要がある（憲章「8. ブートストラップ規定」）。
#
#    休眠中のゲートについては警告しない（コードの無い採用で無関係な警告を出さないため）。
#    ゲート本体と同一の検出条件を用いる。
code_stack=0
for m in package.json go.mod pom.xml build.gradle build.gradle.kts pyproject.toml requirements.txt setup.py; do
  [ -f "$m" ] && code_stack=1
done
dep_stack=0
for m in package.json go.mod pom.xml build.gradle build.gradle.kts pyproject.toml requirements.txt setup.py Gemfile Cargo.toml composer.json; do
  [ -f "$m" ] && dep_stack=1
done

unwired() { # $1=説明 $2=台帳番号 $3=配線方法
  warn "未配線: $1（強制台帳 $2）— $3"
  warns=1
}

if [ "$code_stack" -eq 1 ]; then
  [ -n "${SAST_CMD:-}" ] || [ -x "scripts/dev/sast-tool.sh" ] \
    || unwired "SAST（第一者コードの静的解析）" "#40" "ADR でツールを選定し \$SAST_CMD または scripts/dev/sast-tool.sh を配線する"
  [ -n "${ARCH_BOUNDARY_CMD:-}" ] || [ -x "scripts/dev/arch-boundary-tool.sh" ] \
    || unwired "アーキテクチャ境界（循環依存の検出）" "#52" "\$ARCH_BOUNDARY_CMD または scripts/dev/arch-boundary-tool.sh を配線する"
  [ -n "${LINT_CMD:-}" ] || [ -x "scripts/dev/lint-tool.sh" ] \
    || unwired "フォーマッタ／リンタ／型チェック" "#56" "\$LINT_CMD または scripts/dev/lint-tool.sh を配線する"
  [ "${COVERAGE_ENFORCED:-}" = "1" ] \
    || unwired "カバレッジ閾値" "#15b" "採用スタックで閾値を配線し COVERAGE_ENFORCED=1 を設定する"
fi

if [ "$dep_stack" -eq 1 ]; then
  [ -n "${LICENSE_SCAN_CMD:-}" ] || [ -x "scripts/dev/license-tool.sh" ] || [ -n "${LICENSE_FAIL_SEVERITY:-}" ] \
    || unwired "依存ライセンスの検査" "#55" "許可/禁止ライセンスを ADR で確定し \$LICENSE_SCAN_CMD / scripts/dev/license-tool.sh / \$LICENSE_FAIL_SEVERITY のいずれかを配線する"
fi

[ "$warns" -eq 0 ] && ok "adoption wiring" || ok "adoption wiring (warnings — 本番運用前に解消)"
