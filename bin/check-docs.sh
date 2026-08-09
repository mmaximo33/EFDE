#!/usr/bin/env bash
# bin/check-docs.sh — EFDE docs auditor (read-only)
# Validates: stale badges, no pt.PT, phantom frameworks, CHANGELOG coverage, scope whitelist.
# Exit: 0 OK, 1 violations, 2 missing files/bad arg.
# Run: ./bin/check-docs.sh [path_to_repo_root]
set -uo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
FAIL=0
VALID_SCOPES="core efde menu implementation service i18n docs install shortcuts docker"

# --- Help ---
usage() {
  cat <<USAGE
Usage: $0 [path_to_repo_root]
Validates docs vs code:
  - stale badges in README.md vs the latest git tag
  - locale typo pt.PT / pt_PT in docs and skills (should be pt.BR / pt_BR)
  - phantom frameworks under "### Coming soon" in README.md
  - CHANGELOG.md coverage for commits since the latest tag
  - scope whitelist for entries under "## [Unreleased]"
Exit 0 = OK, 1 = violations, 2 = missing files / bad arg.
USAGE
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

if [[ ! -d "$ROOT" ]]; then
  echo "Error: $ROOT is not a directory."
  usage
  exit 2
fi

fail() {
  echo "FAIL: $*"
  FAIL=1
}

# --- Check 1: stale badges ---
check_stale_badges() {
  local readme="$ROOT/README.md"
  [[ ! -f "$readme" ]] && { fail "README.md missing"; return; }
  local all_tags latest_tag
  all_tags=$(git -C "$ROOT" tag --list 2>/dev/null)
  latest_tag=$(git -C "$ROOT" describe --tags --abbrev=0 2>/dev/null || echo "")
  [[ -z "$latest_tag" ]] && return  # No tags → nothing to compare
  local line_num line version
  while IFS=: read -r line_num line; do
    [[ -z "$line" ]] && continue
    # Only consider lines that reference badges / commits-since (avoid false positives on dates, etc.)
    [[ "$line" != *badge* && "$line" != *commits-since* ]] && continue
    for version in $(echo "$line" | grep -oE '\b[0-9]+\.[0-9]+\.[0-9]+\b'); do
      # Only flag if the version does NOT exist as a git tag at all
      # (a "since release X.Y.Z" badge is valid as long as X.Y.Z was ever released).
      if ! echo "$all_tags" | grep -qx "$version"; then
        fail "$readme:$line_num stale version $version (not a known tag; latest is $latest_tag)"
      fi
    done
  done < <(grep -nE 'badge/|commits-since/' "$readme" 2>/dev/null)
}

# --- Check 2: pt.PT / pt_PT locale typo ---
check_no_pt_PT() {
  local f line_num
  while IFS= read -r f; do
    [[ ! -f "$f" ]] && continue
    # CHANGELOG.md historical entries are frozen data: only check the [Unreleased] section.
    if [[ "$(basename "$f")" == "CHANGELOG.md" ]]; then
      local unreleased
      unreleased=$(awk '/^## \[Unreleased\]/{flag=1; next} flag && /^## \[/{exit} flag' "$f")
      if [[ -n "$unreleased" ]]; then
        while IFS= read -r line; do
          [[ -z "$line" ]] && continue
          if echo "$line" | grep -qE 'pt[._]PT'; then
            fail "$f locale typo pt.PT/pt_PT in [Unreleased] (should be pt.BR/pt_BR): $line"
          fi
        done <<< "$unreleased"
      fi
      continue
    fi
    while IFS=: read -r line_num _; do
      fail "$f:$line_num locale typo pt.PT/pt_PT (should be pt.BR/pt_BR)"
    done < <(grep -nE 'pt[._]PT' "$f" 2>/dev/null)
  done < <(find "$ROOT" -maxdepth 4 -type f \( -name '*.md' -o -name '*.csv' \) ! -path '*/.git/*' 2>/dev/null)
}

# --- Check 3: phantom frameworks in "Coming soon" ---
check_phantom_frameworks() {
  local readme="$ROOT/README.md"
  [[ ! -f "$readme" ]] && return
  local section
  section=$(awk '/^### Coming soon/{flag=1; next} flag && /^## /{exit} flag' "$readme")
  [[ -z "$section" ]] && return
  # Pull badge labels: tokens right after "badge/" up to the next "-" + 6 hex chars.
  local candidates
  candidates=$(echo "$section" | grep -oE 'badge/[A-Za-z][A-Za-z0-9\.\+\.]+' \
    | sed -E 's|^badge/||; s|-[0-9a-fA-F]{6,}$||' \
    | sort -u)
  local name lower
  for name in $candidates; do
    case "$name" in
      # Generic languages / tools that are not framework implementations
      JavaScript|Python|PHP|HTML|CSS|SQL|Ruby|Go|Rust|Java) continue ;;
    esac
    lower=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's|[.]|-|g')
    if [[ -d "$ROOT/console/implementation/$lower" || -d "$ROOT/console/service/$lower" ]]; then
      continue
    fi
    # Listed in console/efde/props/menu (coming_soon or _mod_TOOLS entries) — case-insensitive
    if [[ -f "$ROOT/console/efde/props/menu" ]] && grep -qiF "$name" "$ROOT/console/efde/props/menu"; then
      continue
    fi
    fail "$readme phantom framework in Coming soon: $name"
  done
}

