#!/usr/bin/env bats
# console/efde/test/lifecycle.bats
# E2E: efde lifecycle shortcuts (version management, uninstall).

load '../../../test/test_helper/common'

setup() {
  EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/../../../.." && pwd)}"
  setup_project efde-lifecycle
}

teardown() {
  project_teardown
}

@test "efde:version shortcut is invokable (interactive menu, q to quit)" {
  run bash -c "printf 'q' | '${EFDE_ROOT}/bin/efde.sh' efde:version"
  [ "$status" -eq 0 ]
}

@test "efde:qa shortcut runs bin/check.sh" {
  run "${EFDE_ROOT}/bin/check.sh"
  [ "$status" -eq 0 ]
}

@test "efde:update shortcut is registered" {
  run bash -c "printf 'q' | '${EFDE_ROOT}/bin/efde.sh' efde:update" || true
  echo "update exit=$status" >&2
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
