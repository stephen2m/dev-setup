#!/usr/bin/env bash

################################################################################
################################################################################
# Name:            01_git.sh
# Usage:           n/a
# Description:     Setups git basics, distro-agnostic
################################################################################
################################################################################

# shellcheck disable=SC1091
. common.sh

GLOBAL_GITIGNORE="$HOME/.gitignore"
SSH_KEY_PUB="$HOME/.ssh/id_rsa.pub"

_outputMessage "Started git configuration script $(basename "$0")"

if [[ ! -e "$GLOBAL_GITIGNORE" ]]; then
 _outputMessage "Initializing global gitignore and update gitconfig"
 touch "${GLOBAL_GITIGNORE}"
 git config --global core.excludesfile "${GLOBAL_GITIGNORE}"
fi

if [[ $(_ask "Do you wish to initialize your gitconfig?" "Y") && !{CIRCLE} ]]; then
  echo -n "Enter your git name: "
  read -r git_name

  echo -n "Enter your git email address: "
  read -r git_email

  git config --global user.name ${git_name:="circleci"}
  git config --global user.email ${git_email:="circleci@testing.com"}
fi

if ! [[ -f ${SSH_KEY_PUB} && !${CIRCLECI} ]]; then
  if [[ $(_ask "Do you wish to create an SSH key?" "Y") ]]; then
    ssh-keygen  -t rsa -b 4096 -o -a 100 -q
    [[ -f ${SSH_KEY_PUB} ]] && cat ${SSH_KEY_PUB} | xclip -r -selection clipboard
    _outputMessage "Public key successfully created and copied into your clipboard."
  fi
fi

if [[ $(_ask "Do you wish to enable auto prune on fetch or pull?" "Y") ]]; then
  # https://stackoverflow.com/a/40842589/499855
  _outputMessage "Enabling auto prune on fetch or pull"
  git config --global fetch.prune true
  git config --global gui.pruneDuringFetch true
fi

if [[ $(_ask "Do you wish to enable a better looking git log?" "Y") ]]; then
  git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
  git config --global alias.lg-ascii "log --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit"
  _outputMessage "Done"
fi

_scriptCompletedMessage
