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

# 3) ブランチ保護で 'verify' が必須チェックか（gh 利用可能時のみ・助言）
if have gh; then
  prot="$(gh api "repos/{owner}/{repo}/branches/main/protection" 2>/dev/null || true)"
  if [ -z "$prot" ]; then
    warn "main のブランチ保護が未設定の可能性（ADOPTION.md「3.」: 'verify' を必須ステータスチェックに登録）"
    warns=1
  elif ! printf '%s' "$prot" | grep -q '"verify"'; then
    warn "ブランチ保護に必須チェック 'verify' が見当たりません（ADOPTION.md「3.」）"
    warns=1
  fi
fi

[ "$warns" -eq 0 ] && ok "adoption wiring" || ok "adoption wiring (warnings — 本番運用前に解消)"
