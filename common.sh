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

export DEBIAN_FRONTEND=noninteractive

LOG_DIRECTORY='logs'
LOG_FILE="${LOG_DIRECTORY}/"$(date +%Y-%m-%d).log

# app versions and other useful shortcuts
SDKMAN_URL="https://get.sdkman.io"
JAVA_VERSION_ARCH="jdk8"
JAVA_VERSION_UBUNTU="openjdk-8-jdk"
RBENV_REPO="git://github.com/sstephenson/ruby-build.git"
RUBY_VERSION="2.6.1"
RAILS_VERSION="5.2.2"

# Usage: _outputMessage <message>
#
# Outputs <message> to the terminal
# And also logs to the current LOG_FILE value
_outputMessage() {
  if [[ ! -d "$LOG_DIRECTORY" ]]; then
    mkdir ${LOG_DIRECTORY}
  fi

  if [[ ! -e "$LOG_FILE" ]]; then
    touch "${LOG_FILE}"
  fi

  if [[ "$#" -ne 1 ]]; then
    _errorExit "Function call expected 1 (one) parameter.  Usage: _outputMessage <message>"
  fi

  local fmt="$1"; shift
  date=$(/bin/date "+%F %T")
  printf "$date: $fmt\n" "$@" | tee -a ${LOG_FILE}
}

# Usage: _scriptCompletedMessage
#
# Prints some finishing statistics
# Currently shows how long a script took to run
# Uses the $start_sec script-level variable to determine this
_scriptCompletedMessage() {
  local end_sec=$(/bin/date +%s.%N)
  # shellcheck disable=SC2154
  elapsed_seconds=$(echo "$end_sec" "$start_sec" | awk '{ print $1 - $2 }')

  _outputMessage "Finished execution of $(basename "$0") in $elapsed_seconds seconds\n"
}

# Usage: _errorExit <message>
#
# Writes <message> to screen and logfile as a "fatal"
# And immediately exits the currently running script
_errorExit() {
  local date=$(/bin/date "+%F %T")
  local message=$1
  if [[ "$#" -ne 1 ]]; then
    printf "$date: [FATAL] Function call expected 1 (one) parameter.  Usage: _errorExit <message>"
    exit 1
  fi

  printf "$date: [FATAL] $message\n" "$@" | tee -a ${LOG_FILE}
  exit 1
}

# Usage: _getLinuxVersion
#
# Determines linux-flavor running on the machine in use
_getLinuxVersion() {
  dist=$(grep ID_LIKE /etc/os-release | awk -F '=' '{print $2}')

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
  echo "${INPUT}"

  if [[ "$INPUT" =~ ^[yY]$ ]]; then
    ANSWER=true
  else
    # shellcheck disable=SC2034
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
    arch)
      _outputMessage "Installing $PACKAGE"
      yay -S --noconfirm --needed --overwrite '*' "${PACKAGE}"
      ;;
    debian)
      _outputMessage "Installing $PACKAGE"
      sudo apt install -y "${PACKAGE}"
      ;;
    *)
      _errorExit "Could not determine OS/distro in use to install $PACKAGE. Parser found $(_getLinuxVersion)"
      ;;
  esac
}
