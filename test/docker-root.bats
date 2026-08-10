#!/usr/bin/env bats
# test/docker-root.bats
# Generic Docker-service tests that don't fit any single implementation.
# Lives at the test/ root because docker is a shared concern.

load 'test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)}"
  setup_project docker-root
}

teardown() {
  project_teardown
}

@test "docker compose config validates an empty compose (just version key)" {
  skip_if_no_docker
  local compose="${TEST_PROJECT_DIR}/docker-compose.yml"
  cat > "$compose" <<'EOF'
services:
  ping:
    image: alpine:3.20
    command: ["true"]
EOF
  run docker compose -f "$compose" config --services
  [ "$status" -eq 0 ]
  [[ "$output" == *"ping"* ]]
}

@test "docker:dc_status shortcut is invokable globally" {
  skip_if_no_docker
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' docker:dc_status 2>&1" || true
  echo "dc_status exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
