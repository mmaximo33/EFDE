# EFDE | Agent Guidelines

Este archivo contiene las normas y guías para que los agentes de IA (como Cursor, Claude Code, etc.) trabajen de forma coherente en el proyecto **EFDE**.

## Cómo usar esta guía

- Lee este archivo para entender las normas generales del proyecto.
- Invoca las **Agent Skills** específicas para obtener patrones detallados de código.
- Respeta siempre las convenciones de Bash y la estructura de `console/`.
- **Actualizar skills:** Cuando detectes una convención, regla o patrón relevante que deba persistir para futuros agentes (por ejemplo al corregir un bug, refactorizar o documentar), añádelo a la skill correspondiente en `agents/` o crea una nueva skill si hace falta. No dejes conocimiento importante solo en el código o en la conversación.

## Reglas de Portabilidad y Estilo

Para asegurar que EFDE sea distribuible y funcional en **macOS**, **Linux** y **Windows (WSL/Git Bash)**, se DEBEN seguir las reglas de la skill **portability**: patrones prohibidos (`sed -i`, `date -d`, `find -printf`, `readlink -f`, `which`, `xdg-open`) y sus alternativas portables (`common.core.sed_inplace`, `common.core.date_to_epoch`, `command -v`, `common.tasks.os.open_url`, etc.). Rutas POSIX (barras `/`). Manejo de errores: funciones que buscan variables deben devolver `return 1` en error. **Documentación completa:** [agents/efde/portability/SKILL.md](agents/efde/portability/SKILL.md).

## Skills disponibles

Usa estas skills para obtener patrones detallados bajo demanda (ver [README](agents/README.md)):

### EFDE Skills
| Skill | Descripción | URL |
|-------|-------------|-----|
| `core` | Estructura del proyecto, ciclo de vida y convención `_mod_`. Dependencias opcionales (bats-core, Docker). | [SKILL.md](agents/efde/core/SKILL.md) |
| `portability` | Reglas de portabilidad y compatibilidad (sed, date, find, readlink, which, xdg-open, systemctl) | [SKILL.md](agents/efde/portability/SKILL.md) |
| `module` | Creación de nuevas implementaciones (Laravel, Symfony) o servicios | [SKILL.md](agents/efde/module/SKILL.md) |
| `i18n` | Sistema de traducciones y soporte multi-idioma | [SKILL.md](agents/efde/i18n/SKILL.md) |
| `shortcuts` | Gestión de atajos (shortcuts) globales y por proyecto | [SKILL.md](agents/efde/shortcuts/SKILL.md) |
| `install` | Script de instalación: rutas, compatibilidad Linux/macOS/WSL/Windows. Post-clone `git submodule update --init`. | [SKILL.md](agents/efde/install/SKILL.md) |
| `git` | Convención de commits usada en el proyecto | [SKILL.md](agents/git/SKILL.md) |
| `boot` | Secuencia de arranque: `init_essential` + 3 fases (essentials → modules → generate + updates) | [SKILL.md](agents/efde/boot/SKILL.md) |
| `impl-laravel` | Convención de la implementación Laravel (PHP 8.2 default, menú 5+2+5, 7 atajos) | [SKILL.md](agents/efde/impl-laravel/SKILL.md) |
| `impl-symfony` | Convención de la implementación Symfony (`webapp`/`api`, menú 5+2+4, 7 atajos) | [SKILL.md](agents/efde/impl-symfony/SKILL.md) |
| `impl-wordpress` | Convención de la implementación WordPress (`wordpress:${DOCKER_APP_FPM_VERSION}`, menú 5+2+12, 7 atajos) | [SKILL.md](agents/efde/impl-wordpress/SKILL.md) |
| `qa` | `bin/check.sh` (linter ampliado) + bats-core E2E (`test/run_all.sh`). Convenciones CSV, shortcuts, props, skills. | [SKILL.md](agents/efde/qa/SKILL.md) |
| `service-docker` | Servicio Docker (`dc_*`, root detection, 12 opciones, 12 atajos) | [SKILL.md](agents/efde/service-docker/SKILL.md) |
| `service-mysql` | Servicio MySQL (import/export, 7 opciones, 7 atajos) | [SKILL.md](agents/efde/service-mysql/SKILL.md) |
| `release` | Proceso de release: pre-flight checks, semver, CHANGELOG, manual steps, validaciones. | [SKILL.md](agents/efde/release/SKILL.md) |

## QA & Tests

EFDE ahora cubre QA en dos capas:

| Capa | Herramienta | Comando | Cubre |
|---|---|---|---|
| **Estática (linting)** | `bin/check.sh` | `./bin/check.sh` (alias: `efde:qa`) | Estructura, portabilidad, naming, boot, i18n CSV, props/shortcuts, props/menu, frontmatter de skills, `chmod +x` de sí mismo. Excluye `console/service/traefik` (WIP). |
| **End-to-end (comportamiento)** | `bats-core` + `test/run_all.sh` | `./test/run_all.sh` | Atajos globales (`efde:qa`, `efde:version`, `efde:shortcuts`), instalación de frameworks (wordpress, laravel, symfony) y servicios (mysql, docker), bug #1 stdin/tty regression guard. Requiere `git submodule update --init` post-clone. |

