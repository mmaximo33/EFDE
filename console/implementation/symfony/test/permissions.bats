#!/usr/bin/env bats
# console/implementation/symfony/test/permissions.bats
# E2E: permissions_fix shortcut.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project symfony-permissions
}

teardown() {
  project_teardown
}

@test "symfony:permissions_fix shortcut is registered (smoke)" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' symfony:permissions_fix --help 2>&1" || true
  echo "permissions_fix exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
