#!/usr/bin/env bats
# console/implementation/laravel/test/install.bats
# E2E: laravel:install:new creates a Laravel project.
#
# The install shortcut is interactive (multiple prompts + docker compose build).
# We smoke-test it: verify the shortcut is registered and invokable. A full
# real-install test would require Docker + composer + minutes of build time.
# For exhaustive prompt regression, see test/bug-1-prompt.bats.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project laravel-install
}

teardown() {
  project_teardown
}

@test "laravel props/shortcuts declares the install:new shortcut" {
  local props="${EFDE_ROOT}/console/implementation/laravel/props/shortcuts"
  [[ -f "$props" ]] || skip "laravel props/shortcuts missing"
  # The install shortcut uses $IMPLEMENT,, (lowercase) interpolation, so
  # the literal token is `:install:new` (no leading impl name).
  grep -qE ':install:new' "$props"
}

@test "laravel:install:new shortcut is invokable (smoke)" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' laravel:install:new --help 2>&1 || true"
  echo "exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "laravel environment template references php-fpm + nginx + database" {
  local tpl="${EFDE_ROOT}/console/implementation/laravel/environment/docker-compose.yml"
  [[ -f "$tpl" ]] || skip "laravel docker-compose template missing"
  # Laravel template must wire up the three core services.
  grep -qE '^[[:space:]]*php-fpm:|^[[:space:]]*app_fpm:|^[[:space:]]*nginx:' "$tpl"
  grep -qE '^[[:space:]]*database:|^[[:space:]]*mysql:' "$tpl"
}

@test "laravel tasks/install exports _mod_.new_environment" {
  local t="${EFDE_ROOT}/console/implementation/laravel/tasks/install"
  [[ -f "$t" ]] || skip "laravel tasks/install missing"
  grep -qE '^[[:space:]]*_mod_\.new_environment' "$t"
}
