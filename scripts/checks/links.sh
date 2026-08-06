#!/usr/bin/env bash
# Link check (lychee). Verifies internal links and external reference URLs.
set -eu
. scripts/lib/common.sh
say "Link check"
need lychee "https://github.com/lycheeverse/lychee (or: task setup)" || exit 0

# レート制限（429）への対処。ゲートの緩和ではない（憲章「自己修正ループの防止」）。
#   - 原因側の低減: lychee の既定同時実行数は 128 で、これが相手側のレート制限を誘発する。
#     16 に下げ、そもそも 429 を踏みにくくする。
#   - 残余の 429 の扱い: 429 は「こちらが制限された」という応答であり、リンク切れを一切示さない。
#     受理してもリンク腐敗の検出力は変わらない（404 / 410 / 5xx / 名前解決失敗・相対リンク切れは従来どおり失敗する）。
#     --accept は既定値を置き換えるため、既定の 100..=103,200..=299 を明示して 429 を追加する。
# 恒久的にボット判定される URL（403 等）は .lycheeignore で個別に除外する（本フラグでは扱わない）。
lychee --no-progress --cache --max-retries 2 \
  --max-concurrency 16 \
  --accept '100..=103,200..=299,429' \
  './**/*.md'
ok "Link check"
