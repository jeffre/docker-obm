#!/bin/sh
# Ahsay Online Backup Manager 6.29.0.0

#################################  Decrypt.sh  #################################
# You can use this shell script to decrypt backup files using command-line.    #
# Just customize the "User Define Section" below with values for your          #
# decrypt action.                                                              #
################################################################################

#########################  Start: User Defined Section  ########################

# ---------------------------------  ID_DIR  -----------------------------------
# | Path to the backup set ID directory                                        |
# | e.g. ID_DIR="/john/files/1119083740107"                                    |
# |      where the directory 1119083740107 is under the "files" directory      |
# |      under the [User Home] directory                                       |
# ------------------------------------------------------------------------------
ID_DIR=""

# -------------------------------  DECRYPT_TO  ---------------------------------
# | Directory to where you want files to be decrypted                          |
# | set to "" to decrypt files to original location                            |
# | e.g. DECRYPT_TO="/tmp"                                                     |
# ------------------------------------------------------------------------------
DECRYPT_TO=""

# ------------------------------  DECRYPT_FROM  --------------------------------
# | File/Directory on the backup server that you would like to decrypt         |
# | e.g. DECRYPT_FROM="/Data"                                                  |
# ------------------------------------------------------------------------------
DECRYPT_FROM=""

# -----------------------------  POINT_IN_TIME  --------------------------------
# | The point-in-time snapshot that you want to decrypt                        |
# | Use "Current" for the latest backup snapshot                               |
# | e.g. POINT_IN_TIME="2006-10-04-12-57-13"                                   |
# |   or POINT_IN_TIME="Current"                                               |
# ------------------------------------------------------------------------------
POINT_IN_TIME=""

# ------------------------------  DECRYPT_KEY  ---------------------------------
# | Your encrypting key. It will be used to decrypt your backup files          |
# | e.g. DECRYPT_KEY="abc"                                                     |
# ------------------------------------------------------------------------------
DECRYPT_KEY=""

# ---------------------------  RESTORE_PERMISSION  -----------------------------
# | set to "Y" if you want to restore file permissions                         |
# | set to "N" if you do NOT want to restore file permissions                  |
# ------------------------------------------------------------------------------
RESTORE_PERMISSION=""

# ----------------------------  SKIP_INVALID_KEY  ------------------------------
# | set to "Y" if you want to skip decrypt file with invalid key               |
# | set to "N" if you want to prompt user to input a correct key               |
# ------------------------------------------------------------------------------
SKIP_INVALID_KEY=""

# ------------------------------  SYNC_OPTION  ---------------------------------
# | Delete extra files                                                         |
# | set to "Y" if you want to enable sync option                               |
# | set to "N" if you do NOT want to enable sync option                        |
# | set to "" to prompt for selection                                          |
# ------------------------------------------------------------------------------
SYNC_OPTION=""

# -------------------------  REPLACE_EXISTING_FILE  ----------------------------
# | set to "-all" to replace all existing file(s) of the same filename         |
# | set to "-none" to skip all existing file(s) with the same filename         |
# | set to "" to prompt for selection                                          |
# ------------------------------------------------------------------------------
REPLACE_EXISTING_FILE="-all"

# ---------------------------------  FILTER  -----------------------------------
# | Filter out what files you want to decrypt                                  |
# | -Pattern=xxx-Type=yyy-Target=zzz                                           |
# | where xxx is the filter pattern,                                           |
# |       yyy is the filter type, whice can be one of the following:           |
# |           [exact | exactMatchCase | contains | containsMatchCase|          |
# |            startWith | startWithMatchCase | endWith | endWithMatchCase]    |
# |       zzz is the filter target, which can be one of the following:         |
# |           [toFile | toFileDir | toDir]                                     |
# |                                                                            |
# | e.g. FILTER="-Pattern=.txt-Type=exact-Target=toFile"                       |
# ------------------------------------------------------------------------------
FILTER=""

##########################  END: User Defined Section  #########################

################################################################################
#      R E T R I E V E            A P P _ H O M E           P A T H            #
################################################################################

EXE_DIR=`pwd`
SCRIPT_HOME=`dirname "$0"`
cd "$SCRIPT_HOME"
APP_BIN=`pwd`
APP_HOME=`dirname "$APP_BIN"`

################################################################################
#      R E T R I E V E           J A V A _ H O M E           P A T H           #
################################################################################

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

################################################################################
#                  J A V A                 E X E C U T I O N                   #
################################################################################

# Change to APP_BIN for JAVA execution
cd "${APP_BIN}"

# Reference path will be used to avoid empty space in the parent directory
LIB_HOME=.
JAVA_OPTS="-Xrs -Xms128m -Xmx768m -client"
JNI_PATH="-Djava.library.path=$LIB_HOME"
CLASSPATH="$LIB_HOME:$LIB_HOME/obc.jar:$LIB_HOME/obc-lib.jar"
MAIN_CLASS=Decrypt

echo "Using APP_HOME:          : ${APP_HOME}"
echo "Using ID_DIR             : ${ID_DIR}"
echo "Using DECRYPT_FROM       : ${DECRYPT_FROM}"
echo "Using DECRYPT_TO         : ${DECRYPT_TO}"
echo "Using POINT_IN_TIME      : ${POINT_IN_TIME}"
echo "Using RESTORE_PERMISSION : ${RESTORE_PERMISSION}"

# Do not include double-quote for java options, jni path, classpath and
# main class.
# Only apply double-quote for path to java executable and execution arguments
"${JAVA_EXE}" $JAVA_OPTS $JNI_PATH -cp $CLASSPATH $MAIN_CLASS -to="${DECRYPT_TO}" -from="${DECRYPT_FROM}" -source="${ID_DIR}" "${REPLACE_EXISTING_FILE}" -date="${POINT_IN_TIME}" -key="${DECRYPT_KEY}" -setPermission="${RESTORE_PERMISSION}" -skipInvalidKey="${SKIP_INVALID_KEY}" -sync="${SYNC_OPTION}" -Filter="${FILTER}" -AppHome="${APP_HOME}"

################################################################################
#                   R E S E T          A N D          E X I T                  #
################################################################################

cd "${EXE_DIR}"
exit 0
