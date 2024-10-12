#!/usr/bin/env bash
set -euo pipefail

declare -gA EFDE_CORE_CONFIG=(
  [REPOSITORY]="https://github.com/mmaximo33/EFDE"
  [I18N_DEFAULT]="en_US"
  [FILE_CONFIG_HOST]="cfg.host"
  [FILE_CONFIG_CORE]="cfg.core"
  [UPDATE_AVAILABLE]="false"
)

declare -gA EFDE_CORE_PATH=(['INSTALL']="", [CONSOLE]="", [BIN]="", [TMP]="", [FILE_CONFIG_HOST]="", [FILE_CONFIG_CORE]="")

declare -gA EFDE_CONFIG_CORE=(
  [KEYS_REQUIRED]="DEBUG DEBUG_MODULE DEBUG_CONFIG DEBUG_SHORTCUTS DEBUG_I18N DEBUG_MENU"
  [KEYS_OPTIONAL]="UPDATE_CHECK UPDATE_CHECK_LAST UPDATE_CHECK_AVAILABLE"
) # Sets in cfg.core

declare -gA EFDE_CONFIG_HOST=(
  [KEYS_REQUIRED]="HOST_SO HOST_I18N HOST_EDITOR_DEFAULT HOST_CLI_MODE"
  [KEYS_OPTIONAL]=""
) # Sets in cfg.core

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
  EFDE_CORE_PATH['FILE_CONFIG_HOST']="${EFDE_CORE_PATH['BIN']}/${EFDE_CORE_CONFIG['FILE_CONFIG_HOST']}"
  EFDE_CORE_PATH['FILE_CONFIG_CORE']="${EFDE_CORE_PATH['BIN']}/${EFDE_CORE_CONFIG['FILE_CONFIG_CORE']}"

  efdeinit.init_configs
  source "${EFDE_CORE_PATH['CONSOLE']}/init"
}

efdeinit.init_configs() {
  local config_file="${EFDE_CORE_PATH['FILE_CONFIG_CORE']}"
  local REQUIRED_KEYS=()
  eval "read -a REQUIRED_KEYS <<< \"\${EFDE_CONFIG_CORE['KEYS_REQUIRED']}\""
  if [[ ! -f "$config_file" ]]; then
    for key in "${REQUIRED_KEYS[@]}"; do
      EFDE_CONFIG_CORE[$key]="false"
    done
  else
    for key in "${REQUIRED_KEYS[@]}"; do
      local value="$(grep -E "^${key}=" "$config_file" | cut -d'=' -f2 | sed 's/^"//;s/"$//')"
      EFDE_CONFIG_CORE[$key]="${value:-false}"
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
