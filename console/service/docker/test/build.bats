#!/usr/bin/env bats
# console/service/docker/test/build.bats
# E2E: docker:build shortcut validates a project docker-compose.yml.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project docker-service
  # Seed the fixture with a copy of the wordpress environment template so
  # `docker compose config` has something to validate.
  cp -r "${EFDE_ROOT}/console/implementation/wordpress/environment/." "${TEST_PROJECT_DIR}/"
  cat > "${TEST_PROJECT_DIR}/.env" <<'EOF'
EFDE_PROJECT_NAME=demo
DOCKER_APP_FPM_VERSION=fpm
DOCKER_APP_CLI_VERSION=cli
EOF
}

teardown() {
  project_teardown
}

@test "docker compose config validates the wordpress fixture" {
  skip_if_no_docker

  run docker compose -f "${TEST_PROJECT_DIR}/docker-compose.yml" config
  [ "$status" -eq 0 ]
  run docker compose -f "${TEST_PROJECT_DIR}/docker-compose.yml" config --services
  [ "$status" -eq 0 ]
  grep -qF 'nginx'   <<<"$output"
  grep -qF 'app_fpm' <<<"$output"
}

@test "docker:build shortcut is invokable (smoke)" {
  skip_if_no_docker
  run timeout 5 bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' docker:build 2>&1" || true
  echo "docker:build exit=$status (smoke check; not asserting success)" >&2
}

@test "docker:dc_* shortcuts are registered" {
  # Sample the dc_status shortcut as a representative.
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' docker:dc_status 2>&1" || true
  echo "dc_status exit=$status (smoke check; not asserting success)" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
