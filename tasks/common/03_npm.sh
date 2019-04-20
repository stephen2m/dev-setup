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

if [[ $CIRCLECI = true ]]; then
  _outputMessage "Skipping sudo check for circleci"
else
  _hasSudo

  # keep existing `sudo` timestamp until the script is completed
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

_outputMessage "Installing NPM and related helpers"

if [[ ${CIRCLECI} != true ]]; then
  answer=`_promptUser "Do you wish to install npm?" true`
  userResponse=${answer}
fi

if [[ ${userResponse} =~ ^[Yy]$ || ${CIRCLECI} ]]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  if [[ ${CIRCLECI} ]]; then
    _outputMessage "Trying to install NPM packages without sudo - circleci tweak"
    nvm install node
    nvm use $(node -v)
    nvm alias default $(node -v)
    npm install -g @angular/cli tslint
  else
    sudo npm install -g @angular/cli tslint
  fi
fi

_scriptCompletedMessage
