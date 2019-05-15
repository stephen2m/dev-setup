#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            01_osprep.sh
# Usage:           n/a
# Description:     Installs basic packages needed for an ArchLinux environment
################################################################################
################################################################################

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1091
. common.sh

_outputMessage "Started OS init script $(basename "$0")"

if [[ $CIRCLECI = true ]]; then
  _outputMessage "Skipping sudo check for circleci"
else
  _hasSudo

  # keep existing `sudo` timestamp until the script is completed
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

_outputMessage "Update system packages"
sudo pacman -Syyu
_outputMessage "Done updating system packages"


if _ask "Do you wish to speed up compiling packages by changing makeflags and compression settings?" Y; then
  numberOfCores=$(grep -c ^processor /proc/cpuinfo)

  case ${numberOfCores} in
    8)
      _outputMessage "You have ${numberOfCores} cores. Changing the makeflags for ${numberOfCores} cores"
      sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j9"/g' /etc/makepkg.conf
      _outputMessage "Changing the compression settings for ${numberOfCores} cores."
      sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 8 -z -)/g' /etc/makepkg.conf
      ;;
    6)
      _outputMessage "You have ${numberOfCores} cores. Changing the makeflags for ${numberOfCores} cores"
      sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j7"/g' /etc/makepkg.conf
      _outputMessage "Changing the compression settings for ${numberOfCores} cores."
      sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 6 -z -)/g' /etc/makepkg.conf
      ;;
    4)
      _outputMessage "You have ${numberOfCores} cores. Changing the makeflags for ${numberOfCores} cores"
      sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j5"/g' /etc/makepkg.conf
      _outputMessage "Changing the compression settings for ${numberOfCores} cores."
      sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 4 -z -)/g' /etc/makepkg.conf
      ;;
    2)
      _outputMessage "You have ${numberOfCores} cores. Changing the makeflags for ${numberOfCores} cores"
      sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j3"/g' /etc/makepkg.conf
      _outputMessage "Changing the compression settings for ${numberOfCores} cores."
      sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 2-z -)/g' /etc/makepkg.conf
      ;;
    *)
      _outputMessage "Could not determine number of cores. Skipping changing makeflags and compression settings"
      ;;
  esac
fi

# once installed, run `arch-audit --upgradable --quiet` to see packages 
# that have vulnerabilities and a fix has been made
sudo pacman -S --noconfirm --needed git xclip base-devel yay bind-tools zip unzip wget curl asciinema netcat lsd arch-audit

_scriptCompletedMessage $start_sec
