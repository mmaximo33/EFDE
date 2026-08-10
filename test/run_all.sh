#!/usr/bin/env bash
# test/run_all.sh
# Runs every bats suite under both roots:
#   - test/*.bats                   (generic / cross-cutting)
#   - console/ -path '*/test/*.bats' (scope-specific: per implementation/service)
# Discovery is automatic via `find`. Add a new bats file under either root
# and it is picked up without editing this wrapper.
#
# Usage:
#   ./test/run_all.sh                      # run all discovered suites
#   ./test/run_all.sh test/shortcuts.bats  # run a single suite
#
# Conventions:
#   - bats-core MUST be installed under test/bats/. Initialise it once per
#     fresh clone with: git submodule update --init --recursive
#   - Suite output is captured so the wrapper only prints the summary line
#     and on failure the captured log for triage.
#   - Exit 0 only if every discovered suite passes (or skips gracefully).

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BATS_BIN="${ROOT}/test/bats/bin/bats"

if [[ ! -x "$BATS_BIN" ]]; then
  echo "Error: bats-core not installed at ${BATS_BIN}" >&2
  echo "Hint:   git submodule update --init --recursive" >&2
  exit 2
fi

# Pick the suites to run.
if [[ $# -gt 0 ]]; then
  suites=( "$@" )
else
  # Auto-discover: generic tests in test/ + scope-specific in console/<scope>/test/.
  # shellcheck disable=SC2207
  GENERIC=( "${ROOT}"/test/*.bats )
  # shellcheck disable=SC2207
  SPECIFIC=( $(find "${ROOT}/console" -path '*/test/*.bats' -type f 2>/dev/null) )
  suites=( "${GENERIC[@]:-}" "${SPECIFIC[@]:-}" )

  # Drop empty/glob-failure entries.
  filtered=()
  for s in "${suites[@]}"; do
    [[ -e "$s" && "$s" != *"*" ]] && filtered+=( "$s" )
  done
  suites=( "${filtered[@]}" )

  if [[ ${#suites[@]} -eq 0 ]]; then
    echo "Error: no *.bats files found under test/ or console/" >&2
    exit 2
  fi
fi

FAIL=0
SUITE_COUNT=0
PASS_COUNT=0
SKIP_COUNT=0

for suite in "${suites[@]}"; do
  [[ -e "$suite" ]] || continue
  SUITE_COUNT=$((SUITE_COUNT + 1))
  name="$(basename "$suite")"

  # Run the suite and capture the per-suite log.
  log="$(mktemp -t "bats-${name%.bats}.XXXXXX.log")"
  if "$BATS_BIN" "$suite" >"$log" 2>&1; then
    # bats output looks like: "1..3", then "ok N ..." or "not ok N ...".
    total="$(grep -oE '^1\.\.[0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || echo '?')"
    skipped="$(grep -cE '^ok [0-9]+ .*# skip' "$log" || true)"
    if [[ "$skipped" -gt 0 && "$skipped" == "$total" ]]; then
      echo "[SKIP] ${name} (${skipped}/${total} skipped)"
      SKIP_COUNT=$((SKIP_COUNT + 1))
    else
      echo "[PASS] ${name} (${total}/${total})"
      PASS_COUNT=$((PASS_COUNT + 1))
    fi
    rm -f "$log"
  else
    failed="$(grep -cE '^(not ok)' "$log" || true)"
    total="$(grep -oE '^1\.\.[0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || echo '?')"
    echo "[FAIL] ${name} (${failed}/${total})"
    echo "--- captured output ---"
    cat "$log"
    echo "------------------------"
    rm -f "$log"
    FAIL=1
  fi
done

echo "---"
echo "Summary: ${PASS_COUNT}/${SUITE_COUNT} passed, ${SKIP_COUNT} skipped (Docker-free)"

if [[ $FAIL -eq 0 ]]; then
  exit 0
else
  exit 1
fi
