# Skill: EFDE Service — MySQL

Knowledge area for the MySQL service at `console/service/mysql/`: menu, shortcuts, and import/export flows.

## Metadatos

- **Nombre:** service-mysql
- **Alcance:** `console/service/mysql/` (tasks + props + i18n), MySQL service contract.
- **Activación:** When creating, modifying, or debugging the MySQL service; when working on database import/export.

## Reglas Críticas

1. **No duplicated `env_show`**: the service exposes one canonical `env_show` (`.env` file display); do not duplicate it. Other modules reference it via `mysql.tasks.menu.env_show`.
2. **Database path discipline**: export dumps land under `./dumps` of the project; imports are read from `./dumps` only — never from arbitrary user-supplied paths without confirmation.
3. **Privileges**: `permissions` applies the `DATABASE:USER` privileges configured in the project's `.efde/.env`. Never grant `ALL PRIVILEGES ON *.*` or anything outside the project's database scope.
4. **Run inside Docker**: most actions execute via `docker exec` against the project's MySQL container; respect Docker service-root detection (`dc_project_root`) before issuing container commands.
5. **macOS / non-systemd**: any helper that touches `systemctl` must guard with `command -v systemctl` first.

## Menu Options (7)

The MySQL service exposes 7 entries via `console/service/mysql/props/menu` (`_mod_MAIN`):

1. Show variables — display values in `./.env`.
2. Run custom query — run a user-supplied query against the database.
3. Export database — produce a SQL dump under `./dumps`.
4. Import database — restore a SQL dump from `./dumps`.
5. Apply privileges — apply `DATABASE:USER` privileges from `.env`.
6. Entry container — open a shell in the MySQL container.
7. Run command line — execute an arbitrary command in the MySQL container (delegates to `docker.tasks.menu.command`).

## Shortcuts (7)

Registered in `console/service/mysql/props/shortcuts` (`_mod_ITEMS`):

- `mysql:env:show`, `mysql:db:query`, `mysql:db:export`, `mysql:db:import`, `mysql:db:permissions`, `mysql:container`, `mysql:run:script`.

## Import / Export Flows

### Export

1. Resolve project root (via Docker service `dc_project_root`).
2. Ensure `./dumps` exists inside the project.
3. Invoke `mysqldump` (or the equivalent) inside the MySQL container; stream output to `./dumps/<database>-<timestamp>.sql`.
4. Print the resulting path to the user.

### Import

1. Resolve project root.
2. List available SQL files under `./dumps`.
3. After user confirmation, stream the selected file into the database via `mysql` (or equivalent) inside the container.
4. Print a summary of the restore (rows / tables touched when available).

## References

- **Service Docker (root detection, container exec)**: [../service-docker/SKILL.md](../service-docker/SKILL.md).
- **Core (naming, structure)**: [../core/SKILL.md](../core/SKILL.md).
- **Module (creating a service)**: [../module/SKILL.md](../module/SKILL.md).