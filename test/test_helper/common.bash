#!/usr/bin/env bash
# test/test_helper/common.bash
# Shared helpers for every *.bats suite under test/.
#
# Usage in a .bats file:
#   load '../test_helper/common'
#
# Provides:
#   setup_project <domain>      # sets $TEST_DOMAIN, $TEST_PROJECT_DIR; creates fixture dir
#   project_setup               # alias for setup_project used inside setup()
#   project_teardown            # removes $TEST_PROJECT_DIR (best-effort)
#   assert_file_exists <path>   # fails if the file does not exist
#   assert_file_contains <file> <text>   # fails if the file does not contain the text
#   assert_grep <file> <pattern>         # fails if the file does not match the extended regex
#   assert_success_msg <msg>    # fails with a custom message after a successful run
#   skip_if_no_docker           # bats skip if docker is not available
#   skip_if_no_bats_binary      # bats skip if the bats-core binary is missing
#
# Conventions:
#   - Fixtures live under /tmp/efde-test/<domain>/ (ephemeral).
#   - Each suite cleans up its own slice on teardown.
#   - Test names are SPEC-scoped (spec #63), not implementation-detail.

# Absolute path to the EFDE repo root (the directory holding `bin/`).
EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
EFDE_BIN="${EFDE_ROOT}/bin/efde.sh"
TEST_FIXTURE_ROOT="${TEST_FIXTURE_ROOT:-/tmp/efde-test}"

# Project directory under test (set by setup_project per suite).
TEST_DOMAIN=""
TEST_PROJECT_DIR=""

# Generic per-test teardown hook (override per suite if needed).
project_teardown() {
  if [[ -n "$TEST_PROJECT_DIR" && -d "$TEST_PROJECT_DIR" ]]; then
    rm -rf "$TEST_PROJECT_DIR" 2>/dev/null || true
  fi
}

# Prepare a fresh fixture directory for <domain>. Creates $TEST_PROJECT_DIR
# under /tmp/efde-test/<domain>/, ensures it is empty, and exports it.
setup_project() {
  local domain="${1:?setup_project requires <domain>}"
  TEST_DOMAIN="$domain"
  TEST_PROJECT_DIR="${TEST_FIXTURE_ROOT}/${domain}"
  mkdir -p "$TEST_PROJECT_DIR"
  # Clean any stale state from a previous run.
  rm -rf "${TEST_PROJECT_DIR:?}"/* 2>/dev/null || true
  export TEST_DOMAIN TEST_PROJECT_DIR
}

# Skip the test if docker is not available on the host.
skip_if_no_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    skip "docker not available on PATH"
  fi
  if ! docker compose version >/dev/null 2>&1; then
    skip "docker compose plugin not available"
  fi
}

# Poll <url> with curl -sf until it returns HTTP 2xx or <max_seconds> elapses.
# Returns 0 on success, 1 on timeout. Logs each attempt to stderr.
wait_for_url() {
  local url="${1:?wait_for_url requires <url>}"
  local max="${2:-30}"
  local i
  for i in $(seq 1 "$max"); do
    if curl -sf --max-time 2 "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "wait_for_url: timed out after ${max}s waiting for ${url}" >&2
  return 1
}

# Run <compose_args...> from <project_dir>; runs `docker compose down -v` on EXIT
# regardless of success/failure. Use as `compose_up <project_dir> up -d --wait`.
compose_up() {
  local project_dir="${1:?compose_up requires <project_dir>}"
  shift
  (
    cd "$project_dir" && docker compose "$@"
  )
}

# Force teardown of a docker-compose project (used in bats teardown hooks).
#
# Removes EVERYTHING that the compose file mentioned:
#   - Containers (default)
#   - Networks (default)
#   - Volumes (`-v`)
#   - Images that the compose build / pull referenced (`--rmi all`)
#   - Networks orphaned by the removal (`--remove-orphans`)
#
# Compose does NOT touch images/vols/networks that belong to other
# projects on the host. Use cleanup_all for an aggressive global purge.
compose_down() {
  local project_dir="${1:?compose_down requires <project_dir>}"
  if [[ -f "${project_dir}/docker-compose.yml" ]]; then
    (cd "$project_dir" && docker compose down --rmi all -v --remove-orphans 2>/dev/null) || true
  fi
}

# Aggressive global cleanup. Removes everything docker knows about that
# is not currently running: dangling images, unused networks, dangling
# build cache, stopped containers. Volumes are pruned only when -f is
# passed (default off to avoid wiping user data).
#
#   cleanup_all                # safe purge (no volumes)
#   cleanup_all --volumes      # also wipe anonymous volumes
#
# Use this in bats teardown when you want a deterministic host state
# after a test that may have left docker artifacts behind.
cleanup_all() {
  local purge_volumes="false"
  [[ "${1:-}" == "--volumes" ]] && purge_volumes="true"
  docker container prune -f >/dev/null 2>&1 || true
  docker image prune -f >/dev/null 2>&1 || true
  docker network prune -f >/dev/null 2>&1 || true
  docker builder prune -f >/dev/null 2>&1 || true
  if [[ "$purge_volumes" == "true" ]]; then
    docker volume prune -f >/dev/null 2>&1 || true
  fi
  echo "cleanup_all: pruned containers, images, networks, build cache${purge_volumes:+, volumes}"
}

# Skip the test if the bats-core binary is missing (submodule not initialised).
skip_if_no_bats_binary() {
  if [[ ! -x "${EFDE_ROOT}/test/bats/bin/bats" ]]; then
    skip "bats-core not installed (run: git submodule update --init --recursive)"
  fi
}

# Assertion: file at <path> exists.
assert_file_exists() {
  local path="${1:?assert_file_exists requires <path>}"
  if [[ ! -e "$path" ]]; then
    echo "Expected file to exist: $path" >&2
    return 1
  fi
}

# Assertion: file contains literal text (whitespace-sensitive).
assert_file_contains() {
  local file="${1:?assert_file_contains requires <file>}"
  local text="${2:?assert_file_contains requires <text>}"
  if ! grep -qF -- "$text" "$file" 2>/dev/null; then
    echo "Expected $file to contain: $text" >&2
    return 1
  fi
}

# Assertion: file matches extended regex.
assert_grep() {
  local file="${1:?assert_grep requires <file>}"
  local pattern="${2:?assert_grep requires <pattern>}"
  if ! grep -qE -- "$pattern" "$file" 2>/dev/null; then
    echo "Expected $file to match: $pattern" >&2
    return 1
  fi
}

# Assertion: emit a custom error message after a run that succeeded.
assert_success_msg() {
  local msg="${1:?assert_success_msg requires <msg>}"
  if [[ "$status" -eq 0 ]]; then
    return 0
  fi
  echo "Expected success but command failed: $msg" >&2
  echo "status=$status" >&2
  echo "output: $output" >&2
  return 1
}
