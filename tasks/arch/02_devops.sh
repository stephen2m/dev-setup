#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            osprep.sh
# Usage:           n/a
# Description:     Sets commonly needed os-level tweaks depending on distro
################################################################################
################################################################################

# shellcheck disable=SC1091
. common.sh

_outputMessage "Started system tweaks script $(basename "$0")"

if [[ $CIRCLECI = true ]]; then
  _outputMessage "Skipping sudo check for circleci"
else
  _hasSudo

  # keep existing `sudo` timestamp until the script is completed
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

answer=$(_promptUser "Do you wish to install the Heroku CLI client?" false)
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  _outputMessage "Installing the Heroku CLI"
  _installPackage heroku-cli-nightly
fi

answer=$(_promptUser "Do you wish to install Docker?" false)
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  sudo tee /etc/modules-load.d/loop.conf <<< "loop"
  sudo modprobe loop
  _installPackage docker docker-compose
  sudo systemctl enable docker.service
  sudo gpasswd -a "$USER" docker
fi

answer=$(_promptUser "Do you wish to install Docker?" false)
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  kernelVersion=$(uname -r | awk -F. '{print $1$2}')
  _installPackage virtualbox
  _installPackage linux"${kernelVersion}"-virtualbox-host-modules
  sudo modprobe vboxdrv
  _installPackage virtualbox-ext-oracle
  sudo gpasswd -a "$USER" vboxusers
fi

answer=$(_promptUser "Do you wish to install Kubernetes binaries?" false)
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  _installPackage kubectl-bin
fi

answer=$(_promptUser "Do you wish to install Google Cloud SDK binaries?" false)
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  _installPackage google-cloud-sdk
fi

_scriptCompletedMessage
