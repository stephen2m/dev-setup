#!/usr/bin/env bash
################################################################################
################################################################################
# Name:            02_java.sh
# Usage:           n/a
# Description:     Installs Java (version specified in common.sh) and sdkman
################################################################################
################################################################################

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1091
. common.sh

case $(_getLinuxVersion) in
arch)
  JAVA_VERSION=${JAVA_VERSION_ARCH}
  ;;
fedora)
  JAVA_VERSION=${JAVA_VERSION_FEDORA}
  ;;
debian)
  JAVA_VERSION=${JAVA_VERSION_DEBIAN}
  ;;
*)
  _outputMessage "Could not determine OS/distro in use to install java"
  _scriptCompletedMessage ${start_sec}
  exit 1
  ;;
esac

logMessage="installing java ${JAVA_VERSION}, sdkman, groovy, and gradle setup"

_writeHeader "${logMessage}"

_outputMessage "Started ${logMessage} $(basename "$0")"

if [[ ${CIRCLECI} ]]; then
  _outputMessage "Skipping sudo check for circleci"
else
  _hasSudo

  # keep existing `sudo` timestamp until the script is completed
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

_outputMessage "Installing JAVA and related helpers"

if [[ $(which java) == "/usr/bin/java" ]]; then
  _outputMessage "Skipping installing JAVA as there's already an installed version: $(java -version 2>&1 | head -n 1)"
else
  if _ask "Do you wish to install ${JAVA_VERSION}?" Y; then
    _installPackage ${JAVA_VERSION}
  fi
fi

if [[ ! $(sdk version) =~ "SDKMAN" ]]; then
  if _ask "Do you wish to install sdkman?" Y; then
    curl -s ${SDKMAN_URL} | bash
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
  fi
fi

if _ask "Do you wish to install springboot, gradle and groovy?" Y; then
  sdk install springboot
  sdk install gradle
  sdk install groovy
fi

_scriptCompletedMessage ${start_sec}
