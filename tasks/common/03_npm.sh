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
  nvm install --lts
  if [[ ${CIRCLECI} ]]; then
  touch $BASH_ENV
    echo 'export NVM_DIR="$HOME/.nvm"' >> $BASH_ENV
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $BASH_ENV
    echo 'nvm alias default 10.6.0' >> $BASH_ENV
  fi
  sudo npm install -g @angular/cli tslint
fi

_scriptCompletedMessage
