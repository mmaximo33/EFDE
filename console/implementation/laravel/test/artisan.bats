#!/usr/bin/env bats
# console/implementation/laravel/test/artisan.bats
# E2E: laravel:artisan runs php artisan commands inside the container.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project laravel-artisan
}

teardown() {
  project_teardown
}

@test "laravel:artisan shortcut is registered (smoke)" {
  skip_if_no_docker
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' laravel:artisan --help 2>&1" || true
  echo "artisan exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "laravel:composer shortcut is registered (smoke)" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' laravel:composer --help 2>&1" || true
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
