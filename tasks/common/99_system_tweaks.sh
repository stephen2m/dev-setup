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

if [[ $(_getLinuxVersion) =~ ^[manjaro]$ ]]; then
  # https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
  # https://stackoverflow.com/questions/535768/what-is-a-reasonable-amount-of-inotify-watches-with-linux
  _outputMessage "Increase inotify watches to half the value of the max possible value ie 524288/2 => 262144"
  echo fs.inotify.max_user_watches=262144 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

  _outoutMessage "Enable user namespaces"
  echo kernel.unprivileged_userns_clone = 1 | sudo tee /etc/sysctl.d/00-local-userns.conf

  _outputMessage "Adding TLP, thermald and cpupower for better power & CPU management"
  yay --noconfirm --needed -S tlp
  sudo systemctl enable tlp
  sudo systemctl enable tlp-sleep.service

  yay --noconfirm --needed -S thermald
  sudo systemctl enable thermald

  yay --noconfirm --needed -S cpupower
  sudo systemctl enable cpupower
fi

_scriptCompletedMessage
