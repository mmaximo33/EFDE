# Skill: EFDE Implementation — WordPress

Knowledge area for the WordPress implementation at `console/implementation/wordpress/`: official Docker image, menu structure, shortcuts.

## Metadatos

- **Nombre:** impl-wordpress
- **Alcance:** `console/implementation/wordpress/` (tasks + props + i18n), WordPress / WooCommerce contract.
- **Activación:** When creating, modifying, or debugging the WordPress implementation; when wiring the official `wordpress` image; when adding WooCommerce support.

## Reglas Críticas

1. **Official image, no custom build**: the WordPress container MUST use `image: wordpress:${DOCKER_APP_FPM_VERSION}` directly. Do NOT add a `build:` section for WordPress — the project relies on the official upstream image parameterized by `DOCKER_APP_FPM_VERSION`. Local customization happens via volumes and `.env`, not via a custom Dockerfile.
2. **Menu shape `5 + 2 + 12`**: `_mod_MAIN` has 5 entries; `_mod_CREATE_ENVIRONMENT` has 2 entries; `_mod_CREATE_ENVIRONMENT_VERSION` has 12 entries (See versions compatibility + 11 PHP lines: 5.6 / 7.1 / 7.2 / 7.3 / 7.4 / 8.0 / 8.1 / 8.2 / 8.3 / 8.4 [coming soon] / 8.x [coming soon]).
3. **WooCommerce lives on top of WordPress**: the menu advertises "Install for Wordpress and WooCommerce"; WooCommerce is bundled at the project level, not as a separate framework.
4. **Console via `_mod_.console_run_command`** (WP-CLI): same delegation pattern as Laravel / Symfony.
5. **PHP version comparison uses `sort -V`**: when comparing installed vs. required PHP, use `sort -V` (portable). Do not rely on lexicographic `<` / `>`.

## Docker Image Contract

The generated `docker-compose.yml` for a WordPress project MUST contain at minimum:

```yaml
services:
  wordpress:
    image: wordpress:${DOCKER_APP_FPM_VERSION}
```

There is no `build:` key for the `wordpress` service. Customization is done via `volumes:` (themes, plugins, uploads) and the project's `.env`.

## Menu (5 + 2 + 12 = 19 options)

`_mod_MAIN` (5):

1. Project config (`config_show`).
2. WP-CLI (`console`).
3. Docker (delegates to `docker.tasks.menu.main`).
4. Fix permissions (`permissions_fix`).
5. Database (delegates to `mysql.tasks.menu.main`).

`_mod_CREATE_ENVIRONMENT` (2):

1. Create new project (`install.new_environment`).
2. Clone existing project (`install.clone_environment`).

`_mod_CREATE_ENVIRONMENT_VERSION` (12):

1. See versions compatibility.
2. PHP 5.6.
3. PHP 7.1.
4. PHP 7.2.
5. PHP 7.3.
6. PHP 7.4.
7. PHP 8.0.
8. PHP 8.1.
9. PHP 8.2.
10. PHP 8.3.
11. PHP 8.4 — Coming Soon.
12. PHP 8.x — Coming Soon.

## Shortcuts (7)

Registered in `console/implementation/wordpress/props/shortcuts`:

- `wordpress:project:config`, `wordpress:cli`, `wordpress:permissions:fix`, `wordpress:install`, `wordpress:install:new`, `wordpress:install:clone`, `wordpress:doc:compatibility`.

## References

- **Core (naming, structure)**: [../../core/SKILL.md](../../core/SKILL.md).
- **Module (creating an implementation)**: [../../module/SKILL.md](../../module/SKILL.md).
- **Service Docker (project root, container ops)**: [../../service-docker/SKILL.md](../../service-docker/SKILL.md).
- **Service MySQL (database menu)**: [../../service-mysql/SKILL.md](../../service-mysql/SKILL.md).