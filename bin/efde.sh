#!/usr/bin/env bash
set -euo pipefail

declare -gA EFDE_CORE_CONFIG=(
  [PROJECT_NAME]="efde"
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

# Portable resolution of install root (parent of bin/). Works on Linux, macOS, WSL, Git Bash/Cygwin.
efdeinit.resolve_absolute_dir() {
  local script_path="$0"
  local script_dir
  # If $0 has no path (e.g. "efde" from PATH), resolve via command -v
  [[ "$script_path" != */* ]] && script_path="$(command -v "$0" 2>/dev/null)" || true
  [[ -z "$script_path" ]] && script_path="$0"
  # Make absolute if relative
  [[ "$script_path" != /* ]] && script_path="$(pwd)/$script_path"
  # Follow symlinks (readlink without -f is portable; loop handles multiple levels)
  while [ -L "$script_path" ]; do
    script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    script_path="$(readlink "$script_path")"
    [[ "$script_path" != /* ]] && script_path="$script_dir/$script_path"
  done
  script_dir="$(cd "$(dirname "$script_path")" && pwd)"
  # Script lives in INSTALL/bin/efde.sh -> install root is parent of script_dir
  echo "$(cd "$script_dir/.." && pwd)"
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
  local PATH_ENV=$(efde.tasks.implementation.get_current_path_env_file)
  local IMPLEMENTATION=$(common.tasks.env_variable.get_variable "EFDE_PROJECT_IMPLEMENTATION" "$PATH_ENV")

  RUN_FUNCTION_IMPLEMENTATION_MAIN="$IMPLEMENTATION.tasks.menu.main"
  if  common.tasks.module.exists_function "${RUN_FUNCTION_IMPLEMENTATION_MAIN}"; then
    ${RUN_FUNCTION_IMPLEMENTATION_MAIN}
  fi
}

efdeinit.menu(){
  efde.tasks.implementation.has_folder_implementation && \
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
