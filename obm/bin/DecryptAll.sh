#!/bin/sh
# Ahsay Online Backup Manager 6.27.0.0

##############################  DecryptAll.sh  #################################
# You can use this batch file to decrypt all backup files under a single       #
# directory using command-line. It will decrypt all backup files found         #
# with the encrypting key provided with corrupted files skipped                #
# automatically. However, this script doesn't restore file attributes and      #
# permissions associated with backup files.                                    #
# Just customize the "User Define Section" below with values for your          #
# decrypt action.                                                              #
################################################################################

#########################  Start: User Defined Section  ########################

# ------------------------------  SRC_DIR  -----------------------------------
# | File/Directory on the backup server that you would like to decrypt       |
# | e.g. SRC_DIR="/john/files/1119083740107"                                              |
# ----------------------------------------------------------------------------
SRC_DIR=""

# -------------------------------  DECRYPT_TO  -------------------------------
# | Directory to where you want files to be decrypted                        |
# | set to "" to decrypt files to original location                          |
# | e.g. DECRYPT_TO="/tmp"                                                   |
# ----------------------------------------------------------------------------
DECRYPT_TO=""

# ------------------------------  DECRYPT_KEY  -------------------------------
# | Your encrypting key. It will be used to decrypt your backup files        |
# | e.g. DECRYPT_KEY="abc"                                               |
# ----------------------------------------------------------------------------
DECRYPT_KEY=""

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
JAVA_OPTS="-Xrs -Xms128m -Xmx768m"
JNI_PATH="-Djava.library.path=$LIB_HOME"
CLASSPATH="$LIB_HOME:$LIB_HOME/obc.jar:$LIB_HOME/obc-lib.jar"
MAIN_CLASS=DecryptAll

echo "Using APP_HOME:          : ${APP_HOME}"
echo "Using SRC_DIR            : ${SRC_DIR}"
echo "Using DECRYPT_TO         : ${DECRYPT_TO}"
echo "Using DECRYPT_KEY        : ${DECRYPT_KEY}"

# Do not include double-quote for java options, jni path, classpath and
# main class.
# Only apply double-quote for path to java executable and execution arguments
"${JAVA_EXE}" $JAVA_OPTS $JNI_PATH -cp $CLASSPATH $MAIN_CLASS DecryptAll ${SRC_DIR} ${DECRYPT_TO} ${DECRYPT_KEY}

################################################################################
#                   R E S E T          A N D          E X I T                  #
################################################################################

cd "${EXE_DIR}"
exit 0
