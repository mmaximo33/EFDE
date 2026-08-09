# EFDE | Easy and fast development environment
In this small guide you will find all the necessary elements if you want to start collaborating on the project.

Here are mentioned the variables and workflow that must be considered when
- Fix a bug
- Improve an existing feature
- Add a new feature

# Report issue 
In case you want to contribute, you can do so by reporting a new issue from [here](https://github.com/mmaximo33/EFDE/issues/new/choose)

to begin following up on the request.

# Prepare development environment
To prepare the EFDE development environment, see the following steps according to the corresponding role.

## Collaborators

```sh
# Prepare environment
mkdir -p ~/Domains
cd $_
git clone https://github.com/mmaximo33/EFDE.git efdev
cd $_
ln -sfT $PWD/bin/efde.sh ~/bin/efdev 
# Check the installation by running 'efdev' in your console

# Begin to work
git switch develop
git pull origin master
git checkout -b <issue-new-feature> # example 31-description-of-new-feature
git add <files>
git commit -m "feat(core): feature description" # See [agents/git/SKILL.md](../agents/git/SKILL.md) for the EFDE commit convention

# Confirm that it is up to date with other updates
git rebase origin/develop
# Verify that there are no conflicts
git status
# If there are, resolve them, add the changes and commit.
# git add <files>
# git commit -m "fix(core): resolved conflicts"
# git rebase --continue

# Upload your changes
git push origin <issue-new-feature> --force-with-lease
```

### Settings

#### For full developer

To enable debug and developer features (regenerate `.tmp`, see module/shortcuts/i18n/config/menu flow), edit `bin/cfg.core` and see **[debug-workflow.md](debug-workflow.md)** for full documentation (configuration, what each flag does, and reference images).

### Rules for developer
If you want to add a new feature you must keep the following rules in mind
- Define type
  - **Service**: (docker, mysql, phpmyadmin, mailhog, others)
  - **Implementation**: frameworks, cms, others (symfony, laravel, magento, wordpress, prestashop, others)
- Inside `console/implementation` or `console/service`, create a directory named after your new implementation or service (example: `myserv`)
  - In `console/service/myserv`
  - Create the directories
    - `./tasks`
      - Create your files, the methods here must start with `_mod_.FUNCTION_NAME`
      - You can call other methods as appropriate to your location `common.tasks.menu.FUNCTION_NAME`
    - `./props`
      - Create your files, the properties here must start with `_mod_PROPERTY_NAME`
        - **Important**: It does not have the point in the middle like the methods `_mod_.` vs `_mod_` 

### Shortcuts
If you want to add shortcuts to your new deployment, just add the file in `console/service/myserv/props/shortcuts`
The file must contain the following format, where each column represents a piece of data.

> [!CAUTION]
> DO NOT CHANGE VARIABLE NAME `_mod_ITEMS`
 
```bash
#!/usr/bin/env bash
{
  _mod_ITEMS=(
    "shortcut,                  path.of.a.function,                   Description"          
    "myserv:test,               myserv.tasks.file.function,           This is a shortcut test"
  )
}
```

### Translations
- Translations must be incorporated into each implementation and service with the **i18n** directory.
- Languages: **en_US** (default), **es_ES**, **fr_FR**, **pt_BR**, **de_DE** (códigos con guión bajo: idioma_PAÍS).
- Format: one file per locale with extension `.csv` (e.g. `es_ES.csv`, `pt_BR.csv`) in `console/<module>/i18n/`. Each line has two quoted fields: `"text_in_english","translated_text"`. The first field must match the string in the code exactly (including variables like `$DIR_PATH`, `$FILE_PATH`). Commas and quotes inside a field are supported (use `""` for a literal quote).
- Full documentation: [i18n.md](i18n.md) (format, parsing, when applied, adding strings, debugging).

### Boot sequence | Workflow

EFDE boots in two stages: first `bin/efde.sh` loads the config files into memory, then `console/init` runs three explicit phases.

#### Configuration (in `bin/efde.sh`, before `console/init`)
- `bin/efde.sh` reads `bin/cfg.core` (DEBUG, UPDATE_CHECK_*) and `bin/cfg.host` (HOST_*) into associative arrays. This happens **before** `console/init` is sourced, so `console/init` and `console/init_essential` can already read those values. See [debug-workflow.md](debug-workflow.md) for the DEBUG flags.

#### Phases (in `console/init`, after config is loaded)
- **Phase 1 — Essentials:** `console/init` sources `common/core` (stub delegating to `init_essential`) and then `console/init_essential`; the latter holds the bootstrap logic (check, load, message) used by the core. See refactor [#49](https://github.com/mmaximo33/EFDE/issues/49).
- **Phase 2 — Modules:** `console/init.load_modules` walks `console/` recursively and sources every module (efde, implementation/*, service/*) except `common/` (which is already loaded).
- **Phase 3 — Generate + Updates:** `common.core.generate_extra_elements` merges all per-module shortcuts into `bin/.tmp/common.props.shortcuts` and applies i18n translations when `HOST_I18N != I18N_DEFAULT`; `common.tasks.config.updates_availables` checks for upstream updates.

#### Menu flow (entry, history, return)
- Full documentation: [menu-flow.md](menu-flow.md) (entry point, which menu is shown, `common.tasks.menu.show`, choice_options, [R]eturn/[Q]uit/[I]nfo, history, and how actions return to menu).

#### Docker and project directory
- The **Docker** service assumes an **EFDE project** = a directory that contains `docker-compose.yml` and/or `.efde`. It resolves the project root by walking up from the current working directory until it finds one of these markers.
- **Implementations** (Laravel, Symfony, WordPress): during install, the process changes to the project root (`cd` to the new project) before calling Docker; the same detection then finds that directory.
- The **Docker menu** (Build, Start, Logs, etc.) can be used from the project root or from any subdirectory of the project; if no project is detected, a clear error is shown. The same applies to **MySQL** when it runs commands via Docker.

#### Details
Taking into account the installation carried out previously.

- When executing in global symbolic link `~/bin/efdev -> ~/Domains/bin/efde.sh`
- Is loaded `console/init`
  - By default change the CORE `console/common/core` in `bin/.tmp/common.core` **(to work on the transformation)**
  - It loops through all the directories within `./console` recursively until it finds a folder called `tasks`
  - At that moment the transformation of the files found in that implementation or service begins `./console/.../wordpress/{tasks | props}`
    - Renaming methods and variables according to the rules mentioned before
      - Files: multiple files from
        - `console/efde/tasks/menu` to `bin/.tmp/efde.tasks.menu`
        - `console/efde/props/menu` to `bin/.tmp/efde.props.menu`
      - Methods: from `_mod_.main` to `efde.tasks.menu.main`
      - Variables: from `_mod_MAIN` to `efde_prop_menu_MAIN`
  - Generate the shortcuts
    - Finds all files in `../props/shortcuts` locations and merges them into `~/Domains/bin/.tmp/common.props.shortcuts` to improve speed on future runs
  - Apply translations
    - Translations apply only if the language set in `bin/cfg.host` (variable `HOST_I18N`) is different from the default in `bin/cfg.core` (`I18N_DEFAULT`). With `DEBUG=true` and `DEBUG_I18N="true"`, I18N steps are shown. See [debug-workflow.md](debug-workflow.md); [i18n.md](i18n.md) for format and flow.
    - The system parses each module's `i18n/<locale>` file (CSV format), escapes strings for `sed`, and replaces origin strings with translations in the generated files under `bin/.tmp`; when done it restarts EFDE. 


- Determines whether the launch directory in the `efdev` command console has a project created by it or not (search for `$PATH_PROJECT/.efde/`)
  - Is TRUE, loads the implementation menu according to what is established in the `$PATH_PROJECT/.efde/.env` file variable `EFDE_PROJECT_IMPLEMENTATION`
  - Is FALSE, load the default menu to configure `efdev` or install implementations

## Admin
### To Develop
```sh
git switch develop
git fetch origin <issue-new-feature>
git merge <issue-new-feature>

# Remember to update the docs CHANGELOG.md, README.md 
git add CHANGELOG.md 
git commit -m "fix(docs): update changelog"

git push origin develop --force-with-lease
```

### To Main (Release)
```sh
# See https://semver.org/
git fetch --tags

git tag -a <major.minor.patch> -m "<major.minor.patch> comments" 
# git tag -a 1.0.0 -m "1.0.0 comments" 

git push origin <major.minor.patch>

# Create new pull request in github
```