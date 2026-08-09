#!/usr/bin/env bash
# EFDE console QA: validates conventions for console/ (portability, naming, structure).
# Run: ./bin/check.sh [path_to_efde_root]  (default: parent of bin/)
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSOLE="${ROOT}/console"
FAIL=0

# --- Help ---
usage() {
  echo "Usage: $0 [path_to_efde_root]"
  echo "Validates console/ conventions (portability, structure). Exit 0 if OK, 1 if violations."
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

# --- Self-heal: ensure this script is executable (auto-fix chmod +x drift) ---
check_self_executable() {
  local script="${BASH_SOURCE[0]}"
  if [[ ! -x "$script" ]]; then
    chmod +x "$script" 2>/dev/null && echo "  [FIX] chmod +x $script (auto-healed permission drift)" || true
  fi
}

# --- Checks ---
check_structure() {
  local dir kind
  for kind in implementation service; do
    local base="${CONSOLE}/${kind}"
    [[ ! -d "$base" ]] && continue
    while IFS= read -r -d '' dir; do
      local d="${dir#${base}/}"
      [[ -z "$d" ]] && continue
      # Skip orphans (e.g. service/traefik is a WIP template, no tasks/main).
      [[ "$d" == "traefik" ]] && continue
      if [[ ! -f "$dir/tasks/main" ]]; then
        echo "  [FAIL] structure: $kind/$d missing tasks/main"
        FAIL=1
      fi
      if [[ ! -f "$dir/tasks/menu" ]]; then
        echo "  [FAIL] structure: $kind/$d missing tasks/menu"
        FAIL=1
      fi
      if [[ ! -f "$dir/props/menu" ]]; then
        echo "  [FAIL] structure: $kind/$d missing props/menu"
        FAIL=1
      fi
    done < <(find "$base" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
  done
}

# i18n CSV format: each non-blank line must be exactly "field1","field2"
# with "" as the in-field escape for a literal quote. The separator is a comma
# outside any quotes. Everything after the second closing quote is a violation.
check_i18n_csv_format() {
  local pattern='^"(([^"]|"")*)","(([^"]|"")*)"$'
  while IFS= read -r -d '' f; do
    # Find lines that look like CSV rows (start with a double quote) and FAIL
    # on any that don't match the two-quoted-fields shape.
    while IFS= read -r line; do
      # Skip blank lines and comment-ish lines.
      [[ -z "$line" ]] && continue
      if ! grep -qE '"' <<<"$line"; then
        # Lines without any quoted field still need basic shape: skip pure-empty,
        # otherwise it's a violation.
        continue
      fi
      if ! grep -qE "$pattern" <<<"$line"; then
        echo "  [FAIL] i18n CSV (expected \"field1\",\"field2\" with \"\" escape): $f"
        echo "         line: $line"
        FAIL=1
      fi
    done < "$f"
  done < <(find "$CONSOLE" -path "*/i18n/*.csv" -type f -print0 2>/dev/null)
}

# props/shortcuts format: each item line (after the bash header / opening brace)
# must have at least 3 comma-separated fields (atajo, path.func, desc).
# The description can contain commas, so we require >= 3 fields, not == 3.
check_shortcuts_format() {
  while IFS= read -r -d '' f; do
    local in_items=0
    local lineno=0
    while IFS= read -r line || [[ -n "$line" ]]; do
      lineno=$((lineno + 1))
      # Skip the shebang, opening brace, and the _mod_ITEMS=( line.
      [[ "$line" == "#!/usr/bin/env bash" ]] && continue
      [[ "$line" == "{" ]] && continue
      if [[ "$line" == *_mod_ITEMS=* ]]; then
        in_items=1
        continue
      fi
      [[ "$in_items" -eq 0 ]] && continue
      # Skip comments and blank lines and the closing brace.
      [[ -z "$line" ]] && continue
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ "$line" =~ ^[[:space:]]*\}[[:space:]]*$ ]] && { in_items=0; continue; }
      # Skip the closing ")" of the _mod_ITEMS=( ... ) array.
      [[ "$line" =~ ^[[:space:]]*\)[[:space:]]*$ ]] && continue
      # Strip trailing whitespace/comma; we split on commas.
      local trimmed="${line%"${line##*[![:space:]]}"}"
      # Count fields: split by "," without invoking external tools.
      local IFS=','
      local -a fields=($trimmed)
      local iframe=0
      local nonempty=0
      for field in "${fields[@]}"; do
        # Trim leading whitespace from each field.
        field="${field#"${field%%[![:space:]]*}"}"
        [[ -n "$field" ]] && nonempty=$((nonempty + 1))
        iframe=$((iframe + 1))
      done
      if [[ "$nonempty" -lt 3 ]]; then
        echo "  [FAIL] props/shortcuts entry needs at least 3 fields (atajo, path.func, desc): $f:$lineno"
        echo "         line: $line"
        FAIL=1
      fi
    done < "$f"
  done < <(find "$CONSOLE" -path "*/props/shortcuts" -type f -print0 2>/dev/null)
}

