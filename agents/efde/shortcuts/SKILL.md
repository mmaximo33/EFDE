# Skill: EFDE Shortcuts

Gestión y definición de atajos (shortcuts) en EFDE.

## Metadatos
- **Nombre:** shortcuts
- **Alcance:** `props/shortcuts` y configuración de proyectos.
- **Activación:** Al añadir o modificar comandos rápidos.

## Reglas Críticas

1. **Nombre de variable**: NO cambies el nombre de la variable `_mod_ITEMS`.
2. **Formato**: Cada línea en `_mod_ITEMS` debe seguir el patrón: `"atajo, path.funcion, descripcion"`.
3. **Prefijos**:
   - Los atajos globales de EFDE suelen empezar por `efde:`.
   - Los atajos de implementación suelen empezar por el nombre de la implementación (ej: `laravel:`).
   - Los atajos personalizados del usuario usan el prefijo `custom:`.

## Ejemplo de Atajos (`props/shortcuts`)

```bash
#!/usr/bin/env bash
{
  _mod_ITEMS=(
    "mimod:test,  _mod_.test_function,  Ejecuta un test rápido"
  )
}
```

## Shortcuts de Proyecto
Los proyectos pueden tener sus propios atajos en `.efde/shortcuts/`. Estos no son globales y solo están disponibles dentro del directorio del proyecto.
