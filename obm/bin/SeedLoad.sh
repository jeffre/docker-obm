#!/bin/sh
# Ahsay Online Backup Manager 6.27.0.0

################################  SeedLoad.sh  #################################
# You can use this shell script to seed load any of your backup sets from the  #
# command line. Just customize the "User Defined Section" below with your      #
# values for your seed load action.                                            #
################################################################################

######################### START: User Defined Section ##########################

# -------------------------------  BACKUP_SET  ---------------------------------
# | The name or ID of the backup set that you want to run                      |
# | If backup set name is not in English, please use BackupSetID               |
# | e.g. BACKUP_SET="1119083740107"                                            |
# |   or BACKUP_SET="FileBackupSet-1"                                          |
# |                                                                            |
# | You can leave this parameter blank if you have only 1 backup set.          |
# ------------------------------------------------------------------------------
BACKUP_SET=""

# -------------------------------  OUTPUT_DIR  ---------------------------------
# | The directory where you want your seed loaded file to be spooled           |
# | e.g. OUTPUT_DIR="${HOME}/Seedload"                                         |
# ------------------------------------------------------------------------------
OUTPUT_DIR=""

# ------------------------------  BACKUP_TYPE  ---------------------------------
# | Set backup type. You don't need to change this if you are backing up a     |
# | file backup set.                                                           |
# | Options available: FILE/DATABASE/DIFFERENTIAL/LOG                          |
# | e.g. BACKUP_TYPE="FILE"          for file backup                           |
# |  or  BACKUP_TYPE="DATABASE"      for Full database backup                  |
# |  or  BACKUP_TYPE="DIFFERENTIAL"  for Differential database backup          |
# |  or  BACKUP_TYPE="LOG"           for Log database backup                   |
# ------------------------------------------------------------------------------
BACKUP_TYPE="FILE"

# ------------------------------  SETTING_HOME  --------------------------------
# | Directory to your setting home.                                            |
# | Default to ${HOME}/.obm when not set.                                      |
# | e.g. SETTING_HOME="${HOME}/.obm"                                           |
# ------------------------------------------------------------------------------
SETTING_HOME=""

########################## END: User Defined Section ###########################

################################################################################
#             P A R A M E T E R             V E R I F I C A T I O N            #
################################################################################

# Input Arguments will overwrite the above settings
# defined in 'User Defined Section'.
if [ $# -ge 2 ]; then

    if [ -n "$1" ]; then
        BACKUP_SET="$1"
    fi

    if [ -n "$2" ]; then
        OUTPUT_DIR="$2"
    fi

fi

if [ -z "${OUTPUT_DIR}" ]; then
    echo "Please set OUTPUT_DIR"
    exit 1
fi

###############################################################################
#        R E T R I E V E            A P P _ H O M E            P A T H        #
###############################################################################

EXE_DIR=`pwd`
SCRIPT_HOME=`dirname "$0"`
cd "$SCRIPT_HOME"
APP_BIN=`pwd`
APP_HOME=`dirname "$APP_BIN"`

###############################################################################
#        R E T R I E V E           J A V A _ H O M E           P A T H        #
###############################################################################

if [ "Darwin" = `uname` ]; then
    JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
fi

if [ ! -x "$APP_HOME/jvm" ];
then
    echo "'$APP_HOME/jvm' does not exist!"
    if [ ! -n "$JAVA_HOME" ]; then
        echo "Please set JAVA_HOME!"
        exit 0
    else
        ln -sf "$JAVA_HOME" "$APP_HOME/jvm"
        echo "Created JAVA_HOME symbolic link at '$APP_HOME/jvm'"
    fi
fi

if [ ! -x "$APP_HOME/jvm" ];
then
    echo "Please create symbolic link for '$JAVA_HOME' to '$APP_HOME/jvm'"
    exit 0
fi

JAVA_HOME="$APP_HOME/jvm"
JAVA_EXE="$JAVA_HOME/bin/java"

# Verify the JAVA_EXE whether it can be executed or not.
if [ ! -x "${JAVA_EXE}" ]
then
    echo "The Java Executable file \"${JAVA_EXE}\" cannot be executed. Exit \""`basename "$0"`"\" now."
    exit 1
fi

# Verify the JAVA_EXE whether it is a valid JAVA Executable or not.
STRING_JAVA_VERSION="java version,openjdk version"
OUTPUT_JAVA_VERSION=`"${JAVA_EXE}" -version 2>&1`
OUTPUT_JVM_SUPPORT=0
BACKUP_IFS=$IFS
IFS=","
for word in $STRING_JAVA_VERSION; do
    if [ `echo "${OUTPUT_JAVA_VERSION}" | grep "${word}" | grep -cv "grep ${word}"` -le 0 ]
    then
      #echo "The Java Executable \"${JAVA_EXE}\" is not a valid Java Executable. Exit \""`basename "$0"`"\" now."
      continue;
    else
      OUTPUT_JVM_SUPPORT=1
      break;
    fi
done
IFS=$BACKUP_IFS
if [ $OUTPUT_JVM_SUPPORT -eq 0 ]
then
    echo "The Java Executable \"${JAVA_EXE}\" is not a valid Java Executable. Exit \""`basename "$0"`"\" now."
    exit 1
fi

###############################################################################
#      E X E C U T I O N          J A V A         P R O P E R T I E S         #
###############################################################################

# Set LD_LIBRARY_PATH for Lotus Notes on Linux
if [ "Linux" = `uname` ];
then
    NOTES_PROGRAM=`cat "$APP_HOME/bin/notesenv"`
    LD_LIBRARY_PATH="${APP_HOME}/bin":"${NOTES_PROGRAM}":"${LD_LIBRARY_PATH}"
    export NOTES_PROGRAM
else
    LD_LIBRARY_PATH="${APP_HOME}/bin":"${LD_LIBRARY_PATH}"
fi

DEP_LIB_PATH="X64"
case "`uname -m`" in
    i[3-6]86)
        DEP_LIB_PATH="X86"
    ;;
esac
LD_LIBRARY_PATH="${APP_BIN}/${DEP_LIB_PATH}":"${LD_LIBRARY_PATH}"

# Set Library path for other OS
SHLIB_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH SHLIB_PATH



###############################################################################
#                  J A V A                 E X E C U T I O N                  #
###############################################################################

# Change to APP_BIN for JAVA execution
cd "${APP_BIN}"

# Reference path will be used to avoid empty space in the parent directory
LIB_HOME=.
JAVA_OPTS="-Xrs -Xms128m -Xmx768m -client"
JNI_PATH="-Djava.library.path=$LIB_HOME"
CLASSPATH="$LIB_HOME:$LIB_HOME/obc.jar:$LIB_HOME/obc-lib.jar"
MAIN_CLASS=SeedLoad

# Do not include double-quote for java options, jni path, classpath and main class
# Only apply double-quote for path to java executable and execution arguments
"${JAVA_EXE}" $JAVA_OPTS $JNI_PATH -cp $CLASSPATH $MAIN_CLASS "${APP_HOME}" "${BACKUP_SET}" "${OUTPUT_DIR}" "${BACKUP_TYPE}" "${SETTING_HOME}"

###############################################################################
#                   R E S E T          A N D          E X I T                 #
###############################################################################

cd "${EXE_DIR}"
exit 0
