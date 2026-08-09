# Skill: EFDE Boot

Knowledge area for the EFDE bootstrap sequence: `console/init` and `console/init_essential`, and the three ordered boot phases.

## Metadatos

- **Nombre:** boot
- **Alcance:** `console/init`, `console/init_essential`, `bin/efde.sh` entrypoint ordering.
- **Activación:** When reading, modifying, or debugging the boot sequence; when working on `init_essential`, `common/core`, or the module loading order.

## Reglas Críticas

1. **`init_essential` is the source of truth for essentials bootstrap**: it holds the check / load / message logic for the common module (tasks + props + config.check). `console/init` sources it after `common/core`. Do NOT move this logic back into `console/common/core` — that file is now a stub.
2. **Three ordered phases**: phase 1 = essentials, phase 2 = rest of modules (efde + implementations + services), phase 3 = generate_extra_elements + updates_availables. Each phase MUST complete before the next starts.
3. **`console/init` MUST NOT call modules directly**: no `efde.tasks.*` or `common.tasks.*` calls inside `init` or `common/core`. Use Bash primitives or local helpers.
4. **No new scope `boot` in commits**: `agents/git/SKILL.md` keeps `core` as the canonical scope for init/bootstrap changes. A "boot" skill here is a knowledge area, NOT a commit scope.

## Boot Phases

### Phase 1 — Essentials

`init.load_essential()` in `console/init` (lines ~24–43):

1. Remove `bin/.tmp` if `EFDE_INIT['DEBUG']="true"` (regeneration mode).
2. Ensure `bin/.tmp` exists.
3. Copy `console/common/core` → `bin/.tmp/common.core` with `_mod_` replaced by `common.core` (only if the target does not exist yet).
4. `source` the generated `bin/.tmp/common.core` via `init.load_scripts`.
5. **`source "${EFDE_INIT['CONSOLE']}/init_essential"`** — this is the only place init_essential enters the call stack.
6. Load the rest of `console/common` (tasks + props) via `init.load_scripts "${EFDE_INIT['CONSOLE']}/$MODULE_NAME"`.

`init_essential.essential_to_run_check()` decides whether to load the common module elements (tasks + props) — used as the lazy gate so the essentials bootstrap is idempotent across shells.

### Phase 2 — Modules

`init.load_modules` walks `console/` recursively. For each subdirectory that contains a `tasks/` folder, it sources it via `init.load_scripts` → `common.core.load_module`. `common` is skipped at the top level (already loaded in phase 1). Implementations (`console/implementation/{laravel,symfony,wordpress}`) and services (`console/service/{docker,mysql}`) are loaded here.

### Phase 3 — Generate + Updates

After modules are loaded:

1. `common.core.generate_extra_elements` — builds `bin/.tmp/common.props.shortcuts` from every `console/*/props/shortcuts` to speed up subsequent runs.
2. `common.tasks.config.updates_availables` — checks the remote for a newer tag/version.

## Where `bin/efde.sh` Fits

`bin/efde.sh` (the launcher) loads `bin/cfg.core` and `bin/cfg.host` BEFORE sourcing `console/init`, because `init` / `init_essential` read paths and DEBUG flags from those configs. Reversing that order breaks the essentials bootstrap.

## References

- **Core**: [../core/SKILL.md](../core/SKILL.md) — `_mod_` convention and project structure.
- **Portability**: [../portability/SKILL.md](../portability/SKILL.md) — install-root resolution, `command -v`, etc.
- **QA**: [../qa/SKILL.md](../qa/SKILL.md) — boot validation performed by `bin/check.sh`.