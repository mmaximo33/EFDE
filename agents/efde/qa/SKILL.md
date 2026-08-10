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

EFDE ships a [bats-core](https://github.com/bats-core/bats-core) test rig under `test/` for runtime validation of the most-used shortcuts and the framework/service install flows. The linting harness above covers structural correctness; the E2E rig covers "does the shortcut actually run".

### Layout

```
test/
├── run_all.sh                    # wrapper: runs every *.bats and prints [PASS]/[FAIL]
├── shortcuts.bats                # pilot: efde:qa, efde:version, efde:shortcuts
├── wordpress.bats                # E2E: wordpress:install:new
├── laravel.bats                  # E2E: laravel:install:new
├── symfony.bats                  # E2E: symfony:install:new
├── mysql.bats                    # E2E: mysql:db:export
├── docker.bats                   # E2E: docker compose config
├── test_helper/
│   ├── common.bash               # setup_project, teardown, assert_file_*
│   └── efde_pty.bash             # PTY wrapper for interactive prompts
└── bats/                          # git submodule (bats-core)
```

### Running

```bash
# Initialise bats-core once per fresh clone
git submodule update --init --recursive

# Run everything
./test/run_all.sh

# Run a single suite
./test/bats/bin/bats test/wordpress.bats
```

`run_all.sh` exits 0 only if every suite passes. Each suite prints `[PASS] <name>.bats (N/N)` or `[FAIL] <name>.bats (X/N)` plus a captured output dump on failure.

### Conventions for new `.bats` files

1. `load 'test_helper/common'` for assertions and fixture helpers.
2. `load 'test_helper/efde_pty'` if the shortcut is interactive (uses `script -qefc` to allocate a PTY so `common.tasks.prompt` reads from `/dev/tty`).
3. Set up a fixture under `${TEST_FIXTURE_ROOT:-/tmp/efde-test}/<domain>/` via `setup_project <domain>` in `setup()`. Clean it up in `teardown()` via `project_teardown`.
4. Skip with `skip_if_no_docker` or `skip_if_no_pty` rather than failing when the environment can't support the test.
5. NEVER fix bugs found in E2E — record them in the apply summary and open a separate change. The E2E rig surfaces truth; it doesn't patch it.

### Known limitations

- EFDE's `common.tasks.prompt` reads from `/dev/tty`, not stdin. Tests that drive interactive shortcuts rely on `script(1)` to allocate a PTY. Some terminal configurations still hang; the tests skip with a clear message when they do.
- `*:install:new` shortcuts run `docker compose build` which can take minutes. The tests cap the install at `EFDE_PTY_TIMEOUT` (default 120s) and only assert on the artefacts written before the build step (`.efde/.env`).
- The environment assumes Docker is available on the host. Production CI should also wire `docker info` as a precondition.

## References

- **Boot**: [../boot/SKILL.md](../boot/SKILL.md) — what `check.sh` validates under "Boot (init_essential)".
- **Core**: [../core/SKILL.md](../core/SKILL.md) — `_mod_` naming that the validator enforces.
- **Portability**: [../portability/SKILL.md](../portability/SKILL.md) — forbidden-pattern list and their portable alternatives.
- **Install**: [../install/SKILL.md](../install/SKILL.md) — `git submodule update --init` post-clone step.