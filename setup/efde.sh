#!/bin/bash
#
# EFDE             : Easy and fast development environment
# Author           : Marucci Maximo (https://mmaximo33.github.io/cv/)
# GitHub           : https://github.com/mmaximo33/efde
# GitLab           : https://gitlab.com/dockerizations/efde
# Description      :

# Make sure we exit on error
set -euo pipefail

# Set the version and revision
project_run="$(basename $0)"
project_name="Easy and fast development environment"
project_version='v1.1.1'

######################################################################
########                                                     #########
########              Utility functions                      #########
########                                                     #########
######################################################################

efde_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

question_yes_no() {
  while true; do
    read -p "$1 [y/n]: " yn
    case $yn in
    [Yy]*)
      $2
      exit
      ;;
    [Nn]*)
      $3
      exit
      ;;
    *) efde_echo "You must indicate a valid option" ;;
    esac
  done

}

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
  efde_echo $project_version
}

open_more_info() {
  url="https://github.com/mmaximo33/efde"
  xdg-open $url
}

remove_check() {
  question_yes_no "Do you want to remove EFDE from your computer?" remove_action break
}

remove_action() {
  echo -e "\nOkey. We will be removing ${project_run^^} from your computer"
  sleep 3s
  rm -rf ~/.efde
  rm ~/bin/efde
  echo -e "We remove all elements related to ${project_run^^}"
  sleep 3s
  echo -e "\nRemember that you can reinstall it by following these steps\n"
  sleep 2s
  open_more_info
}

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
    question_yes_no "Do you want to download the new version of ${project_run^^}?" update_action break
  fi
}

update_action() {
  cd $HOME/.efde
  git checkout main
  git reset --hard origin/main
  git pull origin main
}

invalid_argument() {
  echo -e "\n${project_run}: unrecognized argument '$1'" >&2
  echo -e "Try '${project_run} --help' for more information. \n" >&2
  exit 1
}

######################################################################
########                                                     #########
########              Command line args                      #########
########                                                     #########
######################################################################

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

python3 ~/.efde/bin/start.py
