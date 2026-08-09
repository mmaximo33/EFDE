# AI Agent Skills

Este directorio contiene **Agent Skills** para el proyecto. Estas skills proporcionan patrones, convenciones y salvaguardas específicas del dominio para ayudar a los asistentes de IA a entender los requisitos del proyecto.

## ¿Qué son las Skills?

Las skills enseñan a los asistentes de IA cómo realizar tareas específicas. Cuando una IA carga una skill, gana contexto sobre:

- Reglas críticas (qué hacer siempre/nunca).
- Patrones de código y convenciones (Bash, `_mod_`, etc.).
- Flujos de trabajo específicos del proyecto.
- Referencias a documentación detallada.

## Cómo usar las Skills

Las skills son descubiertas automáticamente por el agente. Para cargar una skill manualmente durante una sesión, simplemente lee el archivo `SKILL.md` correspondiente.

## Skills Disponibles (EFDE)

| Skill | Descripción | Ruta |
|-------|-------------|------|
| `core` | Visión general del proyecto, navegación y lógica del núcleo. | [efde/core/SKILL.md](efde/core/SKILL.md) |
| `portability` | Reglas de portabilidad y compatibilidad (sed, date, find, readlink, which, xdg-open, systemctl). | [efde/portability/SKILL.md](efde/portability/SKILL.md) |
| `module` | Patrones para crear y extender implementaciones y servicios. | [efde/module/SKILL.md](efde/module/SKILL.md) |
| `i18n` | Estándares de traducción para `en_US`, `es_ES`, `fr_FR`, `pt_BR`, `de_DE`. | [efde/i18n/SKILL.md](efde/i18n/SKILL.md) |
| `shortcuts` | Configuración de atajos en `props/shortcuts`. | [efde/shortcuts/SKILL.md](efde/shortcuts/SKILL.md) |
| `install` | Script de instalación: rutas ($HOME/.efde, $HOME/bin), compatibilidad por SO. | [efde/install/SKILL.md](efde/install/SKILL.md) |
| `git` | Convención de commits usada en el proyecto. | [git/SKILL.md](git/SKILL.md) |

## Estructura del Directorio

```
agents/
├── README.md                 # Este archivo
├── efde/
│   ├── core/
│   ├── install/
│   ├── {skill-name}/
│   │   ├── SKILL.md          # Requerido - Instrucciones principales y metadatos
│   │   └── assets/           # Opcional - Plantillas o recursos
└── git/
    └── SKILL.md              # Convención de commits
```

## Creación y actualización de Skills

Para crear una nueva skill, sigue la estructura de las existentes, asegurándote de incluir las reglas críticas al principio.

**Regla para agentes:** Cuando consideres que algo es relevante para que otros agentes o desarrolladores lo sigan (convenciones, patrones, reglas críticas, ejemplos del proyecto), debe quedar documentado en una skill. Añade o actualiza el `SKILL.md` correspondiente en `agents/efde/` o `agents/git/`, y si aplica actualiza la tabla de skills en este README y en la raíz `AGENTS.md`.
