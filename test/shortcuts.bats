#!/usr/bin/env bats
# test/shortcuts.bats
# Pilot suite: smoke-test the three most-used EFDE shortcuts.
# All three are non-interactive entry points in `console/efde/props/shortcuts`.
#
# Layout: each test runs in an isolated fixture under /tmp/efde-test/<domain>/.
# We exercise the shortcuts but do NOT create a real project on disk — the
# shortcuts are global (no --project-directory required for these three).

load 'test_helper/common'

setup() {
  setup_project shortcuts
}

teardown() {
  project_teardown
}

# KNOWN BUG (will be reported, NOT fixed in this change):
#   `efde:shortcuts` always calls `_mod_.show_custom`, which tries to load
#   `<project_root>/.efde/shortcuts/list`. If that file is missing, the
#   command exits 1 even though the global shortcuts were already printed.
#   To make the test pass without modifying the script, we seed an empty
#   list file in the fixture so the load succeeds.

create_project_shortcuts_stub() {
  mkdir -p "${TEST_PROJECT_DIR}/.efde/shortcuts/folder"
  # Note: must NOT wrap in `{ ... }` because the EFDE shortcuts loader
  # uses `source` on this file and the `{ ... }` block would create a
  # subshell, hiding the CUSTOM_SHORTCUTS array from the parent.
  # Also, an empty `CUSTOM_SHORTCUTS=()` does NOT mark the variable as
  # 'set' for the `[[ -z "${CUSTOM_SHORTCUTS+x}" ]]` test, so we declare
  # the array with a single placeholder entry that is then filtered out.
  cat > "${TEST_PROJECT_DIR}/.efde/shortcuts/list" <<'STUB'
#!/usr/bin/env bash
declare -ga CUSTOM_SHORTCUTS=("__placeholder__")
STUB
}

@test "efde:qa exits 0 (runs bin/check.sh)" {
  run "${EFDE_ROOT}/bin/check.sh"
  [ "$status" -eq 0 ]
}

@test "efde:version exits 0 (interactive menu, q to quit)" {
  # efde:version opens an interactive menu (manage_version). Piping
  # 'q' on stdin makes it exit cleanly, which is the same code path
  # the user exercises when they run the shortcut interactively.
  run bash -c "printf 'q' | '${EFDE_BIN}' efde:version"
  [ "$status" -eq 0 ]
}

@test "efde:shortcuts exits 0 and lists known atajos" {
  create_project_shortcuts_stub
  # KNOWN BUG: efde:shortcuts -> shortcuts_show -> common.tasks.shortcuts.show
  # then calls _mod_.main (the main menu). The test pipes 'q' to exit the
  # menu cleanly. This bug will be reported in the apply summary.
  run bash -c "cd '${TEST_PROJECT_DIR}' && printf 'q' | '${EFDE_BIN}' efde:shortcuts"
  [ "$status" -eq 0 ]
  # The shortcuts screen must mention at least these well-known entries.
  # bats-support is not vendored, so use plain grep on $output.
  grep -qF 'efde:qa'        <<<"$output" || { echo "missing efde:qa in output"; return 1; }
  grep -qF 'efde:version'   <<<"$output" || { echo "missing efde:version in output"; return 1; }
  grep -qF 'efde:shortcuts' <<<"$output" || { echo "missing efde:shortcuts in output"; return 1; }
}
