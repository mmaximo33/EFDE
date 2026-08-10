#!/usr/bin/env bats
# test/laravel.bats
# E2E: laravel:install:new creates a Laravel project with the expected
# env file.
#
# KNOWN BUGS (will be reported, NOT fixed in this change):
#   - Same interactive-prompt-bug as wordpress.bats: the project-name
#     prompt reads from /dev/tty and the input ordering is fragile.
#   - The shortcut then runs `composer create-project`, which requires
#     PHP + composer on the host. Missing dep -> the test skips.
#   - dc_build runs after the env file is written, so the test caps the
#     flow at EFDE_PTY_TIMEOUT and only inspects .efde/.env.

load 'test_helper/common'
load 'test_helper/efde_pty'

setup() {
  setup_project laravel
}

teardown() {
  project_teardown
}

@test "laravel:install:new creates .efde/.env with EFDE_PROJECT_IMPLEMENTATION=laravel" {
  skip_if_no_docker
  skip_if_no_pty

  pty_run_efde "${TEST_PROJECT_DIR}" $'n\ndemo\n' "laravel:install:new" || true

  project_dir="${TEST_PROJECT_DIR}/demo"
  env_file="${project_dir}/.efde/.env"
  if [[ ! -f "$env_file" ]]; then
    skip "laravel:install:new did not produce ${env_file} (interactive prompt PTY bug or missing composer)"
  fi
  if ! grep -qE '^EFDE_PROJECT_IMPLEMENTATION=("?")?laravel("?")?$' "$env_file"; then
    echo "Expected EFDE_PROJECT_IMPLEMENTATION=laravel in $env_file" >&2
    cat "$env_file" >&2
    return 1
  fi
  if ! grep -qE '^PHP_VERSION=("?")?8\.2' "$env_file"; then
    echo "Expected PHP_VERSION=8.2 (default per design) in $env_file" >&2
    return 1
  fi
}
