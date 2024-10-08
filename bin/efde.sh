#!/usr/bin/env bash
set -euo pipefail

declare -gA EFDE_CORE_CONFIG=(
  [I18N_DEFAULT]="en_US"
  [FILE_CONFIG]="config.env"
)

declare -gA EFDE_CORE_PATH=(['INSTALL']="", [CONSOLE]="", [BIN]="", [TMP]="", [FILE_CONFIG]="")

declare -gA GLOBAL_EFDE_CONFIG=() # Sets in config.env

efdeinit.resolve_absolute_dir() {
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

efdeinit.init_dirs()
{
  EFDE_PATH_INSTALL="$(efdeinit.resolve_absolute_dir)"
  EFDE_CORE_PATH['INSTALL']="$EFDE_PATH_INSTALL"
  EFDE_CORE_PATH['BIN']="${EFDE_PATH_INSTALL}/bin"
  EFDE_CORE_PATH['TMP']="${EFDE_PATH_INSTALL}/bin/.tmp"
  EFDE_CORE_PATH['CONSOLE']="${EFDE_PATH_INSTALL}/console"
  EFDE_CORE_PATH['FILE_CONFIG']="${EFDE_PATH_INSTALL}/bin/${EFDE_CORE_CONFIG['FILE_CONFIG']}"

  efdeinit.init_configs
  source "${EFDE_CORE_PATH['CONSOLE']}/init"
}

efdeinit.init_configs() {
  local config_file="${EFDE_CORE_PATH['FILE_CONFIG']}"
  local variables=("EFDE_MODE_DEBUG" "EFDE_MODE_DEBUG_MODULE" "EFDE_MODE_DEBUG_CONFIG" "EFDE_MODE_DEBUG_SHORTCUTS" "EFDE_MODE_DEBUG_I18N" "EFDE_MODE_DEBUG_MENU")

  if [[ ! -f "$config_file" ]]; then
    for key in "${variables[@]}"; do
      GLOBAL_EFDE_CONFIG["$key"]="false"
    done
  else
    for key in "${variables[@]}"; do
      local value="$(grep -E "^${key}=" "$config_file" | cut -d'=' -f2 | sed 's/^"//;s/"$//')"
      GLOBAL_EFDE_CONFIG["$key"]="${value:-false}"
    done
  fi
}

efdeinit.menu_implementation(){
  local PATH_ENV=$(efde.tasks.implemention.get_current_path_env_file)
  local IMPLEMENTION=$(common.tasks.env_variable.get_variable "EFDE_PROJECT_IMPLEMENTION" "$PATH_ENV")

  RUN_FUNCTION_IMPLEMENTATION_MAIN="$IMPLEMENTION.tasks.menu.main"
  if  common.tasks.module.exists_function "${RUN_FUNCTION_IMPLEMENTATION_MAIN}"; then
    ${RUN_FUNCTION_IMPLEMENTATION_MAIN}
  fi
}

efdeinit.menu(){
  efde.tasks.implemention.has_folder_implementation && \
  efdeinit.menu_implementation || efde.tasks.menu.main
}

efdeinit.shortcuts(){
  common.tasks.shortcuts.target "$@"
}

efdeinit.main() {
  efdeinit.init_dirs # IMPORTANT
  [ $# -gt 0 ] && efdeinit.shortcuts "$@" || efdeinit.menu
}

efdeinit.main "$@"
