#!/usr/bin/env bash
#
# EFDE             : Easy and fast development environment
# Author           : Marucci Maximo (https://mmaximo33.github.io/cv/)
# GitHub           : https://github.com/mmaximo33/efde
# GitLab           : https://gitlab.com/dockerizations/efde
# Description:
#   This script is in charge of carrying out the installation
# ToDo:
#   Review instalation processo for ZSH

{ # this ensures the entire script is downloaded #

  #######################################################################
  # INIT section
  #----------------------------------------------------------------------
  declare -gA INSTALL=(
    ['PROJECT_NAME']="EFDE"
    ['GIT_USER']="mmaximo33"
    ['GIT_BRANCH']="main"
  )

  efde_sets_variables(){
    INSTALL['PROJECT_FOLDER']="${INSTALL['PROJECT_NAME'],,}"
    INSTALL['GIT_REPOSITORY']="${INSTALL['PROJECT_NAME'],,}"
    INSTALL['GIT_URL_REPOSITORY']="https://github.com/${INSTALL['GIT_USER']}/${INSTALL['GIT_REPOSITORY']}"
    INSTALL['PROJECT_LAST_VERSION']="$(efde_latest_version)"
  }

  efde_echo() {
    # shellcheck disable=SC2068
    local MSG="$(efde_msg "$@")"
    command printf "$MSG\n"  2>/dev/null
  }

  efde_msg(){
    local MSG
    local RESET="\033[0m"
    case $1 in
      success)  shift;  MSG="\033[1;32m$@$RESET";;
      info)     shift;  MSG="\033[1;36m$@$RESET";;
      warning)  shift;  MSG="\033[1;33m$@$RESET";;
      danger)   shift;  MSG="\033[1;31m$@$RESET";;
      debug)    shift;  MSG="\033[1;35m$@$RESET";;
      *)                MSG="$@";;
    esac

    echo "$MSG"
  }

  efde_tree(){
    local line prefix=""
    local level="${2:-0}"
    local end="${3:-0}"
    local mode="${4:-}"

    if [ "$level" -eq 1 ]; then
      prefix+="├──"
    fi
    if [ "$level" -gt 1 ]; then
      for ((i=1; i<level; i++)); do
        prefix+="│   "
      done
      if [ "$end" -eq 0 ]; then
        prefix+="├──"
      else
        prefix+="└──"
      fi
    fi

    local LINE="$prefix $1"
    command printf "$LINE\n" 2>/dev/null
  }


  if [ -z "${BASH_VERSION}" ] || [ -n "${ZSH_VERSION}" ]; then
    # shellcheck disable=SC2016
    efde_echo danger '[ERROR] The install instructions explicitly say to pipe the install script to `bash`; please follow them'
    exit 1
  fi

  #######################################################################
  # Dialog section
  #----------------------------------------------------------------------

  # Read a single char from /dev/tty, prompting with "$*"
  # Note: pressing enter will return a null string. Perhaps a version terminated with X and then remove it in caller?
  # See https://unix.stackexchange.com/a/367880/143394 for dealing with multi-byte, etc.
  efde_get_keypress() {
    local REPLY IFS=
    printf >/dev/tty '%s' "$*"
    [[ $ZSH_VERSION ]] && read -rk1 # Use -u0 to read from STDIN
    # See https://unix.stackexchange.com/q/383197/143394 regarding '\n' -> ''
    [[ $BASH_VERSION ]] && read </dev/tty -rn1
    printf '%s' "$REPLY"
  }

  # Get a y/n from the user, return yes=0, no=1 enter=$2
  # Prompt using $1.
  # If set, return $2 on pressing enter, useful for cancel or defualting
  efde_get_yes_keypress() {
    local prompt="$(efde_echo warning "${1:-Are you sure [y/n]? }")"
    local enter_return=$2
    local REPLY
    # [[ ! $prompt ]] && prompt="[y/n]? "
    while REPLY=$(efde_get_keypress "$prompt"); do
      [[ $REPLY ]] && printf '\n' # $REPLY blank if user presses enter
      case "$REPLY" in
      Y | y) return 0 ;;
      N | n) return 1 ;;
      '') [[ $enter_return ]] && return "$enter_return" ;;
      esac
    done
  }

  # Credit: http://unix.stackexchange.com/a/14444/143394
  # Prompt to confirm, defaulting to NO on <enter>
  # Usage: efde_confirm_default_no "Dangerous. Are you sure? [y/N]" && rm *
  efde_confirm_default_no() {
    local prompt="${*:-Are you sure} [y/N]? "
    efde_get_yes_keypress "$prompt" 1
  }

  efde_confirm_default_yes() {
    local prompt="${*:-Are you sure} [Y/n]? "
    efde_get_yes_keypress "$prompt" 0
  }

  efde_input_response() {
    read -p "$1 " RESPONSE
    echo $RESPONSE
  }

  # MMToDo: Review install for version
  efde_latest_version() {
    echo $(curl -s "https://api.github.com/repos/${INSTALL['GIT_USER']}/${INSTALL['GIT_REPOSITORY']}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
  }

  #######################################################################
  # Requiriments section
  #----------------------------------------------------------------------
  efde_has() {
    local command_to_check="$1"
    if [ "$command_to_check" == "docker-compose" ]; then
      local command_result=$(type "$command_to_check" 2>/dev/null)
      [ $? -eq 0 ] && type "$command_to_check" >/dev/null 2>&1 || type "compose" >/dev/null 2>&1
    else
      type "$command_to_check" >/dev/null 2>&1
    fi
  }

  efde_check_environment() {
    # MMTodo: Review code check
    if [ -n "${EFDE_DIR-}" ] && ! [ -d "${EFDE_DIR}" ]; then
      if [ -e "${EFDE_DIR}" ]; then
        efde_echo warning "File \"${EFDE_DIR}\" has the same name as installation directory."
        exit 1
      fi

      if [ "${EFDE_DIR}" = "$(efde_default_install_dir)" ]; then
        mkdir "${EFDE_DIR}"
      else
        efde_echo warning "You have \$EFDE_DIR set to \"${EFDE_DIR}\", but that directory does not exist. Check your profile files and environment."
        exit 1
      fi
    fi

    # Disable the optional which check, https://www.shellcheck.net/wiki/SC2230
    # shellcheck disable=SC2230
    if efde_has xcode-select && [ $(xcode-select -p >/dev/null 2>/dev/null; echo $?) = '2' ] && \
      [ "$(which git)" = '/usr/bin/git' ] && [ "$(which curl)" = '/usr/bin/curl' ]; then
      efde_echo warning 'You may be on a Mac, and need to install the Xcode Command Line Developer Tools.'
      # shellcheck disable=SC2016
      efde_echo warning 'If so, run `xcode-select --install` and try again. If not, please report this!'
      exit 1
    fi
  }

  efde_check_requirements() {
    efde_print_step requirements
    local errors=""

    check_and_install() {
      local tool_name="$1"
      local install_command="$2"
      local isend=$([[ -n ${3} ]] && echo 1 || echo 0)

      if ! efde_has "$tool_name"; then
        efde_tree "You must install ${tool_name^^} to use ${INSTALL['PROJECT_NAME']}" 3 $isend
        if efde_confirm_default_yes "Do you want to install ${tool_name^^} now?"; then
          $install_command || errors="$errors\n==> Failed to install ${tool_name^^}"
        else
          errors="$errors\n==> You need to have ${tool_name^^} installed"
        fi
      else
        efde_tree "$(efde_msg success "[OK]") Install ${tool_name^^}" 3 $isend
      fi
    }

    efde_tree "Check " 2 0
    check_and_install "git" "efde_install_git"
    check_and_install "docker" "efde_install_docker"
    check_and_install "docker-compose" "efde_install_docker_compose" true

    if [ -n "$errors" ]; then
      efde_tree "$(efde_msg danger "[ERROR]") The following problems were detected: " 2 1
      echo -e "$errors"
      exit 1
    fi
    efde_tree "$(efde_msg success "[DONE]") All Requirements verified" 2 1
  }

  efde_install_git() {
    sudo apt install -y git-all
  }

  efde_install_docker() {
    # https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # https://docs.docker.com/engine/install/ubuntu/#install-docker-engine
    sudo apt update -y
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # https://docs.docker.com/engine/install/linux-postinstall/
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R

    sudo systemctl restart docker
  }

  efde_install_docker_compose() {
    # https://docs.docker.com/compose/install/linux/
    sudo apt-get install docker-compose-plugin
  }

  #######################################################################
  # Installation section
  #----------------------------------------------------------------------
  efde_print_step() {
    case $1 in
    "requirements")
      efde_echo debug '
███████ ███████ ██████  ███████
██      ██      ██   ██ ██
█████   █████   ██   ██ █████
██      ██      ██   ██ ██
███████ ██      ██████  ███████

[E]asy and [F]ast [D]eveloper [E]nvironment
Install'
      efde_tree "Verifying requirements for ${INSTALL['PROJECT_NAME']}" 1 0
      ;;
    "install")
      efde_tree "Installing ${INSTALL['PROJECT_NAME']}" 1 0
      ;;
    "end")
      efde_tree "$(efde_msg success "Done install")" 1 1
      efde_tree "${INSTALL['PROJECT_NAME']} is successfully installed and configured." 2 0
      efde_tree "Select the directory and create your new project" 2 0
      efde_tree "By running '$(efde_msg debug "$ efde")'" 2 1
      ;;
    *)
      efde_echo danger "Error step"
    ;;
    esac
  }

  efde_source() {
    echo "https://github.com/${INSTALL['GIT_USER']}/${INSTALL['GIT_REPOSITORY']}"
  }

  efde_default_install_dir() {
    [ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.${INSTALL['PROJECT_FOLDER']}" || printf %s "${XDG_CONFIG_HOME}/${INSTALL['PROJECT_FOLDER']}"
  }

  efde_install_dir() {
    if [ -n "$EFDE_DIR" ]; then
      printf %s "${EFDE_DIR}"
    else
      efde_default_install_dir
    fi
  }

  efde_create_bin() {
    local INSTALL_DIR="$(efde_install_dir)"
    local INSTALL_DIR_FILE="$INSTALL_DIR/bin/${INSTALL['PROJECT_FOLDER']}.sh"
    local BIN_DIR="$HOME/bin"
    local BIN_FILE="$BIN_DIR/${INSTALL['PROJECT_FOLDER']}"

    efde_tree "Creating symbolic link" 2 0
    # PATCH_FROM_V1x_TO_V2x
    if [ -f "$BIN_FILE" ]; then
      efde_tree "Removing symbolic link previous versions" 3 0
      rm "$BIN_FILE" || {
        efde_tree "$(efde_msg danger "[ERROR]") Failed to remove existing $BIN_FILE" 3 1
        exit 1
      }
    fi

    mkdir -p $BIN_DIR
    efde_tree "In $BIN_FILE FROM $INSTALL_DIR_FILE" 3 0
    if ! ln -sfT "$INSTALL_DIR_FILE" "$BIN_FILE"; then
      efde_tree "$(efde_msg danger "[ERROR]") Cannot create symbolic link. Please report this!" 4 1
      exit 1
    fi

    efde_tree "$(efde_msg success "[DONE]")" 3 1
  }

  efde_do_install() {
    efde_print_step install
    efde_project_install_from_git
    efde_reset
  }

  efde_project_install_from_git() {
    local INSTALL_DIR="$(efde_install_dir)"

    if [ -d "$INSTALL_DIR/.git" ]; then
      efde_project_install_existing_folder
    elif [ -d "${INSTALL_DIR}" ] && [ "$(ls -A "${INSTALL_DIR}" 2>/dev/null)" ]; then
      efde_project_install_recovery_project
    else
      efde_project_install_clone_project
    fi

    efde_project_install_optimization
    efde_create_bin

    efde_print_step end
  }

  efde_project_install_existing_folder(){
    local INSTALL_DIR="$(efde_install_dir)"

    efde_tree "${INSTALL['PROJECT_NAME']} is already installed in $INSTALL_DIR" 2 0
    efde_tree "Checking for updates" 3 0
    if (command cd $INSTALL_DIR; git checkout main; git reset --hard origin/${INSTALL['GIT_BRANCH']}; git pull origin ${INSTALL['GIT_BRANCH']}) >/dev/null 2>&1; then
      efde_tree "$(efde_msg success "[SUCCESS]") Updated repository!" 4 1
      efde_print_step end
      exit 1
    else
      efde_tree "$(efde_msg danger "[ERROR]") Failed to updated ${INSTALL['PROJECT_NAME']} repo. Please report this!" 4 1
    fi
  }

  efde_project_install_recovery_project(){
    local INSTALL_DIR="$(efde_install_dir)"
    local BACKUP_DIR="${INSTALL_DIR}_bkp_install_$(date +'%Y%m%d%H%M%S')"

    efde_tree "$(efde_msg warning "[WARNING]") The $INSTALL_DIR directory exists without version control (.git)" 2 0
    if efde_confirm_default_no "Do you want to create a backup?" ;then
      efde_tree "Creating a backup" 2 0
      if mv "$INSTALL_DIR" "$BACKUP_DIR"; then
        efde_tree "$(efde_msg success "[SUCCESS]") Backup created in $BACKUP_DIR" 4 1
      else
        efde_tree "$(efde_msg danger "[ERROR]") Backup created in $BACKUP_DIR" 4 1
        exit 2
      fi
    else
      if rm -rf "$INSTALL_DIR"; then
        efde_tree "$(efde_msg success "[SUCCESS]") Remove directory $INSTALL_DIR" 4 1
      else
        efde_tree "$(efde_msg danger "[ERROR]") Remove directory $INSTALL_DIR" 4 1
      fi
    fi

    efde_project_install_clone_project
  }

  efde_project_install_clone_project(){
    local INSTALL_DIR="$(efde_install_dir)"

    efde_tree "Downloading ${INSTALL['PROJECT_NAME']} from git to $INSTALL_DIR" 2 0
    efde_tree "Cloning repository" 3 0

    mkdir -p "${INSTALL_DIR}"
    if command git clone --branch ${INSTALL['GIT_BRANCH']} "$(efde_source)" "$INSTALL_DIR" 2>/dev/null; then
      cd "$INSTALL_DIR"
      command git fetch origin develop 2>/dev/null
      if [[ ! "${INSTALL['GIT_BRANCH']}" == "main" ]]; then
        efde_tree "$(efde_msg debug "[DEBUG]") TESTING BRANCH $(git rev-parse --abbrev-ref HEAD 2>&1)" 4 1
      else
        command git checkout "tags/${INSTALL['PROJECT_LAST_VERSION']}" 2>/dev/null
        efde_tree "$(efde_msg success "[DONE]") Switch $(efde_msg debug "v${INSTALL['PROJECT_LAST_VERSION']}")" 4 1
      fi
    else
      efde_tree "$(efde_msg danger "[ERROR]") Failed to clone ${INSTALL['PROJECT_NAME']} repo. Please report this!" 4 1
      exit 2
    fi
  }

efde_project_install_optimization() {
    efde_tree "Repository optimization" 2 0
    local action cmd
    declare -A actions=(
      [Compression]="git --git-dir=\"$INSTALL_DIR\"/.git --work-tree=\"$INSTALL_DIR\" reflog expire --expire=now --all"
      [Cleaning]="git --git-dir=\"$INSTALL_DIR\"/.git --work-tree=\"$INSTALL_DIR\" gc --auto --aggressive --prune=now"
    )

    for action in "${!actions[@]}"; do
      cmd="${actions[$action]}"
      if eval "$cmd"; then
        efde_tree "$(efde_msg success "[SUCCESS]") $action" 3 0
      else
        efde_tree "$(efde_msg warning "[ERROR]") $action: Your version of git is out of date. Please update it!" 3 0
      fi
    done

    efde_tree "$(efde_msg success "[DONE]")" 3 1
}

  #######################################################################
  # Clear section
  #
  # Unsets the various functions defined
  # during the execution of the install script
  #----------------------------------------------------------------------
  efde_reset() {
    unset -f efde_echo efde_msg efde_tree efde_sets_variables \
      efde_get_keypress efde_get_yes_keypress efde_confirm_default_no efde_confirm_default_yes \
      efde_input_response efde_latest_version \
      efde_has efde_check_environment efde_check_requirements \
      efde_install_git efde_install_docker efde_install_docker_compose \
      efde_source efde_default_install_dir efde_install_dir efde_create_bin efde_print_step \
      efde_do_install efde_project_install_from_git \
      efde_project_install_existing_folder efde_project_install_recovery_project efde_project_install_clone_project \
      efde_project_install_optimization efde_reset
  }

  #######################################################################
  # Main section
  #----------------------------------------------------------------------
  main() {
    efde_sets_variables
    efde_check_environment
    efde_check_requirements
    efde_do_install
  }
  main


} # this ensures the entire script is downloaded #

#Reference
#https://bioinf.comav.upv.es/courses/unix/scripts_bash.html
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
