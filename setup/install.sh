#!/usir/bin/env bash
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

  PROJECT_NAME=EFDE
  PROJECT_FOLDER=efde
  PROJECT_REPO_GIT=https://github.com/mmaximo33/efde
  PROJECT_REPO_DOWNLOAD=$PROJECT_REPO_GIT/-/archive/main/efde-main.tar.gz

  set -- $(locale LC_MESSAGES)
  yesexpr="$1"
  noexpr="$2"
  yesword="$3"
  noword="$4"

  efde_has() {
    type "$1" >/dev/null 2>&1
  }

  efde_echo() {
    command printf %s\\n "$*" 2>/dev/null
  }

  if [ -z "${BASH_VERSION}" ] || [ -n "${ZSH_VERSION}" ]; then
    # shellcheck disable=SC2016
    efde_echo >&2 'Error: the install instructions explicitly say to pipe the install script to `bash`; please follow them'
    exit 1
  fi

  efde_input_yes_no() {
    while true; do
      read -p "$1 [${yesword}/${noword}] " yn
      if [[ "$yn" =~ $yesexpr ]]; then
        $2
        break
      fi
      if [[ "$yn" =~ $noexpr ]]; then
        $3
        break
      fi
    done
  }

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
      EFDE_SOURCE_URL="${EFDE_GIT_REPO}"
    else
      efde_echo >&2 "Unexpected value \"$EFDE_METHOD\" for \$EFDE_METHOD"
      return 1
    fi

    efde_echo "$EFDE_SOURCE_URL"
  }

  efde_input_response() {
    read -p "$1 " RESPONSE
    echo $RESPONSE
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

  efde_latest_version() {
    efde_echo "1.0.0"
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

  efde_project_install_from_git() {
    if ! efde_has git; then
      efde_echo "You must install git to download ${PROJECT_NAME}"
      efde_input_yes_no 'Do you want to install git now?' efde_git_install
    fi

    efde_echo "#######################################################################"

    local INSTALL_DIR
    INSTALL_DIR="$(efde_install_dir)"

    local fetch_error

    if [ -d "$INSTALL_DIR/.git" ]; then
      # Updating repo
      efde_echo "=> $PROJECT_NAME is already installed in $INSTALL_DIR"
      efde_echo "==> Updating repository"
      if (command git checkout main && git reset --hard origin/main && git pull origin main) >/dev/null 2>&1; then
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

    efde_echo "#######################################################################"
    efde_echo "$PROJECT_NAME is successfully installed and configured."
    efde_echo "Select the directory and create your new project by running '$ efde'"
    efde_echo "-----------------------------------------------------------------------"
    efde --help
  }

  efde_project_install_from_script() {
    efde_echo "Not available"
  }

  efde_python_install() {
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install python3.8
    efde_python_dependecy_install
  }
  
  efde_python_dependecy_install() {
    sudo apt install python3-pip
    pip3 install python-dotenv
  }

  efde_git_install() {
    sudo apt install git-all
  }

  efde_git_configure() {
    efde_echo >&2 "Let's load the initial configuration for git"
    git config --global user.email "$(efde_input_response 'Whats is your email?')"
    git config --global user.name "$(efde_input_response 'Whats is your name?')"
    git config -l | egrep user.
    efde_echo >&2 "You can all the configuration with 'git config -l'"
    efde_input_response 'Press enter to continue'
  }

  efde_do_install() {
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

    #Check python3
    if ! efde_has python3; then
      efde_echo >&2 "$PROJECT_NAME requires having python3 to work"
      efde_input_yes_no 'Do you want to install python3 now?' efde_python_install
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

  }

  #
  # Unsets the various functions defined
  # during the execution of the install script
  #
  efde_reset() {
    unset -f efde_do_install efde_git_configure efde_git_install efde_python_install \
      efde_python_dependecy_install efde_project_install_from_script efde_project_install_from_git \
      efde_create_bin efde_latest_version efde_install_dir efde_default_install_dir efde_echo efde_has \
      efde_input_response efde_source efde_input_yes_no
  }

  [ "_$EFDE_ENV" = "_testing" ] || efde_do_install

} # this ensures the entire script is downloaded #

#Reference
#https://bioinf.comav.upv.es/courses/unix/scripts_bash.html
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
