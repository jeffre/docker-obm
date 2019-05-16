#!/bin/bash


# Create user config folder
mkdir -p /root/.obm/config/


# Create configuration for logging into OBSR
cat << EOF > /root/.obm/config/config.ini
SET_VERSION_52_SCHEDULE_TAG=Y
ID=${USERNAME:-unknown}
PWD=${PASSWORD:-unknown}
LANG=${LANG:-en}
HOST=${SERVER-unknown}
PROTOCOL=${PROTO:-https}
SAVE_PWD=Y
EOF


# Append any default Encrytion rules (per backupset)
# These should be provided to the container as an environment variable such as:
# BSET-1498585537118=PKCS7Padding,AES-256,ECB,SuperStrongSecretString
#
# Encrytion format: Algorithm, Mode, Bits, Key
#   Algorithms: AES, Twofish, TripleDES, None
#   Modes: ECB, CBC
#   Bits: 128, 256
#   Key: [anything you want]
# Examples:
#   PKCS7Padding,AES-256,ECB,SuperStrongSecretString
#   PKCS7Padding,-256,,     # No Encryption
env | grep "BSET*" >> /root/.obm/config/config.ini


# Point OBM at configuation path
echo "/root/.obm" > ${APP_HOME}/home.txt


if [[ "${#}" == 0 ]]; then
  # Establishes symlinks to jvm and sets file permissions
  ${APP_HOME}/bin/config.sh

  if [[ ${ENABLE_AUA^^} == "TRUE" ]]; then
    # Start AUA (automatically daemonizes)
    ${APP_HOME}/aua/bin/startup.sh
  fi

  # Monitor scheduler logs
  tail -F /root/.obm/log/Scheduler/debug.log 2>/dev/null &

  # Starts Scheduler Service
  ${APP_HOME}/bin/Scheduler.sh

elif [[ ${1,,} == "runbackupset" ]]; then
  # $2 should be backupsetid
  sed -i bin/RunBackupSet.sh \
    -e 's|^BACKUP_SET=.*$|BACKUP_SET="${2}"|' \
    -e 's|^SETTING_HOME=.*$|SETTING_HOME="${DOT_OBM}"|' 

  ./bin/RunBackupSet.sh

else
  exec "${@}"

fi
