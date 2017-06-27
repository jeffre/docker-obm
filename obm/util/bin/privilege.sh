#!/bin/sh
# Ahsay Online Backup Manager 6.27.0.0

# /bin/sh: Assume the following contents should be run in the posix shell environment.
# ----------------------------------------------------------------------------------------------------------
# "privilege.sh": Verifying the current user privilege if the current user have enough privilege to install / config / uninstall in this machine.
# ----------------------------------------------------------------------------------------------------------
# Resolving Paths
# This script path: "$APP_HOME/util/bin"
UTIL_BIN_HOME=`dirname "$0"`
UTIL_HOME=`dirname "$UTIL_BIN_HOME"`
APP_HOME=`dirname "$UTIL_HOME"`
# ----------------------------------------------------------------------------------------------------------
# Default Variables
# OS Type
DEFAULT_OS_NAME_LIN="Linux"
DEFAULT_OS_NAME_SOL="Solaris"
DEFAULT_OS_NAME_SUN="SunOS"
DEFAULT_OS_NAME_BSD="BSD"
DEFAULT_OS_NAME_OPENBSD="OpenBSD"

DEFAULT_OS_TYPE_NIX="NIX"
DEFAULT_OS_TYPE_BSD="BSD"
DEFAULT_OS_TYPE_LIN="LIN"
DEFAULT_OS_TYPE_OPENBSD="OPENBSD"

# Actions / Process
DEFAULT_DO_ACTION_CONFIG="config"
DEFAULT_DO_ACTION_INSTALL="install"
DEFAULT_DO_ACTION_UNINSTALL="uninstall"

# Paths
DEFAULT_CHARDEVPATH_URANDOM="/dev/urandom"
DEFAULT_DIRPATH_TMP="/tmp"

# Command
DEFAULT_S_CMD_AWK="awk"
DEFAULT_S_CMD_HEAD="head"
DEFAULT_S_CMD_OD="od"

# ----------------------------------------------------------------------------------------------------------
# Variables
[ "$1" = "" ] && echo "Argument 1: [Action: ${DEFAULT_DO_ACTION_CONFIG} | ${DEFAULT_DO_ACTION_INSTALL} | ${DEFAULT_DO_ACTION_UNINSTALL}]" && exit 1

# Actions can be install / config / uninstall etc.
DO_ACTION="$1"
# Exit Code: true = 0, false != 0
# If there are errors, set this value to '1'.
# NEVER set this value to '0' inside all the procedures.
B_EXIT_CODE=0

# Determine variables according to OS type
S_OS_TYPE=""

case "`uname`" in
  "$DEFAULT_OS_NAME_LIN"*)      S_OS_TYPE="${DEFAULT_OS_TYPE_LIN}" ;;
  "$DEFAULT_OS_NAME_SOL"*)      S_OS_TYPE="${DEFAULT_OS_TYPE_NIX}" ;;
  "$DEFAULT_OS_NAME_SUN"*)      S_OS_TYPE="${DEFAULT_OS_TYPE_NIX}" ;;
  "$DEFAULT_OS_NAME_OPENBSD"*)  S_OS_TYPE="${DEFAULT_OS_TYPE_OPENBSD}" ;;
  *"$DEFAULT_OS_NAME_BSD"*)     S_OS_TYPE="${DEFAULT_OS_TYPE_BSD}" ;;
  **)                         echo "This OS `uname` is not supported by this script!"
                               return 3 ;;
esac

# Go to Main method "verify-privilege" at the bottom.
# ----------------------------------------------------------------------------------------------------------
# "verify-privilege" functions
# Remarks: The directory structure for creating the services should be referenced to the "install-service.sh" and "remove-service.sh".

