# Skill: EFDE Implementation — Laravel

Knowledge area for the Laravel implementation at `console/implementation/laravel/`: PHP defaults, menu structure, shortcuts.

## Metadatos

- **Nombre:** impl-laravel
- **Alcance:** `console/implementation/laravel/` (tasks + props + i18n), Laravel framework contract.
- **Activación:** When creating, modifying, or debugging the Laravel implementation; when working on PHP version compatibility.

## Reglas Críticas

1. **PHP 8.2 default**: Laravel 11.x and Laravel 12.x (the current supported lines) target PHP 8.2. The environment template and version selector MUST default to PHP 8.2 when generating `.env` / `docker-compose.yml`.
2. **Menu shape `5 + 2 + 5`**: `_mod_MAIN` has 5 entries (Project config, Artisan, Docker, Fix permissions, Database); `_mod_CREATE_ENVIRONMENT` has 2 entries (Create new, Clone existing); `_mod_CREATE_ENVIRONMENT_VERSION` has 5 entries (See versions compatibility + Laravel 9.x / 10.x / 11.x / 12.x).
3. **Console via `_mod_.console_run_command`**: the Artisan menu entry delegates to `laravel.tasks.main.console_run_command`. Do NOT rename or split.
4. **Permissions fix is shared**: `permissions_fix` runs the same per-implementation permission recipe as Symfony / WordPress; keep the public name stable.
5. **Project config from `efde.tasks.project.config_show`**: the menu delegates to `efde.tasks.project.config_show` (not a local implementation). Don't redefine locally.

## Menu (5 + 2 + 5 = 12 options)

`_mod_MAIN` (5):

1. Project config (`config_show`).
2. Artisan (`console`).
3. Docker (delegates to `docker.tasks.menu.main`).
4. Fix permissions (`permissions_fix`).
5. Database (delegates to `mysql.tasks.menu.main`).

`_mod_CREATE_ENVIRONMENT` (2):

1. Create new project (`install.new_environment`).
2. Clone existing project (`install.clone_environment`).

`_mod_CREATE_ENVIRONMENT_VERSION` (5):

1. See versions compatibility.
2. Laravel 9.x — works from PHP 8.0.
3. Laravel 10.x — works from PHP 8.1.
4. Laravel 11.x — works with PHP 8.2.
5. Laravel 12.x — works with PHP 8.2.

## Shortcuts (7)

Registered in `console/implementation/laravel/props/shortcuts`:

- `laravel:project:config`, `laravel:artisan`, `laravel:permissions:fix`, `laravel:install`, `laravel:install:new`, `laravel:install:clone`, `laravel:doc:compatibility`.

## Default Version Selection

When the user runs `laravel:install` (or `laravel:install:new`) without specifying a version, the implementation MUST default to **Laravel 11.x / PHP 8.2** (the project-wide default). Older lines (9.x, 10.x) remain selectable through the version sub-menu but are not the default.

## References

- **Core (naming, structure)**: [../../core/SKILL.md](../../core/SKILL.md).
- **Module (creating an implementation)**: [../../module/SKILL.md](../../module/SKILL.md).
- **Service Docker (project root, container ops)**: [../../service-docker/SKILL.md](../../service-docker/SKILL.md).
- **Service MySQL (database menu)**: [../../service-mysql/SKILL.md](../../service-mysql/SKILL.md).