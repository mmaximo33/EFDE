# Skill: Git / Commits

Convención de commits usada en el proyecto EFDE (extraída del historial).

## Metadatos
- **Nombre:** git
- **Alcance:** Mensajes de commit y PRs
- **Activación:** Antes de crear un commit o abrir un PR.

## Cuándo invocar esta skill

Invocar **siempre** esta skill cuando:
- Vayas a crear un commit (`git commit`).
- Vayas a enmendar o reescribir mensajes (`git commit --amend`, `git rebase -i` para reword).
- Revises o sugieras el mensaje de un commit o el título de un PR.
- Verifiques que una serie de commits cumple la convención antes de push o PR.

## Formato

```
<type>(<scope>): <description>
```

Opcionalmente incluir número de issue: `#XX` **al inicio** de la descripción (nunca al final).

## Tipos usados en el proyecto

| Tipo | Uso |
|------|-----|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug o comportamiento |
| `refactor` | Refactor sin cambio de comportamiento |
| `change` | Cambio de documentación o proceso (ej. `change (docs): ...`) |
| `rename` | Renombrado de archivos/carpetas/variables (mensaje descriptivo) |

## Scopes habituales

- `core` — Núcleo común, init, carga de módulos, `console/common`
- `efde` — Lógica EFDE (lifecycle, config, implementation)
- `menu` — Flujo del menú, opciones, historial, retorno
- `implementation` — Implementaciones (Laravel, Symfony, WordPress)
- `service` — Servicios (Docker, MySQL, etc.)
- `i18n` — Traducciones e idiomas
- `docs` — Documentación
- `install` — Script de instalación
- `shortcuts` — Atajos
- `docker` — Recetas Docker o compose

## Ejemplos (del historial)

```
fix(core): portabilidad macOS/Windows y robustez
fix(efde): #54 fix script uninstall
feat(efde): #51 Refactor EFDE update and management of CORE and HOST cfg
refactor(efde): #46 Refactoring and management of global values EFDE_*
change (docs): update with changes 2.3.x
rename from implemention to implementation
feat(shortcuts): #43 add custom shortcut management
fix(docker): #41 correct use of the docker-compose command in implemention
```

## Reglas

1. **Scope** en minúsculas y entre paréntesis. Usar **solo** scopes de la lista anterior (p. ej. `core`, `efde`, `docs`); no inventar scopes como `boot` — para init/bootstrap usar `core`.
2. **Descripción** en minúsculas tras los dos puntos (salvo nombres propios o siglas).
3. **Issue:** si se referencia un issue, poner `#NN` **al inicio** de la descripción: `#49 descripción breve`, nunca al final como `(... #49)`.

## Antes de hacer commit

Comprobar antes de `git commit` o `git push`:

1. El mensaje sigue `<type>(<scope>): <description>`.
2. El **scope** es uno de la lista (no inventar; para init/bootstrap usar `core`).
3. Si hay issue, `#NN` está **al inicio** de la descripción, no al final.
4. La descripción está en minúsculas (salvo nombres propios o siglas).

## Comandos útiles

```bash
# Ver últimos commits (verificar formato)
git log --oneline -5

# Commit con mensaje correcto
git commit -m "fix(core): #49 descripción breve"

# Enmendar último commit (corregir mensaje)
git commit --amend -m "refactor(core): #49 essential common.elements to init_essential"

# Reescribir varios commits (reword)
git rebase -i HEAD~2
# Marcar con "reword" (o "edit") y guardar; en cada parada: git commit --amend -m "nuevo mensaje" && git rebase --continue
```

## Para próximas iteraciones

- Commits de documentación deben llevar **scope**: usar `change(docs): descripción` o `fix(docs): descripción`, no solo `docs: descripción`. Tenerlo en cuenta en futuros commits aunque en el historial haya mensajes sin scope que se dejaron así a propósito.

## Recursos

- **Guía de agentes:** [AGENTS.md](../../AGENTS.md) — sección "Guía de Commits y PRs" y auto-invocación al crear commit.
