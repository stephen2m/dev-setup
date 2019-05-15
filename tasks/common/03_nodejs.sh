#!/usr/bin/env bash
################################################################################
################################################################################
# Name:            03_nodejs.sh
# Usage:           n/a
# Description:     Installs NodeJS, NPM, Angular and tslint
################################################################################
################################################################################

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1091
. common.sh

_writeHeader "NodeJS and NPM Setup"

if [[ $(npm --version) && $(node --version) ]]; then
  _outputMessage "Skipping installing NodeJS NPM as there's already an installed version: node $(node -v) and NPM v$(npm -v)"
else
  _outputMessage "Installing NPM and related helpers"

  if _ask "Do you wish to install npm?" Y; then
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
    nvm install node
    nvm use $(node -v)
    nvm alias default $(node -v)
    _outputMessage "Installed node $(node -v) and NPM v$(npm -v) successfully."
    _outputMessage "Your default node version is node $(node -v)."
    _outputMessage "Installing ANgular CLI & tslint globally."
    npm install -g @angular/cli tslint && \
    _outputMessage "Installed Angular CLI and tslint successfully"
  fi
fi

_scriptCompletedMessage ${start_sec}
