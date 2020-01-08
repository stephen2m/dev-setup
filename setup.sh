#!/usr/bin/env bash

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1090
. "$(dirname "$0")/common.sh"

_outputMessage "Started script $(basename "$0") for a $(_getLinuxVersion)-based distro"

distro=$(_getLinuxVersion)
targetDistros=("arch" "debian" "fedora")

if [[ "${distro}" == "fedora" && ${CIRCLECI} ]]; then
  dnf -y update && dnf install findutils -y && dnf clean all
fi

if [[ "${targetDistros[@]}" =~ "${distro}" ]]; then
  for file in $(find tasks/${distro}/*.sh | sort); do
    bash "$file" -H || break
  done
else
  _errorExit "Could not determine your OS. OS distro identifier found $(_getLinuxVersion)"
fi

for file in $(find tasks/common/*.sh | sort); do
  bash "$file" -H || break
done

_scriptCompletedMessage ${start_sec}
