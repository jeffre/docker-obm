#!/bin/sh

# ------------------------------------------------------
# Note:
# The JVM Directory Path should be in absolute path.
#
# JVM version format provided can be "1.5", "1.5.0", "1.6.0_21"
# Reference of the Java Version Format:
# http://java.sun.com/j2se/versioning_naming.html
#
# Execution Path: "$APP_HOME/util/bin"
# ------------------------------------------------------

########## Resolving Paths ##########
cd `dirname "$0"`
FILENAME_CURRENT_SCRIPT=`basename "$0"`

########## Variables ##########
DIRPATH_JVM_HOME=""
DIRPATH_JVM_BIN_DIR=""
MIN_SUPPORTED_JVM_VERSION=

FILENAME_JAVA_EXECUTABLE="java"

# Note :
# e.g. For the "java version "$VERSION_NUM"" line executed by the command "java -version":
# java version "1.6.0_21"
STRING_JVM_SUPPORT="java version,openjdk version"

########## Debugging Utility ##########
_DEBUG="off" # Set _DEBUG="on" to display the debugging messages.
DEBUG()
{
    [ "$_DEBUG" = "on" ] &&  $@
}

########## Methods ##########
print_usage()
{
    DEBUG echo "Usage: \"$FILENAME_CURRENT_SCRIPT\" \"JVM Home Dir Path\" \"Minimum Supported JVM Version\""
    DEBUG echo "Verify the current JVM version if it meets the minimum supported version."
}

is_jvm_dir_path_valid()
{
    [ ! -d "$DIRPATH_JVM_BIN_DIR" ] && return 1
    "$DIRPATH_JVM_BIN_DIR/$FILENAME_JAVA_EXECUTABLE" -version 1>"/dev/null" 2>&1
    return $?
}

get_current_jvm_version_base()
{
	STRING_JVM=$1
	CURRENT_JVM_VERSION=""

    if [ ! "$STRING_JVM" = "" ]
    then
        CURRENT_JVM_VERSION=`"$DIRPATH_JVM_BIN_DIR/$FILENAME_JAVA_EXECUTABLE" -version 2>&1 | grep "$STRING_JVM" | grep -v "grep $STRING_JVM" | awk '{print $3}' | cut -f2 -d"\""`
    fi
}

init_current_jvm_version()
{
    BACKUP_IFS=$IFS
    IFS=","
    for word in $STRING_JVM_SUPPORT; do
        get_current_jvm_version_base $word
        if [ ! "$CURRENT_JVM_VERSION" = "" ]
        then
            break
        fi
    done
    IFS=$BACKUP_IFS
}

is_jvm_versions_format_valid()
{
    echo "$CURRENT_JVM_VERSION" | egrep "[0-9]+\.[0-9]+.*" 1>"/dev/null"
    if [ $? -eq 0 ]
    then
        echo "$MIN_SUPPORTED_JVM_VERSION" | egrep "[0-9]+\.[0-9]+.*" 1>"/dev/null"
        if [ $? -eq 0 ]
        then
            return 0
        else
             DEBUG echo "Provided Minimum supported JVM version \"$MIN_SUPPORTED_JVM_VERSION\" is NOT valid!"
             DEBUG echo "Please given a valid minimum supported JVM version!"
             return 2
        fi
    else
        DEBUG echo "Current JVM version \"$CURRENT_JVM_VERSION\" is NOT valid!"
        return 2
    fi
}

parse_current_jvm_version_tokens()
{
    CURRENT_JVM_VERSION_MAJ_VER_NUM=`echo "$CURRENT_JVM_VERSION" | cut -f1 -d"."`
    CURRENT_JVM_VERSION_MINOR_VER_NUM=`echo "$CURRENT_JVM_VERSION" | cut -f2 -d"."`
    CURRENT_JVM_VERSION_MINOR2_VER_NUM=`echo "$CURRENT_JVM_VERSION" | cut -f3 -d"." | cut -f1 -d"-" | cut -f1 -d"_"`
    if [ `echo "$CURRENT_JVM_VERSION" | grep "_" | grep -cv "grep _"` -ge 1 ]
    then
        CURRENT_JVM_VERSION_UPDATE_VER_NUM=`echo "$CURRENT_JVM_VERSION" | cut -f2 -d"_" | cut -f1 -d"-"`
    else
        CURRENT_JVM_VERSION_UPDATE_VER_NUM=0
    fi

    CURRENT_JVM_VERSION_SPACE_SEPEARATED="${CURRENT_JVM_VERSION_MAJ_VER_NUM} ${CURRENT_JVM_VERSION_MINOR_VER_NUM} ${CURRENT_JVM_VERSION_MINOR2_VER_NUM} ${CURRENT_JVM_VERSION_UPDATE_VER_NUM}"

}