# --- Check 4: CHANGELOG coverage ---
check_changelog_coverage() {
  local changelog="$ROOT/CHANGELOG.md"
  [[ ! -f "$changelog" ]] && { fail "CHANGELOG.md missing"; return; }
  local prev_tag log_format commits subject type_scope
  prev_tag=$(git -C "$ROOT" describe --tags --abbrev=0 2>/dev/null || echo "")
  if [[ -n "$prev_tag" ]]; then
    commits=$(git -C "$ROOT" log --format='%s' "$prev_tag"..HEAD 2>/dev/null)
  else
    commits=$(git -C "$ROOT" log --format='%s' -30 2>/dev/null)
  fi
  while IFS= read -r subject; do
    [[ -z "$subject" ]] && continue
    # Extract type(scope) prefix (e.g. "fix(core)", "feat(docker)", "rename")
    type_scope=$(echo "$subject" | sed -nE 's/^([a-zA-Z]+)(\(([a-z_]+)\))?.*/\1\2/p')
    if [[ -z "$type_scope" ]]; then
      continue
    fi
    # If the commit has a parenthesized scope, the CHANGELOG MUST mention a matching section header.
    local scope
    scope=$(echo "$subject" | sed -nE 's/^[a-zA-Z]+ \(([a-z_]+)\).*/\1/p')
    if [[ -n "$scope" ]]; then
      # Look for any header containing the scope (case-insensitive) under [Unreleased]
      local unreleased_section
      unreleased_section=$(awk '/^## \[Unreleased\]/{flag=1; next} flag && /^## \[/{exit} flag' "$changelog")
      # efde scope → "EFDE" header; service → "Service"; core → "Core"; etc.
      local header
      header=$(echo "$unreleased_section" | grep -iE "^[[:space:]]*-\s+\*\*$scope([ /][^*]*)?\*\*:" | head -1)
      if [[ -z "$header" ]]; then
        fail "$changelog missing commit (no $scope section header in [Unreleased]): $subject"
      fi
    fi
  done <<< "$commits"
}

# --- Check 5: scope whitelist ---
check_scope_whitelist() {
  local changelog="$ROOT/CHANGELOG.md"
  [[ ! -f "$changelog" ]] && return
  local unreleased
  unreleased=$(awk '/^## \[Unreleased\]/{flag=1; next} flag && /^## \[/{exit} flag' "$changelog")
  local entry scope
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    # Match type(scope) - if no parenthesized scope, skip (e.g. bare "rename", "docs:").
    scope=$(echo "$entry" | sed -nE 's/^[a-zA-Z]+ \(([a-z_]+)\).*/\1/p')
    [[ -z "$scope" ]] && continue
    if ! echo " $VALID_SCOPES " | grep -q " $scope "; then
      fail "$changelog invalid scope: $scope (entry: $entry)"
    fi
  done < <(echo "$unreleased" | grep -E '\([a-z_]+\)' | sed -E 's/^[[:space:]]*//')
}

# --- Main ---
echo "--- Audit docs vs code ($ROOT) ---"
check_stale_badges
check_no_pt_PT
check_phantom_frameworks
check_changelog_coverage
check_scope_whitelist

if [[ $FAIL -eq 0 ]]; then
  echo "--- OK: no violations ---"
  exit 0
else
  echo "--- Fix the above and run again ---"
  exit 1
fi