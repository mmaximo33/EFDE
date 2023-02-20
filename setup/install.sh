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
  PROJECT_VERSION="1.2.0"
  PROJECT_REPO_GIT=https://github.com/mmaximo33/efde

  efde_echo() {
    command printf %s\\n "$*" 2>/dev/null
  }

  if [ -z "${BASH_VERSION}" ] || [ -n "${ZSH_VERSION}" ]; then
    # shellcheck disable=SC2016
    efde_echo >&2 'Error: the install instructions explicitly say to pipe the install script to `bash`; please follow them'
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
  # Usage: confirm "Dangerous. Are you sure?" && rm *
  efde_confirm() {
    local prompt="${*:-Are you sure} [y/N]? "
    efde_get_yes_keypress "$prompt" 1
  }

  # Prompt to confirm, defaulting to YES on <enter>
  efde_confirm_yes() {
    local prompt="${*:-Are you sure} [Y/n]? "
    efde_get_yes_keypress "$prompt" 0
  }

  efde_input_response() {
    read -p "$1 " RESPONSE
    echo $RESPONSE
  }

  # ToDo: Review install for version
  efde_latest_version() {
    efde_echo "$PROJECT_VERSION"
  }

  #######################################################################
  # Requiriments section
  #----------------------------------------------------------------------
  efde_has() {
    type "$1" >/dev/null 2>&1
  }

  efde_check_requirements() {
    local errors
    efde_print_step requirements

    if ! efde_has git; then
      efde_echo >&2 "\nYou must install GIT to download ${PROJECT_NAME}"
      if efde_confirm_yes "Do you want to install GIT now?"; then
        efde_git_install
      elif ! efde_has curl && ! efde_has wget; then
        efde_echo >&2 "\nYou must install CURL to download ${PROJECT_NAME}"
        efde_confirm_yes "Do you want to install CURL now?" && efde_curl_install || errors="$errors\n==> You need to have GIT or CURL or WGET installed"
      fi
    fi

    if ! efde_has python3; then
      efde_echo >&2 "$PROJECT_NAME requires having python3 to work"
      efde_confirm_yes "Do you want to install python3 now?" && efde_python_install || errors="$errors\n==> You need to have python3"
    elif ! efde_has pip; then
      efde_echo >&2 "$PROJECT_NAME requires having python3-pip (dependencies) to work"
      efde_confirm_yes "Do you want to install python3-pip now?" && efde_python_dependecy_install || errors="$errors\n==> You need to have python3-pip (dependencies)"
    fi

    if ! efde_has docker; then
      efde_echo >&2 "$PROJECT_NAME requires having docker to work"
      efde_confirm_yes "Do you want to install docker now?" && efde_docker_install || errors="$errors\n==> You need to have docker"
    else
      if ! efde_has compose; then
        efde_echo >&2 "$PROJECT_NAME requires having docker compose(v2) to work"
        efde_confirm_yes "Do you want to install docker compose (v2) now?" && efde_docker_compose_install || errors="$errors\n==> You need to have docker compose (v2)"
      fi
    fi

    if [ ! -z "$errors" ]; then
      efde_echo "=> The following problems were detected:"
      echo -e "$errors"
      exit 1
    fi

    efde_echo "=> Requirements OK"
  }

  efde_curl_install() {
    sudo apt install -y curl
  }

  efde_git_install() {
    sudo apt install -y git-all
    efde_git_configure
  }

  efde_git_configure() {
    efde_echo >&2 "Let's load the initial configuration for git"
    git config --global user.email "$(efde_input_response 'Whats is your email?')"
    git config --global user.name "$(efde_input_response 'Whats is your name?')"
    git config -l | egrep user.
    efde_echo >&2 "You can all the configuration with 'git config -l'"
    efde_input_response 'Press enter to continue'
  }

  efde_python_install() {
    sudo apt install -y software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python3.8
    efde_python_dependecy_install
  }

  efde_python_dependecy_install() {
    sudo apt install -y python3-pip
    pip3 install python-dotenv
  }

  efde_docker_install() {
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
    
    #sudo systemctl restart docker

    # docker compose (v2)
    efde_docker_compose_install
  }

  efde_docker_compose_install() {
    # https://docs.docker.com/compose/install/linux/
    sudo apt-get install docker-compose-plugin
  }

  #######################################################################
  # Installation section
  #----------------------------------------------------------------------
  efde_source() {
    local EFDE_GIT_REPO
    EFDE_GIT_REPO=$PROJECT_REPO_GIT

    local EFDE_METHOD
    EFDE_METHOD="$1"

    local EFDE_SOURCE_URL
    EFDE_SOURCE_URL="$EFDE_REPO_URL"

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
    local INSTALL_DIR
    INSTALL_DIR="$(efde_install_dir)"
    local BIN_FILE
    BIN_DIR="$HOME/bin"
    BIN_FILE="$BIN_DIR/efde"

    efde_echo >&2 "=> Creating $BIN_FILE"
    if [ -f $BIN_FILE ]; then
      rm $BIN_FILE
    fi

    mkdir -p $BIN_DIR
    cp "$INSTALL_DIR/setup/efde.sh" $BIN_FILE
    chmod +x $BIN_FILE
  }

  efde_print_step() {
    efde_echo >&2 ""
    efde_echo >&2 "#######################################################################"
    case $1 in
    "requirements")
      efde_echo >&2 "# Verifying requirements for $PROJECT_NAME"
      efde_echo >&2 "# Download: GIT or CURL or WGET"
      efde_echo >&2 "# Run: python3 y pip"
      efde_echo >&2 "# Implement: docker and docker-compose"
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

  efde_do_install() {
    efde_print_step install

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
    if efde_has xcode-select && [ "$(
      xcode-select -p >/dev/null 2>/dev/null
      echo $?
    )" = '2' ] && [ "$(which git)" = '/usr/bin/git' ] && [ "$(which curl)" = '/usr/bin/curl' ]; then
      efde_echo >&2 'You may be on a Mac, and need to install the Xcode Command Line Developer Tools.'
      # shellcheck disable=SC2016
      efde_echo >&2 'If so, run `xcode-select --install` and try again. If not, please report this!'
      exit 1
    fi

    # Install repo
    if [ -z "${METHOD}" ]; then
      # Autodetect install method
      if efde_has git; then
        efde_project_install_from_git
      elif efde_has curl || efde_has wget; then
        efde_project_install_from_script
      else
        efde_echo >&2 "You need git, curl, or wget to install $PROJECT_NAME"
        exit 1
      fi
    elif [ "${METHOD}" = 'git' ]; then
      if ! efde_has git; then
        efde_echo >&2 "You need git to install $PROJECT_NAME"
        exit 1
      fi
      efde_project_install_from_git
    elif [ "${METHOD}" = 'script' ]; then
      if ! efde_has curl && ! efde_has wget; then
        efde_echo >&2 "You need curl or wget to install $PROJECT_NAME"
        exit 1
      fi
      efde_project_install_from_script
    else
      efde_echo >&2 "The environment variable \$METHOD is set to \"${METHOD}\", which is not recognized as a valid installation method."
      exit 1
    fi

    efde_reset
  }

  efde_project_install_from_git() {
    local INSTALL_DIR
    INSTALL_DIR="$(efde_install_dir)"

    if [ -d "$INSTALL_DIR/.git" ]; then
      # Updating repo
      efde_echo "=> $PROJECT_NAME is already installed in $INSTALL_DIR"
      efde_echo "==> Updating repository"
      if (command cd $INSTALL_DIR; git checkout main; git reset --hard origin/main; git pull origin main) >/dev/null 2>&1; then
        efde_echo >&2 "===> Successfully updated!"
      else
        efde_echo >&2 "===> Failed to updated ${PROJECT_NAME} repo. Please report this!"
      fi
    else
      # Installing
      efde_echo "=> Downloading $PROJECT_NAME from git to '$INSTALL_DIR'"
      mkdir -p "${INSTALL_DIR}"
      if [ "$(ls -A "${INSTALL_DIR}")" ]; then
        # Initializing repo
        command git init "${INSTALL_DIR}" || {
          efde_echo >&2 "==> Failed to initialize $PROJECT_NAME repo. Please report this!"
          exit 2
        }
        command git --git-dir="${INSTALL_DIR}/.git" remote add origin "$(efde_source)" 2>/dev/null ||
          command git --git-dir="${INSTALL_DIR}/.git" remote set-url origin "$(efde_source)" || {
          efde_echo >&2 '==> Failed to add remote "origin" (or set the URL). Please report this!'
          exit 2
        }
      else
        # Cloning repo
        efde_echo >&2 "==> Cloning repository"
        if command git clone "$(efde_source)" --depth=1 "$INSTALL_DIR" 2>/dev/null; then
          efde_echo >&2 "===> Successfully updated"
        else
          efde_echo >&2 "===> Failed to clone $PROJECT_NAME repo. Please report this!"
          exit 2
        fi

      fi
    fi

    # Checks
    if [ -n "$(command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" show-ref refs/heads/master)" ]; then
      if command git --no-pager --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" branch --quiet 2>/dev/null; then
        command git --no-pager --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" branch --quiet -D main >/dev/null 2>&1
      else
        efde_echo >&2 "=> Your version of git is out of date. Please update it!"
        command git --no-pager --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" branch -D main >/dev/null 2>&1
      fi
    fi

    efde_echo "=> Compressing and cleaning up git repository"
    if ! command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" reflog expire --expire=now --all; then
      efde_echo >&2 "==> Your version of git is out of date. Please update it!"
    fi
    if ! command git --git-dir="$INSTALL_DIR"/.git --work-tree="$INSTALL_DIR" gc --auto --aggressive --prune=now; then
      efde_echo >&2 "==> Your version of git is out of date. Please update it!"
    fi

    #
    efde_create_bin
    efde_print_step end

    command efde --help
  }

  # ToDo: Improve this scripts
  efde_project_install_from_script() {
    local HOME_DIR
    HOME_DIR=$(printf %s "${HOME}")
    local INSTALL_DIR
    INSTALL_DIR="$(efde_install_dir)"
    local EFDE_SOURCE_SCRIPT 
    EFDE_SOURCE_SRIPT="$(efde_source script)"
    local EFDE_SOURCE_FILE
    EFDE_SOURCE_FILE=$(basename $EFDE_SOURCE_SRIPT)
    local EFDE_UNZIP_FOLDER
    EFDE_UNZIP_FOLDER=$(basename $EFDE_SOURCE_SRIPT .zip)

    efde_project_download -LJO "$EFDE_SOURCE_SRIPT" --output-dir "$HOME_DIR"
    
    command unzip -uqq "$HOME_DIR/$PROJECT_FOLDER-$EFDE_SOURCE_FILE" -d $HOME_DIR
    
    command mv "$HOME_DIR/$PROJECT_FOLDER-$EFDE_UNZIP_FOLDER" $INSTALL_DIR
    command rm "$HOME_DIR/$PROJECT_FOLDER-$EFDE_SOURCE_FILE"

    efde_create_bin
    
    efde_print_step end

    command efde --help
  }

  efde_project_download() {
    if efde_has "curl"; then
      curl --fail --compressed -q "$@"
    elif efde_has "wget"; then
      # Emulate curl with wget
      ARGS=$(efde_echo "$@" | command sed -e 's/--progress-bar /--progress=bar /' \
        -e 's/--compressed //' \
        -e 's/--fail //' \
        -e 's/-L //' \
        -e 's/-I /--server-response /' \
        -e 's/-s /-q /' \
        -e 's/-sS /-nv /' \
        -e 's/-o /-O /' \
        -e 's/-C - /-c /')
      # shellcheck disable=SC2086
      eval wget $ARGS
    fi
  }

  #######################################################################
  # Clear section
  #
  # Unsets the various functions defined
  # during the execution of the install script
  #----------------------------------------------------------------------
  efde_reset() {
    unset -f efde_do_install efde_git_configure efde_git_install efde_python_install \
      efde_python_dependecy_install efde_project_install_from_script efde_project_install_from_git \
      efde_create_bin efde_latest_version efde_install_dir efde_default_install_dir efde_echo efde_has \
      efde_input_response efde_source efde_get_keypress efde_get_yes_keypress efde_confirm efde_confirm_yes \
      efde_project_download efde_print_step
  }

  [ "_$EFDE_ENV" = "_testing" ] || efde_check_requirements
  efde_do_install

} # this ensures the entire script is downloaded #

#Reference
#https://bioinf.comav.upv.es/courses/unix/scripts_bash.html
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
