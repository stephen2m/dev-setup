gnome-shell-extension-dash-to-dock gnome-shell-extension-topicons-plus gnome-shell-extension-user-theme gnome-tweak-tool
#!/usr/bin/env bash
################################################################################
################################################################################
# Name:            08_desktop_environments.sh
# Usage:           n/a
# Description:     Installs some helpful addons for common desktop environments
################################################################################
################################################################################

start_sec=$(/bin/date +%s.%N)

# shellcheck disable=SC1091
. common.sh

logMessage="Desktop environment addons"

_writeHeader "${logMessage}"

_outputMessage "Started ${logMessage} $(basename "$0")"

currentDesktop=$(echo $XDG_CURRENT_DESKTOP | tr '[:upper:]' '[:lower:]')

gnomeExtras=("gnome-tweak-tools" "gnome-shell-extension-dash-to-dock" "gnome-shell-extension-topicons-plus")

if [[ ! ${CIRCLECI} && $DISPLAY != x ]]; then
  case $(currentDesktop) in
    gnome)
      for extra in $gnomeExtras; do
        if _ask "Do you wish to install ${extra}?"; then
          _installPackage ${extra}
        fi
      done
      ;;
    *)
      _outputMessage "Could not determine desktop environment in use. Found $(currentDesktop)"
      ;;
  esac
else
  _outputMessage "Found env variable CIRCLECI and skipped customizations"
fi

_scriptCompletedMessage ${start_sec}
