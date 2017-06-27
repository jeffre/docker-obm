#!/bin/sh

# ----------------------------------------------------------------------------------------------------------
# USER INPUT PARAMETERS
# ----------------------------------------------------------------------------------------------------------
# USER_APP_HOME is the current application installation path
# A JRE HOME must be existed in the USER_APP_HOME
# e.g. USER_APP_HOME: /usr/local/myapp, JRE HOME: /usr/local/myapp/jvm
# If nothing is inputted, i.e. USER_APP_HOME="" , the default value will be used.
# Default value: ../..
# e.g. USER_APP_HOME="/usr/local/myapp"
USER_APP_HOME=""
# ----------------------------------------------------------------------------------------------------------
# USER_ALIAS variable is for the alias in the jvm keystore.
# If nothing is inputted, i.e. USER_ALIAS="", the default value will be used.
# Default value: myapp
# e.g. USER_ALIAS="myapp"
USER_ALIAS=""
# ----------------------------------------------------------------------------------------------------------
# USER_CERT_FILE_PATH variable is the trust cerificate file PATH that used to import to the jvm keystore
# If nothing is inputted, i.e. USER_CERT_FILE_PATH="", the default value will be used.
# Default value: $USER_APP_HOME/util/cert/bundle.cer
# e.g. USER_CERT_FILE_PATH="$USER_APP_HOME/util/cert/bundle.cer"
USER_CERT_FILE_PATH=""
# ----------------------------------------------------------------------------------------------------------
# USER_KEYSTORE_PASSWORD variable is the jvm keystore's password
# If nothing is inputted, i.e. USER_KEYSTORE_PASSWORD="", the default value will be used.
# Default value: changeit
# e.g. USER_KEYSTORE_PASSWORD="changeit"
USER_KEYSTORE_PASSWORD=""
# ----------------------------------------------------------------------------------------------------------
# END OF USER INPUT PARAMETERS
# ----------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------
# Define file-paths/file
CERT_HOME=`pwd`
cd `dirname "$0"`
UTIL_CERT_HOME=`pwd`
UTIL_HOME=`dirname "$UTIL_CERT_HOME"`
DEFAULT_APP_HOME=`dirname "$UTIL_HOME"`

if [ "$USER_APP_HOME" = "" ]
then
  USER_APP_HOME="$DEFAULT_APP_HOME"
fi

JVM_HOME="$USER_APP_HOME/jvm"
JVM_BIN_PATH="$JVM_HOME/bin"
JVM_KEYSTORE="$JVM_HOME/lib/security/cacerts"

cd $CERT_HOME

# ----------------------------------------------------------------------------------------------------------
# Default settings
DEFAULT_JVM_STORETYPE="jks"

DEFAULT_ALIAS="myapp"
DEFAULT_CERT_FILE_PATH="$UTIL_CERT_HOME/bundle.cer"
DEFAULT_KEYSTORE_PASSWORD="changeit"

# ----------------------------------------------------------------------------------------------------------
# Define LOGGING Services
LOG_TRACE=0
LOG_DEBUG=1
LOG_INFO=2
LOG_WARN=3
LOG_ERROR=4
LOG_FATAL=5
LOG_LEVEL=$LOG_INFO

# ----------------------------------------------------------------------------------------------------------
log_trace() {
  log_message $LOG_TRACE "$1"
}

log_debug() {
  log_message $LOG_DEBUG "$1"
}

log_info() {
  log_message $LOG_INFO "$1"
}

log_warn() {
  log_message $LOG_WARN "$1"
}

log_error() {
  log_message $LOG_ERROR "$1"
}

log_fatal() {
  log_message $LOG_FATAL "$1"
}

log_message() {
  LOG_TYPE=$1
  LOG_MESSAGE=$2
  if [ $LOG_TYPE -ge $LOG_LEVEL ]
  then
    [ "$LOG_TYPE" = "$LOG_TRACE" ] && echo "[TRACE][$LOG_MESSAGE]"
    [ "$LOG_TYPE" = "$LOG_DEBUG" ] && echo "[DEBUG][$LOG_MESSAGE]"
    [ "$LOG_TYPE" = "$LOG_INFO"  ] && echo "[INFO] [$LOG_MESSAGE]"
    [ "$LOG_TYPE" = "$LOG_WARN"  ] && echo "[WARN] [$LOG_MESSAGE]"
    [ "$LOG_TYPE" = "$LOG_ERROR" ] && echo "[ERROR][$LOG_MESSAGE]"
    [ "$LOG_TYPE" = "$LOG_FATAL" ] && echo "[FATAL][$LOG_MESSAGE]"
  fi
}
# ----------------------------------------------------------------------------------------------------------
# functions for checking user's enter things
handle_user_parameters()
{

  if [ "$USER_ALIAS" = "" ]
  then
    USER_ALIAS=$DEFAULT_ALIAS
  fi
  
  if [ "$USER_CERT_FILE_PATH" = "" ]
  then
    USER_CERT_FILE_PATH=$DEFAULT_CERT_FILE_PATH
  fi
  
  if [ "$USER_KEYSTORE_PASSWORD" = "" ]
  then
    USER_KEYSTORE_PASSWORD=$DEFAULT_KEYSTORE_PASSWORD
  fi
}

# ----------------------------------------------------------------------------------------------------------
# function for print user used parameters for importing certs
print_used_parameters()
{
	echo ""
	echo "-----------------------------------------------------------------"
	echo ""
	echo "USER_APP_HOME=\""$USER_APP_HOME"\""
	echo "USER_ALIAS=\""$USER_ALIAS"\""
	echo "USER_CERT_FILE_PATH=\""$USER_CERT_FILE_PATH"\""
	echo "USER_KEYSTORE_PASSWORD=\""$USER_KEYSTORE_PASSWORD"\""
	echo ""
	echo "-----------------------------------------------------------------"
	echo ""
}

