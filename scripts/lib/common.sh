# Shared helpers for quality-gate check scripts (POSIX sh). Source from repo root.
# shellcheck shell=sh
RED='\033[31m'; GRN='\033[32m'; YEL='\033[33m'; CYN='\033[36m'; RST='\033[0m'
say()  { printf '%b▶ %s%b\n' "$CYN" "$1" "$RST"; }
ok()   { printf '%b✓ %s%b\n' "$GRN" "$1" "$RST"; }
warn() { printf '%b⚠ %s%b\n' "$YEL" "$1" "$RST" >&2; }
err()  { printf '%b✗ %s%b\n' "$RED" "$1" "$RST" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

# need <tool> <install-hint>: in CI a missing tool is fatal; locally it warns and the
# caller skips (returns 1). This keeps "task verify" identical everywhere while letting
# CI guarantee full coverage (CI installs all tools).
need() {
  if have "$1"; then return 0; fi
  if [ "${CI:-}" = "true" ]; then err "$1 is required in CI but was not found"; exit 1; fi
  warn "$1 not found — skipped locally (CI runs it). Install: $2  (or: task setup)"
  return 1
}

# py: run the available Python (python3 preferred, then python).
py() {
  if have python3; then python3 "$@";
  elif have python; then python "$@";
  else err "python not found"; return 1; fi
}
