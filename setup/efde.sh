#!/usr/bin/env bash
#
# EFDE             : Easy and fast development environment
# Author           : Marucci Maximo (https://mmaximo33.github.io/cv/)
# GitHub           : https://github.com/mmaximo33/efde
# GitLab           : https://gitlab.com/dockerizations/efde
# Description      :

# Make sure we exit on error
set -euo pipefail

#######################################################################
# INIT section
#----------------------------------------------------------------------
# Set the version and revision
project_run="${0##*/}"
project_name="Easy and Fast Development Environment"
project_version='v1.2.0'

efde_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

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

#######################################################################
# Actions section
#----------------------------------------------------------------------

show_help() {
  cat >&2 <<END
${project_name^^} | ${project_run^^} | $project_version
Debian GNU/LINUX
Copyright (C) 2022 Marucci Maximo
This is free software, see the GNU General Public Licence for copyingconditions.
There is NO warranty.

Usage: ${project_run^}  [options] 
Options:
  -h,  --help	   Use and arguments
  -v,  --version   Show current version
  -i,  --info      Official project information ${project_run^^}
       --update    Update ${project_run^^} 
       --remove    Remove ${project_run^^} 

By default, ${project_run^^} will determine the actions it can perform on the directory where it was executed.

To know more write ${project_run^^} --info 

END

}

show_version() {
  efde_echo "${project_run} ${project_version}"
}

open_more_info() {
  url="https://github.com/mmaximo33/efde"
  xdg-open "$url"
}

# Remove
remove_check() {
  efde_confirm "Do you want to remove EFDE from your computer?" remove_action
}

remove_action() {
  echo -e "\nOkey. We will be removing ${project_run^^} from your computer"
  sleep 3s
  rm -rf $HOME/.efde
  rm $HOME/bin/efde
  echo -e "We remove all elements related to ${project_run^^}"
  sleep 3s
  echo -e "\nRemember that you can reinstall it by following these steps\n"
  sleep 2s
  open_more_info
}

# Update
update_check() {
  # https://stackoverflow.com/a/3278427
  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(
    cd $HOME/.efde
    git rev-parse @
  )
  REMOTE=$(
    cd $HOME/.efde
    git rev-parse "$UPSTREAM"
  )
  if [ $LOCAL == $REMOTE ]; then
    echo -e 'Up to date!' >&2
  else
    efde_echo 'There is an update available!'
    efde_confirm_yes "Do you want to download the new version of ${project_run^^}?" update_action
  fi
}

update_action() {
  cd $HOME/.efde
  git checkout main
  git reset --hard origin/main
  git pull origin main
}

#######################################################################
# Command line args
#----------------------------------------------------------------------

invalid_argument() {
  echo -e "\n${project_run}: unrecognized argument '${1:-}'" >&2
  echo -e "Try '${project_run} --help' for more information. \n" >&2
  exit 1
}

if [ $# -gt 0 ]; then
  case "$1" in
  -h | --help)
    show_help
    exit 0
    ;;
  -v | --version)
    show_version
    exit 0
    ;;
  -i | --info)
    open_more_info
    exit 0
    ;;
  --update)
    update_check
    exit 0
    ;;
  --remove)
    remove_check
    exit 0
    ;;
  -*)
    invalid_argument $1
    exit 1
    ;;
  esac
fi

python3 "$HOME/.efde/bin/start.py"
