#!/usr/bin/env bash
set -euo pipefail

declare -gA GLOBAL_EFDE_CONFIG=(
  [LANGUAGE_DEFAULT]="en_US"
  [EFDE_MODE_DEBUG]=false          # Debug Messages
  [EFDE_MODE_DEVELOP]=false        # MMTodo: Prepared for create tmps
)

resolve_absolute_dir() {
  local ABSOLUTE_BIN_PATH
  case "$OSTYPE" in
    linux-gnu) #Linux
      ABSOLUTE_BIN_PATH=$(dirname $(dirname "$(readlink -f "$0")"))
      ;;
    darwin*)      os="macOS"                                                    ;;
    cygwin|msys)  os="Windows"                                                  ;;
    *)            os="Undefined"                                                ;;
  esac

  echo "${ABSOLUTE_BIN_PATH}"
}

init_dirs()
{
    EFDE_PATH_INSTALL="$(resolve_absolute_dir)"
    export PATH_CONSOLE="${EFDE_PATH_INSTALL}/console"
    export PATH_BIN="${EFDE_PATH_INSTALL}/bin"
    source "$PATH_CONSOLE/init"
}

menu_implementation(){
  local PATH_ENV=$(efde.tasks.implemention.get_current_path_env_file)
  local IMPLEMENTION=$(common.tasks.env_variable.get_variable "EFDE_PROJECT_IMPLEMENTION" "$PATH_ENV")

  RUN_FUNCTION_IMPLEMENTATION_MAIN="$IMPLEMENTION.tasks.menu.main"
  if  common.tasks.module.exists_function "${RUN_FUNCTION_IMPLEMENTATION_MAIN}"; then
    ${RUN_FUNCTION_IMPLEMENTATION_MAIN}
  fi
}

generate_extra_elements(){
  efde.tasks.config.check_config

  if [ "${GLOBAL_EFDE_CONFIG['EFDE_MODE_DEBUG']}" = "true" ]; then
    if [ ${GLOBAL_EFDE_CONFIG['LANGUAGE_DEFAULT']} != "$(efde.tasks.config.get_var "EFDE_LANGUAGE")" ]; then
      common.core.generate_translation
    fi
  fi
}

menu(){
  if ! efde.tasks.implemention.has_folder_implementation ; then
    efde.tasks.menu.main
  fi

  menu_implementation
}

shortcuts(){
  common.tasks.shortcuts.target "$@"
}

main() {
  init_dirs # IMPORTANT
  generate_extra_elements
  if [ $# -gt 0 ]; then
    shortcuts "$@"
  else
    menu
  fi
}

main "$@"
