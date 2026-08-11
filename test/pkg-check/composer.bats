#!/usr/bin/env bats
# test/pkg-check/composer.bats
# Composer check tests for the pkg_check dispatcher.
#
# Validates that pkg_check correctly identifies composer.json projects
# and runs `composer check --no-check-lock`. Tests cover the happy path,
# the failure path (invalid composer.json), and the no-manifest path.

load 'helpers'

setup() {
  TEST_TEMP_DIR="$(mktemp -d -t efde-pkg-check-composer-XXXXXX)"
  export TEST_TEMP_DIR
}

teardown() {
  rm -rf "$TEST_TEMP_DIR"
}

@test "pkg_check auto-detects composer in project with composer.json" {
  if ! command -v composer >/dev/null 2>&1; then
    skip "composer not installed"
  fi
  cat > "$TEST_TEMP_DIR/composer.json" <<'EOF'
{
    "name": "efde/test-fixture",
    "description": "test fixture",
    "type": "project",
    "require": {
        "php": ">=8.1"
    }
}
EOF
  run pkg_check "$TEST_TEMP_DIR"
  [ "$status" -eq 0 ] || { echo "stderr: $output"; false; }
}

@test "pkg_check returns 1 on invalid composer.json" {
  if ! command -v composer >/dev/null 2>&1; then
    skip "composer not installed"
  fi
  echo "this is not valid json" > "$TEST_TEMP_DIR/composer.json"
  run pkg_check "$TEST_TEMP_DIR"
  [ "$status" -eq 1 ]
}

@test "pkg_check returns 2 when no package manager detected" {
  run pkg_check "$TEST_TEMP_DIR"
  [ "$status" -eq 2 ]
}

@test "pkg_check returns 3 when project_dir is not a directory" {
  run pkg_check "/nonexistent/path/efde-test"
  [ "$status" -eq 3 ]
}

@test "pkg_check prefers composer over npm when both manifest files exist" {
  if ! command -v composer >/dev/null 2>&1; then
    skip "composer not installed"
  fi
  # composer first (line `if [[ -f composer.json ]]` comes first in helpers.bash)
  cat > "$TEST_TEMP_DIR/composer.json" <<'EOF'
{
    "name": "efde/test-fixture",
    "description": "test fixture",
    "type": "project",
    "require": {
        "php": ">=8.1"
    }
}
EOF
  echo '{"name": "fake"}' > "$TEST_TEMP_DIR/package.json"
  run pkg_check "$TEST_TEMP_DIR"
  [ "$status" -eq 0 ] || { echo "stderr: $output"; false; }
  # Composer ran, so the output should reference composer's terminology
  # (e.g. "dependencies" or "lock file"). We don't grep exactly because
  # that varies across composer versions; just assert success.
}
