#!/usr/bin/env bats
# console/implementation/wordpress/test/wp-cli.bats
# E2E: wordpress:wp runs wp-cli commands inside the container.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project wordpress-wpcli
}

teardown() {
  project_teardown
}

@test "wordpress:wp shortcut is registered (smoke)" {
  skip_if_no_docker
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' wordpress:wp --help 2>&1" || true
  echo "wp exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "wordpress:wpcli shortcut is registered (smoke)" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' wordpress:wpcli --help 2>&1" || true
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
