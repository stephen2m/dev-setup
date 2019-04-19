#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            01_osprep.sh
# Usage:           n/a
# Description:     Installs basic packages needed for an Ubuntu environment
################################################################################
################################################################################

. common.sh

_outputMessage "Started OS init script $(basename $0)"

if [[ $CIRCLECI ]]; then
  _outputMessage "skipping sudo check for circleci"
else
  _hasSudo

  # keep existing `sudo` timestamp until the script is completed
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

_outputMessage "Update system packages"
apt update -y
_outputMessage "Done updating system packages"

apt install -y git software-properties-common gcc build-essential libssl-dev libffi-dev curl wget

LOCALE_CONFIG='#locale
export LC_ALL="en_US.UTF-8"'
grep -qF -- "$LOCALE_CONFIG" /etc/profile || echo "$LOCALE_CONFIG" >> /etc/profile

_scriptCompletedMessage
