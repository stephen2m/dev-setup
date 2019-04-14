#!/usr/bin/env bash

# common functions useful to the other scripts

# Usage: msg <message>
#
# Outputs <message> to the terminal
msg() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

# Usage: finish_msg
#
# Prints some finishing statistics
finish_msg() {
  msg "Finished $(basename $0) at $(/bin/date "+%F %T")"

  end_sec=$(/bin/date +%s.%N)
  elapsed_seconds=$(echo "$end_sec" "$start_sec" | awk '{ print $1 - $2 }')

  msg "Elapsed time: $elapsed_seconds"
}

# Usage: error_exit <message>
#
# Writes <message> to STDERR as a "fatal" and immediately exits the currently running script.
error_exit() {
    local message=$1

    echo "[FATAL] $message" 1>&2
    exit 1
}

# Usage: get_linux_version
# Determines linux-flavor running on the machine in use
# Currently only detects debian and arch
get_linux_version() {


}
