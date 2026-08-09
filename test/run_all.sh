#!/usr/bin/env bash
# test/run_all.sh
# Runs every test/*.bats suite with the bats-core submodule and reports a
# human-readable summary. Exit 0 only if every suite passes.
#
# Usage:
#   ./test/run_all.sh                      # run all suites
#   ./test/run_all.sh test/shortcuts.bats  # run a single suite
#
# Conventions:
#   - bats-core MUST be installed under test/bats/. Initialise it once per
#     fresh clone with:
#         git submodule update --init --recursive
#   - Per-suite output is captured so the wrapper only prints the summary line
#     and on failure the captured log for triage.

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
  # shellcheck disable=SC2207
  suites=( "$ROOT"/test/*.bats )
  if [[ ! -e "${suites[0]:-}" ]]; then
    echo "Error: no *.bats files found under ${ROOT}/test/" >&2
    exit 2
  fi
fi

FAIL=0
SUITE_COUNT=0
PASS_COUNT=0

for suite in "${suites[@]}"; do
  [[ -e "$suite" ]] || continue
  SUITE_COUNT=$((SUITE_COUNT + 1))
  name="$(basename "$suite")"

  # Run the suite and capture the per-suite log.
  log="$(mktemp -t "bats-${name%.bats}.XXXXXX.log")"
  if "$BATS_BIN" "$suite" >"$log" 2>&1; then
    # bats output looks like: "1..3", then "ok N ..." or "not ok N ...".
    # Total tests: highest number in the "1..N" line.
    total="$(grep -oE '^1\.\.[0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || echo '?')"
    echo "[PASS] ${name} (${total}/${total})"
    PASS_COUNT=$((PASS_COUNT + 1))
    rm -f "$log"
  else
    # Count ok / not ok lines.
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
echo "Summary: ${PASS_COUNT}/${SUITE_COUNT} suites passed"

if [[ $FAIL -eq 0 ]]; then
  exit 0
else
  exit 1
fi
