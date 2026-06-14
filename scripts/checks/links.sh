#!/usr/bin/env bash
# Link check (lychee). Verifies internal links and external reference URLs.
set -eu
. scripts/lib/common.sh
say "Link check"
need lychee "https://github.com/lycheeverse/lychee (or: task setup)" || exit 0
lychee --no-progress --cache --max-retries 2 './**/*.md'
ok "Link check"
