#!/usr/bin/env bash
set -euo pipefail
# Debug mode
EFDE_MOD_DEBUG=false # Messages debug
EFDE_MOD_DEV=true # Create tmps

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
    export DOCKERGENTO_DIR="${ABSOLUTE_PATH}"

    export PATH_CONSOLE="${EFDE_PATH_INSTALL}/console/"
    export PATH_BIN="${EFDE_PATH_INSTALL}/bin/"

#    export COMMANDS_DIR="${ABSOLUTE_PATH}/console/commands"
#    export TASKS_DIR="${ABSOLUTE_PATH}/console/tasks"
#    export PROPERTIES_DIR="${EFDE_PATH_INSTALL}/console/common/properties"
}

init_dirs
source "$PATH_CONSOLE/init"



main(){
  if efde.tasks.implemention.has_folder_implementation ; then
    #ES SYMFONY CARGA MENU
    echo "symfony"
  else
    menu_init
  fi
}

menu_init(){

#IFS=',' read -ra elements <<< "${ALL_MENUS["MENU_INIT"]}"
#
#for element in "${elements[@]}"; do
#  echo "$element"
#done
    #common.tasks.menu.print_menu "Select an option:" "${ALL_MENUS["MENU_INIT"][@]}"
    common.tasks.menu.print_menu "Select an option:" "${MENU_INIT[@]}"
    RESPONSE_CODE=${MENU_RESPONSE_ARRAY_ASOCITIVE['code']}
    RESPONSE_TITLE=${MENU_RESPONSE_ARRAY_ASOCITIVE['title']}

    efde.tasks.implemention.setup_environment $RESPONSE_CODE
    exit;
    if common.tasks.module.exists_function "$RESPONSE_CODE.tasks.install.environment" ;then
      efde.tasks.implemention.setup_environment $RESPONSE_CODE
    else
      common.tasks.message.danger "The installation of the selected environment is not yet available '$RESPONSE_TITLE'"

      common.tasks.prompt.confirm_default_yes "Back to menu?" && menu_init
    fi
}

main



