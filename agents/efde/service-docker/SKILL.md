# Skill: EFDE Service — Docker

Knowledge area for the Docker service at `console/service/docker/`: `dc_*` prefix, project-root detection, menu and shortcuts.

## Metadatos

- **Nombre:** service-docker
- **Alcance:** `console/service/docker/` (tasks + props + i18n), Docker service contract.
- **Activación:** When creating, modifying, or debugging the Docker service; when wiring `--project-directory` behavior; when adding `dc_*` functions.

## Reglas Críticas

1. **Function prefix `dc_`**: every public function in `console/service/docker/tasks/` MUST be prefixed with `dc_` (e.g. `dc_project_root`, `dc_build`, `dc_start`, `dc_stop`, `dc_down`, `dc_logs`). After `_mod_` substitution the full name becomes `docker.tasks.main.dc_<verb>`.
2. **Project-root detection**: `dc_project_root` walks up from the current working directory until it finds `docker-compose.yml` or `.efde`. If none is found, it MUST fail with a clear message — never assume the project root.
3. **Run from anywhere in the project tree**: the Docker menu and `dc_*` operations MUST work whether the user invokes `efde` from the project root or from any subdirectory. Use `docker compose --project-directory <root> -f <root>/docker-compose.yml ...` so the right compose file is selected regardless of CWD.
4. **macOS / non-systemd**: anything that touches `apache2` or `systemctl` MUST guard with `command -v systemctl` first; `apache_stop` is a no-op on macOS.
5. **`docker compose` (v2)**, not `docker-compose` (v1): all invocations use the v2 CLI. The legacy v1 binary is not supported.

## Menu Options (12)

The Docker service exposes 12 entries via `console/service/docker/props/menu` (`_mod_MAIN`):

1. Build — build or re-build the project containers.
2. Show — show process status of containers (`docker compose ps`).
3. Start — start containers of the project.
4. Restart — restart containers of the project.
5. Stop — stop containers of the project.
6. Logs — inspect environment logs.
7. Entry — enter the indicated container.
8. Command — run command in container (`bash`, `cp`, `rm`, etc.).
9. All Stop — stop every Docker container on the host.
10. Apache Stop — `apache2` stop service (Linux only; guarded by `command -v systemctl`).
11. Down — destroy all project containers and networks.
12. See Recipe — print the project's `docker-compose.yml`.

## Shortcuts (12)

Registered in `console/service/docker/props/shortcuts` (`_mod_ITEMS`):

- `docker:build`, `docker:ps`, `docker:start`, `docker:restart`, `docker:stop`, `docker:logs`, `docker:entry`, `docker:commands`, `docker:allstop`, `docker:down`, `docker:recipe`.
- `apache:stop` — Linux-only `apache2` stop.

## Function Catalog (prefix `dc_`)

The `dc_*` family covers at least: `dc_project_root`, `dc_command_run`, `dc_build`, `dc_start`, `dc_stop`, `dc_restart`, `dc_all_stop`, `dc_down`, `dc_logs`, `dc_show_container`. Helper functions (e.g. `apache_stop`, `container_entry`, `container_run_command`, `recipe_see`) live alongside but do not require the `dc_` prefix.

## References

- **Core (naming, structure)**: [../core/SKILL.md](../core/SKILL.md).
- **Portability (`command -v systemctl`, `find`, etc.)**: [../portability/SKILL.md](../portability/SKILL.md).
- **Module (creating a service)**: [../module/SKILL.md](../module/SKILL.md).
- **Docker and project directory**: [../../docs/developer.md](../../docs/developer.md).