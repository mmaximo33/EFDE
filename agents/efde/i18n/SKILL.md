# Skill: EFDE i18n

Estándar para el sistema de traducciones de EFDE.

## Metadatos
- **Nombre:** i18n
- **Alcance:** Directorios `i18n/` en cualquier módulo (common, efde, implementation/*, service/*).
- **Activación:** Al añadir o corregir soporte multi-idioma.

## Reglas críticas

1. **Idiomas soportados:** `en_US` (base), `es_ES`, `fr_FR`, `pt_BR`, `de_DE`. Códigos con guión bajo (idioma_PAÍS).
2. **Formato:** Archivo por idioma con extensión `.csv` (p. ej. `es_ES.csv`, `pt_BR.csv`) en `i18n/`. Cada línea: dos campos entre comillas `"texto_original","texto_traducido"`. El texto original debe coincidir **exactamente** con la cadena en el código (incluidas variables como `$DIR_PATH`, `$FILE_PATH`).
3. **Comas y comillas:** Dentro de un campo se pueden usar comas (el parser respeta las comillas). Una comilla literal dentro del texto se escribe `""`.
4. **Coincidencia:** Si el mensaje en el código cambia (por ejemplo de `$PATH` a `$DIR_PATH`), hay que añadir o actualizar la línea en el i18n con el texto exacto nuevo; la antigua dejará de hacer match.
5. **Escape:** No es necesario escapar caracteres especiales para `sed`; el sistema los escapa automáticamente.

## Ejemplo de archivo `es_ES.csv`

```text
"Select an option","Seleccione una opción"
"Error: Path '$DIR_PATH' does not exist.","Error: La ruta '$DIR_PATH' no existe."
"Hello, user","Hola, usuario"
"Say ""hi""","Di ""hola"""
```

## Proceso de carga

El sistema aplica traducciones durante el arranque si `HOST_I18N` (en `bin/cfg.host`) es distinto de `I18N_DEFAULT` (en `bin/cfg.core`). Lee los archivos `console/<módulo>/i18n/<locale>.csv`, parsea cada línea como CSV de dos campos, escapa origen y destino para `sed`, y sustituye en los ficheros generados de `bin/.tmp` correspondientes a ese módulo.

## Documentación completa

Ver [docs/i18n.md](../../../docs/i18n.md) para formato CSV, cuándo se aplican las traducciones, coincidencia exacta y depuración (DEBUG_I18N).
