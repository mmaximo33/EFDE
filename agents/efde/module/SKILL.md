# Skill: EFDE Module

Guía para la creación y extensión de módulos (Implementaciones y Servicios).

## Metadatos
- **Nombre:** module
- **Alcance:** `console/implementation/`, `console/service/`
- **Activación:** Al crear o modificar un framework o servicio.

## Reglas Críticas

1. **Ubicación**: 
   - Implementaciones: `console/implementation/<nombre>/`
   - Servicios: `console/service/<nombre>/`
2. **Archivos Requeridos**:
   - `tasks/main`: Punto de entrada del módulo.
   - `tasks/menu`: Definición del menú del módulo.
   - `props/menu`: Variables de texto para el menú.
   - `props/shortcuts`: Definición de atajos del módulo.
3. **Naming**: El nombre de la carpeta debe ser en minúsculas (ej: `laravel`, `mysql`).

## Estructura Recomendada

```
mi-modulo/
├── i18n/
│   ├── es_ES.csv
│   ├── fr_FR.csv
│   ├── pt_BR.csv
│   └── de_DE.csv
├── props/
│   ├── menu
│   └── shortcuts
└── tasks/
    ├── main
    └── menu
```

## Consistencia entre implementations y services

Para alinear con Laravel, Symfony y WordPress:

- **Nombres de funciones de menú**: Usar `config_show` (mostrar configuración del proyecto), `permissions_fix` (aplicar permisos), `console` (consola/CLI del framework).
- **Abrir URLs**: Usar `common.tasks.os.open_url "$url"` en lugar de `xdg-open` para portabilidad (macOS/Linux).
- **Comparación de versiones**: Usar `sort -V` (p. ej. `printf "%s\n%s" "$tag" "$min" | sort -V | head -1`) en lugar de comparación lexicográfica con `<` o `>`.
- **Servicios**: Comprobar existencia de rutas o directorios antes de `cp`/`rm`; funciones que usen `systemctl` deben comprobar `command -v systemctl` para no fallar en macOS.
- **Docker**: El servicio Docker usa el prefijo `dc_` (docker compose) en sus funciones: `dc_project_root`, `dc_command_run`, `dc_build`, `dc_start`, `dc_stop`, `dc_restart`, `dc_all_stop`, `dc_down`, `dc_logs`, `dc_show_container`. Resuelve la raíz del proyecto buscando hacia arriba `docker-compose.yml` o `.efde`; las implementaciones durante install hacen `cd` al proyecto antes de llamar a Docker. Ver [developer.md](../../docs/developer.md) (Docker and project directory) y la skill [service-docker](../service-docker/SKILL.md).

## Skills especializadas

Cuando crees o modifiques un módulo de tipo **service** o **implementation**, consultá primero la skill específica correspondiente para conocer su contrato (prefijos de funciones, menú, atajos):

- **Services**:
  - [service-docker](../service-docker/SKILL.md) — prefijo `dc_`, detección de raíz, 12 atajos.
  - [service-mysql](../service-mysql/SKILL.md) — import/export, 7 atajos.
- **Implementations**:
  - [impl-laravel](../impl-laravel/SKILL.md) — PHP 8.2 default, 7 atajos.
  - [impl-symfony](../impl-symfony/SKILL.md) — `webapp` / `api`, 7 atajos.
  - [impl-wordpress](../impl-wordpress/SKILL.md) — `wordpress:${DOCKER_APP_FPM_VERSION}`, 7 atajos.

## Ejemplo de Menú (`props/menu`)

```bash
#!/usr/bin/env bash
{
  _mod_TITLE="MI MODULO"
  _mod_MAIN=(
    "Accion 1,  _mod_.accion_uno,  Descripcion de la accion"
    "Volver,    efde.tasks.menu.main,  Volver al menu principal"
  )
}
```
