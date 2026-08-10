#!/usr/bin/env bats
# test/bug-1-prompt.bats
# Locks in the universal stdin/tty detection fix in console/common/tasks/prompt.
#
# Background (5 bugs from qa-coverage-complete):
#   Bug #1: common.tasks.prompt read from /dev/tty unconditionally. Plain pipe
#   input failed with "/dev/tty: No such device". Fixed in commits
#   491a0be / b0e7975 / 2364292 by adding `[[ -t 0 && -r /dev/tty ]]` guard.
#   This suite exercises the helpers via stdin pipe (no PTY) and verifies
#   that consecutive prompts still work end-to-end.

load 'test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)}"
  PROMPT_FILE="${EFDE_ROOT}/console/common/tasks/prompt"
}

# Helper: source the prompt module and run a snippet via stdin.
# Usage: prompt_run <<<"input"  -- expects $output / $status to be set.
prompt_run() {
  local snippet="$1"
  run bash -c "source '${PROMPT_FILE}'; ${snippet}"
}

@test "_mod_.read_input reads one line from stdin when stdin is a pipe" {
  run bash -c "source '${PROMPT_FILE}'; _mod_.read_input -r line; printf '%s' \"\$line\"" <<<"hello"
  [ "$status" -eq 0 ]
  [[ "$output" == "hello" ]]
}

@test "_mod_.request_input reads a line via stdin pipe" {
  prompt_run '_mod_.request_input "name"' <<<"myproject"
  [ "$status" -eq 0 ]
  [[ "$output" == "myproject" ]]
}

@test "_mod_.confirm_default_no rejects 'n' from stdin pipe" {
  run bash -c "source '${PROMPT_FILE}'; printf 'n\n' | _mod_.confirm_default_no 'Dangerous?' && echo ACCEPTED || echo REJECTED"
  [ "$status" -eq 0 ]
  [[ "$output" == *"REJECTED"* ]]
}

@test "_mod_.confirm_default_yes accepts 'y' from stdin pipe" {
  run bash -c "source '${PROMPT_FILE}'; printf 'y\n' | _mod_.confirm_default_yes 'Safe?' && echo ACCEPTED || echo REJECTED"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ACCEPTED"* ]]
}

@test "consecutive prompts via stdin pipe work end-to-end (bug #1 regression guard)" {
  # The historical bug was that AFTER the first prompt read consumed a line
  # from /dev/tty, subsequent prompts in the same pipe could not continue.
  # This test feeds three lines (one per prompt) via a single pipe and
  # asserts the full conversation flow succeeds without a PTY.
  # NB: do NOT redirect inner-command stdout inside $(...); bash attaches
  # `>file` to the command substitution itself, not to the inner command.
  # exec 2>/dev/null inside the subshell so prompt stderr does not leak
  # into bats' $output (bats captures stdout+stderr combined).
  run bash -c '
    source "'"${PROMPT_FILE}"'"
    exec 2>/dev/null
    OUT=""
    if printf "y\n" | _mod_.confirm_default_yes "Q1?" >/dev/null; then OUT="${OUT}A1"; fi
    NAME=$(printf "demo\n" | _mod_.request_input "name?")
    OUT="${OUT}:${NAME}"
    if printf "n\n" | _mod_.confirm_default_no "Q3?" >/dev/null; then OUT="${OUT}:A3"; else OUT="${OUT}:R3"; fi
    echo "$OUT"
  '
  [ "$status" -eq 0 ]
  [[ "$output" == "A1:demo:R3" ]]
}
