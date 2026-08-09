# Skill: EFDE QA

Knowledge area for `bin/check.sh`, the read-only EFDE console validator (shortcut: `efde:qa`).

## Metadatos

- **Nombre:** qa
- **Alcance:** `bin/check.sh` (console-side); `bin/check-docs.sh` (docs-side, separate script).
- **Activación:** When running, modifying, or extending the static QA surface for `console/` (structure, portability, naming, boot).

## Reglas Críticas

1. **Read-only**: `bin/check.sh` MUST NOT modify anything under `console/`, `bin/`, or any target path. It only reads files and prints violations.
2. **Run from the repo root**: invocation is `./bin/check.sh [path_to_efde_root]`; default root is the parent of `bin/`. Exit codes: `0` = OK, `1` = violations, `2` = missing files / bad arg.
3. **Shortcut `efde:qa`**: exposes `bin/check.sh` through the EFDE shortcuts system (`efde:qa` is registered in `console/efde/props/shortcuts`). Running `efde efde:qa` is equivalent to `./bin/check.sh` from the EFDE project root.
4. **Docs vs. console**: `bin/check.sh` validates `console/` code conventions. `bin/check-docs.sh` (separate script) validates markdown vs. code truth (badges, locale typos, "Coming soon" claims, CHANGELOG coverage, scope whitelist). They are independent surfaces.
5. **Adding new checks**: extend `bin/check.sh` with a new `check_*()` function; the new check MUST be added to `run_checks` (or its own aggregator) to actually fire.

## What `bin/check.sh` Validates

| Layer | What it checks |
|-------|----------------|
| **Boot** | `console/init_essential` exists; `console/init` sources it (`grep -q init_essential`). |
| **Structure** | Every `console/{implementation,service}/*` has `tasks/main`, `tasks/menu`, `props/menu`. |
| **Forbidden patterns** | `sed -i` (without `common.core` / `sed_inplace`), `xdg-open`, `find -printf`, `date -d` (without `common.core`), `readlink -f`, `which` (use `command -v`). All under `console/`. |
| **Naming (functions)** | Inside `console/*/tasks/*`, function definitions MUST start with `_mod_.` (single-word `name() {` is a violation). `console/common/core` is excluded (internal helpers). |
| **Naming (variables)** | Inside `console/*/props/menu` and `console/*/props/shortcuts`, exported ALL_CAPS variables MUST start with `_mod_` (no dot, only the prefix). |

## What `bin/check.sh` Does NOT Validate

- Runtime correctness of the generated EFDE shell session.
- Behavior of installed implementations or services (only structural / convention checks).
- Docs (markdown truth, badges, CHANGELOG coverage). That's `bin/check-docs.sh`.
- Style preferences unrelated to portability (indentation, naming inside `i18n/*.csv`, etc.).

## Where it Runs

- During development: `./bin/check.sh` from the EFDE project root.
- Via shortcut: `efde efde:qa` from any project that has EFDE installed.
- CI: wire the same command into your pipeline before merging. The script is self-contained Bash and needs only standard POSIX tools.

## References

- **Boot**: [../boot/SKILL.md](../boot/SKILL.md) — what `check.sh` validates under "Boot (init_essential)".
- **Core**: [../core/SKILL.md](../core/SKILL.md) — `_mod_` naming that the validator enforces.
- **Portability**: [../portability/SKILL.md](../portability/SKILL.md) — forbidden-pattern list and their portable alternatives.