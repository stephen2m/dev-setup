#!/usr/bin/env bash
. ../../common.sh

GLOBAL_GITIGNORE="~/.gitignore"

msg "Started git configuration script $(basename $0)"

if [[ ! -e "$GLOBAL_GITIGNORE" ]]; then
    msg "Initializing global gitignore and update gitconfig"
    touch ${GLOBAL_GITIGNORE}
    git config --global core.excludesfile ${GLOBAL_GITIGNORE}
fi

ANSWER=`prompt_user "Do you wish to initialize your gitconfig?" false`
userResponse=${ANSWER}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
    echo -n "Enter your git name: "
    read git_name

    echo -n "Enter your git email address: "
    read git_email

    git config --global user.name ${git_name}
    git config --global user.email ${git_email}
fi

ANSWER=`prompt_user "Do you wish to enable auto prune on fetch or pull?" true`
userResponse=${ANSWER}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
    ## https://stackoverflow.com/a/40842589/499855
    msg "Enabling auto prune on fetch or pull"
    git config --global fetch.prune true
    git config --global gui.pruneDuringFetch true
fi

ANSWER=`prompt_user "Do you wish to enable a better looking git log?" true`
userResponse=${ANSWER}
if [[ ${userResponse} =~ ^[Yy]$ ]]; then
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.lg-ascii "log --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit"
fi

finish_msg
