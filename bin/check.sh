#!/usr/bin/env bash
# EFDE console QA: validates conventions for console/ (portability, naming, structure).
# Run: ./bin/check.sh [path_to_efde_root]  (default: parent of bin/)
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSOLE="${ROOT}/console"
FAIL=0

# --- Help ---
usage() {
  echo "Usage: $0 [path_to_efde_root]"
  echo "Validates console/ conventions (portability, structure). Exit 0 if OK, 1 if violations."
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

# --- Checks ---
check_structure() {
  local dir kind
  for kind in implementation service; do
    local base="${CONSOLE}/${kind}"
    [[ ! -d "$base" ]] && continue
    while IFS= read -r -d '' dir; do
      local d="${dir#${base}/}"
      [[ -z "$d" ]] && continue
      if [[ ! -f "$dir/tasks/main" ]]; then
        echo "  [FAIL] structure: $kind/$d missing tasks/main"
        FAIL=1
      fi
      if [[ ! -f "$dir/tasks/menu" ]]; then
        echo "  [FAIL] structure: $kind/$d missing tasks/menu"
        FAIL=1
      fi
      if [[ ! -f "$dir/props/menu" ]]; then
        echo "  [FAIL] structure: $kind/$d missing props/menu"
        FAIL=1
      fi
    done < <(find "$base" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
  done
}

# Forbidden patterns (portability / conventions)
run_checks() {
  echo "Checking: $CONSOLE"
  echo "--- Forbidden patterns ---"

  # sed -i without common.core (allow sed_inplace / common.core)
  while IFS= read -r -d '' f; do
    if grep -n 'sed\s+-i' "$f" 2>/dev/null | grep -v 'common\.core\|sed_inplace\|#.*sed' >/dev/null 2>&1; then
      echo "  [FAIL] sed -i (use common.core.sed_inplace): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # xdg-open (use common.tasks.os.open_url); allow common/tasks/os (defines open_url)
  while IFS= read -r -d '' f; do
    [[ "$f" == *"/common/tasks/os" ]] && continue
    if grep -n 'xdg-open' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] xdg-open (use common.tasks.os.open_url): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # find -printf (GNUism)
  while IFS= read -r -d '' f; do
    if grep -n 'find.*-printf' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] find -printf (GNUism): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # date -d (use common.core.date_to_epoch); allow common/core (defines the wrapper)
  while IFS= read -r -d '' f; do
    [[ "$f" == *"/common/core" ]] && continue
    if grep -n 'date\s+-d' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] date -d (use common.core.date_to_epoch): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # readlink -f (not portable; use resolve loop or pwd)
  while IFS= read -r -d '' f; do
    if grep -n 'readlink\s+-f' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] readlink -f (not portable): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # which (use command -v)
  while IFS= read -r -d '' f; do
    if grep -nE '\bwhich\s+' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] which (use command -v): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  echo "--- Naming: tasks (functions _mod_.name) ---"
  # In tasks/*: function definitions must be _mod_.name() (exclude common/core: has internal helpers)
  while IFS= read -r -d '' f; do
    [[ "$f" == *"/common/core" ]] && continue
    # Match "word() {" where word has NO dot -> violation (should be _mod_.word)
    if grep -nE '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{' "$f" 2>/dev/null | grep -v '_mod_\.' >/dev/null 2>&1; then
      echo "  [FAIL] function without _mod_. prefix: $f"
      grep -nE '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{' "$f" 2>/dev/null | grep -v '_mod_\.' || true
      FAIL=1
    fi
  done < <(find "$CONSOLE" -path "*/tasks/*" -type f ! -name "*.csv" -print0 2>/dev/null)

  echo "--- Naming: props (variables _mod_NAME in menu/shortcuts) ---"
  # In props/menu and props/shortcuts: main exported variables should be _mod_NAME (no dot)
  while IFS= read -r -d '' f; do
    # Assignment to ALL_CAPS variable that is not _mod_* -> violation
    if grep -nE '^[[:space:]]*[A-Z][A-Z0-9_]+=' "$f" 2>/dev/null | grep -v '_mod_' >/dev/null 2>&1; then
      echo "  [FAIL] prop variable should start with _mod_: $f"
      grep -nE '^[[:space:]]*[A-Z][A-Z0-9_]+=' "$f" 2>/dev/null | grep -v '_mod_' || true
      FAIL=1
    fi
  done < <(find "$CONSOLE" -path "*/props/menu" -type f -print0 2>/dev/null; find "$CONSOLE" -path "*/props/shortcuts" -type f -print0 2>/dev/null)

  echo "--- Structure (implementation / service) ---"
  check_structure
}

# --- Main ---
[[ ! -d "$CONSOLE" ]] && { echo "Error: $CONSOLE not found."; usage; exit 2; }

run_checks

if [[ $FAIL -eq 0 ]]; then
  echo "--- OK: no violations ---"
  exit 0
else
  echo "--- Fix the above and run again ---"
  exit 1
fi
