#!/usr/bin/env bash
################################################################################
################################################################################
# Name:            03_npm.sh
# Usage:           n/a
# Description:     Installs NPM and a few basic node modules
################################################################################
################################################################################

. common.sh

_outputMessage "Started npm installation script $(basename $0)"

_hasSudo

# keep existing `sudo` timestamp until the script is completed
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

_outputMessage "installing NPM and related helpers"

answer=`_promptUser "Do you wish to install npm?" false`
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  sudo npm install -g @angular/cli tslint
fi

_scriptCompletedMessage
