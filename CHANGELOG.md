# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.1/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Boot (#49)**: Validación en `bin/check.sh`: comprueba que `console/init_essential` existe y que `console/init` lo carga. Documentación en `docs/developer.md` (Boot sequence) de la Fase 1 — essentials e `init_essential`.
- **Docker**: Detección de raíz del proyecto (`docker-compose.yml` o `.efde`) hacia arriba desde el CWD; `docker compose` se ejecuta con `--project-directory` y `-f`; menú Docker y `recipe_see` usables desde la raíz o cualquier subdirectorio del proyecto; mensaje claro si no se detecta proyecto. Documentación en `docs/developer.md` (Docker and project directory) y en `agents/efde/module/SKILL.md`.
- **QA (efde:qa, 74ac39b)**: Nuevo script `bin/check.sh` (read-only; valida estructura / portabilidad / naming / boot en `console/`) y atajo `efde:qa` que lo invoca; el chequeo de boot verifica que `console/init_essential` exista y que `console/init` lo cargue.
- **Install (3bdda0f)**: `bin/install.sh` detecta el SO host y ramifica el flujo de instalación para Linux, macOS, WSL y Windows (Git Bash); el chequeo de requisitos se adapta por plataforma.
- **Menu (bd9e522)**: Mejoras de flujo y documentación en el menú principal de `console/efde/` (entry/exit/history); el path de retorno es ahora estable entre implementaciones.
- **Rename (82e31c4)**: Carpeta `console/implemention` renombrada a `console/implementation`; referencias en scripts y docs actualizadas al nuevo path.

### Changed

