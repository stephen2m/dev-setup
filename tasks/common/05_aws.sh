#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            05_aws.sh
# Usage:           n/a
# Description:     Setups AWS CLI & EB CLI, and runs the AWS config
################################################################################
################################################################################

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1091
. common.sh

_writeHeader "AWS CLI and EB CLI Setup"

if _ask "Do you wish to install the AWS CLI and EB CLI tools (will also install Python 3 and PIP)" Y; then
    if [[ ${CIRCLECI} ]]; then
      _outputMessage "Skipping sudo check for circleci"
    else
      _hasSudo

      # keep existing `sudo` timestamp until the script is completed
      while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi

    if [[ $(which python3) =~ "/usr/bin/python" ]]; then
      _outputMessage "Skipping installing Python as there's already an installed version: $(python3 --version 2>&1 | head -n 1)"
    else
      _outputMessage "Installing Python 3"
      cd /tmp
      wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
      tar -xf Python-3.7.3.tar.xz
      cd Python-3.7.3
      ./configure --enable-optimizations
      make -j 8
      sudo make altinstall
      outputMessage "Python 3 successfully installed to: $(python3 --version 2>&1 | head -n 1)"
    fi

    if [[ $(which pip) == "/usr/bin/pip" ]]; then
      _outputMessage "Skipping installing PIP as there's already an installed version: $(pip --version 2>&1 | head -n 1)"
    else
      _outputMessage "Installing PIP"
      if [[ $(_getLinuxVersion) == "debian" ]]; then
        _installPackage python3-distutils
        _installPackage python3-testresources
      fi
      wget -q https://bootstrap.pypa.io/get-pip.py
      sudo python3 get-pip.py
      _outputMessage "PIP successfully installed to: $(pip --version 2>&1 | head -n 1)"
    fi

    if _ask "Do you wish to install the AWS CLI" Y; then
      pip3 install awscli --upgrade --user
      _outputMessage "AWS CLI successfully installed"
    fi

    if [[ ! {$CIRCLECI} ]]; then
      # for any issues, refer to https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
      if [[ $(_ask "Do you wish to configure AWS CLI.  You'll need your AWS Access Key ID and AWS Secret Access Key" "Y") ]]; then
        aws configure
      fi
    fi

    if _ask "Do you wish to install the EB CLI" Y; then
      # for any issues, refer to https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html#eb-cli3-install.scripts
      git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git
      .\aws-elastic-beanstalk-cli-setup\scripts\bundled_installer
      _outputMessage "EB CLI successfully installed"
    fi
fi

_scriptCompletedMessage ${start_sec}
