#!/bin/sh
# Ahsay Online Backup Manager 6.29.0.0

# --------------------------- Change to AUA_HOME -------------------------------
cd `dirname "$0"`
cd ..
AUA_HOME=`pwd`

# ----------------- Setup the IPC directory ------------------------------------
# Check if IPC directory exist
if [ ! -d "./ipc" ]
  then mkdir "./ipc"
fi
# Allow all clients to access the ipc directory
chmod 777 "./ipc"

if [ ! -d "./ipc/xmlchannel" ]
  then mkdir "./ipc/xmlchannel"
fi
# Allow all clients to access the xmlchannel
chmod 777 "./ipc/xmlchannel"

# ----------------- Setup the Config file permission ---------------------------
# Allow all clients to update the config file
chmod 777 "./config.xml"

# ----------------- Remove the last created Property file ----------------------
# Remove the last created local-machine.properties file
if [ -f "./builds/local-machine.properties" ]
  then rm "./builds/local-machine.properties"
fi

# -------------------------- Set the Build Filename ----------------------------
AUA_BUILD_FILENAME=aua-check-properties.xml

# ------------------- ApacheANT Execution via Java -----------------------------
# The following properties are referenced from path "/Applications/Ahsay Online Backup Manager/aua"
AUA_ANT_CLASSPATH=./ant/lib/ant.jar:./ant/lib/ant-launcher.jar

# Run ApacheANT with AutoUpdateAgent JVM
"${AUA_HOME}/jvm/bin/java" -Xrs -Dant.home=./ant -cp ${AUA_ANT_CLASSPATH} org.apache.tools.ant.launch.Launcher -quiet -f ./builds/${AUA_BUILD_FILENAME}

exit 0
