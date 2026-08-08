#!/usr/bin/env bash
# Adoption wiring check (advisory): 採用配線の完遂を点検する。
# 統治文書は完成していても、CODEOWNERS の実体化・ブランチ保護・必須チェック登録は
# リポジトリ/組織側の設定であり、これらが未了だと強制が「休眠」する（強制台帳 #12/#13/#19）。
# 本チェックは助言（warn）であり、verify を失敗させない。CI/pull_request で実行する。
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

[ "$warns" -eq 0 ] && ok "adoption wiring" || ok "adoption wiring (warnings — 本番運用前に解消)"