is_cmd_exist()
{
  # $1 : command to test whether it is installed inside the system.
  [ $1 = "" ] && echo "Please specify the command to test in argument 1." && return 2

  case "`uname`" in
  "$DEFAULT_OS_NAME_LIN"*|*"$DEFAULT_OS_NAME_BSD"*|"$DEFAULT_OS_NAME_OPENBSD"*)
    which $1 > "/dev/null" 2>&1
    return $?
    ;;
  ## Since the 'which' command inside the Solaris has defects that cannot return a proper exit code.
  ## therefore special handling is used for verifying if a command is exist or not.
  "$DEFAULT_OS_NAME_SOL"*|"$DEFAULT_OS_NAME_SUN"*)
    "/usr/bin/ksh" "whence" "$1" > "/dev/null" 2>&1
    return $?
    ;;
  **)
    echo "This OS `uname` is not supported by this script!"
    return 3
    ;;
  esac
}

generate_random_number()
{
  eval is_cmd_exist "${DEFAULT_S_CMD_OD}"
  I_EXIT_CODE_IS_CMD_EXIST_OD=$?
  eval is_cmd_exist "${DEFAULT_S_CMD_HEAD}"
  I_EXIT_CODE_IS_CMD_EXIST_HEAD=$?
  eval is_cmd_exist "${DEFAULT_S_CMD_AWK}"
  I_EXIT_CODE_IS_CMD_EXIST_AWK=$?

  if [ $I_EXIT_CODE_IS_CMD_EXIST_OD -eq 0 ] && [ $I_EXIT_CODE_IS_CMD_EXIST_HEAD -eq 0 ] && [ $I_EXIT_CODE_IS_CMD_EXIST_AWK -eq 0 ]
  then
    if [ -c "$DEFAULT_CHARDEVPATH_URANDOM" ]
    then
      # Generated a 12 digits hex (e.g. "fe5bd5f6eacb")
      S_RANDOM_NUMBER=`${DEFAULT_S_CMD_OD} -x "${DEFAULT_CHARDEVPATH_URANDOM}" | ${DEFAULT_S_CMD_HEAD} -1 | ${DEFAULT_S_CMD_AWK} -F" " '{print $2$3$4}'`
    fi
  fi
}

verify_directory_path_can_be_written()
{
  [ "$1" = "" ] && echo "Please provide DIRECTORY PATH for verifying privilege." && return 1

  PATH_DIRECTORY_TO_VERIFY_PRIVILEDGE="$1"
  ERROR_MESSAGE_VERIFY_PRIVILEDGE="\"${PATH_DIRECTORY_TO_VERIFY_PRIVILEDGE}\""

  if [ -f "${PATH_DIRECTORY_TO_VERIFY_PRIVILEDGE}/${FILENAME_TEST_PERMISSION}" ]
  then
    # Remove the Test file if the test file already exist
    [ -f "${PATH_DIRECTORY_TO_VERIFY_PRIVILEDGE}/${FILENAME_TEST_PERMISSION}" ] && rm -f "${PATH_DIRECTORY_TO_VERIFY_PRIVILEDGE}/${FILENAME_TEST_PERMISSION}" > "/dev/null" 2>&1
    [ $? -ne 0 ] && B_EXIT_CODE=1 && echo "$ERROR_MESSAGE_VERIFY_PRIVILEDGE" >> "${FILEPATH_OUTPUT_ERROR}"
  else
    # Create (Touch) the Test file if the test file does not exist
    touch "${PATH_DIRECTORY_TO_VERIFY_PRIVILEDGE}/${FILENAME_TEST_PERMISSION}" > "/dev/null" 2>&1
    [ $? -ne 0 ] && B_EXIT_CODE=1 && echo "$ERROR_MESSAGE_VERIFY_PRIVILEDGE" >> "${FILEPATH_OUTPUT_ERROR}"
  fi

  # Remove the dummy test file after testing.
  [ -f "${PATH_DIRECTORY_TO_VERIFY_PRIVILEDGE}/${FILENAME_TEST_PERMISSION}" ] && rm -f "${PATH_DIRECTORY_TO_VERIFY_PRIVILEDGE}/${FILENAME_TEST_PERMISSION}" > "/dev/null" 2>&1

  return 0
}

