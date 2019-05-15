#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            osprep.sh
# Usage:           n/a
# Description:     Sets commonly needed os-level tweaks depending on distro
################################################################################
################################################################################

start_sec=$(/bin/date +%s.%N)

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

if [[ $(_getLinuxVersion) == "arch" ]]; then
  # https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
  # https://stackoverflow.com/questions/535768/what-is-a-reasonable-amount-of-inotify-watches-with-linux
  _outputMessage "Increase inotify watches to half the value of the max possible value ie 524288/2 => 262144"
  echo fs.inotify.max_user_watches=262144 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

  _outoutMessage "Enable user namespaces"
  echo kernel.unprivileged_userns_clone = 1 | sudo tee /etc/sysctl.d/00-local-userns.conf

  # only install TLP and thermald if script is running on a laptop
  if [[ -f /sys/module/battery/initstate || -d /proc/acpi/battery/BAT* ]]; then
    _outputMessage "Installing TLP and thermald for better power management"
    _installPackage tlp
    sudo systemctl enable tlp
    sudo systemctl enable tlp-sleep.service

    _installPackage thermald
    sudo systemctl enable thermald
  fi

  _outputMessage "Installing cpupower to enable scaling CPU frequency"
  _installPackage cpupower
  sudo systemctl enable cpupower
fi

_scriptCompletedMessage $start_sec
