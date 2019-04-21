dev-setup
============

[![CircleCI](https://circleci.com/gh/stephen2m/dev-setup/tree/master.svg?style=svg)](https://circleci.com/gh/stephen2m/dev-setup/tree/master)

Some inspiration drawn from:
- https://github.com/donnemartin/dev-setup
- https://github.com/komuw/hardstone

## Main Aim

Simplify & automate setting up the following:

* **Developer Tools & Apps**: Java, Spring Boot, git, curl, wget, Intellij IDEA, Visual Studio Code, Docker etc
* **Cloud Services**: Amazon Web Services, Kubernetes, Google Cloud
* **Frontend Development Tools**: NPM, Angular, JSHint
* **Backend Development Tools**: Java, Gradle/Maven, Spring Boot

## Sections

### Section 1: About

1. **Scripts tested on Manjaro Deepin 18.0.2 and Ubuntu 18.04.2 Bionic Beaver**
1. **For directories with more than one file, they'll execute based on their numbering, starting from `01_*.sh`**
3. If you fancy using optional githooks, use [my custom githooks](https://github.com/stephen2m/githooks) by running `git submodule update --init && git config core.hooksPath .githooks`

### Section 2: Brief Overview of the Scripts 

* [setup.sh script](#setup-script)
    * This script will kicks-off all the other scripts in the repo, first running the distro-specific scripts then the [common scripts](#common-tasks-scripts)
* [common.sh script](#common-script)
    * Has a few helper functions used by the other scripts.  Handles logic such as outputting progress & error handling,
      determining the user's OS, generic handling of package installation between the tested distros etc
* [tasks/common/*.sh scripts](#common-tasks-scripts)
    * **01_git.sh** setups a few git-related things: gitconfig, global gitignore, auto prune branches on pull/fetch, 
       other git tweaks such as a better git log
    * **02_java.sh** setups Java as per the version specified in common.sh.  By default installs OpenJDK 8
    * **03_npm.sh** setups the latest NPM using [NVM](https://github.com/creationix/nvm) (Node Version Managers)
    * **04_ruby.sh** setups Ruby on Rails as per the version specified in common.sh.  By default installs Ruby 2.6.1 and Rails 5.2.2.
      For any issues in the install process, the [gorails setup guide](https://gorails.com/setup) should iron things out

## TODOS
- Add macos scripting
