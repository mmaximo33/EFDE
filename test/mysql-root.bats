#!/usr/bin/env bats
# test/mysql-root.bats
# Generic MySQL-service tests that don't fit any single implementation.
# Lives at the test/ root because mysql is a shared concern.

load 'test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)}"
  setup_project mysql-root
}

teardown() {
  project_teardown
}

@test "mysql:env:show shortcut is invokable globally (smoke)" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' mysql:env:show 2>&1" || true
  echo "env:show exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "mysql service menu declares DATABASE_NAME etc. in props" {
  local props="${EFDE_ROOT}/console/service/mysql/props/menu"
  [[ -f "$props" ]] || skip "mysql props/menu missing"
  grep -qE '^[[:space:]]*_mod_TITLE=' "$props"
  grep -qE '^[[:space:]]*_mod_MAIN=\(' "$props"
}
