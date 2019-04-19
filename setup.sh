#!/usr/bin/env bash

. common.sh

_outputMessage "Started script $(basename $0) for $(_getLinuxVersion)"
start_sec=$(/bin/date +%s.%N)

case $(_getLinuxVersion) in
  ManjaroLinux)
    for file in `ls tasks/arch/*.sh | sort`
    do
      ./file
    done
    ;;
  Ubuntu)
    for file in `ls tasks/ubuntu/*.sh | sort`
    do
      ./file
    done
    ;;
  *)
    _errorExit "Could not determine your OS. OS parser found $(_getLinuxVersion)"
    ;;
esac

for file in `ls tasks/common/*.sh | sort`
do
  ./file
done

_scriptCompletedMessage
