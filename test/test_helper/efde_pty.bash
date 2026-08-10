#!/usr/bin/env bash
# test/test_helper/efde_pty.bash
# Helper that runs `./bin/efde.sh <shortcut>` inside a `script`-allocated PTY
# so the interactive prompts (which read from /dev/tty) see canned input.
# Shared by every framework/service bats file.
#
# WHY: EFDE's prompt module reads from /dev/tty, not stdin. When run from
# bats (which captures stdin into `$output`), the prompt throws
# "/dev/tty: No such device or address" and the flow exits. `script -qefc`
# allocates a PTY and reconnects the inner command's stdin there, so the
# canned input reaches the prompt via /dev/tty inside the inner shell.
#
# IMPORTANT: we pass the inner command directly to `script`, NOT through
# `bash -c`. A `bash -c` wrapper detaches the inner command's stdin from
# the PTY (the inner command ends up reading from an empty stdin), which
# silently makes `read` calls return empty values and the prompt loop
# fails. The PTY is the script process's stdin, so the inner shell must
# inherit it directly.

EFDE_PTY_TIMEOUT="${EFDE_PTY_TIMEOUT:-30}"

# Skip if the host cannot allocate a PTY.
skip_if_no_pty() {
  if ! command -v script >/dev/null 2>&1; then
    skip "script(1) not available (cannot allocate PTY for interactive prompts)"
  fi
  if ! timeout 5 script -qefc "echo hello" /dev/null >/dev/null 2>&1; then
    skip "PTY allocation failed (interactive prompts cannot be automated)"
  fi
}

# Run EFDE inside a PTY with canned input.
#
# Args:
#   $1 = working directory
#   $2 = canned input (string; \n separates lines)
#   $3 = shortcut to invoke (e.g. "wordpress:install:new")
#   $4+ = extra args to efde.sh
# Output: combined stdout/stderr.
# Status: 0 if shortcut completed within timeout, 124 if killed.
pty_run_efde() {
  local workdir="$1"
  local input="$2"
  local shortcut="$3"
  shift 3
  # Feed canned input via a heredoc, which goes to `script`'s stdin (== PTY).
  # The inner command inherits that PTY as its stdin, so `read` calls
  # inside EFDE's prompt module see the canned input. The inner command
  # itself runs `cd` and then the shortcut directly (no `bash -c`).
  timeout "${EFDE_PTY_TIMEOUT}" script -qefc "cd '${workdir}' && '${EFDE_BIN}' ${shortcut} $*" /dev/null <<<"$input" 2>&1
}