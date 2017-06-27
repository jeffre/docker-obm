#!/bin/sh
# Ahsay Online Backup Manager 6.29.0.0

# ------------------------- Retrieve APP_HOME ----------------------------------
cd `dirname "$0"`
APP_BIN=`pwd`
APP_HOME=`dirname "$APP_BIN"`
UTIL_HOME=${APP_HOME}/util
AUA_HOME=${APP_HOME}/aua
AUA_BIN=${AUA_HOME}/bin

# -------------------- Print Logging Message Header ----------------------------
echo "Log Time: `date`"
# ------------ Verify if the privilege is enough for install ------------------
## Verify the privilege if the shell script "privilege.sh" exist.
echo ""
if [ -f "$UTIL_HOME/bin/privilege.sh" ]
then
  echo "Verifying current user privilege ..."
  "$UTIL_HOME/bin/privilege.sh" "install"
  [ $? -ne 0 ] && echo "Exit \"`basename $0`\" now!" && exit 1
else
  echo "The shell script \"$UTIL_HOME/bin/privilege.sh\" is missing."
  echo "Exit \"`basename $0`\" now!" && exit 1
fi
echo "Current user has enough privilege to \"install\"."
echo ""

# -------------------- Print Logging Message -----------------------------------

case "`uname`" in
  Linux*)   echo "Start installation on Generic Linux Platform (`uname`)";;
  Solaris*) echo "Start installation on Solaris 2.X Platform (`uname`)";;
  SunOS*)   echo "Start installation on Solaris 5.X Platform (`uname`)";;
  *BSD*)    echo "Start installation on BSD distribution Platform (`uname`)";;
  **)       echo "This OS `uname` is not supported by this script! Exit `basename $0` now!"
            exit 0 ;;
esac

echo ""

echo "Installation Path: ${APP_HOME}"

# ----------------------- Configure Application --------------------------------
cd "$APP_BIN"
echo "Configure Application Path: ${APP_HOME}"
./config.sh 1>config.log 2>&1

[ $? -ne 0 ] && echo "" && echo "Error is found during \"config\"." && echo "Please read the file \"`pwd`/config.log\" for more information." && echo "\"Exit \"`basename $0`\" now!" && exit 1
# ------------------------- Install Scheduler ----------------------------------
echo "Installing Scheduler Service"
SCH_SCRIPT_PATH=${APP_BIN}
SCH_SCRIPT_NAME=obmscheduler

cd "${APP_BIN}"

# Create the service script
case "`uname`" in
  Linux*)   SCH_SCRIPT_SRC=scheduler ;;
  Solaris*) SCH_SCRIPT_SRC=scheduler ;;
  SunOS*)   SCH_SCRIPT_SRC=scheduler ;;
  OpenBSD*) SCH_SCRIPT_SRC=scheduler-openbsd ;;
  *BSD*)    SCH_SCRIPT_SRC=scheduler-bsd ;;
  **)       echo "This OS `uname` is not supported by this script! Exit `basename $0` now!"
            exit 0 ;;
esac

sed "s|@sed.script.name@|${SCH_SCRIPT_NAME}|g" <./${SCH_SCRIPT_SRC} | sed "s|@sed.product.home@|${APP_HOME}|g" > ./${SCH_SCRIPT_NAME}

echo "Scheduler Service Script created at ${APP_BIN}/${SCH_SCRIPT_NAME}"

"${UTIL_HOME}/bin/install-service.sh" "${SCH_SCRIPT_PATH}/${SCH_SCRIPT_NAME}"

# ------------------------- Install AutoUpdate ---------------------------------
echo "Installing AutoUpdate Service"
AUA_SCRIPT_PATH=$AUA_BIN
AUA_SCRIPT_NAME=obmaua

cd "${AUA_BIN}"

case "`uname`" in
  Linux*)   AUA_SCRIPT_SRC=autoupdate ;;
  Solaris*) AUA_SCRIPT_SRC=autoupdate ;;
  SunOS*)   AUA_SCRIPT_SRC=autoupdate ;;
  OpenBSD*) AUA_SCRIPT_SRC=autoupdate-openbsd ;;
  *BSD*)    AUA_SCRIPT_SRC=autoupdate-bsd ;;
  **)       echo "This OS `uname` is not supported by this script! Exit `basename $0` now!"
            exit 0 ;;
esac

sed "s|@sed.script.name@|${AUA_SCRIPT_NAME}|g" <./${AUA_SCRIPT_SRC} | sed "s|@sed.autoupdate.home@|${AUA_HOME}|g" > ./${AUA_SCRIPT_NAME}
echo "AutoUpdate Service Script created at ${AUA_BIN}/${AUA_SCRIPT_NAME}"

"${UTIL_HOME}/bin/install-service.sh" "${AUA_SCRIPT_PATH}/${AUA_SCRIPT_NAME}"

# -------------------------- Startup Services ----------------------------------
echo "Run Scheduler Service"
sh "${APP_BIN}/Scheduler.sh" &
echo "Started Scheduler Service"

echo "Run AutoUpdate Service"
sh "${AUA_BIN}/startup.sh" &
echo "Started AutoUpdate Service"

exit 0
