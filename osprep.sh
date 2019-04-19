#!/usr/bin/env bash

. common.sh

_outputMessage "Started script $(basename $0) using $(_getLinuxVersion) config"
start_sec=$(/bin/date +%s.%N)

_scriptCompletedMessage
