#!/usr/bin/env bash
################################################################################
################################################################################
# Name:            java.sh
# Usage:           n/a
# Description:     Installs Java (version specified in common.sh) and sdkman
################################################################################
################################################################################

. ../../common.sh

_outputMessage "Started java installation script $(basename $0)"

_hasSudo

# keep existing `sudo` timestamp until the script is completed
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

_outputMessage "installing JAVA and related helpers"

answer=`_promptUser "Do you wish to install $JAVA_VERSION?" false`
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  _outputMessage "Installing $JAVA_VERSION"
  _installPackage ${JAVA_VERSION}
fi

answer=`_promptUser "Do you wish to install sdkman?" false`
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

#-------------------------------------------------------------------------------
# sdk install springboot
# sdk install gradle
# sdk install groovy
#-------------------------------------------------------------------------------

_scriptCompletedMessage
