#!/usr/bin/env bash
################################################################################
################################################################################
# Name:            02_java.sh
# Usage:           n/a
# Description:     Installs Java (version specified in common.sh) and sdkman
################################################################################
################################################################################

. common.sh

_outputMessage "Started java installation script $(basename $0)"

if [[ $CIRCLECI ]]; then
  _outputMessage "skipping sudo check for circleci"
else
  _hasSudo

  # keep existing `sudo` timestamp until the script is completed
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

_outputMessage "installing JAVA and related helpers"

if [[ $(_getLinuxVersion) == "ManjaroArch" ]]; then
  JAVA_VERSION=${JAVA_VERSION_ARCH}
else
  JAVA_VERSION=${JAVA_VERSION_UBUNTU}
fi

if [[ $(_getLinuxVersion) == "/usr/bin/java" ]]; then
  _outputMessage "Skipping installing JAVA as there's already an installed version: $(java -version 2>&1 | head -n 1)"
else
  answer=`_promptUser "Do you wish to install $JAVA_VERSION?" false`
  userResponse=${answer}
  if [[ ${userResponse} =~ ^[Yy]$ ]]; then
    _outputMessage "Installing $JAVA_VERSION"
    _installPackage ${JAVA_VERSION}
  fi
fi

answer=`_promptUser "Do you wish to install sdkman?" false`
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  curl -s ${SDKMAN_URL} | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

#-------------------------------------------------------------------------------
# sdk install springboot
# sdk install gradle
# sdk install groovy
#-------------------------------------------------------------------------------

_scriptCompletedMessage
