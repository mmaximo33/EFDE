#!/usr/bin/env bats
# console/implementation/symfony/test/console.bats
# E2E: symfony:console runs bin/console commands inside the container.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project symfony-console
}

teardown() {
  project_teardown
}

@test "symfony:console shortcut is registered (smoke)" {
  skip_if_no_docker
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' symfony:console --help 2>&1" || true
  echo "console exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "symfony:composer shortcut is registered (smoke)" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' symfony:composer --help 2>&1" || true
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
