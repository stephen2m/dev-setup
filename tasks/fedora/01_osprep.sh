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

_writeHeader "Fedora Environment Bootstrapping"

_outputMessage "Started OS init script $(basename "${0}")"

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

  sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
  sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-modular.repo
  _outputMessage "Modular repos disabled, they will be enabled at the end"
fi

_outputMessage "Updating system packages"
sudo dnf upgrade --best --allowerasing --refresh -y
sudo dnf distro-sync -y
_outputMessage "Done updating system packages"
_outputMessage "Install RpmFusion Free Repo"
###
# RpmFusion Free Repo
# This is holding only open source, vetted applications - fedora just cant legally distribute them themselves thanks to
# Software patents
###
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y git gnome-shell-extension-dash-to-dock gnome-shell-extension-topicons-plus gnome-shell-extension-user-theme gnome-tweak-tool python3-devel dnf-plugins-core

if [[ ! ${CIRCLECI} ]]; then
  sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/fedora-updates-modular.repo
  sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/fedora-modular.repo
  _outputMessage "Modular repos re-enabled"

  sudo systemctl enable --now tuned
  sudo tuned-adm profile balanced

  LOCALE_CONFIG='#locale
  export LC_ALL="en_US.UTF-8"'
  grep -qF -- "$LOCALE_CONFIG" /etc/profile || echo "$LOCALE_CONFIG" | sudo tee -a /etc/profile >/dev/null
fi

_scriptCompletedMessage ${start_sec}
