#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            01_git.sh
# Usage:           n/a
# Description:     Setups git basics, distro-agnostic
################################################################################
################################################################################

. common.sh

GLOBAL_GITIGNORE="~/.gitignore"

_outputMessage "Started git configuration script $(basename $0)"

# if [[ ! -e "$GLOBAL_GITIGNORE" ]]; then
#   _outputMessage "Initializing global gitignore and update gitconfig"
#   touch ${GLOBAL_GITIGNORE}
#   git config --global core.excludesfile ${GLOBAL_GITIGNORE}
# fi

if [[ ${CIRCLECI} != true ]]; then
  ANSWER=`_promptUser "Do you wish to initialize your gitconfig?" false`
  userResponse=${ANSWER}

  echo -n "Enter your git name: "
  read git_name

  echo -n "Enter your git email address: "
  read git_email
fi

if [[ ${userResponse} =~ ^[Yy]$ || ${CIRCLECI} ]]; then
  git config --global user.name ${git_name:="circleci"}
  git config --global user.email ${git_email:="circleci@testing.com"}
fi

if [[ ${CIRCLECI} != true ]]; then
  ANSWER=`_promptUser "Do you wish to enable auto prune on fetch or pull?" true`
  userResponse=${ANSWER}
fi

if [[ ${userResponse} =~ ^[Yy]$ || ${CIRCLECI} ]]; then
  # https://stackoverflow.com/a/40842589/499855
  _outputMessage "Enabling auto prune on fetch or pull"
  git config --global fetch.prune true
  git config --global gui.pruneDuringFetch true
fi

if [[ ${CIRCLECI} != true ]]; then
  ANSWER=`_promptUser "Do you wish to enable a better looking git log?" true`
  userResponse=${ANSWER}
fi

if [[ ${userResponse} =~ ^[Yy]$ || ${CIRCLECI} ]]; then
  git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
  git config --global alias.lg-ascii "log --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit"
fi

_scriptCompletedMessage
