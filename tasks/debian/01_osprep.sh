#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            01_osprep.sh
# Usage:           n/a
# Description:     Installs basic packages needed for a debian environment
################################################################################
################################################################################

export DEBIAN_FRONTEND=noninteractive

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1091
. common.sh

_writeHeader "Debian Environment Bootstrapping"

_outputMessage "Started OS init script $(basename "$0")"

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

_outputMessage "Updating system packages"
sudo apt update -y
_outputMessage "Done updating system packages"

sudo apt install -y git xclip unzip zip software-properties-common gcc build-essential libssl-dev libffi-dev zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev iputils-ping libreadline-dev libffi-dev curl wget asciinema snapd apt-transport-https ca-certificates

LOCALE_CONFIG='#locale
export LC_ALL="en_US.UTF-8"'
grep -qF -- "$LOCALE_CONFIG" /etc/profile || echo "$LOCALE_CONFIG" | sudo tee -a /etc/profile >/dev/null

_scriptCompletedMessage ${start_sec}
