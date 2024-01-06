#!/usr/bin/env bash
set -euo pipefail
# Debug mode
EFDE_MOD_DEBUG=false # Messages debug
EFDE_MOD_DEV=true # MMTodo: Prepared for create tmps
EFDE_CFG_SHOW_CLI=true #show COMMANDLINE
declare -gA GLOBAL_EFDE_CONFIG=(
  [CLI_SHOW_DEFAULT]=true   # Omite configuraciones personalizadas
  [CLI_SHOW_CLI]=true        #
  [CLI_SHOW_OUTPUT]=false
)


GLOBAL_RUN_EFDE=$([ "$EFDE_MOD_DEBUG" = "true" ] && echo "e2" || echo "efde")

[[ $(echo "$@" | grep -oP '(?<=--debug=)[^ ]+') = "true" && "$EFDE_MOD_DEBUG" = "false" ]] && EFDE_MOD_DEBUG=true

resolve_absolute_dir()
{
    SOURCE="${BASH_SOURCE[0]}"

    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname ${SOURCE} )" && pwd )"
      SOURCE="$(readlink ${SOURCE})"
      [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done

    ABSOLUTE_BIN_PATH="$( cd -P "$( dirname ${SOURCE} )" && pwd )"
    ABSOLUTE_PATH="${ABSOLUTE_BIN_PATH}/.."
    EFDE_PATH_INSTALL="$(dirname $ABSOLUTE_BIN_PATH)"
}

init_dirs()
{
    resolve_absolute_dir
    export PATH_CONSOLE="${EFDE_PATH_INSTALL}/console"
    export PATH_BIN="${EFDE_PATH_INSTALL}/bin"

#    export COMMANDS_DIR="${ABSOLUTE_PATH}/console/commands"
#    export TASKS_DIR="${ABSOLUTE_PATH}/console/tasks"
#    export PROPERTIES_DIR="${EFDE_PATH_INSTALL}/console/common/properties"
}

init_dirs
source "$PATH_CONSOLE/init"

menu_main(){
  common.tasks.menu.print_menu "Select an option:" "${efde_props_menu_MAIN[@]}"
}

menu_implementation(){
  local PATH_ENV=$(efde.tasks.implemention.get_current_path_env_file)
  variables_string="$(efde.tasks.config.load_variables_from_file ${PATH_ENV})"
  # Evaluar la cadena de variables
  eval "$variables_string"
  RUN_FUNCTION_IMPLEMENTATION_MAIN= "$IMPLEMENTION.tasks.menu.main"

  ${RUN_FUNCTION_IMPLEMENTATION_MAIN}
}

main(){
  if ! efde.tasks.implemention.has_folder_implementation ; then
    menu_main
  fi
  menu_implementation
}

main

