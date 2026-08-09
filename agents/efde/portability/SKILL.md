# Skill: EFDE Portabilidad / Compatibilidad

Reglas para que el código Bash funcione en **Linux**, **macOS** (BSD), **WSL** y **Windows (Git Bash/Cygwin)**.

## Metadatos

- **Nombre:** portability
- **Alcance:** Todo el código en `console/`, `bin/` (Bash).
- **Activación:** Al escribir o modificar scripts que usen comandos del sistema, rutas, sed, date, find, resolución de rutas o apertura de URLs.

## Objetivo

EFDE debe ejecutarse sin cambios en distintos sistemas operativos. Estas reglas evitan GNUisms y comandos no portables para no fallar en macOS/BSD o en entornos mínimos.

---

## Reglas críticas (patrones prohibidos y alternativas)

### 1. `sed -i`

- **No usar:** `sed -i` (comportamiento distinto en GNU vs BSD).
- **Usar:** `common.core.sed_inplace` (wrapper en `console/common/core` que elige `sed -i ''` en macOS y `sed -i` en Linux).

### 2. `date -d`

- **No usar:** `date -d "..."` (GNU; en macOS no existe).
- **Usar:** `common.core.date_to_epoch` para convertir fechas a epoch (usa `date -j` en macOS y `date -d` en Linux internamente).

### 3. `find -printf`

- **No usar:** `find ... -printf` (GNU).
- **Usar:** Alternativas portables, p. ej. `find ... | while read -r dir; do basename "$dir"; done`, o `find ... -print0` con `read -r -d ''` si se necesita null-terminated.

### 4. `readlink -f`

- **No usar:** `readlink -f` (no existe en macOS/BSD).
- **Usar:** En `bin/efde.sh`, `efdeinit.resolve_absolute_dir()` (bucle con `readlink` de un nivel y `cd`/`pwd`). En otros sitios, el mismo patrón: bucle `while [ -L "$path" ]; do ... readlink "$path"; ... done` y al final `cd "$(dirname "$path")" && pwd`.

### 5. `which`

- **No usar:** `which` (no está en POSIX; comportamiento variable).
- **Usar:** `command -v <comando>` para comprobar si existe o para obtener la ruta (POSIX). Ejemplo: `EFDE_BIN_PATH=$(command -v "$GLOBAL_RUN_EFDE" 2>/dev/null) || true`.

### 6. `xdg-open`

- **No usar:** `xdg-open` (solo Linux/entornos X).
- **Usar:** `common.tasks.os.open_url "$url"` (abre la URL en el navegador de forma portable; usa la función adecuada por SO).

### 7. Comandos que dependen del SO (systemctl, service, etc.)

- **Regla:** Si usas `systemctl`, `service apache2`, etc., comprueba antes que existan para no fallar en macOS.
- **Ejemplo:** `if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet apache2 2>/dev/null; then ... fi`. Así en Linux se ejecuta la lógica y en macOS se omite sin error.

---

## Rutas y estilo

- **Rutas:** Usar siempre barras `/` (POSIX). Evitar rutas de sistema que requieran root; preferir `$HOME`, `$XDG_CONFIG_HOME`, etc. cuando aplique.
- **Enlaces simbólicos:** En macOS/BSD, `ln -sfT` no existe; usar `ln -sf` o detectar SO y usar la forma adecuada (ver skill [install](../install/SKILL.md)).

---

## Validación automática

El script **`bin/check.sh`** (atajo `efde:qa`) valida en `console/` que no aparezcan los patrones prohibidos anteriores. Si añades una nueva regla de portabilidad, actualiza este skill y, si aplica, `bin/check.sh`.

---

## Referencias

- **Core (convención _mod_, estructura):** [../core/SKILL.md](../core/SKILL.md).
- **Instalación y uninstall (rutas, command -v, systemctl):** [../install/SKILL.md](../install/SKILL.md).
- **Módulos (open_url, sort -V, Docker dc_):** [../module/SKILL.md](../module/SKILL.md).
