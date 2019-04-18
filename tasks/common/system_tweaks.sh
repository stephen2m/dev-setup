#!/usr/bin/env bash
. ../../common.sh

if [[ $(get_linux_version) =~ ^[manjaro]$ ]]; then
    echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system
fi
