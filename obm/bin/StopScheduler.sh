#!/bin/sh
# Ahsay Online Backup Manager 6.29.0.0

#############################  Scheduler.sh  ###################################
# Stop scheduler.                                                              #
################################################################################

################################################################################
#      R E T R I E V E            A P P _ H O M E           P A T H            #
################################################################################

EXE_DIR=`pwd`
SCRIPT_HOME=`dirname "$0"`
cd "$SCRIPT_HOME"
APP_BIN=`pwd`
APP_HOME=`dirname "$APP_BIN"`

touch "$APP_HOME/ipc/Scheduler/stop"

exit 0
