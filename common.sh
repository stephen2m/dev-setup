#!/usr/bin/env bash

# common functions useful to the other scripts

LOG_DIRECTORY='logs'
LOG_FILE="${LOG_DIRECTORY}/"`date +%Y-%m-%d`.log

# Usage: msg <message>
#
# Outputs <message> to the terminal
# And also logs to the current LOG_FILE value
msg() {
  if [[ ! -d "$LOG_DIRECTORY" ]]; then
    mkdir ${LOG_DIRECTORY}
  fi

  if [[ ! -e "$LOG_FILE" ]]; then
    touch ${LOG_FILE}
  fi

  local fmt="$1"; shift
  printf "$(/bin/date "+%F %T"): $fmt\n" "$@" | tee -a ${LOG_FILE}
}

# Usage: finish_msg
#
# Prints some finishing statistics
finish_msg() {
  end_sec=$(/bin/date +%s.%N)
  elapsed_seconds=$(echo "$end_sec" "$start_sec" | awk '{ print $1 - $2 }')

  msg "Finished execution of $(basename $0) in $elapsed_seconds seconds\n"
}

# Usage: error_exit <message>
#
# Writes <message> to STDERR as a "fatal" and immediately exits the currently running script.
error_exit() {
    local message=$1

    echo "[FATAL] $message\n" 1>&2 | tee -a ${LOG_FILE}
    exit 1
}

# Usage: get_linux_version
# Determines linux-flavor running on the machine in use
# Currently only detects debian and arch
get_linux_version() {
  dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`

  echo "$dist"
}

# Usage prompt_user <question> <default-boolean-response>
prompt_user() {
  QUESTION=$1
  DEFAULT=$2
  if [[ "$DEFAULT" = true ]]; then
    OPTIONS="[Y/n]"
    DEFAULT="y"
  else
    OPTIONS="[y/N]"
    DEFAULT="n"
  fi
  read -ep "$QUESTION $OPTIONS " -n 1 -s -r INPUT
  INPUT=${INPUT:-${DEFAULT}}
  echo ${INPUT}
  if [[ "$INPUT" =~ ^[yY]$ ]]; then
    ANSWER=true
  else
    ANSWER=false
  fi
}
