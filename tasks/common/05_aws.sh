#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            05_aws.sh
# Usage:           n/a
# Description:     Setups AWS CLI & EB CLI, and runs the AWS config
################################################################################
################################################################################

# shellcheck disable=SC1091
. common.sh

_outputMessage "Started AWS configuration script $(basename "$0")"

if [[ $(_ask "Do you wish to install the AWS CLI and EB CLI tools (will also install Python 3 and PIP)" "Y") ]]; then
    if [[ $(which python3) == "/usr/bin/python3" ]]; then
      _outputMessage "Skipping installing Python as there's already an installed version: $(python --version 2>&1 | head -n 1)"
    else
      _outputMessage "Installing Python 3"
      _installPackage python3
      outputMessage "Python 3 successfully installed to: $(python --version 2>&1 | head -n 1)"
    fi

    if [[ $(which pip) == "/usr/bin/pip" ]]; then
      _outputMessage "Skipping installing PIP as there's already an installed version: $(pip --version 2>&1 | head -n 1)"
    else
      _outputMessage "Installing PIP"
      wget -q https://bootstrap.pypa.io/get-pip.py
      python get-pip.py
      _outputMessage "PIP successfully installed to: $(pip --version 2>&1 | head -n 1)"
    fi

    if [[ $(_ask "Do you wish to install the AWS CLI" "Y") ]]; then
      pip install awscli --upgrade --user
      _outputMessage "AWS CLI successfully installed"
    fi

    if [[ ! {$CIRCLECI} ]]; then
      # for any issues, refer to https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
      if [[ $(_ask "Do you wish to configure AWS CLI.  You'll need your AWS Access Key ID and AWS Secret Access Key" "Y") ]]; then
        aws configure
      fi
    fi

    if [[ $(_ask "Do you wish to install the EB CLI" "Y") ]]; then
      #  for any issues, refer to https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html#eb-cli3-install.scripts
      git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git
      .\aws-elastic-beanstalk-cli-setup\scripts\bundled_installer
      _outputMessage "EB CLI successfully installed"
    fi
fi
