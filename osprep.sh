#!/usr/bin/env bash

. $(dirname $0)/common.sh

msg "Started script $(basename $0) using $(get_linux_version) config"
start_sec=$(/bin/date +%s.%N)
printf "\nPlease provide your root password to allow this script to work as intended\n"

# ask for administrator password upfront
sudo -v

# keep existing `sudo` timestamp until `osprep.sh` is completed
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

finish_msg
