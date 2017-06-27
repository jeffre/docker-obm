#!/bin/sh
# Ahsay Online Backup Manager 6.29.0.0

# ------------------------- Retrieve APP_HOME ----------------------------------
cd `dirname "$0"`
APP_BIN=`pwd`
APP_HOME=`dirname "$APP_BIN"`
UTIL_HOME="${APP_HOME}/util"
AUA_HOME="${APP_HOME}/aua"
AUA_BIN="${AUA_HOME}/bin"

# -------------------- Print Logging Message Header ----------------------------
echo "Log Time: `date`"
# ------------ Verify if the privilege is enough for install ------------------
## Verify the privilege if the shell script "privilege.sh" exist.
echo ""
if [ -f "$UTIL_HOME/bin/privilege.sh" ]
then
  echo "Verifying current user privilege ..."
  "$UTIL_HOME/bin/privilege.sh" "config"
  [ $? -ne 0 ] && echo "Exit \"`basename $0`\" now!" && exit 1
else
  echo "The shell script \"$UTIL_HOME/bin/privilege.sh\" is missing."
  echo "Exit \"`basename $0`\" now!" && exit 1
fi
echo "Current user has enough privilege to \"config\"."
echo ""

# -------------------- Print Logging Message  ----------------------------------

OS_IS_LINUX=0

case "`uname`" in
  Linux*)
    echo "Start configuration on Generic Linux Platform (`uname`)"
    OS_IS_LINUX=1
    ;;
  Solaris*) echo "Start configuration on Solaris 2.X Platform (`uname`)";;
  SunOS*)   echo "Start configuration on Solaris 5.X Platform (`uname`)";;
  *BSD*)    echo "Start configuration on BSD distribution Platform (`uname`)";;
  **)       echo "This OS `uname` is not supported by this script! Exit `basename $0` now!"
      exit 1 ;;
esac


echo ""
echo "Installation Path: ${APP_HOME}"

# ----------------------- Configure Application --------------------------------
# Get the JAVA Home path.
cd "${APP_HOME}"
BUNDLED_JAVA_HOME=jvm

# JVM symbolic link has higher priority for installation than the Environment variable JAVA_HOME
if [ -x "${BUNDLED_JAVA_HOME}" ]
then
    echo "JVM symbolic link already exists, it will be used for installation."
else
    if [ -n "${JAVA_HOME}" ]
    then
        echo "\"JAVA_HOME\" variable is set."
        BUNDLED_JAVA_HOME="${JAVA_HOME}"
    else
        if [ "$OS_IS_LINUX" = "1" ]
        then
            case "`uname -m`" in
                i[3-6]86)
                    if [ -d "${APP_HOME}/jre32" ]
                    then
                        BUNDLED_JAVA_HOME="jre32"
                    fi
                ;;
                x86_64 | amd64)
                    if [ -d "${APP_HOME}/jre64" ]; then
                        BUNDLED_JAVA_HOME="jre64"
                    fi
                ;;
                *)
                    # Linux i[3-6]86, [ x86_64 | amd64 ] OS require custom JAVA_HOME
                    echo "Please create a symbolic link to \"${APP_HOME}/jvm\" or"
                    echo "Please set JAVA_HOME!"
                    exit 1;
                ;;
            esac
        else
            # Non Linux OS require custom JAVA_HOME
            echo "Please create a symbolic link to \"${APP_HOME}/jvm\" or"
            echo "Please set JAVA_HOME!"
            exit 1
        fi
    fi
    # Create symlink for JVM_HOME
    ln -sf "${BUNDLED_JAVA_HOME}" "jvm" && echo "Current Directory: \"`pwd`\"." && echo "Created symlink \"jvm\" to \"${BUNDLED_JAVA_HOME}\"."
fi

# Remove the existing "${APP_HOME}/jvm" symlink first.
# if [ -L "${APP_HOME}/jvm" ]
# then
    # rm -f "${APP_HOME}/jvm"
# fi
# Create symlink for JVM_HOME
# cd "${APP_HOME}"
# ln -sf "${BUNDLED_JAVA_HOME}" "jvm"

# Verify the JAVA_EXE whether it is a valid JAVA Executable or not.
STRING_JAVA_VERSION="java version,openjdk version"
OUTPUT_JAVA_VERSION=`"${APP_HOME}/jvm/bin/java" -version 2>&1`
OUTPUT_JVM_SUPPORT=0
BACKUP_IFS=$IFS
IFS=","
for word in $STRING_JAVA_VERSION; do
    if [ `echo "${OUTPUT_JAVA_VERSION}" | grep "${word}" | grep -cv "grep ${word}"` -le 0 ]
    then
      #echo "The Java Executable \"${APP_HOME}/jvm/bin/java\" is not a valid Java Executable. Exit \""`basename "$0"`"\" now."
      continue;
    else
      OUTPUT_JVM_SUPPORT=1
      break;
    fi
done
IFS=$BACKUP_IFS
if [ $OUTPUT_JVM_SUPPORT -eq 0 ]
then
    echo "The Java Executable \"${APP_HOME}/jvm/bin/java\" is not a valid Java Executable. Exit \""`basename "$0"`"\" now."
    exit 1
fi

