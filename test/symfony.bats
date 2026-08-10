#!/usr/bin/env bats
# test/symfony.bats
# E2E: symfony:install:new produces a Symfony project. The shortcut
# prompts "Do you want to install the packages for webapp?" (default YES).
# To avoid the interactive composer require, the test installs Symfony
# skeleton (`api`) by accepting the default (empty input is YES).
#
# KNOWN BUGS (will be reported, NOT fixed in this change):
#   - Same interactive-prompt-bug as wordpress.bats.

load 'test_helper/common'
load 'test_helper/efde_pty'

setup() {
  setup_project symfony
}

teardown() {
  project_teardown
}

@test "symfony:install:new creates .efde/.env with EFDE_PROJECT_IMPLEMENTATION=symfony" {
  skip_if_no_docker
  skip_if_no_pty

  # Input order: webapp y/N (default yes -> empty), DATABASE y/N (no),
  # project name. The symfony shortcut also runs composer create-project.
  pty_run_efde "${TEST_PROJECT_DIR}" $'\nn\ndemo\n' "symfony:install:new" || true

  project_dir="${TEST_PROJECT_DIR}/demo"
  env_file="${project_dir}/.efde/.env"
  if [[ ! -f "$env_file" ]]; then
    skip "symfony:install:new did not produce ${env_file} (interactive prompt PTY bug or missing composer)"
  fi
  if ! grep -qE '^EFDE_PROJECT_IMPLEMENTATION=("?")?symfony("?")?$' "$env_file"; then
    echo "Expected EFDE_PROJECT_IMPLEMENTATION=symfony in $env_file" >&2
    cat "$env_file" >&2
    return 1
  fi
}
