# EFDE | Easy and fast development environment
In this small guide you will find all the necessary elements if you want to start collaborating on the project.

Here are mentioned the variables and workflow that must be considered when
- Fix a bug
- Improve an existing feature
- Add a new feature

## Report issue 
In case you want to contribute, you can do so by reporting a new issue from [here](https://github.com/mmaximo33/EFDE/issues/new/choose)

to begin following up on the request.

## Configurations
**EFDE** has its own configurations which it uses in each new execution

These configurations are established on the first run and are stored in the file `bin/config.env`

### All Settings
```sh
HOST_SO="Linux | windows | macOS"
HOST_EDITOR="nano | vim | nvim"

EFDE_LAST_UPDATE="2024-01-20"
EFDE_LANGUAGE="en_US"
EFDE_VERSION="2.0.0"

CLI_DEFAULT="false"                    
CLI_SHOW_CLI="true"
CLI_SHOW_OUTPUT="true"

# Only Developer 
EFDE_MODE_DEBUG=false                  # Messages debug
EFDE_MODE_DEVELOPER=false              # Transformation multifiles
```

### Command line Settings

|              | CLI_DEFAULT                     | CLI_SHOW_CLI            | CLI_SHOW_OUTPUT           |
|--------------|---------------------------------|-------------------------|---------------------------|
| **Mode**     | Established by implementation   | Command executed        | Command output            |
| **Default**  | True                            | n/a                     | n/a                       |
| **Training** | False                           | True                    | False                     |
| **Auditor**  | False                           | True                    | True                      |
| **Silent**   | False                           | False                   | False                     |

### EFDE Modes Settings (for EFDE collaborators)

| EFDE_MODE_DEBUG                                    | EFDE_MODE_DEVELOP                                                                | 
|----------------------------------------------------|----------------------------------------------------------------------------------|
| Shows additional information for debugging actions | On each run, clean the `bin/.tmp` directory and transform the files individually | 
| ![Efde mode debug](./media/efde_mode_debug.png)    | ![Efde mode debug](./media/efde_mode_developer.png)                              |  


## Rules 
If you want to add a new feature you must keep the following rules in mind
- Define type
  - Service: (docker, mysql, phpmyadmin, mailhog, others)
  - Implementation: frameworks, cms, others (symfony, laravel, magento, woordpress, prestashop, others)
- Inside `console/{Implemention | Service}` creates the directory with your name (example: `wordpress`)
  - In `console/implemention/wordpress`
  - Add the init file to the root of the directory `./init`, 
  - Create the directories
    - `./tasks`
      - Create your bash files, the methods here must start with `_mod_.FUNCTION_NAME`
      - You can call other methods as appropriate to your location `common.tasks.menu.FUNCTION_NAME`
    - `./props`
      - Create your bash files, the properties here must start with `_mod_PROPERTY_NAME`
        - **Important**: It does not have the point in the middle like the methods `_mod_.` vs `_mod_` 

## Workflow
- When executing in glogal symbolic link `~/bin/efde -> ~/.efde/bin/efde`
- Is loaded `console/init`
  - By default change the CORE `console/common/core` in `bin/.tmp/core` (to work on the transformation)
  - Loops through all directories recursively on console looking for the initiator file `$path/init`
  - Transform the files found from that implementation or service (for the tasks or props directories) 
    - `EFDE_MODE_DEVELOP=true`, rename files, methods and variables in a `bin/.temp/{files}` directory
      - Files: multiple files from `console/efde/tasks/menu` to `bin/.tmp/efde.tasks.menu`
      - Methods: from `_mod_.main` to `efde.tasks.menu.main`
      - Variables: from `_mod_MAIN` to `efde_prop_menu_MAIN`
    - `EFDE_MODE_DEVELOP=false`, change the name of methods and variables in `bin/.temp/transformation` (File with all the code)
      - File: single file
-  Determines whether the launch directory in the `efde` command console has a project created by it or not (search for `$PATH/.efde/`)
   - Is TRUE, loads the implementation menu according to what is established in the `$PATH/.efde/.env` file variable `EFDE_PROJECT_IMPLEMENTION`
   - Is FALSE, load the default menu to configure `efde` or install implementations

##