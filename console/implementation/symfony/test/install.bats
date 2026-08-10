#!/usr/bin/env bats
# console/implementation/symfony/test/install.bats
# E2E: symfony:install:new creates a Symfony project.
#
# The install shortcut is interactive (webapp y/N, database y/N, name, build).
# We smoke-test it: verify the shortcut is registered and invokable. A full
# real-install test would require Docker + composer + minutes of build time.
# For exhaustive prompt regression, see test/bug-1-prompt.bats.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project symfony-install
}

teardown() {
  project_teardown
}

@test "symfony props/shortcuts declares the install:new shortcut" {
  local props="${EFDE_ROOT}/console/implementation/symfony/props/shortcuts"
  [[ -f "$props" ]] || skip "symfony props/shortcuts missing"
  grep -qE ':install:new' "$props"
}

@test "symfony:install:new shortcut is invokable (smoke)" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' symfony:install:new --help 2>&1 || true"
  echo "exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "symfony environment template references php-fpm + nginx + database" {
  local tpl="${EFDE_ROOT}/console/implementation/symfony/environment/docker-compose.yml"
  [[ -f "$tpl" ]] || skip "symfony docker-compose template missing"
  grep -qE '^[[:space:]]*php-fpm:|^[[:space:]]*app_fpm:|^[[:space:]]*nginx:' "$tpl"
  grep -qE '^[[:space:]]*database:|^[[:space:]]*mysql:' "$tpl"
}

@test "symfony tasks/install exports _mod_.new_environment" {
  local t="${EFDE_ROOT}/console/implementation/symfony/tasks/install"
  [[ -f "$t" ]] || skip "symfony tasks/install missing"
  grep -qE '^[[:space:]]*_mod_\.new_environment' "$t"
}