parse_mini_supported_jvm_version_tokens()
{
    MIN_SUPPORTED_JVM_VERSION_MAJ_VER_NUM=`echo "$MIN_SUPPORTED_JVM_VERSION" | cut -f1 -d"."`
    MIN_SUPPORTED_JVM_VERSION_MINOR_VER_NUM=`echo "$MIN_SUPPORTED_JVM_VERSION" | cut -f2 -d"."`
    MIN_SUPPORTED_JVM_VERSION_MINOR2_VER_NUM=`echo "$MIN_SUPPORTED_JVM_VERSION" | cut -f3 -d"." | cut -f1 -d"-" | cut -f1 -d"_"`
    [ "$MIN_SUPPORTED_JVM_VERSION_MINOR2_VER_NUM" = "" ] && MIN_SUPPORTED_JVM_VERSION_MINOR2_VER_NUM=0
    if [ `echo "$MIN_SUPPORTED_JVM_VERSION" | grep "_" | grep -cv "grep _"` -ge 1 ]
    then
        MIN_SUPPORTED_JVM_VERSION_UPDATE_VER_NUM=`echo "$MIN_SUPPORTED_JVM_VERSION" | cut -f2 -d"_" | cut -f1 -d"-"`
    else
        MIN_SUPPORTED_JVM_VERSION_UPDATE_VER_NUM=0
    fi

    MIN_SUPPORTED_JVM_VERSION_SPACE_SEPEARATED="${MIN_SUPPORTED_JVM_VERSION_MAJ_VER_NUM} ${MIN_SUPPORTED_JVM_VERSION_MINOR_VER_NUM} ${MIN_SUPPORTED_JVM_VERSION_MINOR2_VER_NUM} ${MIN_SUPPORTED_JVM_VERSION_UPDATE_VER_NUM}"
}

parse_jvm_version_tokens()
{
    parse_current_jvm_version_tokens
    parse_mini_supported_jvm_version_tokens
}

is_jvm_version_supported()
{
    DEBUG echo "---------------------------------------------------------------"
    DEBUG echo "Minimum JVM version supported: \"$MIN_SUPPORTED_JVM_VERSION+\""
    DEBUG echo "Given JVM version by the JVM Home \"$DIRPATH_JVM_HOME\": \"$CURRENT_JVM_VERSION\""
    DEBUG echo "---------------------------------------------------------------"

    parse_jvm_version_tokens

    FLAG_IS_JVM_VERSION_SUPPORTED=0
    COUNT_TOKEN_JVM_VERSION_WORKING=1

    for TOKEN_CURRENT_JVM_VERSION in $CURRENT_JVM_VERSION_SPACE_SEPEARATED
    do
        TOKEN_MIN_SUPPORTED_JVM_VERSION=`echo "$MIN_SUPPORTED_JVM_VERSION_SPACE_SEPEARATED" | cut -f$COUNT_TOKEN_JVM_VERSION_WORKING -d" "`
        if [ $TOKEN_CURRENT_JVM_VERSION -gt $TOKEN_MIN_SUPPORTED_JVM_VERSION ]
        then
            FLAG_IS_JVM_VERSION_SUPPORTED=0
            break
        elif [ $TOKEN_CURRENT_JVM_VERSION -lt $TOKEN_MIN_SUPPORTED_JVM_VERSION ]
        then
            FLAG_IS_JVM_VERSION_SUPPORTED=1
            break
        fi
        COUNT_TOKEN_JVM_VERSION_WORKING=`expr $COUNT_TOKEN_JVM_VERSION_WORKING + 1`
    done

    [ $FLAG_IS_JVM_VERSION_SUPPORTED -eq 0 ] && DEBUG echo "Current JVM version is supported."
    [ $FLAG_IS_JVM_VERSION_SUPPORTED -ne 0 ] && DEBUG echo "Current JVM version is NOT supported."
    return $FLAG_IS_JVM_VERSION_SUPPORTED
}

########## Main ##########
[ $# -lt 2 ] && print_usage && exit 3
DIRPATH_JVM_HOME="$1"
DIRPATH_JVM_BIN_DIR="$1/bin"
MIN_SUPPORTED_JVM_VERSION=$2
eval is_jvm_dir_path_valid
if [ $? -eq 0 ]
then
    init_current_jvm_version
    eval is_jvm_versions_format_valid
    if [ $? -eq 0 ]
    then
        eval is_jvm_version_supported
        exit $?
    else
        DEBUG echo "One of the JVM versions' format is NOT valid. Exit this script \"$FILENAME_CURRENT_SCRIPT\"!"
        exit 2
    fi
else
    DEBUG echo "The JVM in the JVM Home directory \"$1\" is NOT valid. Exit this script \"$FILENAME_CURRENT_SCRIPT\"!"
    exit 4
fi
