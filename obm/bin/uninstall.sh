#!/bin/sh
# Ahsay Online Backup Manager 6.27.0.0

# ------------------------- Retrieve APP_HOME ----------------------------------
cd `dirname "$0"`
APP_BIN=`pwd`
APP_HOME=`dirname $APP_BIN`
UTIL_HOME=${APP_HOME}/util
AUA_HOME=$APP_HOME/aua

# ------------ Print Logging Message Header ------------------------------------
echo "Log Time: `date`"
# ------------ Verify if the privilege is enough for uninstall ----------------
## Verify the privilege if the shell script "privilege.sh" exist.
echo ""
if [ -f "$UTIL_HOME/bin/privilege.sh" ]
then
  echo "Verifying current user privilege ..."
  "$UTIL_HOME/bin/privilege.sh" "uninstall"
  [ $? -ne 0 ] && echo "Exit \"`basename $0`\" now!" && exit 1
else
  echo "The shell script \"$UTIL_HOME/bin/privilege.sh\" is missing."
  echo "Exit \"`basename $0`\" now!" && exit 1
fi
echo "Current user has enough privilege to \"uninstall\"."
echo ""

# ------------------------- Uninstall Procedure --------------------------------

# Print Logging Message Header
echo "Uninstall Ahsay Online Backup Manager from $APP_HOME"
echo ""

cd "$APP_BIN"
SCH_SCRIPT_NAME=obmscheduler

if [ -d "$APP_HOME/ipc/Scheduler" ];
then
  if [ -f "$APP_HOME/ipc/Scheduler/running" ];
  then
    echo "Shutting down Scheduler"
    touch "$APP_HOME/ipc/Scheduler/stop"
    echo "Wait 5 seconds before Scheduler exits"
    sleep 5
  fi
fi

# Remove Scheduler service file
echo "Removing Scheduler script $SCH_SCRIPT_NAME from service"
"$UTIL_HOME/bin/remove-service.sh" $SCH_SCRIPT_NAME

# ------------------------------------------------------------------------------
cd "$AUA_HOME/bin"
AUA_SCRIPT_NAME=obmaua

./shutdown.sh
echo "Wait 5 seconds before AutoUpdateAgent exits"

# Remove AutoUpdate service file
echo "Removing AutoUpdate script $AUA_SCRIPT_NAME from service"
"$UTIL_HOME/bin/remove-service.sh" $AUA_SCRIPT_NAME

# -------------------------- Finished Uninstallation ---------------------------

echo "Ahsay Online Backup Manager uninstall procedure is complete!"
echo "It is now safe to remove files from $APP_HOME"

exit 0
