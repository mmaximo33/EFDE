#!/bin/bash
#
# EFDE             : Easy and fast development environment
# Author           : Marucci Maximo (https://mmaximo33.github.io/cv/)
# Created On       : 2022-11-01
# Last Modified By : Marucci Maximo
# Last Modified On : 2022-11-27
# Status           : construction
# GitLab           : https://gitlab.com/dockerizations/efde
# GitHub           : https://github.com/mmaximo33/efde
# Description      :

# make sure we exit on error
set -e

# set the version and revision
project_run="$(basename $0)"
project_name="Easy and fast development environment"
project_version='v1.1.0'

######################################################################
########                                                     #########
########              Utility functions                      #########
########                                                     #########
######################################################################

questionYesNo(){
while true; do
  read -p "Are you sure you want to remove EFDE? [y/n]: " yn
    case $yn in
      [Yy]* ) removeEfde; break;;
      [Nn]* ) echo "Operation cancelled"; exit;;
      * ) echo "You must indicate a valid option";;
    esac
  done

}

showHelp(){
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
       --remove    Remove ${project_run^^} 

By default, ${project_run^^} will determine the actions it can perform on the directory where it was executed.

To know more write ${project_run^^} --info 

END

}

showVersion(){
  cat >&2 $project_version
}

openMoreInfo(){
  url="https://github.com/mmaximo33/efde"
  xdg-open $url
}

removeEfde(){
  echo -e "\nOkey. We will be removing ${project_run^^} from your computer"
  sleep 6s
  rm -rf ~/.efde
  rm ~/bin/efde
  echo "We remove all elements related to ${project_run^^}"
  sleep 6s
  echo -e "\nRemember that you can reinstall it by following these steps\n"
  sleep 3s
  openMoreInfo
}

invalidArgument(){
  echo -e "\n${project_run}: unrecognized argument '$1'" >&2
  echo -e "Try '${project_run} --help' for more information. \n" >&2
  exit 1
}

######################################################################
########                                                     #########
########              Command line args                      #########
########                                                     #########
######################################################################

if [[ $# -gt 0 ]] ; then
  case "$1" in
    -h|--help) showHelp;			exit 0 ;;
    -v|--version) showVersion;			exit 0 ;;
    -i|--info) openMoreInfo;			exit 0 ;;
    --remove) questionYesNo; 			exit 0 ;;
    -*) invalidArgument $1;			exit 1 ;;
  esac
fi

python3 ~/.efde/bin/start.py
