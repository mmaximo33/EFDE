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
  PROJECT_NAME=EFDE
  PROJECT_FOLDER=efde

  GIT_USER=mmaximo33
  GIT_REPOSITORY=$PROJECT_NAME
  GIT_BRANCH="15-migrate-to-full-bash"
  GIT_VERSION_LATEST=""
  GIT_URL_REPOSITORY="https://github.com/$GIT_USER/$GIT_REPOSITORY"

  efde_echo() {
    local level="${2:-0}"

    local prefix=""
    if [ "$level" -gt 0 ]; then
      for ((i=0; i<level; i++)); do
        prefix+="─"
      done
    fi

    if [ ! -z $prefix ]; then
      prefix+="$prefix "
    fi
    command printf "%s%s\\n" "$prefix" "$1" 2>/dev/null
  }

  if [ -z "${BASH_VERSION}" ] || [ -n "${ZSH_VERSION}" ]; then
    # shellcheck disable=SC2016
    efde_echo >&2 'Error: The install instructions explicitly say to pipe the install script to `bash`; please follow them'
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
    local prompt="${1:-Are you sure [y/n]? }"
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
    GIT_VERSION_LATEST=$(curl -s "https://api.github.com/repos/$GIT_USER/$GIT_REPOSITORY/releases/latest" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
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
        efde_echo >&2 "File \"${EFDE_DIR}\" has the same name as installation directory."
        exit 1
      fi

      if [ "${EFDE_DIR}" = "$(efde_default_install_dir)" ]; then
        mkdir "${EFDE_DIR}"
      else
        efde_echo >&2 "You have \$EFDE_DIR set to \"${EFDE_DIR}\", but that directory does not exist. Check your profile files and environment."
        exit 1
      fi
    fi

    # Disable the optional which check, https://www.shellcheck.net/wiki/SC2230
    # shellcheck disable=SC2230
    if efde_has xcode-select && [ $(xcode-select -p >/dev/null 2>/dev/null; echo $?) = '2' ] && \
       [ "$(which git)" = '/usr/bin/git' ] && [ "$(which curl)" = '/usr/bin/curl' ]; then
      efde_echo >&2 'You may be on a Mac, and need to install the Xcode Command Line Developer Tools.'
      # shellcheck disable=SC2016
      efde_echo >&2 'If so, run `xcode-select --install` and try again. If not, please report this!'
      exit 1
    fi
  }

  efde_check_requirements() {
    efde_print_step requirements
    local errors=""
    check_and_install() {
      local tool_name="$1"
      local install_command="$2"

      if ! efde_has "$tool_name"; then
        efde_echo >&2 "You must install ${tool_name^^} to use $PROJECT_NAME" 1
        if efde_confirm_default_yes "Do you want to install ${tool_name^^} now?"; then
          $install_command || errors="$errors\n==> Failed to install ${tool_name^^}"
        else
          errors="$errors\n==> You need to have ${tool_name^^} installed"
        fi
      else
        efde_echo >&2 "[OK] Check install ${tool_name^^}" 1
      fi
    }

    check_and_install "git" "efde_install_git"
    check_and_install "docker" "efde_install_docker"
    check_and_install "docker-compose" "efde_install_docker_compose"

    if [ -n "$errors" ]; then
      efde_echo "[ERROR] The following problems were detected:" 1
      echo -e "$errors"
      exit 1
    fi

    efde_echo >&2 "[SUCCESS] Requirements verified" 1
  }

  efde_install_git() {
    sudo apt install -y git-all
  }

  efde_install_docker() {
    # https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
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
      efde_echo >&2 ""
      efde_echo >&2 "#######################################################################"
      case $1 in
      "requirements")
        efde_echo >&2 "# Verifying requirements for $PROJECT_NAME"
        ;;
      "install")
        efde_echo >&2 "# Installing $PROJECT_NAME"
        ;;
      "end")
        efde_echo >&2 "# $PROJECT_NAME is successfully installed and configured."
        efde_echo >&2 "# Select the directory and create your new project"
        efde_echo >&2 "# By running '$ efde --help'"
        ;;
      *)
        efde_echo >&2 "# Error step"
      ;;
      esac

      efde_echo >&2 "-----------------------------------------------------------------------"
    }

  efde_source() {
    local EFDE_GIT_REPO=$GIT_URL_REPOSITORY
    local EFDE_METHOD="$1"
    local EFDE_SOURCE_URL="$EFDE_REPO_URL"

    if [ "_$EFDE_METHOD" = "_git" ] || [ -z "$EFDE_METHOD" ]; then
      EFDE_SOURCE_URL="${EFDE_GIT_REPO}.git"
    elif [ "_$EFDE_METHOD" = "_script" ]; then
      EFDE_SOURCE_URL="${EFDE_GIT_REPO}/archive/refs/heads/main.zip"
    else
      efde_echo >&2 "Unexpected value \"$EFDE_METHOD\" for \$EFDE_METHOD"
      return 1
    fi

    efde_echo "$EFDE_SOURCE_URL"
  }

  efde_default_install_dir() {
    [ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.${PROJECT_FOLDER}" || printf %s "${XDG_CONFIG_HOME}/${PROJECT_FOLDER}"
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
    local INSTALL_DIR_FILE="$INSTALL_DIR/bin/efde.sh"
    local BIN_DIR="$HOME/bin"
    local BIN_FILE="$BIN_DIR/efde"

    efde_echo >&2 "Creating symbolic link" 1
    # PATCH_FROM_V1x_TO_V2x
    if [ -f "$BIN_FILE" ]; then
        efde_echo >&2 "Removing symbolic link previous versions (v1.*.*)" 2
        rm "$BIN_FILE" || {
            efde_echo >&2 "[ERROR]: Failed to remove existing $BIN_FILE" 3
            exit 1
        }
    fi

    mkdir -p $BIN_DIR
    efde_echo >&2 "In $BIN_FILE FROM $INSTALL_DIR_FILE" 2
    if ! ln -sfT "$INSTALL_DIR_FILE" "$BIN_FILE"; then
      echo "[ERROR]: Cannot create symbolic link. Please report this!"
      exit 1
    fi
  }

  efde_do_install() {
    efde_latest_version
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
    efde_confirm_default_yes "You want to run efde --help now?" && efde --help
  }

  efde_project_install_existing_folder(){
    local INSTALL_DIR="$(efde_install_dir)"

    efde_echo "$PROJECT_NAME is already installed in $INSTALL_DIR" 1
    efde_echo "Checking for updates" 2
    if (command cd $INSTALL_DIR; git checkout main; git reset --hard origin/$GIT_BRANCH; git pull origin $GIT_BRANCH) >/dev/null 2>&1; then
      efde_echo >&2 "[SUCCESS] Updated repository!" 3
    else
      efde_echo >&2 "[ERROR] Failed to updated ${PROJECT_NAME} repo. Please report this!" 3
    fi
  }

  efde_project_install_recovery_project(){
    local INSTALL_DIR="$(efde_install_dir)"
    local BACKUP_DIR="${INSTALL_DIR}_bkp_install_$(date +'%Y%m%d%H%M%S')"

    efde_echo >&2 "The $INSTALL_DIR directory exists without version control (.git)" 1
    if efde_confirm_default_no "─── Do you want to create a backup?" ;then
      efde_echo >&2 "Creating a backup" 2
      if mv "$INSTALL_DIR" "$BACKUP_DIR"; then
        efde_echo >&2 "[SUCCESS] Backup created in $BACKUP_DIR" 3
      else
        efde_echo >&2 "[ERROR] Failed to create a backup of the existing directory. Please report this!" 3
        exit 2
      fi
    fi

    efde_project_install_clone_project
  }

  efde_project_install_clone_project(){
    local INSTALL_DIR="$(efde_install_dir)"

    efde_echo >&2 "Downloading $PROJECT_NAME from git to $INSTALL_DIR" 1
    mkdir -p "${INSTALL_DIR}"
    efde_echo >&2 "Cloning repository" 2
    if command git clone --branch $GIT_BRANCH "$(efde_source)"  "$INSTALL_DIR" 2>/dev/null; then
      cd "$INSTALL_DIR"
      if [[ ! "$GIT_BRANCH" == "main" ]]; then
        efde_echo >&2 "[DEBUG] TESTING BRANCH $(git rev-parse --abbrev-ref HEAD 2>&1)" 3
      else
        efde_echo >&2 "[SUCCESS] $(git switch -c $GIT_VERSION_LATEST 2>&1)" 3
      fi
    else
      efde_echo >&2 "[ERROR] Failed to clone $PROJECT_NAME repo. Please report this!" 3
      exit 2
    fi
  }

  efde_project_install_optimization(){
    efde_echo >&2 "Repository optimization" 2
    local action
    action="Compression"
    if command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" reflog expire --expire=now --all; then
      efde_echo >&2 "[SUCCESS] $action" 3
    else
      efde_echo >&2 "[ERROR] $action: Your version of git is out of date. Please update it!" 3
    fi

    action="Cleaning"
    if command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" gc --auto --aggressive --prune=now; then
      efde_echo >&2 "[SUCCESS] $action" 3
    else
      efde_echo >&2 "[ERROR] $action: Your version of git is out of date. Please update it!" 3
    fi
  }

  #######################################################################
  # Clear section
  #
  # Unsets the various functions defined
  # during the execution of the install script
  #----------------------------------------------------------------------
  efde_reset() {
    unset -f efde_echo efde_get_keypress efde_get_yes_keypress efde_confirm_default_no efde_confirm_default_yes \
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
    if [ "_$EFDE_ENV" != "_testing" ]; then
      efde_check_environment
      efde_check_requirements
    fi

    efde_do_install
  }
  main


} # this ensures the entire script is downloaded #

#Reference
#https://bioinf.comav.upv.es/courses/unix/scripts_bash.html
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
