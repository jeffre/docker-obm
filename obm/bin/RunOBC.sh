#!/bin/sh
# Ahsay Online Backup Manager 6.29.0.0

################################## RunOBC.sh ###################################
# You can use this shell to run the application without AutoUpdate             #
################################################################################

######################### START: User Defined Section ##########################

# ------------------------------- SETTING_HOME ---------------------------------
# | Directory to your setting home.                                            |
# | Default to ${HOME}/.obm when not set.                                      |
# | e.g. SETTING_HOME="${HOME}/.obm"                                           |
# ------------------------------------------------------------------------------
SETTING_HOME=""

# -------------------------------- DEBUG_MODE ----------------------------------
# | Enable/Disable debug mode                                                  |
# | e.g. DEBUG_MODE="--debug"                                                  |
# |  or  DEBUG_MODE=""                                                         |
# ------------------------------------------------------------------------------
DEBUG_MODE=""

########################## END: User Defined Section ###########################


################################################################################
#          R E T R I E V E     A P P _ H O M E     P A T H                     #
################################################################################

EXE_DIR=`pwd`
SCRIPT_HOME=`dirname "$0"`
cd "$SCRIPT_HOME"
APP_BIN=`pwd`
APP_HOME=`dirname "$APP_BIN"`

################################################################################
#          R E T R I E V E     J A V A _ H O M E     P A T H                   #
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

# Use alternative executable name to define the GUI execution
if [ "Darwin" = `uname` ]; then
    JAVA_EXE="$JAVA_HOME/bin/java"
else
    JAVA_EXE="$JAVA_HOME/bin/bJW"
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
#          S T A R T - U P     W I T H     U P D A T E     C H E C K           #
################################################################################

if [ "run" = "$1" ]; then
    RUN_BACKUP_MANAGER=true
fi

if [ -n "$RUN_BACKUP_MANAGER" -o ! -f "$APP_HOME/aua/auas-message.xml" ]; then
    # Set LD_LIBRARY_PATH for Lotus Notes on Linux
    if [ "Linux" = `uname` ]; then
        NOTES_PROGRAM=`cat "$APP_HOME/bin/notesenv"`
        LD_LIBRARY_PATH="$APP_HOME/bin:$NOTES_PROGRAM:$LD_LIBRARY_PATH"
        export NOTES_PROGRAM
    else
        LD_LIBRARY_PATH="$APP_HOME/bin:$LD_LIBRARY_PATH"
    fi
    
    DEP_LIB_PATH="X64"
    case "`uname -m`" in
        i[3-6]86)
            DEP_LIB_PATH="X86"
        ;;
    esac
    LD_LIBRARY_PATH="${APP_BIN}/${DEP_LIB_PATH}":"${LD_LIBRARY_PATH}"
    
    SHLIB_PATH="$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH SHLIB_PATH

    # Change to APP_BIN for JAVA execution
    cd "${APP_BIN}"

    # Reference path will be used to avoid empty space in the parent directory
    LIB_HOME=.
    JAVA_OPTS="-Xrs -Xms128m -Xmx768m -client"
    JNI_PATH="-Djava.library.path=$LIB_HOME"
    CLASSPATH="$LIB_HOME:$LIB_HOME/obc.jar:$LIB_HOME/obc-lib.jar"
    MAIN_CLASS=obc

    # Execute Java VM Runtime for BackupManager
    echo "Startup BackupManager ... "
    "${JAVA_EXE}" $JAVA_OPTS $JNI_PATH -cp $CLASSPATH $MAIN_CLASS "${DEBUG_MODE}" "${APP_HOME}" "${SETTING_HOME}" &

else
    # Set Java VM Runtime Environment
    JAVA_OPTS="-Xrs -Xms128m -Xmx768m"
    CLASSPATH="$APP_HOME/aua/lib:$APP_HOME/aua/lib/jdom.jar:$APP_HOME/aua/lib/log4j.jar:$APP_HOME/aua/lib/aua.jar:$APP_HOME/aua/ant/lib/ant.jar:$APP_HOME/aua/ant/lib/ant-launcher.jar:$APP_HOME/aua/ant/lib/xercesImpl.jar:$APP_HOME/aua/ant/lib/xml-apis.jar"
    MAIN_CLASS=auac

    # Execute Java VM Runtime for AutoUpdateAgent Client
    echo "AutoUpdate Message is found, now process message."
    "$APP_HOME/aua/jvm/bin/java" $JAVA_OPTS -cp $CLASSPATH $MAIN_CLASS ./config.xml update

    # Execute Backup Client
    sh "$APP_BIN/RunOBC.sh" run &
fi

################################################################################
#                   R E S E T          A N D          E X I T                  #
################################################################################

cd "${EXE_DIR}"
exit 0