- **Boot (#49)**: Refactor essential common.elements: `console/init_essential` creado con la lógica de bootstrap (check, load, message); `console/common/core` pasa a ser stubs que delegan en `init_essential`; `console/init` usa fases explícitas (Fase 1: essentials) y renombra `check_construct` a `load_essential`.
- **i18n**: Idiomas unificados (es_ES, fr_FR, pt_BR, de_DE), archivos `.csv`, parseo CSV robusto y documentación en `docs/i18n.md`.
- **Docker**: Prefijo de funciones renombrado de `dp_` a `dc_` (docker compose): `dc_project_root`, `dc_command_run`, `dc_build`, `dc_start`, `dc_stop`, `dc_restart`, `dc_all_stop`, `dc_down`, `dc_logs`, `dc_show_container`.
- **Developer / i18n docs (599d99f)**: `docs/developer.md` y `docs/i18n.md` actualizados (pt_BR); sección `[Unreleased]` de `CHANGELOG.md` reestructurada siguiendo Keep-a-Changelog.
- **Debug workflow (d03c46c)**: `docs/debug-workflow.md` consolidado como doc de uso (config en `bin/cfg.core`, qué hace cada flag, imágenes de referencia); referencias consolidadas entre `docs/`, `AGENTS.md` y skills.

### Fixed

- **Core / common**: Portabilidad GNU/BSD y macOS (sed, date, find), mensajes de error con variables correctas, iteración segura de archivos, escape para sed en i18n.
- **EFDE**: Comparación de versiones con `sort -V` en lifecycle; comprobación de que ORIGIN existe en `copy_environment`; typos (WooCommerce, Set settings).
- **Implementation**: Consistencia Laravel/Symfony/WordPress (config_show, permissions_fix, console), URLs con `common.tasks.os.open_url`, comparación de versión PHP en WordPress con `sort -V`, typos.
- **Service**: Docker `apache_stop` solo cuando `systemctl` está disponible (evita fallo en macOS); MySQL: eliminado env_show duplicado, typo `--isfunction`, mensaje de importación, MSG_CUSTOM sin sed.
- **Update check**: Default de `UPDATE_CHECK_AVAILABLE` corregido a `false` en message; lifecycle: sin falsos positivos cuando el remoto no responde (NEW_TAG vacío), `ls-remote` con `2>/dev/null`, mensaje "Could not reach remote to check tags"; config: `set_core_update_last` solo después de ejecutar la comprobación.
- **Uninstall**: Uso de `command -v` en lugar de `type -P` (portable); solo se elimina el launcher si la ruta existe y no está vacía.

## [2.3.1] 2025-03-13

### Fixed

- EFDE
  - #53 Force symbolic link update after installation
  - #54 Fail update, uninstall, manager version
  - Update documentations

## [2.3.0] 2025-01-28

### Added

- EFDE:
  - #43 Add custom shortcuts / commands line
  - #48 Validate that the base configuration is complete
  - #51 Refactor EFDE update and management of CORE and HOST cfg

### Changed

- EFDE:
  - #17 Installation - Version management 
  - #42 Don't show menu after shortcuts
  - #46 Refactor EFDE_MODE_* validation
  - #50 Simplify config.env for commands and outputs

### Fixed

- EFDE:
  - #39 error project name folder creation
  - #41 Correct use of the docker-compose command in implementation
  - #44 Adjust indentation in the menu
  - #45 Fix menu return
  - #47 Improve translation debugging

## [2.2.0] 2024-05-12

### Added

- EFDE: #32 Translation system (en_US es_ES pt_PT)
- Laravel: #5 Add new implementation
- Wordpress: #31 Add new implementation
- Symfony: #35 Add new version of Symfony 7.x

### Fixed

- EFDE
  - #37 ASAP! EFDE does not run after installation from v2.1.0
  - #36 Function info menu not aligned (Debug Mode)
- Symfony: #33 fix application directory permissions application
- MySQL: #3 General fixes for database import and export
 
## [2.1.0] 2024-03-04

### Added

- MySQL: #3 Add service for MySQL management
- EFDE: #28 Add SHORTCUTS

### Changed

- EFDE: #15
  - Refactoring module loading (Remove ../init)
  - Cleaning the bin/efde
  - Add configuration for default editor
  - Improve mode management (debug and develop)

## [2.0.0] 2024-01-15

### Changed

- EFDE: #15 Migrate from PYTHON to full BASH
  - Refactoring console/{implementation or service}
  - Improve bin/install.sh
  - Fixed main script bin/efde.sh
  - Core refactoring
  - Auto loading module
  - Module structure (common efde docker symfony)
  - Feature management by category or element
  - module.props.element.variable
  - module.tasks.element.method
  - Added debug methods
  - Fixed documentation

## [1.2.0] 2022-01-30

### Added

- EFDE: #14 Installation - Option by script due to lack of git and refactoring of the install.sh scripts
- EFDE: #16 Installation - Migrate docker-compose (v1) to docker compose (v2)
- EFDE: #18 Installation - Validate requirements for docker and docker compose
- Symfony: #6 Being able to indicate the version to use 5.x or 6.x
- Symfony: #13 Install - Establish type of application, microservice or webapp

### Changed

- EFDE: #10 Disable automatic EFDE update - Available by parameter --update
- EFDE: #1 - Partial - Create a file to save configurations

### Fixed

- EFDE: #11 Installation on clean ubuntu - $HOME/bin
- EFDE: #12 Installation - Missing python dependencies

## [1.1.1] 2022-12-28

### Fixed

- Symfony: Fix createapp script sequence
- Symfony: #7 Fix permission to folder ./app
- Symfony: #8 Remove environment variable from docker-compose.yml
- Symfony: #9 PMA login as root user

## [1.1.0] 2022-12-26

### Added

- #2 Symfony - Add ability to clone existing project

### Changed

- Installation process refactor

### Fixed

- Fixed bin/composer actions management
- General fixes in bin/{start environment}

### Removed

- Remove bin/requiriments, not used

## [1.0.0] 2022-12-21

### Added

- Added environment for symfony and automations
- Preparation of basic documentation (README, LICENSE, CHANGELOG, others)
- Automation of the installation and uninstallation process
- Creation of basic structure
- Start of the project

### Fixed

- General fixes
