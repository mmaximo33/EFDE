# Skill: EFDE Install (bin/install.sh)

Comportamiento del script de instalación y compatibilidad por sistema operativo.

## Metadatos
- **Nombre:** install
- **Alcance:** `bin/install.sh`
- **Activación:** Al modificar el instalador o documentar instalación en otros SO.

## Dónde se instala (todas las plataformas soportadas)

El script **no** usa rutas de sistema (`/` ni `/bin`). Siempre trabaja en espacio de usuario:

| Concepto | Ruta |
|----------|------|
| **Directorio de instalación** | `$HOME/.efde` (o `$XDG_CONFIG_HOME/efde` si está definido). También respeta `$EFDE_DIR` si el usuario lo define. |
| **Acceso directo (comando `efde`)** | `$HOME/bin/efde` → enlace simbólico a `$INSTALL_DIR/bin/efde.sh` |

Es decir: instalación en `~/.efde` y comando en `~/bin/efde`, tanto en Linux como en macOS o WSL si se adaptara.

## Detección de sistema operativo

El script usa `efde_get_os` (basado en `uname -s`) y guarda el resultado en `INSTALL['OS']`:

- **Linux** — Debian/Ubuntu o WSL2: instala con `apt`, enlace con `ln -sfT`.
- **Darwin** — macOS: instala con Homebrew (`brew`), enlace con `ln -sf` (BSD no tiene `-T`).
- **Windows** — MINGW/MSYS/CYGWIN: el script sale con mensaje indicando usar WSL2.

La lógica de requisitos e instalación ramifica según `INSTALL['OS']` (por ejemplo `efde_install_git_linux` vs `efde_install_git_macos`).

## Compatibilidad actual del script

| Entorno | ¿Compatible? | Notas |
|---------|--------------|--------|
| **Linux (Debian/Ubuntu)** | Sí | `apt`, `ln -sfT`, instalación de git/docker/docker-compose. |
| **Windows (WSL2)** | Sí | WSL es Linux; mismo flujo. Añadir `$HOME/bin` al PATH si hace falta. |
| **macOS (nativo)** | Sí | Requiere Homebrew. Instala git/docker con `brew`; enlace con `ln -sf`. Docker Desktop incluye Compose. |
| **Windows (nativo, sin WSL)** | No | Sale con mensaje: usar WSL2. |

## Reglas para el instalador

1. **Rutas:** Usar siempre `$HOME` (o `$XDG_CONFIG_HOME`) y `$HOME/bin` para el enlace; nunca `/bin` ni rutas bajo `/` que requieran root.
2. **Comprobación de comandos:** Usar `command -v` en lugar de `which` (más portable).
3. **Enlaces simbólicos:** En macOS/BSD, `ln -sfT` no existe; para compatibilidad futura usar algo como: `ln -sf "$INSTALL_DIR_FILE" "$BIN_FILE"` (o detectar SO y usar la forma adecuada).
4. **Instalación de dependencias:** La lógica actual (`efde_install_git`, `efde_install_docker`, etc.) es Debian/Ubuntu. Para macOS haría falta una rama con `brew`; para Windows nativo, otra estrategia (instaladores o Chocolatey), o indicar uso de WSL.

## Post-clone / post-install: bats-core submodule

EFDE ships `bats-core` as a git submodule under `test/bats/` (used by the QA skill). On a fresh clone, initialise the submodule before running the test harness:

```bash
git submodule update --init --recursive
```

Without this step, `./test/run_all.sh` exits with a clear "bats-core not installed" hint. `bin/install.sh` does NOT run the submodule init automatically (the install step targets the runtime, not the contributor test rig).

## Servicios que dependen del SO

En `console/service/`, si un script usa comandos específicos de Linux (p. ej. `systemctl`, `service apache2`), debe comprobar antes que existan para no fallar en macOS:

- Ejemplo: `if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet apache2 2>/dev/null; then ... fi`

Así el comportamiento en Linux se mantiene y en macOS se omite la lógica sin error.

## Uninstall (portabilidad)

El flujo de desinstalación (`efde.tasks.lifecycle.uninstall`) no forma parte de `bin/install.sh` pero debe ser portable: usa `command -v "$GLOBAL_RUN_EFDE"` para obtener la ruta del launcher (nunca `type -P` ni `which`), y solo elimina el archivo si la ruta es no vacía y existe. El directorio de instalación se elimina con `common.tasks.directory.remove force "$EFDE_PATH_INSTALL"`.

## Resumen para agentes

Al tocar `bin/install.sh`: mantener rutas en `$HOME`/`$HOME/bin`, usar `command -v`, y documentar aquí cualquier cambio que afecte a macOS o Windows (WSL o nativo).
