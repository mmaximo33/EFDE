# EFDE | Easy and fast development environment

## Index
- [EFDE CONFIG](#efde-config)
  - [Global](#global-config)
  - [For project](#project-config)
- [Basic Use](#basic-use)

## Efde config
Distributing configurations for local deployments between different team members is easy with **EFDE**

### Global config
The global **EFDE** configurations can be found in this file `bin/config.env`

```bash
# Core
EFDE_CORE_LAST_UPDATE="2024-10-07"
EFDE_CORE_VERSION="2.2.0"

# Host
HOST_EDITOR_DEFAULT="nvim"
HOST_I18N="en_US"
HOST_SO="Linux"
 
HOST_CLI_MODE="default"

```

#### HOST_CLI_MODE

| MODE         | CLI_SHOW_CLI            | CLI_SHOW_OUTPUT           |
|--------------|-------------------------|---------------------------|
| **Default**  | n/a                     | n/a                       |
| **Training** | True                    | False                     |
| **Auditor**  | True                    | True                      |
| **Silent**   | False                   | False                     |


### Project config
Configurations for implementations installed with **EFDE** are located in

```sh
cd  <project>     # Project folder

cat .efde/.env    # Variable file  
ls -la .env       # Symbolic link for docker recipe
```

## Basic Use 
Below we show you some of the characteristics that all implementations have. 
This may vary depending on the framework, language or technology, adjusting to the needs of each type of project.

![efde symfony use](../console/implemention/symfony/docs/media/use.gif)

## Custom Shortcuts
You can add custom shortcuts per project.

Since version 2.2.1 you can find example data in the following directory

`project/.efde/shortcuts/`
- List: In this list you can add your custom commands
  - First term, it is the alias for the shortcuts, where the prefix `custom:` is added
  - Second term, the location of the bash file to execute
  - Third term, the description for your custom shortcut
- Files Bash: Inside the shortcuts directory, you can add bash files with your custom scripts or create subfolders if necessary

> [!TIP]  
> These shortcuts are NOT global, they are available in the directory where EFDE is executed. You can use it in your projects or the project container directory (Example: ~/Domains)

![efde_shortcuts_custom.png](./media/efde_shortcuts_custom.png)