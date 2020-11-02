#!/bin/bash

DOT_OBM="/root/.obm"

# Ensure proper environment variables are set for some specific scripts
REQ_CONFIG=(
    ListBackupJob.sh ListBackupSet.sh ListBackupSetFiles.sh Restore.sh
    RunBackupSet.sh RunDataIntegrityCheck.sh RunLotusBackup.sh
    Scheduler.sh
)
if [[ " ${REQ_CONFIG[@]} " =~ " ${1} " ]]; then
  [[ -n $USERNAME ]] || ERRORS+=("USERNAME must be set")
  [[ -n $PASSWORD ]] || ERRORS+=("PASSWORD must be set")
  [[ -n $SERVER ]] || ERRORS+=("SERVER must be set")
  if [[ ${#ERRORS[@]} -gt 0 ]]; then
    for e in "${ERRORS[@]}"; do
      echo $e
    done
    exit 1
  fi
fi


shopt -s nocaseglob


if [[ ${1} == "VERSION" ]]; then
  cat /obm/version.txt
  exit 0
fi


# Create user config folder
mkdir -p "${DOT_OBM}"/config/


# Create configuration for logging into OBSR
sed -re 's|^\s{2}||g' << EOF > "${DOT_OBM}"/config/config.ini
  ID=${USERNAME}
  PWD=${PASSWORD}
  LANG=en
  HOST=${SERVER}
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
#   ,,,     # No Encryption
env | grep "BSET*" >> "${DOT_OBM}"/config/config.ini


# Point OBM at configuation path
echo "${DOT_OBM}" > ${APP_HOME}/home.txt


exec "${@}"
