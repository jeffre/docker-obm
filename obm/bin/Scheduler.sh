#!/bin/sh
# Ahsay Online Backup Manager 6.27.0.0

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

NAME_IS_JAVA=0

# Use alternative executable name to define the GUI execution
if [ "Darwin" = `uname` ]; then
    JAVA_EXE="$JAVA_HOME/bin/java"
    NAME_IS_JAVA=1
else
    JAVA_EXE="$JAVA_HOME/bin/bschJW"
fi

# Create the binary file for GUI, Scheduler, AutoUpdate
if [ ! -x "$APP_HOME/jvm/bin/bschJW" ]; then
    echo "Create Scheduler Service JVM, Path: $APP_HOME/jvm/bin/bschJW"
    ln -sf "$APP_HOME/jvm/bin/java" "$APP_HOME/jvm/bin/bschJW"
    chmod 755 "$APP_HOME/jvm/bin/bschJW"
fi

if [ ! -x "$APP_HOME/jvm/bin/bJW" ]; then
    echo "Create Backup Manager JVM, Path: $APP_HOME/jvm/bin/bJW"
    ln -sf "$APP_HOME/jvm/bin/java" "$APP_HOME/jvm/bin/bJW"
    chmod 755 "$APP_HOME/jvm/bin/bJW"
fi

if [ ! -x "$APP_HOME/aua/jvm/bin/auaJW" ]; then
    echo "Create AutoUpdate Service JVM, Path: $APP_HOME/jvm/bin/auaJW"
    ln -sf "$APP_HOME/aua/jvm/bin/java" "$APP_HOME/aua/jvm/bin/auaJW"
    chmod 755 "$APP_HOME/aua/jvm/bin/auaJW"
fi

# Verify the JAVA_EXE whether it can be executed or not.
if [ ! -x "${JAVA_EXE}" ]
then
    if [ $NAME_IS_JAVA -eq 0 ]
    then
        # If the symlink cannot be executed, using the Java Executable instead.
        echo "The file \"${JAVA_EXE}\" cannot be executed, using \"${JAVA_HOME}/bin/java\" for Java Executable instead."
        JAVA_EXE="$JAVA_HOME/bin/java"
        if [ ! -x "${JAVA_EXE}" ]
        then
            echo "The Java Executable file \"${JAVA_EXE}\" cannot be executed. Exit \""`basename "$0"`"\" now."
            exit 1
        fi
    else
        echo "The Java Executable file \"${JAVA_EXE}\" cannot be executed. Exit \""`basename "$0"`"\" now."
        exit 1
    fi
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

# Current directory has been changed to APP_HOME

LD_LIBRARY_PATH="$APP_BIN"

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
CLASSPATH="$LIB_HOME:$LIB_HOME/obcs.jar:$LIB_HOME/obc-lib.jar"
MAIN_CLASS=obcs

mkdir -p "${APP_HOME}/log"
mkdir -p "${APP_HOME}/log/Scheduler"

# Do not include double-quote for java options, jni path, classpath and
# main class.
# Only apply double-quote for path to java executable and execution arguments
"${JAVA_EXE}" $JAVA_OPTS $JNI_PATH -cp $CLASSPATH $MAIN_CLASS "${APP_HOME}" > "${APP_HOME}/log/Scheduler/console.log" 2>&1 &

################################################################################
#                   R E S E T          A N D          E X I T                  #
################################################################################

cd "${EXE_DIR}"
exit 0
