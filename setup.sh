#!/usr/bin/env bash

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1090
. "$(dirname "$0")/common.sh"

_outputMessage "Started script $(basename "$0") for a $(_getLinuxVersion)-based distro"

case $(_getLinuxVersion) in
  arch)
    for file in $(find tasks/arch/*.sh | sort)
    do
      bash "$file" -H || break
    done
    ;;
  debian)
    for file in $(find tasks/debian/*.sh | sort)
    do
      bash "$file" -H || break
    done
    ;;
  *)
    _errorExit "Could not determine your OS. OS parser found $(_getLinuxVersion)"
    ;;
esac

for file in $(find tasks/common/*.sh | sort)
do
  bash "$file" -H || break
done

_scriptCompletedMessage ${start_sec}
