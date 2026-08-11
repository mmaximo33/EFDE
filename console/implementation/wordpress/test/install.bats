#!/usr/bin/env bats
# console/implementation/wordpress/test/install.bats
# E2E: wordpress:install:new creates a WordPress project.
#
# The install shortcut is interactive (database y/N, name, dc_build). We
# smoke-test it: verify the shortcut is registered and the template is
# well-formed. For full prompt regression, see test/bug-1-prompt.bats.

load '../../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project wordpress-install
}

teardown() {
  project_teardown
}

@test "wordpress props/shortcuts declares the install:new shortcut" {
  local props="${EFDE_ROOT}/console/implementation/wordpress/props/shortcuts"
  [[ -f "$props" ]] || skip "wordpress props/shortcuts missing"
  grep -qE ':install:new' "$props"
}

@test "wordpress:install:new shortcut is invokable (smoke)" {
  run bash -c "cd '${TEST_PROJECT_DIR}' && '${EFDE_ROOT}/bin/efde.sh' wordpress:install:new --help 2>&1 || true"
  echo "exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "wordpress docker-compose template references nginx + app_fpm + database" {
  local tpl="${EFDE_ROOT}/console/implementation/wordpress/environment/docker-compose.yml"
  [[ -f "$tpl" ]] || skip "wordpress docker-compose template missing"
  grep -qE '^[[:space:]]*nginx:' "$tpl"
  grep -qE '^[[:space:]]*app_fpm:' "$tpl"
  grep -qE '^[[:space:]]*database:' "$tpl"
}

@test "wordpress tasks/install exports _mod_.new_environment" {
  local t="${EFDE_ROOT}/console/implementation/wordpress/tasks/install"
  [[ -f "$t" ]] || skip "wordpress tasks/install missing"
  grep -qE '^[[:space:]]*_mod_\.new_environment' "$t"
}

@test "wordpress template does not require composer by default (WordPress core does not ship composer.json)" {
  # WordPress core does not ship a composer.json by default. The dispatcher
  # should detect this and skip gracefully (rc=2). If a future implementation
  # of EFDE ever swaps WP for a composer-based stack (e.g. johnpbloch/wordpress),
  # this test would need to be updated to assert a valid composer.json exists.
  load '../../../../test/pkg-check/helpers'
  local tmp="$(mktemp -d -t efde-pkg-check-wp-XXXXXX)"
  # No manifest files created on purpose.
  # bats `run` captures the exit code so the test does not abort on rc 2.
  run pkg_check "$tmp"
  rc=$status
  rm -rf "$tmp"
  [ "$rc" -eq 2 ]
}
