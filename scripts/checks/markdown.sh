#!/usr/bin/env bash
# Markdown lint (markdownlint-cli2 with the repo config).
set -eu
. scripts/lib/common.sh
say "Markdown lint"
if have markdownlint-cli2; then
  markdownlint-cli2 --config .markdownlint.jsonc "**/*.md"
elif have npx; then
  npx --yes markdownlint-cli2 --config .markdownlint.jsonc "**/*.md"
else
  need markdownlint-cli2 "npm i -g markdownlint-cli2 (or: task setup)" || exit 0
fi
ok "Markdown lint"
