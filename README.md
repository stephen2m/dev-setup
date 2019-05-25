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
4. Most yes/no prompts can be disabled by setting an environment variable `AUTO_ANSWER` with the value `true`.
   This however doesn't cover any other user input eg git name & email

### Section 2: Brief Overview of the Scripts 

* [setup.sh script](#setup-script)
    * This script will kicks-off all the other scripts in the repo, first running the distro-specific scripts then the [common scripts](#common-tasks-scripts)
* [common.sh script](#common-script)
    * Has a few helper functions used by the other scripts.  Handles logic such as prompting the user for input, outputting progress messages & error handling, determining the user's OS, generic handling of package installation between the tested distros etc
* [tasks/common/*.sh scripts](#common-tasks-scripts)
    * **01_git.sh** setup a few git-related things: gitconfig, global gitignore, auto prune branches on pull/fetch, other git tweaks such as a better git log
    * **02_java.sh** setup Java as per the version specified in common.sh.  By default installs OpenJDK 8
    * **03_nodejs.sh** setup the latest versions of NodeJS and NPM using [NVM](https://github.com/creationix/nvm) (Node Version Managers)
    * **04_ruby.sh** setup Ruby on Rails as per the version specified in common.sh.  By default installs Ruby 2.6.1 and Rails 5.2.2.
      For any issues in the install process, the [gorails setup guide](https://gorails.com/setup) should iron things out
    * **05_cloud.sh** setup basic cloud-related  - AWS (as well as Python & PIP as a nice side-effect), Google Cloud SDK
    * **06_devops.sh** setup a few common devops tools - Heroku CLI, Docker, Kubernetes
    * **07_ides.sh** setup preferred IDE(s)

## TODOS
- Add macos scripting
