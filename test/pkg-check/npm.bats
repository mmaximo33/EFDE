#!/usr/bin/env bats
# test/pkg-check/npm.bats
# npm check tests for the pkg_check dispatcher.
#
# Placeholder for future npm test coverage. Currently validates only
# the dispatcher behavior (no package manager / dispatcher prefers
# composer). Full npm install + npm ls is out of scope until EFDE
# gains a Node-based implementation (React, Angular, etc.).

load 'helpers'

setup() {
  TEST_TEMP_DIR="$(mktemp -d -t efde-pkg-check-npm-XXXXXX)"
  export TEST_TEMP_DIR
}

teardown() {
  rm -rf "$TEST_TEMP_DIR"
}

@test "pkg_check returns 2 when no package manager detected (npm only)" {
  # No manifest files yet
  run pkg_check "$TEST_TEMP_DIR"
  [ "$status" -eq 2 ]
}

@test "pkg_check dispatcher selects npm when package.json exists" {
  if ! command -v npm >/dev/null 2>&1; then
    skip "npm not installed"
  fi
  cat > "$TEST_TEMP_DIR/package.json" <<'EOF'
{
  "name": "efde-test-fixture",
  "version": "1.0.0",
  "description": "test fixture for npm dispatcher"
}
EOF
  run pkg_check "$TEST_TEMP_DIR"
  # npm ls on a fixture with no deps should exit 0
  [ "$status" -eq 0 ] || { echo "stderr: $output"; false; }
}

# Future tests to add when EFDE gains Node-based implementations:
# @test "npm check on a real React/Angular project" { ... }
# @test "package-lock.json is in sync" { ... }
# @test "outdated dependencies warn" { ... }