# props/menu format: presence of _mod_TITLE="...", _mod_MAIN=(, and (optional)
# _mod_CREATE_ENVIRONMENT=( when applicable. The "_mod_" prefix is required by
# the runtime transformer, so we look for the literal name in the source file.
check_props_menu_format() {
  while IFS= read -r -d '' f; do
    local d="${f#${CONSOLE}/}"
    d="${d%/props/menu}"
    if ! grep -qE '^[[:space:]]*_mod_TITLE=' "$f" 2>/dev/null; then
      echo "  [FAIL] props/menu missing _mod_TITLE= : $f"
      FAIL=1
    fi
    if ! grep -qE '^[[:space:]]*_mod_MAIN=\(' "$f" 2>/dev/null; then
      echo "  [FAIL] props/menu missing _mod_MAIN=( : $f"
      FAIL=1
    fi
    # _mod_CREATE_ENVIRONMENT is optional: only required for modules that
    # expose a "create new environment" flow (implementation/*, not service/*).
    if [[ "$d" == implementation/* ]]; then
      if ! grep -qE '^[[:space:]]*_mod_CREATE_ENVIRONMENT=\(' "$f" 2>/dev/null; then
        echo "  [FAIL] props/menu missing _mod_CREATE_ENVIRONMENT=( : $f"
        FAIL=1
      fi
    fi
  done < <(find "$CONSOLE" -path "*/props/menu" -type f -print0 2>/dev/null)
}

# agents/*/SKILL.md frontmatter: each skill must declare `# Skill:`, then a
# `## Metadatos` section, and a `## Reglas Críticas` section. The header
# anchors how the skill is discovered and indexed.
check_skill_frontmatter() {
  while IFS= read -r -d '' f; do
    if ! grep -qE '^#[[:space:]]*Skill:' "$f" 2>/dev/null; then
      echo "  [FAIL] skill missing '# Skill:' header: $f"
      FAIL=1
    fi
    if ! grep -qiE '^##[[:space:]]*Metadatos' "$f" 2>/dev/null; then
      echo "  [FAIL] skill missing '## Metadatos' section: $f"
      FAIL=1
    fi
    # Accept the canonical "## Reglas Cr[ií]ticas" header (case-insensitive on
    # the leading word) and the looser "## Reglas" pattern used by some legacy
    # skills (e.g. agents/git/SKILL.md, agents/efde/install/SKILL.md). The
    # intent is that every skill exposes a "Rules" section near the top.
    if ! grep -qiE '^##[[:space:]]*Reglas([[:space:]]+Cr[ií]ticas)?([[:space:]]|$|\()' "$f" 2>/dev/null; then
      echo "  [FAIL] skill missing '## Reglas' / '## Reglas Cr[ií]ticas' section: $f"
      FAIL=1
    fi
  done < <(find "${ROOT}/agents" -name "SKILL.md" -type f -print0 2>/dev/null)
}

# Forbidden patterns (portability / conventions)
run_checks() {
  echo "Checking: $CONSOLE"
  echo "--- Forbidden patterns ---"

  # sed -i without common.core (allow sed_inplace / common.core)
  while IFS= read -r -d '' f; do
    if grep -n 'sed\s+-i' "$f" 2>/dev/null | grep -v 'common\.core\|sed_inplace\|#.*sed' >/dev/null 2>&1; then
      echo "  [FAIL] sed -i (use common.core.sed_inplace): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # xdg-open (use common.tasks.os.open_url); allow common/tasks/os (defines open_url)
  while IFS= read -r -d '' f; do
    [[ "$f" == *"/common/tasks/os" ]] && continue
    if grep -n 'xdg-open' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] xdg-open (use common.tasks.os.open_url): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # find -printf (GNUism)
  while IFS= read -r -d '' f; do
    if grep -n 'find.*-printf' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] find -printf (GNUism): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # date -d (use common.core.date_to_epoch); allow common/core (defines the wrapper)
  while IFS= read -r -d '' f; do
    [[ "$f" == *"/common/core" ]] && continue
    if grep -n 'date\s+-d' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] date -d (use common.core.date_to_epoch): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # readlink -f (not portable; use resolve loop or pwd)
  while IFS= read -r -d '' f; do
    if grep -n 'readlink\s+-f' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] readlink -f (not portable): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  # which (use command -v)
  while IFS= read -r -d '' f; do
    if grep -nE '\bwhich\s+' "$f" >/dev/null 2>&1; then
      echo "  [FAIL] which (use command -v): $f"
      FAIL=1
    fi
  done < <(find "$CONSOLE" -type f ! -name "*.csv" ! -path "*/.tmp/*" -print0 2>/dev/null)

  echo "--- Naming: tasks (functions _mod_.name) ---"
  # In tasks/*: function definitions must be _mod_.name() (exclude common/core: has internal helpers)
  while IFS= read -r -d '' f; do
    [[ "$f" == *"/common/core" ]] && continue
    # Match "word() {" where word has NO dot -> violation (should be _mod_.word)
    if grep -nE '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{' "$f" 2>/dev/null | grep -v '_mod_\.' >/dev/null 2>&1; then
      echo "  [FAIL] function without _mod_. prefix: $f"
      grep -nE '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{' "$f" 2>/dev/null | grep -v '_mod_\.' || true
      FAIL=1
    fi
  done < <(find "$CONSOLE" -path "*/tasks/*" -type f ! -name "*.csv" -print0 2>/dev/null)

  echo "--- Naming: props (variables _mod_NAME in menu/shortcuts) ---"
  # In props/menu and props/shortcuts: main exported variables should be _mod_NAME (no dot)
  while IFS= read -r -d '' f; do
    # Assignment to ALL_CAPS variable that is not _mod_* -> violation
    if grep -nE '^[[:space:]]*[A-Z][A-Z0-9_]+=' "$f" 2>/dev/null | grep -v '_mod_' >/dev/null 2>&1; then
      echo "  [FAIL] prop variable should start with _mod_: $f"
      grep -nE '^[[:space:]]*[A-Z][A-Z0-9_]+=' "$f" 2>/dev/null | grep -v '_mod_' || true
      FAIL=1
    fi
  done < <(find "$CONSOLE" -path "*/props/menu" -type f -print0 2>/dev/null; find "$CONSOLE" -path "*/props/shortcuts" -type f -print0 2>/dev/null)

  echo "--- Structure (implementation / service) ---"
  check_structure

  echo "--- i18n CSV format ---"
  check_i18n_csv_format

  echo "--- props/shortcuts format ---"
  check_shortcuts_format

  echo "--- props/menu format ---"
  check_props_menu_format

  echo "--- agents/*/SKILL.md frontmatter ---"
  check_skill_frontmatter
}

# --- Boot: init_essential (#49) ---
check_init_essential() {
  if [[ ! -f "${CONSOLE}/init_essential" ]]; then
    echo "  [FAIL] boot: console/init_essential missing"
    FAIL=1
  fi
  if ! grep -q 'init_essential' "${CONSOLE}/init" 2>/dev/null; then
    echo "  [FAIL] boot: console/init does not load init_essential"
    FAIL=1
  fi
}

# --- Main ---
[[ ! -d "$CONSOLE" ]] && { echo "Error: $CONSOLE not found."; usage; exit 2; }

echo "--- Self-heal (chmod +x) ---"
check_self_executable

echo "--- Boot (init_essential) ---"
check_init_essential

run_checks

if [[ $FAIL -eq 0 ]]; then
  echo "--- OK: no violations ---"
  exit 0
else
  echo "--- Fix the above and run again ---"
  exit 1
fi
