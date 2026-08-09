# Skill: EFDE Implementation — Symfony

Knowledge area for the Symfony implementation at `console/implementation/symfony/`: question types, menu structure, shortcuts.

## Metadatos

- **Nombre:** impl-symfony
- **Alcance:** `console/implementation/symfony/` (tasks + props + i18n), Symfony framework contract.
- **Activación:** When creating, modifying, or debugging the Symfony implementation; when working on `webapp` / `api` selection.

## Reglas Críticas

1. **`question_type` MUST be `webapp` or `api`**: when the user creates a new Symfony environment, the install flow MUST prompt for the project type and accept only `webapp` (full web stack with all bundles) or `api` (microservice / API). No other values are accepted.
2. **Menu shape `5 + 2 + 4`**: `_mod_MAIN` has 5 entries (Project config, Console, Docker, Fix permissions, Database); `_mod_CREATE_ENVIRONMENT` has 2 entries (Create new, Clone existing); `_mod_CREATE_ENVIRONMENT_VERSION` has 4 entries (See versions compatibility + Symfony 7.x / 6.x / 5.x).
3. **PHP version tied to Symfony line**: Symfony 7.x targets PHP 8.2; Symfony 6.x targets PHP 8.1; Symfony 5.x targets PHP 7.x. The version selector MUST reflect these compatibilities.
4. **Console via `_mod_.console_run_command`**: same delegation pattern as Laravel / WordPress.
5. **Docker service dependency**: the implementation menu delegates to `docker.tasks.menu.main` and `mysql.tasks.menu.main`. Do not redefine Docker / MySQL operations locally.

## Question Type: `webapp` vs `api`

- **`webapp`**: installs the full Symfony web stack (`symfony/skeleton` + webapp packs, Twig, forms, security, etc.). Recommended for traditional MVC apps.
- **`api`**: installs the API / microservice skeleton (no Twig, no web bundles). Recommended for headless services and JSON APIs.

The prompt comes from `console/implementation/symfony/i18n/<locale>.csv` keys `Default will install symfony for microservice projects or apis` and `Do you want to install the packages for webapp?`. The default answer corresponds to `api`.

## Menu (5 + 2 + 4 = 11 options)

`_mod_MAIN` (5):

1. Project config (`config_show`).
2. Console (`console`).
3. Docker (delegates to `docker.tasks.menu.main`).
4. Fix permissions (`permissions_fix`).
5. Database (delegates to `mysql.tasks.menu.main`).

`_mod_CREATE_ENVIRONMENT` (2):

1. Create new project (`install.new_environment`).
2. Clone existing project (`install.clone_environment`).

`_mod_CREATE_ENVIRONMENT_VERSION` (4):

1. See versions compatibility.
2. Symfony 7.x — works with PHP 8.2.
3. Symfony 6.x — works with PHP 8.1.
4. Symfony 5.x — works with PHP 7.x.

## Shortcuts (7)

Registered in `console/implementation/symfony/props/shortcuts`:

- `symfony:project:config`, `symfony:console`, `symfony:permissions:fix`, `symfony:install`, `symfony:install:new`, `symfony:install:clone`, `symfony:doc:compatibility`.

## References

- **Core (naming, structure)**: [../../core/SKILL.md](../../core/SKILL.md).
- **Module (creating an implementation)**: [../../module/SKILL.md](../../module/SKILL.md).
- **Service Docker (project root, container ops)**: [../../service-docker/SKILL.md](../../service-docker/SKILL.md).
- **Service MySQL (database menu)**: [../../service-mysql/SKILL.md](../../service-mysql/SKILL.md).