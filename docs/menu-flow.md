# EFDE | Flujo del menú

Este documento describe cómo funciona el menú de EFDE: entrada, historial, retorno y acciones.

## Resumen

- **Entrada:** `bin/efde.sh` decide si ejecutar un shortcut (argumentos) o mostrar menú.
- **Menú inicial:** Si el directorio actual tiene `.efde/`, se muestra el menú de la implementación (Laravel, Symfony, WordPress); si no, el menú principal de EFDE.
- **Cada pantalla de menú** usa `common.tasks.menu.show`: limpia consola, añade al historial, imprime opciones y pide elección.
- **Opciones especiales:** [I]nfo, [R]eturn, [Q]uit. Las acciones del menú suelen terminar llamando de nuevo al menú (`_mod_.main`) para volver a listar opciones.

## 1. Entrada (`bin/efde.sh`)

```
efdeinit.main "$@"
  ├── efdeinit.init_dirs     # Rutas, configs, source console/init
  ├── [ $# -gt 0 ] && efdeinit.shortcuts "$@"   # Con argumentos: ejecutar shortcut (ej. efde qa)
  └── || efdeinit.menu       # Sin argumentos: mostrar menú
```

## 2. Qué menú se muestra (`efdeinit.menu`)

- **Si existe `.efde/` en el directorio actual:** se lee `EFDE_PROJECT_IMPLEMENTATION` en `.efde/.env` y se llama a `$IMPLEMENTATION.tasks.menu.main` (ej. `laravel.tasks.menu.main`).
- **Si no existe:** se llama a `efde.tasks.menu.main` (menú global de EFDE: config, shortcuts, version, etc.).

## 3. Mostrar un menú (`common.tasks.menu.show`)

Cada módulo (efde, laravel, docker, mysql, etc.) define su `_mod_.main()` que llama a:

```bash
common.tasks.menu.show --title "$TITLE" --data "${MENU_DATA[@]}"
```

Dentro de `show`:

1. **validate_params** — Guarda título, datos y si las opciones son funciones.
2. **console_clear** — Limpia la pantalla antes de listar.
3. **history_add** — Añade el menú actual al historial (para [R]eturn).
4. **print_options** — Muestra título y lista numerada (función, nombre, descripción).
5. **choice_options** — Pide al usuario una elección y actúa.

## 4. Elección del usuario (`choice_options`)

Se muestra la línea de ayuda y se pide número o letra:

- **Número válido (0..N):** Se resuelve la función asociada, se hace `console_clear` y se ejecuta `${FUNCTION_NAME}`. Esa función suele acabar con `_mod_.main` para volver a mostrar el mismo menú.
- **[Q]uit:** `console_clear` y `exit`.
- **[R]eturn:** Solo si hay más de un nivel en el historial. Se elimina el menú actual del historial y se vuelve a ejecutar el menú anterior (`history_go_to_last_item` → `check_function_exists` con la función del menú previo).
- **[I]nfo:** Se ejecuta `efde.tasks.main.more_info` y se retorna (el proceso termina y se relanza efde desde el shortcut).
- **Opción inválida (otro texto o número fuera de rango):** Se muestra mensaje de error y se vuelve a listar el mismo menú y a pedir elección (`print_options` + `choice_options`), **sin** volver a llamar a `show`, para no duplicar entradas en el historial.

## 5. Historial

- **history:** Lista de funciones de menú por las que se ha pasado (ej. `efde.tasks.menu.main,laravel.tasks.menu.main`).
- **history_add:** En cada `show()` se añade el “caller” (quién llamó a `show`) al historial, si es distinto del último.
- **history_go_to_last_item:** Al pulsar [R], se quita el menú actual del historial y se ejecuta de nuevo la función del menú anterior, de modo que se “vuelve” un nivel atrás.

## 6. Retorno tras una acción

Para que tras una acción (Build, Fix permissions, etc.) se vuelva a ver el menú:

- La función de la acción debe terminar llamando al menú correspondiente, por ejemplo `_mod_.main` (que a su vez llama a `common.tasks.menu.show` con el título y datos de ese módulo).

Ejemplos:

- **Implementations (Laravel, Symfony, WordPress):** `permissions_fix`, `console`, etc. acaban con `_mod_.main`.
- **config_show / env_show:** Preguntan “Back to menu?”; si sí → `console_clear` + `_mod_.main`; si no → `exit`.
- **Docker:** `logs`, `command` acaban con `_mod_.main` para volver al menú Docker.
- **EFDE:** `shortcuts_show`, `coming_soon` acaban con `_mod_.main`.

## 7. Diagrama simplificado

```
efde.sh (sin args)
  → efdeinit.menu
      → ¿.efde/ en cwd? → SÍ: implementation.tasks.menu.main
      → NO:             efde.tasks.menu.main
  → common.tasks.menu.show
      → console_clear
      → history_add
      → print_options
      → choice_options
            → número → chosen_option → check_function_exists → ${FUNCTION}
                                                                   → (acción)
                                                                   → _mod_.main  (vuelve a show)
            → R → history_go_to_last_item → show del menú anterior
            → Q → exit
            → I → more_info ; return (sale y relanza)
            → inválido → mensaje + print_options + choice_options (sin history_add)
```

## Referencias

- Menú común: `console/common/tasks/menu`
- Punto de entrada: `bin/efde.sh`
- Init y carga de módulos: `console/init`
- Reglas para menús en módulos: [developer.md](developer.md#rules-for-developer)
