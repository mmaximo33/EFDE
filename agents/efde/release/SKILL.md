# Skill: EFDE Release

Proceso de release de EFDE: cuándo cortar una versión, pre-flight checks, comandos manuales, convención de Semver y CHANGELOG, y validaciones automáticas.

## Metadatos
- **Nombre:** release
- **Alcance:** Proyecto completo (tags, GitHub Releases, CHANGELOG, badges).
- **Activación:** Al preparar un release, documentar el proceso, o auditar consistencia entre tags/CHANGELOG/README.

## Reglas Críticas

1. **Semver estricto:** EFDE sigue [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html). El bump se decide por el contenido, no por fecha.
2. **Tag anotado, NO lightweight:** siempre `git tag -a X.Y.Z -m "..."`. El mensaje se usa para `git show X.Y.Z` y para herramientas externas.
3. **Tag Y Release en GitHub:** el tag se pushea, pero el GitHub Release se crea aparte (`gh release create` o web UI). Si solo se pushea el tag, el instalador puede no verlo (Fix B en `bin/install.sh` mitiga esto con fallback a `/tags`).
4. **CHANGELOG primero:** la entrada de `[Unreleased]` se mueve a `[X.Y.Z] - YYYY-MM-DD` en el mismo commit (o uno inmediatamente anterior) al tag. Nunca releasear sin entrada fechada.
5. **Validaciones automáticas antes de taggear:** los tres comandos deben pasar en limpio. Si alguno falla, NO taggear.

## Cuándo hacer un release

| Cambio | Bump | Ejemplo |
|--------|------|---------|
| Breaking change (signature, contrato, flujo incompatible) | **major** | `1.4.2` → `2.0.0` |
| Nueva feature backwards-compatible (atajo nuevo, framework nuevo, menú nuevo) | **minor** | `2.3.1` → `2.4.0` |
| Bug fix, refactor, docs, chore sin cambio funcional | **patch** | `2.3.1` → `2.3.2` |

EFDE hoy está en `2.x`. El próximo major (`3.0.0`) se justifica solo si hay un cambio de contrato breaking (ej. cambio en convención `_mod_`, removal de un shortcut público, cambio en `bin/efde.sh` que rompe launchers externos).

## Pre-release checklist

Antes de `git tag`:

```bash
# 1. Lint estático (estructura, portabilidad, naming, boot, i18n CSV, frontmatter de skills)
./bin/check.sh

# 2. Auditoría de docs (badges, locale typos, scopes, CHANGELOG coverage)
./bin/check-docs.sh

# 3. E2E (shortcuts globales + instalación de frameworks y servicios)
./test/run_all.sh
```

Además, **fuera del rig**:

- `CHANGELOG.md`: la sección `[Unreleased]` lista TODOS los commits desde el último tag. Si falta alguno, agrégalo.
- `README.md`: badges con la versión nueva (`badge/version-2.4.0-blue`, `commits-since-v2.3.1`).
- Branches sincronizados: `git fetch origin && git switch main && git merge --ff-only origin/develop` (si develop tiene commits ahead).
- Working tree limpio: `git status` sin cambios sin commitear (excepto `bin/.tmp/` que está gitignored).

## Manual release steps

```bash
# 1. Asegurarse de estar en main limpio, con develop mergeado
git switch main
git pull --ff-only origin main
git merge --ff-only origin/develop   # solo si develop tiene commits ahead

# 2. Crear tag anotado localmente
git tag -a 2.4.0 -m "2.4.0 — release notes title here"

# 3. Push del tag
git push origin 2.4.0

# 4. Crear GitHub Release (vía CLI o web UI)
gh release create 2.4.0 \
  --title "2.4.0 — short descriptive title" \
  --notes-file RELEASE_NOTES.md   # o --notes "..."

# Alternativa sin gh: ir a github.com/.../releases/new, tag = 2.4.0, título + descripción.
```

### Release notes titles (formato corto)

Mirar los releases pasados en GitHub para el estilo:

- `2.3.1 — WordPress FPM default bump`
- `2.3.0 — Docker Compose root detection + menu flow fixes`
- `2.2.0 — Laravel/Symfony/WordPress consistency + i18n unification`

Convención: `X.Y.Z — <feature area(s)> + <theme>`. Máximo 80 caracteres. Imperativo o sustantivo, ambos OK.

## CHANGELOG convention

EFDE usa [Keep a Changelog 1.1.1](https://keepachangelog.com/en/1.1.1/). Estructura:

```markdown
## [Unreleased]

### Added
- **Scope**: descripción corta.

### Changed
- **Scope**: descripción.

### Fixed
- **Scope**: descripción.

## [X.Y.Z] - YYYY-MM-DD

### Added
- ...
```

Al releasear:
1. Renombrar `## [Unreleased]` → `## [X.Y.Z] - YYYY-MM-DD`.
2. Crear nueva sección `## [Unreleased]` vacía arriba con los mismos sub-headers (`### Added`, `### Changed`, `### Fixed`, `### Removed`).
3. Commit: `fix(docs): update changelog for X.Y.Z`.

**Scopes válidos** (de `bin/check-docs.sh`): `core`, `efde`, `menu`, `implementation`, `service`, `i18n`, `docs`, `install`, `shortcuts`, `docker`. NO inventar scopes nuevos (`boot`, `release`, `qa`, etc. son inválidos).

## Validaciones automáticas post-release

`bin/check-docs.sh` corre 5 checks. Los relevantes para un release:

1. **Stale badges** (`README.md`): cada badge con `X.Y.Z` debe corresponder a un tag real. Si pusheaste el tag pero olvidaste el badge, este check falla.
2. **CHANGELOG coverage**: cada commit desde el último tag debe tener entrada con scope válido bajo `[Unreleased]`. Después de releasear, queda vacío hasta el próximo PR.
3. **Scope whitelist**: cada `(scope)` en `[Unreleased]` debe estar en la whitelist.

Si `bin/check-docs.sh` falla después de un release, hay un mismatch entre código y docs.

## Compatibilidad entre binario y tags (Fix A)

`console/efde/tasks/lifecycle:_mod_.version_min()` deriva dinámicamente el filtro de tags según el binario que corre:

- Si HEAD está en un tag `X.Y.Z` (semver match) → retorna `(X-1).0.0`. Ej: tag `2.3.1` corriendo → filtra a `>= 2.0.0`.
- Si HEAD está en un branch (`develop`, `main`, dirty) → retorna `1.0.0` (muestra todos los tags).

El menú `efde:version` solo lista tags compatibles con el binario en ejecución. Tags incompatibles estructuralmente (ej: `1.x` corriendo binario `2.x`) se ocultan.

## Instalador y detection de latest (Fix B)

`bin/install.sh:efde_latest_version()` consulta dos fuentes en orden:

1. `/releases/latest` — happy path, requiere GitHub Release publicado.
2. `/tags?per_page=1` — fallback cuando `/releases/latest` está vacío o falla.

Esto evita el footgun "tag pusheado pero sin Release": el instalador igual encuentra la versión.

## Resumen para agentes

Al preparar un release:

1. Correr `./bin/check.sh`, `./bin/check-docs.sh`, `./test/run_all.sh`.
2. Mover `[Unreleased]` → `[X.Y.Z] - YYYY-MM-DD` en `CHANGELOG.md`.
3. Actualizar badges en `README.md`.
4. `git tag -a X.Y.Z -m "..."` + `git push origin X.Y.Z`.
5. `gh release create X.Y.Z --title "..." --notes "..."` o web UI.
6. Verificar que `bin/check-docs.sh` siga limpio después.