verify_privilege_nix_service()
{
  # Determine the $INIT_PATH
  if [ -d "/etc/init.d" ]
  then
    INIT_PATH="/etc/init.d"
  else
    if [ -d "/etc/rc.d/init.d" ]
    then
      INIT_PATH="/etc/rc.d/init.d"
      else
      echo "INIT_PATH not found! Please make sure the INIT_PATH exists before continue the \"${DO_ACTION}\"." >> "${FILEPATH_OUTPUT_ERROR}"
      B_EXIT_CODE=1
    fi
  fi

  # Test the write permission in the "$INIT_PATH"
  [ "$INIT_PATH" != "" ] && eval verify_directory_path_can_be_written "$INIT_PATH"

  # Determine the $RC_PATH
  if [ -d "/etc/rc.d" ]
  then
    RC_PATH="/etc/rc.d"
  else
    if [ -d "/etc/rc3.d" ]
    then
      RC_PATH="/etc"
    elif [ -d "/etc/init.d/rc3.d" ]
    then
      RC_PATH="/etc/init.d"
    else
      echo "RC_PATH not found! Please make sure the RC_PATH exists before continue the \"${DO_ACTION}\"." >> "${FILEPATH_OUTPUT_ERROR}"
      B_EXIT_CODE=1
    fi
  fi

  # Test the write permission in the "$RC_PATH"
  if [ "$RC_PATH" != "" ]
  then
    eval verify_directory_path_can_be_written "$RC_PATH"
    [ -d "$RC_PATH/rc1.d" ] && eval verify_directory_path_can_be_written "$RC_PATH/rc1.d"
    [ -d "$RC_PATH/rc2.d" ] && eval verify_directory_path_can_be_written "$RC_PATH/rc2.d"
  fi
}

verify_privilege_bsd_service()
{
  # Determine the $INIT_PATH
  INIT_PATH="/usr/local/etc/rc.d"
  if [ ! -d "${INIT_PATH}" ]
  then
    echo "INIT_PATH not found! Please make sure the directory \"${INIT_PATH}\" exists before continue the \"${DO_ACTION}\"." >> "${FILEPATH_OUTPUT_ERROR}"
    B_EXIT_CODE=1
  fi

  # Test the write permission in the "$INIT_PATH"
  [ "$INIT_PATH" != "" ] && eval verify_directory_path_can_be_written "$INIT_PATH"

}

verify_privilege_linux_service()
{
  if [ "$RC_PATH" != "" ]
  then
    [ -d "$RC_PATH/rc3.d" ] && eval verify_directory_path_can_be_written "$RC_PATH/rc3.d"
    [ -d "$RC_PATH/rc4.d" ] && eval verify_directory_path_can_be_written "$RC_PATH/rc4.d"
    [ -d "$RC_PATH/rc5.d" ] && eval verify_directory_path_can_be_written "$RC_PATH/rc5.d"
    [ -d "$RC_PATH/rc6.d" ] && eval verify_directory_path_can_be_written "$RC_PATH/rc6.d"
  fi
}

verify_privilege_openbsd_service()
{
  #get OpenBSD version
  OPENBSD_VERSION=`uname -r | cut -f1 -d"."`

  if [ $OPENBSD_VERSION -ge 5 ]
  then
    # Determine the $INIT_PATH
    INIT_PATH="/etc/rc.d"
  else 
    INIT_PATH="/etc"
  fi

  if [ ! -d "${INIT_PATH}" ]
  then
    echo "INIT_PATH not found! Please make sure the directory \"${INIT_PATH}\" exists before continue the \"${DO_ACTION}\"." >> "${FILEPATH_OUTPUT_ERROR}"
    B_EXIT_CODE=1
  fi

  # Test the write permission in the "$INIT_PATH"
  [ "$INIT_PATH" != "" ] && eval verify_directory_path_can_be_written "$INIT_PATH"  
}

