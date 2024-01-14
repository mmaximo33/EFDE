#!/usr/bin/env bash
set -euo pipefail
# Debug mode
EFDE_MOD_DEBUG=false # Messages debug
EFDE_MOD_DEV=false # MMTodo: Prepared for create tmps
declare -gA GLOBAL_EFDE_CONFIG


GLOBAL_RUN_EFDE=$([ "$EFDE_MOD_DEV" = "true" ] && echo "e2" || echo "efde")

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
}

init_dirs
source "$PATH_CONSOLE/init"

menu_main(){
  common.tasks.menu.print_menu "Select an option:" "${efde_props_menu_MAIN[@]}"
}

menu_implementation(){
  local PATH_ENV=$(efde.tasks.implemention.get_current_path_env_file)
  local IMPLEMENTION=$(common.tasks.env_variable.get_variable "EFDE_PROJECT_IMPLEMENTION" "$PATH_ENV")


  RUN_FUNCTION_IMPLEMENTATION_MAIN="$IMPLEMENTION.tasks.menu.main"
  if  common.tasks.module.exists_function "${RUN_FUNCTION_IMPLEMENTATION_MAIN}"; then
    ${RUN_FUNCTION_IMPLEMENTATION_MAIN}
  fi
#  else
#    ${GLOBAL_RUN_EFDE}
#  fi
}

main(){
  efde.tasks.config.check_config
  if ! efde.tasks.implemention.has_folder_implementation ; then
    efde.tasks.menu.main
  fi
  menu_implementation
}

main

