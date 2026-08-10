# Skill: EFDE Core

Reglas fundamentales y arquitectura del núcleo de EFDE.

## Metadatos
- **Nombre:** core
- **Alcance:** Proyecto completo
- **Activación:** Siempre que se trabaje en archivos dentro de `console/` o `bin/`.

## Reglas Críticas

1. **Convención `_mod_`**: 
   - SIEMPRE usa el prefijo `_mod_.` para funciones y `_mod_` para variables dentro de los archivos de `console/`.
   - NUNCA uses nombres de funciones absolutos (ej. `common.tasks.menu.main`) si la función pertenece al mismo módulo; usa la transformación dinámica.
   - El sistema `init` reemplaza automáticamente `_mod_` por `nombre_modulo.archivo`.

2. **Portabilidad (macOS/Windows)**: Sigue las reglas de la skill [portability](portability/SKILL.md) (sed -i → sed_inplace, date -d → date_to_epoch, find -printf, readlink -f, which → command -v, xdg-open → open_url, systemctl). El script `bin/check.sh` valida estos patrones en `console/`.

3. **No usar llamadas directas en `init` y `core`**:
   - En `console/init` y `console/common/core`, NO uses llamadas a módulos como `efde.tasks.*` o `common.tasks.*`. Usa Bash puro o funciones locales.

4. **Estructura de Archivos**:
   - Las tareas van en `tasks/`.
   - Las propiedades y variables van en `props/`.
   - Las traducciones van en `i18n/`.

5. **Resolución de ruta de instalación** (`bin/efde.sh`): La ruta de instalación se obtiene con `efdeinit.resolve_absolute_dir()` (portable; no usar `readlink -f`). Ver [portability](portability/SKILL.md).

6. **Modo debug**: Documentación de uso (configuración, flags, imágenes) en [docs/debug-workflow.md](../../docs/debug-workflow.md). No duplicar en skills; referenciar ese doc.

## Dependencias opcionales

EFDE no requiere dependencias externas para ejecutarse como atajos. Sin embargo, el rig de tests E2E (bajo `test/`) y el linter ampliado (`bin/check.sh`) sí las necesitan:

| Dependencia | ¿Obligatoria? | Cómo se obtiene | Uso |
|---|---|---|---|
| `bats-core` | **Opcional** (solo E2E) | Submodule: `git submodule update --init --recursive` bajo `test/bats/` | Test runner para `test/*.bats`. Ver [qa](../qa/SKILL.md). |
| `script` (util-linux) | **Opcional** (solo E2E interactivos) | Paquete del sistema (`util-linux` en Linux, `bsdmainutils` en macOS) | Asigna PTY para automatizar prompts de `efde:wordpress:install:new` etc. |
| Docker | **Opcional** (solo si se ejecutan flujos de instalación) | `bin/install.sh` en Linux/apt; `brew install --cask docker` en macOS | Lo usan los shortcuts `*:install:new`, `docker:build`, `mysql:db:export`. Ninguno de estos es necesario para usar EFDE como capa de menú. |

Las dependencias opcionales se documentan aquí (no son parte del binario EFDE). Si falta una, los tests saltan con un mensaje claro en vez de fallar.

## Patrones de Código

### Definición de funciones
```bash
_mod_.mi_funcion(){
  # ... lógica
}
```

### Definición de variables
```bash
_mod_MI_VARIABLE="valor"
```

## Estructura del Proyecto

- `bin/`: Contiene los scripts de ejecución y archivos temporales generados.
- `console/common/`: Utilidades compartidas (mensajes, sistema de menús, git, etc.).
- `console/efde/`: Lógica central de gestión de proyectos EFDE.
- `console/implementation/`: Implementaciones específicas (frameworks/CMS).
- `console/service/`: Servicios adicionales (bases de datos, etc.).

## Ver también

- [agents/efde/boot/SKILL.md](boot/SKILL.md) — conocimiento del boot de 3 fases (`console/init_essential` → módulos → generate_extra_elements + updates).