verify_privilege_common()
{
  # Test the write permission in the "$APP_HOME"
  [ "$APP_HOME" != "" ] && eval verify_directory_path_can_be_written "$APP_HOME"
}

verify_privilege()
{

  # Default Error Messages
  S_ERROR_MESSAGE_1="${DO_ACTION} cannot be continued due to following error(s):"
  S_ERROR_MESSAGE_2="Current user does not have enough privilege to modify any files in the following directory path(s):"
  S_ERROR_MESSAGE_3="Current user does not have enough privilege to \"${DO_ACTION}\"."

  # Temp files for testing
  S_RANDOM_NUMBER=""
  generate_random_number
  if [ "$S_RANDOM_NUMBER" = "" ]
  then
    FILENAME_TEST_PERMISSION="ObxTestFilePermission.txt"
    FILEPATH_OUTPUT_ERROR="${DEFAULT_DIRPATH_TMP}/ObxVerifyPriviledgeError.log"
  else
    FILENAME_TEST_PERMISSION="ObxTestFilePermission-${S_RANDOM_NUMBER}.txt"
    FILEPATH_OUTPUT_ERROR="${DEFAULT_DIRPATH_TMP}/ObxVerifyPriviledgeError-${S_RANDOM_NUMBER}.log"
  fi

  # Touch the Error file first
  if [ -f "${FILEPATH_OUTPUT_ERROR}" ]
  then
    rm -f "${FILEPATH_OUTPUT_ERROR}" >"/dev/null" 2>&1
  fi

  [ ! -d "$DEFAULT_DIRPATH_TMP" ] && mkdir -p "$DEFAULT_DIRPATH_TMP" > "/dev/null" 2>&1
  touch "${FILEPATH_OUTPUT_ERROR}" > "/dev/null" 2>&1
  [ $? -eq 0 ] && echo "${S_ERROR_MESSAGE_2}" >> "${FILEPATH_OUTPUT_ERROR}"

  ## All of the action checking path.
  verify_privilege_common

  ## Check the install service path
  if [ "$DO_ACTION" != "$DEFAULT_DO_ACTION_CONFIG" ]
  then
    case "$S_OS_TYPE" in
      "${DEFAULT_OS_TYPE_LIN}")
        verify_privilege_nix_service
        verify_privilege_linux_service
        ;;
      "${DEFAULT_OS_TYPE_NIX}")
        verify_privilege_nix_service
        ;;
      "${DEFAULT_OS_TYPE_OPENBSD}")
        verify_privilege_openbsd_service
        ;;
      "${DEFAULT_OS_TYPE_BSD}")
        verify_privilege_bsd_service
        ;;
      **)
        echo "This OS `uname` is not supported by this script!"
        return 3
        ;;
    esac
  fi

  # Handling the error messages and exit the shell script if error is found.
  if [ $B_EXIT_CODE -ne 0 ] && [ -f "${FILEPATH_OUTPUT_ERROR}" ]
  then
    echo "$S_ERROR_MESSAGE_1"
    cat "${FILEPATH_OUTPUT_ERROR}"
    echo "$S_ERROR_MESSAGE_3"
  elif [ $B_EXIT_CODE -ne 0 ] && [ ! -f "${FILEPATH_OUTPUT_ERROR}" ] # If the error log file does not exist, print a general error message.
  then
    echo "$S_ERROR_MESSAGE_3"
  fi

  # Finally, remove the temp files.
  [ -f "${FILEPATH_OUTPUT_ERROR}" ] && rm -f "${FILEPATH_OUTPUT_ERROR}" > "/dev/null" 2>&1

  return $B_EXIT_CODE

}

# ----------------------------------------------------------------------------------------------------------
# Main
eval verify_privilege
exit $?