### Layout modular de bats

Los tests bats se organizan en dos raíces con auto-discovery (`run_all.sh` usa `find`):

| Raíz | Contenido | Ejemplos |
|---|---|---|
| `test/*.bats` | Genéricos (cross-cutting, no atan a una sola impl) | `shortcuts.bats`, `bug-1-prompt.bats`, `docker-root.bats`, `mysql-root.bats` |
| `console/<scope>/test/*.bats` | Específicos por implementación o servicio | `console/efde/test/lifecycle.bats`, `console/implementation/laravel/test/install.bats`, `console/service/mysql/test/export-import.bats` |

Helpers globales viven en `test/test_helper/` (common.bash, efde_pty.bash) y se importan vía `load '<path>'` desde ambos roots.

Detalle y convenciones en [agents/efde/qa/SKILL.md](agents/efde/qa/SKILL.md).

## Auto-invocación de Skills

Cuando realices las siguientes acciones, invoca SIEMPRE la skill correspondiente PRIMERO:

| Acción | Skill |
|--------|-------|
| Modificar el núcleo o el sistema de carga | `core` |
| Escribir o tocar código que use sed, date, find, rutas, which, readlink, URLs o systemctl | `portability` |
| Crear una nueva implementación o framework | `module` |
| Añadir o corregir traducciones | `i18n` |
| Añadir nuevos comandos o atajos | `shortcuts` |
| Crear un nuevo commit | `git` — invocar la skill y respetar: issue `#XX` al **inicio** de la descripción; scope solo de la lista (p. ej. `core` para init, no `boot`). [SKILL.md](agents/git/SKILL.md) |
| Modificar el boot sequence (`console/init`, `init_essential`, fases) | `boot` |
| Modificar o ampliar el chequeo estático de `bin/check.sh` o tests bats (`test/`) | `qa` |
| Trabajar en el servicio Docker (`console/service/docker/`, `dc_*`) | `service-docker` |
| Trabajar en el servicio MySQL (`console/service/mysql/`) | `service-mysql` |
| Trabajar en la implementación Laravel (`console/implementation/laravel/`) | `impl-laravel` |
| Trabajar en la implementación Symfony (`console/implementation/symfony/`) | `impl-symfony` |
| Trabajar en la implementación WordPress (`console/implementation/wordpress/`) | `impl-wordpress` |
| Preparar o documentar un release (tag, GitHub Release, CHANGELOG, badges) | `release` |

---

## Documentación de referencia

- **Modo debug (uso)**: [docs/debug-workflow.md](docs/debug-workflow.md) — configuración en `bin/cfg.core`, qué hace cada flag, imágenes.
- **Flujo del menú**: [docs/menu-flow.md](docs/menu-flow.md) — entrada, historial, retorno, opciones inválidas.
- **Docker y directorio del proyecto**: [docs/developer.md](docs/developer.md) (sección "Docker and project directory") — detección de raíz (`docker-compose.yml` o `.efde`), uso de `--project-directory`.

## Resumen del Proyecto

EFDE es un entorno de desarrollo basado en Bash para gestionar contenedores Docker.

| Componente | Ubicación | Descripción |
|------------|-----------|-------------|
| Core | `console/common` | Lógica fundamental compartida |
| Apps | `console/implementation` | Frameworks (Laravel, Symfony, etc.) |
| Services | `console/service` | Servicios (MySQL, Docker, etc.) |
| Entrypoint | `bin/efde.sh` | Script principal |

---

## Guía de Commits y PRs

Sigue la convención usada en el proyecto (detalle en [agents/git/SKILL.md](agents/git/SKILL.md)):

**Formato:** `<type>(<scope>): <description>`

- **Issue:** si se referencia un issue, poner `#XX` **al inicio de la descripción**, nunca al final: `type(scope): #49 descripción breve`.
- **Scope:** usar solo los definidos en la skill (`core`, `efde`, `menu`, `implementation`, `service`, `i18n`, `docs`, `install`, `shortcuts`, `docker`); para init/bootstrap usar `core`, no inventar `boot` u otros.

**Tipos habituales:** `feat`, `fix`, `refactor`, `change` (docs), `rename`  
**Scopes habituales:** `core`, `efde`, `menu`, `implementation`, `service`, `i18n`, `docs`, `install`, `shortcuts`, `docker`

Ejemplos: `fix(core): portabilidad macOS/Windows y robustez` · `feat(efde): #51 Refactor EFDE update...` · `refactor(core): #49 essential common.elements to init_essential`