# Verify if the JVM version in the JVM Home are supported
MINIMUM_SUPPORTED_JVM_VERSION=1.5 # The JVM supported Version is defined in APP v6.0 onwards.
echo "Minimum supported JVM version: $MINIMUM_SUPPORTED_JVM_VERSION"
[ ! -f "$UTIL_HOME/bin/verify-jvm-version.sh" ] && echo "The shell script \"$UTIL_HOME/bin/verify-jvm-version.sh\" is missing." && echo "Exit \"`basename $0`\" now!" && exit 1
"$UTIL_HOME/bin/verify-jvm-version.sh" "$APP_HOME/jvm" "$MINIMUM_SUPPORTED_JVM_VERSION" 1>"/dev/null" 2>&1
if [ $? -ne 0 ]
then
    [ -L "$APP_HOME/jvm" ] && rm -f "$APP_HOME/jvm" && echo "Removed the Symlink \"$APP_HOME/jvm\"."
    echo "The JVM version is lower than \"$MINIMUM_SUPPORTED_JVM_VERSION\" which is not supported by the APP."
    echo "Please change the JAVA_HOME Directory and run the installation again."
    echo "Exit \"`basename $0`\" now!"
    exit 1
fi

echo "Current JVM version is supported for installation."
FLAG_IS_AUA_JVM_EXIST=0
if [ "$OS_IS_LINUX" = "1" ]; then
    if [ ! -d "$APP_HOME/aua/jvm" ];
    then
        mkdir -p "$APP_HOME/aua/jvm" && echo "Created JAVA_HOME directory at $APP_HOME/aua/jvm"
        FLAG_IS_AUA_JVM_EXIST=1
    else # if [ -d "$APP_HOME/aua/jvm" ]
        "$APP_HOME/aua/jvm/bin/auaJW" -version 1>"/dev/null" 2>&1
        [ $? -ne 0 ] && FLAG_IS_AUA_JVM_EXIST=1
    fi
    if [ $FLAG_IS_AUA_JVM_EXIST -eq 1 ]
    then
        [ -d "$APP_HOME/aua/jvm" ] && [ -d "$APP_HOME/jvm" ] && cp -rp $APP_HOME/jvm/* "$APP_HOME/aua/jvm" && echo "Copied all the APP's JAVA_HOME contents to the directory \"$APP_HOME/aua/jvm\""
    fi
else
    if [ ! -x "$APP_HOME/aua/jvm" ];
    then
        ln -sf "$APP_HOME/jvm" "$APP_HOME/aua/jvm"
        echo "Created JAVA_HOME symbolic link at $APP_HOME/aua/jvm"
    fi
fi

if [ ! -x "$APP_HOME/jre32/bin/bJW" ]; then
    echo "Create Backup Manager JVM in jre32 directory, Path: $APP_HOME/jre32/bin/bJW"
    ln -sf "$APP_HOME/jre32/bin/java" "$APP_HOME/jre32/bin/bJW"
    chmod 755 "$APP_HOME/jre32/bin/bJW"
fi

if [ ! -x "$APP_HOME/jre32/bin/bschJW" ]; then
    echo "Create Scheduler Service JVM in jre32 directory, Path: $APP_HOME/jre32/bin/bschJW"
    ln -sf "$APP_HOME/jre32/bin/java" "$APP_HOME/jre32/bin/bschJW"
    chmod 755 "$APP_HOME/jre32/bin/bschJW"
fi

if [ ! -x "$APP_HOME/jre64/bin/bJW" ]; then
    echo "Create Backup Manager JVM in jre64 directory, Path: $APP_HOME/jre64/bin/bJW"
    ln -sf "$APP_HOME/jre64/bin/java" "$APP_HOME/jre64/bin/bJW"
    chmod 755 "$APP_HOME/jre64/bin/bJW"
fi

if [ ! -x "$APP_HOME/jre64/bin/bschJW" ]; then
    echo "Create Scheduler Service JVM in jre64 directory, Path: $APP_HOME/jre64/bin/bschJW"
    ln -sf "$APP_HOME/jre64/bin/java" "$APP_HOME/jre64/bin/bschJW"
    chmod 755 "$APP_HOME/jre64/bin/bschJW"
fi

if [ ! -x "$APP_HOME/jvm/bin/bJW" ]; then
    echo "Create Backup Manager JVM, Path: $APP_HOME/jvm/bin/bJW"
    ln -sf "$APP_HOME/jvm/bin/java" "$APP_HOME/jvm/bin/bJW"
    chmod 755 "$APP_HOME/jvm/bin/bJW"
fi

if [ ! -x "$APP_HOME/jvm/bin/bschJW" ]; then
    echo "Create Scheduler Service JVM, Path: $APP_HOME/jvm/bin/bschJW"
    ln -sf "$APP_HOME/jvm/bin/java" "$APP_HOME/jvm/bin/bschJW"
    chmod 755 "$APP_HOME/jvm/bin/bschJW"
fi

if [ ! -x "$APP_HOME/aua/jvm/bin/auaJW" ]; then
    echo "Create AutoUpdate Service JVM, Path: $APP_HOME/jvm/bin/auaJW"
    ln -sf "$APP_HOME/aua/jvm/bin/java" "$APP_HOME/aua/jvm/bin/auaJW"
    chmod 755 "$APP_HOME/aua/jvm/bin/auaJW"
fi

if [ ! -x "$APP_HOME/aua/jvm/lib/tools.jar" ]; then
    cp "$APP_HOME/aua/lib/tools.jar" "$APP_HOME/aua/jvm/lib/tools.jar"
fi

# Set File Permission
echo "Setup File Permissions"
touch "$APP_HOME/home.txt"
chmod 777 "$APP_HOME/home.txt"
touch "$APP_BIN/notesenv"
chmod 777 "$APP_BIN/notesenv"
chmod 755 "$APP_BIN/LotusBM"
chmod 755 $APP_BIN/*.sh

# Disabled writing to config.ini since 5.2.2.6
#chmod 777 "$APP_HOME/config.ini"

echo "Configure AutoUpdate Service Property file: ${APP_HOME}/aua/builds/local-machine.properties"
cd "$APP_HOME/aua/bin"
./auas-config.sh > /dev/null

exit 0
