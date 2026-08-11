#!/usr/bin/env bash
# test/pkg-check/helpers.bash
# Extensible package manager check dispatcher.
#
# This helper detects which package manager a project uses by looking
# at its manifest files, then invokes the appropriate validation command.
# Designed to be extensible: add a new "elif" branch to support a new
# package manager, and a corresponding bats file in test/pkg-check/.
#
# Convention: every supported package manager has a `manifest` file
# (composer.json, package.json, Cargo.toml, pyproject.toml, pubspec.yaml)
# at the project root. We auto-detect by shallow file existence check.
#
# Exit codes:
#   0 = package manager found AND validation succeeded
#   1 = package manager found BUT validation failed
#   2 = no package manager detected (skip-like behavior)

# pkg_check <project_dir>
# Validates the package manager of <project_dir>. Auto-detects which
# package manager to use based on manifest files in the dir.
pkg_check() {
  local project_dir="${1:-.}"
  if [[ ! -d "$project_dir" ]]; then
    echo "pkg_check: not a directory: $project_dir" >&2
    return 3
  fi

  # Composer (PHP)
  if [[ -f "$project_dir/composer.json" ]]; then
    if ! command -v composer >/dev/null 2>&1; then
      echo "pkg_check: composer not installed" >&2
      return 4
    fi
    (cd "$project_dir" && composer check --no-check-lock --no-check-publish 2>/dev/null)
    return $?
  fi

  # npm (Node.js) — placeholder for future
  if [[ -f "$project_dir/package.json" ]]; then
    if ! command -v npm >/dev/null 2>&1; then
      echo "pkg_check: npm not installed" >&2
      return 4
    fi
    (cd "$project_dir" && npm ls --depth=0 2>/dev/null)
    return $?
  fi

  # Cargo (Rust) — placeholder for future
  if [[ -f "$project_dir/Cargo.toml" ]]; then
    if ! command -v cargo >/dev/null 2>&1; then
      echo "pkg_check: cargo not installed" >&2
      return 4
    fi
    (cd "$project_dir" && cargo check --quiet 2>/dev/null)
    return $?
  fi

  # pip (Python) — placeholder for future
  if [[ -f "$project_dir/pyproject.toml" || -f "$project_dir/requirements.txt" ]]; then
    if ! command -v pip >/dev/null 2>&1; then
      echo "pkg_check: pip not installed" >&2
      return 4
    fi
    (cd "$project_dir" && pip check 2>/dev/null)
    return $?
  fi

  # Flutter pub (Dart) — placeholder for future
  if [[ -f "$project_dir/pubspec.yaml" ]]; then
    if ! command -v flutter >/dev/null 2>&1; then
      echo "pkg_check: flutter not installed" >&2
      return 4
    fi
    (cd "$project_dir" && flutter pub deps --no-dev 2>/dev/null)
    return $?
  fi

  # No package manager detected
  echo "pkg_check: no package manager detected in $project_dir" >&2
  return 2
}

# pkg_check_skip_if_missing <project_dir>
# Convenience wrapper: returns 0 if pkg_check skipped (rc 2 or 4),
# otherwise returns pkg_check's rc. Bats tests should check the call
# site's own `skip` directive based on the return value (the global
# `skip` from bats is not callable from helper functions).
#
#   pkg_check_skip_if_missing "$dir"   # returns 2 or 4 if skipped
#   rc=$?
#   if [[ $rc -eq 2 || $rc -eq 4 ]]; then
#     skip "no package manager available"
#   fi
#   [[ $rc -eq 0 ]]
pkg_check_skip_if_missing() {
  local project_dir="${1:-.}"
  pkg_check "$project_dir"
}
