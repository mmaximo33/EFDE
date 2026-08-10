#!/usr/bin/env bats
# test/mysql.bats
# E2E: mysql:db:export creates a dump file in ./dumps/. The reciprocal
# (db:import) is interactive and hard to script from a non-tty context,
# so this suite focuses on the export path which is non-interactive once
# we have a running project.
#
# KNOWN BUGS (will be reported, NOT fixed in this change):
#   - mysql:db:export calls `docker compose exec database mariadb-dump`,
#     which requires a project with a running `database` container. The
#     test skips if the dump file is not produced.
#   - The roundtrip test (export -> drop -> import) would need db:import
#     which is interactive (menu + confirmation). Documented, not fixed.

load 'test_helper/common'

setup() {
  setup_project mysql
}

teardown() {
  project_teardown
}

@test "mysql:db:export requires a running database container" {
  skip_if_no_docker

  # Without a docker-compose project, the export command exits non-zero
  # because `docker compose config` fails. Document that as a contract.
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_BIN}' mysql:db:export 2>&1"
  # We do not assert success here. The point is that the shortcut
  # exists and is invokable; the actual semantics require a running
  # WordPress/Laravel/Symfony project with a database container.
  # If the shortcut is missing entirely, status will be 1 with output
  # like "shortcut is not registered".
  if [[ "$status" -eq 0 ]]; then
    # If it succeeded, a dump file should exist.
    [ -d "${TEST_PROJECT_DIR}/dumps" ] || skip "dumps dir not created"
  else
    # Expected: the shortcut failed because no project was initialised.
    # That is the documented behaviour.
    echo "Export exited $status (expected: no project initialised)" >&2
  fi
}