# ----------------------------------------------------------------------------------------------------------
# functions for checking during importing
is_user_app_home_exist()
{
  if [ -f "$USER_APP_HOME" ]
  then
    log_info "The \""$USER_APP_HOME"\" is a file. Please specify a directory path for the USER_APP_HOME."
	return 1
  fi

  if [ ! -d "$USER_APP_HOME" ]
  then
    log_info "Directory \""$USER_APP_HOME"\" does not exist. Please type a correct directory path for the variable USER_APP_HOME in this script."
	return 1
  fi
  
  return 0
}

is_jvm_home_exist()
{
  if [ ! -d "$JVM_HOME" ]
  then
    log_info "JRE Home does not exist under \""$USER_APP_HOME"\", please make sure the JRE HOME is set in \""$JVM_HOME"\"."
	return 1
  fi
  
  return 0
}

is_jvm_bin_path_exist()
{

  if [ ! -d "$JVM_BIN_PATH" ]
  then
    log_info "Bin Path: \""$JVM_BIN_PATH"\" in JRE HOME does not exist. Please make sure the JRE HOME is set in \""$JVM_HOME"\"."
	return 1
  fi
  
  return 0

}

is_alias_not_exist_in_keystore()
{
  $JVM_BIN_PATH/keytool -list -alias $USER_ALIAS -keystore $JVM_KEYSTORE -storetype $DEFAULT_JVM_STORETYPE -storepass $USER_KEYSTORE_PASSWORD 2>&1 1>/dev/null
  ALIAS_EXIST_RESULT_1=$?
  if [ $ALIAS_EXIST_RESULT_1 -eq 0 ]
  then
    log_info "This alias \""$USER_ALIAS"\" is used in the jvm keystore, please remove this entry before using it or provide another name for this cert. in the keystore."
	return 1
  else
    log_trace "is_alias_not_exist_in_keystore return 0"
    return 0
  fi
}

is_cert_file_exist()
{
  if [ -d "$USER_CERT_FILE_PATH" ]
  then
    log_info "The file path \""$USER_CERT_FILE_PATH"\" provided is a directory. Please provide the file path instead of a directory."
	return 1
  fi
  
  if [ ! -f "$USER_CERT_FILE_PATH" ] 
  then
    log_info "Trust cacert file does not exist in the path \""$USER_CERT_FILE_PATH"\"."
    return 1 
  fi
  
  log_trace "is_cert_file_exist return 0"
  return 0
}

is_keystore_password_correct()
{
  $JVM_BIN_PATH/keytool -list -keystore $JVM_KEYSTORE -storetype $DEFAULT_JVM_STORETYPE -storepass $USER_KEYSTORE_PASSWORD 2>&1 1>/dev/null
  if [ $? -eq 0 ]
  then
    log_trace "is_keystore_password_correct return 0"
    return 0
  else
    log_info "Login keystore failed. Please provide the correct password for the jvm keystore."
	return 1
  fi
}

is_keystore_exist()
{
  if [ ! -f "$JVM_KEYSTORE" ] 
  then
    log_info "JVM Keystore file does not exist in the path \""$JVM_KEYSTORE"\". Please set the JAVA HOME to JRE HOME instead of JDK HOME."
    return 1 
  fi
  
  log_trace "is_keystore_exist return 0"
  return 0
}

# ----------------------------------------------------------------------------------------------------------
# functions for processing
is_importation_successful()
{
  echo "yes" | $JVM_BIN_PATH/keytool -import -trustcacerts -alias $USER_ALIAS -keystore $JVM_KEYSTORE -storetype $DEFAULT_JVM_STORETYPE -file $USER_CERT_FILE_PATH -storepass $USER_KEYSTORE_PASSWORD 2>&1 1>/dev/null
  if [ $? -eq 0 ]
  then
    log_info "Importation of the trust cacert with the entry name \""$USER_ALIAS"\" is SUCCESSFUL."
	return 0
  else
    log_info "Importation of the trust cacerts with the entry name \""$USER_ALIAS"\" is UNSUCCESSFUL. Please check the certificate file whether it is a valid trust cacert."
    return 1
  fi
}

# ----------------------------------------------------------------------------------------------------------
# handle import trust cacert function
handle_import_cert()
{
  eval is_user_app_home_exist
  if [ $? -eq 1 ]
  then
    return 1
  fi
  eval is_jvm_home_exist
  if [ $? -eq 1 ]
  then
    return 1
  fi
  eval is_jvm_bin_path_exist
  if [ $? -eq 1 ]
  then
    return 1
  fi
  eval is_keystore_exist
  if [ $? -eq 1 ]
  then 
    return 1
  fi
  eval is_keystore_password_correct
  if [ $? -eq 1 ]
  then 
    return 1
  fi
  eval is_alias_not_exist_in_keystore
  if [ $? -eq 1 ] 
  then
    return 1
  fi
  eval is_cert_file_exist
  if [ $? -eq 1 ] 
  then
    return 1
  fi
  log_trace "Importing the trust cacert to jvm keystore ..."
  eval is_importation_successful
  return $?
}

# ----------------------------------------------------------------------------------------------------------
# main function

# trace information of the jvm -- NEEDED TO BE COMMENTED BEFORE DEPLOYMENT -- 
#echo ""
#$JVM_BIN_PATH/java -version
#echo ""
# ---------------------------------------------------------------------------

eval handle_user_parameters
eval print_used_parameters
eval handle_import_cert
if [ $? -eq 1 ]
then
  exit 1
else
  exit 0
fi



