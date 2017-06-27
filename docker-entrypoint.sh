#!/bin/bash
# This script is compatible with obm


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
# Encrytion format: Algorithms, Mode, Bits, Key
#   Algorithms: AES, Twofish, TripleDES, None
#   Modes: ECB, CBC
#   Bits: 128, 256
#   Key: [anything you want]
# Examples:
#   PKCS7Padding,AES-256,ECB,SuperStrongSecretString
#   PKCS7Padding,-256,,     # No Encryption
env | grep "BSET*" >> /root/.obm/config/config.ini


# Point OBM at configuation path
echo "/root/.obm" > home.txt


# Prevent Scheduler from daemonizing
sed -i bin/Scheduler.sh \
    -e 's@> "\${APP_HOME}/log/Scheduler/console.log" 2>&1 &@@g'


# Establishes symlinks to jvm and sets file permissions
./bin/config.sh


# Monitor scheduler logs
tail -F /root/.obm/log/Scheduler/debug.log &


# Starts Scheduler Service
./bin/Scheduler.sh
