#!/usr/bin/env bash

. $(dirname $0)/common.sh

msg "Started $(basename $0) at $(/bin/date "+%F %T")"
start_sec=$(/bin/date +%s.%N)
msg "Please provide your root password to allow this script to work as intended"

# ask for administrator password upfront
sudo -v

# keep existing `sudo` timestamp until `osprep.sh` is completed
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

finish_msg
