#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            06_devops.sh
# Usage:           n/a
# Description:     Heroku CLI, Docker, Virtual Box, K8s, Google Cloud SDK
################################################################################
################################################################################

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1091
. common.sh

logMessage="Heroku CLI, Docker, Kubernetes"

_writeHeader "${logMessage}"

_outputMessage "Started ${logMessage} $(basename "$0")"

if [[ $CIRCLECI = true ]]; then
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

if _ask "Do you wish to install the Heroku CLI client?" Y; then
  curl https://cli-assets.heroku.com/install.sh | sh
  if [[ $(which heroku) == "/usr/local/bin/heroku" ]]; then
    _outputMessage "Heroku CLI binary is at $(which heroku)"
  fi
fi

if _ask "Do you wish to install Docker?" Y; then
  case $(_getLinuxVersion) in
  arch)
    sudo tee /etc/modules-load.d/loop.conf <<<"loop"
    sudo modprobe loop
    _installPackage docker
    _installPackage docker-compose
    sudo systemctl enable docker.service
    sudo gpasswd -a $(whoami) docker
    ;;
  fedora)
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    _installPackage docker-ce
    _installPackage docker-ce-cli
    _installPackage containerd.io
    # enable Docker service to autostart on system boot
    sudo systemctl enable docker
    # allow non-root users to run Docker containers
    #[ $(getent group docker) ] || sudo groupadd docker
    sudo usermod -aG docker $(whoami)
    ;;
  debian)
    # remove older versions of Docker called "docker" or "docker-engine" along with associated dependencies
    sudo apt -y remove docker docker-engine docker.io
    # add the GPG key for Docker repository
    wget https://download.docker.com/linux/debian/gpg | sudo apt-key add gpg
    # Add the official Docker repository to the sources list
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update -y
    _installPackage docker-ce
    # enable Docker service to autostart on system boot
    sudo systemctl enable docker
    # allow non-root users to run Docker containers
    #[ $(getent group docker) ] || sudo groupadd docker
    sudo usermod -aG docker $(whoami)
    ;;
  *)
    _outputMessage "Could not determine OS/distro in use to install docker"
    ;;
  esac
  if [[ $(which docker) == "/usr/bin/docker" ]]; then
    _outputMessage "Docker binary is at $(which docker)"
  fi
fi

if [[ ! ${CIRCLECI} ]]; then
  if _ask "Do you wish to install Virtual Box?" Y; then
    case $(_getLinuxVersion) in
    arch)
      kernelVersion=$(uname -r | awk -F. '{print $1$2}')
      _installPackage virtualbox
      _installPackage linux"$kernelVersion"-virtualbox-host-modules
      _installPackage linux"$kernelVersion"-virtualbox-guest-modules
      _installPackage virtualbox-guest-iso
      sudo modprobe vboxdrv
      _installPackage virtualbox-ext-oracle
      sudo gpasswd -a $(whoami) vboxusers
      ;;
    debian)
      # add the GPG keys of the Oracle VirtualBox repository
      wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
      wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
      # add the repository to the source list
      sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
      # update the package list and install
      sudo apt update -y && _installPackage virtualbox-6.0
      # install the extension pack
      #wget https://download.virtualbox.org/virtualbox/6.0.0/Oracle_VM_VirtualBox_Extension_Pack-6.0.0.vbox-extpack
      #sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.0.0.vbox-extpack
      ;;
    *)
      _outputMessage "Could not determine OS/distro in use to install virtual box"
      ;;
    esac
    if [[ $(which virtualbox) == "/usr/bin/virtualbox" ]]; then
      _outputMessage "VirtualBox binary at $(which virtualbox)"
    fi
  fi

  if _ask "Do you wish to install Kubernetes binaries (kubeadm, kubelet and kubectl)?" Y; then
    case $(_getLinuxVersion) in
    arch)
      _installPackage kubectl-bin
      ;;
    debian)
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a etc/apt/sources.list.d/kubernetes.list
      sudo apt update -y
      _installPackage kubelet
      _installPackage kubeadm
      _installPackage kubectl
      sudo apt-mark hold kubelet kubeadm kubectl
      ;;
    *)
      _outputMessage "Could not determine OS/distro in use to install Kubernetes"
      ;;
    esac
  fi
fi

_scriptCompletedMessage ${start_sec}
