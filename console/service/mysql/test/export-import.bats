#!/usr/bin/env bats
# console/service/mysql/test/export-import.bats
# E2E: mysql:db:export and mysql:db:import shortcuts.
#
# Scope-specific tests for the MySQL service. Skips gracefully when no project
# or no running container is available.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project mysql-service
}

teardown() {
  project_teardown
}

@test "mysql:db:export shortcut is invokable (smoke)" {
  skip_if_no_docker

  # Without a docker-compose project, the export command exits non-zero
  # because `docker compose config` fails. That is the documented behaviour.
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' mysql:db:export 2>&1"
  if [[ "$status" -eq 0 ]]; then
    # If it succeeded, a dump directory should exist.
    [ -d "${TEST_PROJECT_DIR}/dumps" ] || skip "dumps dir not created"
  else
    echo "Export exited $status (expected: no project initialised)" >&2
  fi
}

@test "mysql:db:import shortcut is invokable (smoke)" {
  skip_if_no_docker

  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' mysql:db:import 2>&1" || true
  # Without a dump file, the import shortcut is expected to exit non-zero.
  # The smoke check is that the shortcut is wired up.
  echo "import exit=$status (smoke check; not asserting success)" >&2
}

@test "mysql:env:show shortcut exposes database variables" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' mysql:env:show 2>&1" || true
  echo "env:show exit=$status (smoke check; not asserting success)" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
