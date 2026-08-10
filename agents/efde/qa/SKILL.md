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

## End-to-end tests (bats-core)

EFDE ships a [bats-core](https://github.com/bats-core/bats-core) test rig for runtime validation of the most-used shortcuts and the framework/service install flows. The linting harness above covers structural correctness; the E2E rig covers "does the shortcut actually run".

### Modular layout (two roots, auto-discovery)

Tests are split between two roots; `test/run_all.sh` discovers both via `find` so adding a new `.bats` requires zero wrapper edits.

```
test/                                              # generic / cross-cutting
├── run_all.sh                                     # find-based discovery
├── shortcuts.bats                                 # pilot: efde:qa, efde:version, efde:shortcuts
├── bug-1-prompt.bats                              # regression guard: universal stdin/tty detection
├── docker-root.bats                               # global docker:dc_status, compose config
├── mysql-root.bats                                # global mysql:env:show
├── test_helper/                                   # global helpers (imported by both roots)
│   ├── common.bash                                # setup_project, teardown, assert_file_*, wait_for_url
│   └── efde_pty.bash                              # PTY wrapper for interactive prompts
└── bats/                                          # git submodule (bats-core)

console/<scope>/test/                              # scope-specific
├── efde/test/lifecycle.bats                       # efde:version, efde:qa, efde:update
├── implementation/laravel/test/install.bats       # laravel:install:new + HTTP smoke
├── implementation/laravel/test/artisan.bats       # laravel:artisan, laravel:composer
├── implementation/laravel/test/permissions.bats    # laravel:permissions_fix
├── implementation/symfony/test/install.bats        # symfony:install:new + webapp/api + HTTP smoke
├── implementation/symfony/test/console.bats        # symfony:console, symfony:composer
├── implementation/symfony/test/permissions.bats     # symfony:permissions_fix
├── implementation/wordpress/test/install.bats      # wordpress:install:new + HTTP smoke
├── implementation/wordpress/test/wp-cli.bats       # wordpress:wp, wordpress:wpcli
├── implementation/wordpress/test/permissions.bats  # wordpress:permissions_fix
├── service/docker/test/build.bats                 # docker:build, dc_status
└── service/mysql/test/export-import.bats          # mysql:db:export, mysql:db:import
```

The relative `load` path differs by location: tests in `test/` use `load 'test_helper/common'`; tests in `console/<scope>/test/` use `load '../../../../test/test_helper/common'` (four `..` segments to climb back to the repo root).

### Running

```bash
# Initialise bats-core once per fresh clone
git submodule update --init --recursive

# Run everything (auto-discovers both roots)
./test/run_all.sh

# Run a single suite
./test/bats/bin/bats test/shortcuts.bats
./test/bats/bin/bats console/implementation/wordpress/test/install.bats
```

`run_all.sh` exits 0 if every suite passes or skips gracefully. Each suite prints `[PASS] <name>.bats (N/N)`, `[SKIP]` (all tests skipped), or `[FAIL]` (with the captured log dump).

### Conventions for new `.bats` files

1. **Location**: generic (Docker/MySQL cross-cutting, bug regression guards, EFDE shortcuts) → `test/<name>.bats`. Scope-specific (per implementation or service shortcut) → `console/<scope>/test/<name>.bats`.
2. **Helpers**: `load '<path-to>/test_helper/common'` for assertions and fixture helpers. `load 'test_helper/efde_pty'` ONLY if you genuinely need a PTY (the universal stdin/tty fix in `common.tasks.prompt` removes the need for it in most cases).
3. **EFDE_ROOT**: set in `setup()` via `EFDE_ROOT="${EFDE_ROOT:-$(cd "$(dirname "$BATS_TEST_FILENAME")/<up-traversal>" && pwd)}"`. The helpers expose `$EFDE_ROOT` for absolute paths.
4. **Fixture**: `${TEST_FIXTURE_ROOT:-/tmp/efde-test}/<domain>/` via `setup_project <domain>` in `setup()`. Clean up in `teardown()` via `project_teardown`.
5. **Skip gracefully**: `skip_if_no_docker` rather than failing when Docker is unavailable. For HTTP smoke, use `wait_for_url <url> [max_seconds]` to poll with `curl -sf --max-time 2`.
6. **NEVER fix bugs found in E2E** — record them in the apply summary and open a separate change. The E2E rig surfaces truth; it doesn't patch it.

### Bug #1 (universal stdin/tty detection) regression guard

`test/bug-1-prompt.bats` exercises `console/common/tasks/prompt` helpers (`_mod_.read_input`, `_mod_.confirm_default_yes/no`, `_mod_.request_input`) via a single stdin pipe with no PTY allocation. It verifies:

- Each helper reads from stdin when stdin is a pipe.
- Consecutive prompts in the same pipe consume lines correctly (no `\n`-leakage).
- TTY input still works when `[[ -t 0 ]]` is true (covered by manual interactive runs; the bats case is the non-TTY regression guard).

The code fix landed in commits `491a0be`, `b0e7975`, `2364292` (`fix(common): ...`). The bats is the lock-in.

### Known limitations

- `*:install:new` shortcuts run `docker compose build` which can take minutes. The tests skip with a clear message when the env file isn't produced within the run, rather than asserting on the long-running build step.
- The environment assumes Docker is available on the host. Production CI should also wire `docker info` as a precondition.
- `mysql:db:import` is interactive; the export-import suite only smoke-checks both shortcuts.

## References

- **Boot**: [../boot/SKILL.md](../boot/SKILL.md) — what `check.sh` validates under "Boot (init_essential)".
- **Core**: [../core/SKILL.md](../core/SKILL.md) — `_mod_` naming that the validator enforces.
- **Portability**: [../portability/SKILL.md](../portability/SKILL.md) — forbidden-pattern list and their portable alternatives.
- **Install**: [../install/SKILL.md](../install/SKILL.md) — `git submodule update --init` post-clone step.