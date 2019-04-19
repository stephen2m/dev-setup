#!/usr/bin/env bash
################################################################################
################################################################################
# Name:            04_ruby.sh
# Usage:           n/a
# Description:     Installs Ruby on Rails (versions specified in common.sh)
################################################################################
################################################################################

. common.sh

_outputMessage "Started ruby on rails installation script $(basename $0)"

if [[ $CIRCLECI ]]; then
  _outputMessage "skipping sudo check for circleci"
else
  _hasSudo

  # keep existing `sudo` timestamp until the script is completed
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

answer=`_promptUser "Do you wish to install Ruby $RUBY_VERSION and Rails $RAILS_VERSION?" false`
userResponse=${answer}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
  if [[ ! -e "~/.rbenv/plugins" ]]; then
    mkdir -p ~/.rbenv/plugins
  fi
  _outputMessage "Cloning rbenv repo"
  git clone${RBENV_REPO} ~/.rbenv/plugins/ruby-build

  if [[ $SHELL == "/usr/bin/zsh" ]]; then
    userShell="zsh"
  else
    userShell="bash"
  fi

  _outputMessage "Installing Ruby $RUBY_VERSION"
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.${userShell}rc
  source ~/.${userShell}
  rbenv install ${RUBY_VERSION}
  rbenv rehash
  rbenv global ${RUBY_VERSION}

  _outputMessage "Installing Rails $RAILS_VERSION"
  echo 'gem: --no-document' >> ~/.gemrc
  gem install bundler ruby-debug-ide debase
  gem install rails -v ${RAILS_VERSION}
  rbenv rehash
fi

_scriptCompletedMessage
