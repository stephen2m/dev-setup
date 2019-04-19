#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            common.sh
# Usage:           n/a
# Description:     Common functions useful to the other scripts
# Created:         n/a
# Last Modified:   n/a
################################################################################
################################################################################

# stop the script when an error occurs
set -o errexit
# causes a pipeline (for example, curl -s https://sipb.mit.edu/ | grep foo)
# to produce a failure return code if any command errors.
# Normally, pipelines only return a failure if the last command errors
set -o pipefail

LOG_DIRECTORY='logs'
LOG_FILE="${LOG_DIRECTORY}/"`date +%Y-%m-%d`.log

# app versions and other useful shortcuts
SDKMAN_URL="https://get.sdkman.io"
JAVA_VERSION="jdk8"
RBENV_REPO="git://github.com/sstephenson/ruby-build.git"
RUBY_VERSION="2.4.3"
RAILS_VERSION="5.1.4"

# Usage: msg <message>
#
# Outputs <message> to the terminal
# And also logs to the current LOG_FILE value
_outputMessage() {
  if [[ "$#" -ne 2 ]]; then
    _errorExit "Expected 1 (one) parameter.  Usage: _outputMessage <message>"
  fi

  if [[ ! -d "$LOG_DIRECTORY" ]]; then
    mkdir ${LOG_DIRECTORY}
  fi

  if [[ ! -e "$LOG_FILE" ]]; then
    touch ${LOG_FILE}
  fi

  local fmt="$1"; shift
  printf "$(/bin/date "+%F %T"): $fmt\n" "$@" | tee -a ${LOG_FILE}
}

# Usage: _scriptCompletedMessage
#
# Prints some finishing statistics
# Currently shows how long a script took to run
# Uses the $start_sec script-level variable to determine this
_scriptCompletedMessage() {
  end_sec=$(/bin/date +%s.%N)
  elapsed_seconds=$(echo "$end_sec" "$start_sec" | awk '{ print $1 - $2 }')

  _outputMessage "Finished execution of $(basename $0) in $elapsed_seconds seconds\n"
}

# Usage: _errorExit <message>
#
# Writes <message> to screen and logfile as a "fatal"
# And immediately exits the currently running script
_errorExit() {
  if [[ "$#" -ne 1 ]]; then
    _errorExit "Expected 1 (one) parameter.  Usage: _errorExit <message>"
  fi
  local message=$1

  _outputMessage "[FATAL] $message\n"
  exit 1
}

# Usage: _getLinuxVersion
#
# Determines linux-flavor running on the machine in use
# Currently only detects debian and arch
_getLinuxVersion() {
  dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`

  echo "$dist"
}

# Usage _promptUser <question> <default-boolean-response>
#
# Displays a yes/no prompt while highlighting the preferred option in uppercase
_promptUser() {
  if [[ "$#" -ne 2 ]]; then
    _errorExit "Expected 2 (two) parameters.  Usage: _promptUser <question> <default-boolean-response>"
  fi

  QUESTION=$1
  DEFAULT=$2

  if [[ "$DEFAULT" = true ]]; then
    OPTIONS="[Y/n]"
    DEFAULT="y"
  else
    OPTIONS="[y/N]"
    DEFAULT="n"
  fi

  read -ep "$QUESTION $OPTIONS " -n 1 -s -r INPUT
  INPUT=${INPUT:-${DEFAULT}}
  echo ${INPUT}

  if [[ "$INPUT" =~ ^[yY]$ ]]; then
    ANSWER=true
  else
    ANSWER=false
  fi
}

# Usage _hasSudo
#
# Ensure user has sudo access and also that the script is not running as root
# Halts all activity if running as root
_hasSudo() {
  isRoot=$(id -u)
  if [[ ${isRoot} ]]; then
    _errorExit "Please run scripts as a normal user and not as root"
  fi
  if [[ "$EUID" != 0 ]]; then
    # prompt for password and elevate privilege
    printf "\nPlease provide your root password to allow this script to work as intended\n"
    sudo -v
  fi
}

# Usage _installPackage
#
# Based on the OS in use, install the specified package
_installPackage() {
  if [[ "$#" -ne 1 ]]; then
    _errorExit "Expected 1 (one) parameter.  Usage: _installPackage '<package-name>'"
  fi
  PACKAGE=$1

  case $(_getLinuxVersion) in
    ManjaroLinux)
      _outputMessage "Installing $PACKAGE"
      yay -S --noconfirm --needed --overwrite '*' ${PACKAGE}
      ;;
    *)
      _errorExit "Could not determine OS in use to install $PACKAGE. OS parser found $(_getLinuxVersion)"
      ;;
  esac
}
