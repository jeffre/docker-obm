#!/bin/sh
# Ahsay Online Backup Manager 6.29.0.0

# --------------------------- Change to AUA_HOME -------------------------------
cd `dirname "$0"`
cd ..
AUA_HOME=`pwd`

# --------------------------- Set the Action Name ------------------------------
AUA_ACTION=update

# ----------------- AutoUpdateAgent Execution via Java -------------------------
# Use JAVA to execute the AutoUpdateAgent Server
AUA_CLASSPATH=./lib:$AUA_HOME/lib/jdom.jar:./lib/log4j.jar:./lib/aua.jar:./ant/lib/ant.jar:./ant/lib/ant-launcher.jar:./ant/lib/xercesImpl.jar:./ant/lib/xml-apis.jar

"${AUA_HOME}/jvm/bin/auaJW" -Xrs -Djava.library.path=./lib -cp $AUA_CLASSPATH auas config.xml ${AUA_ACTION} &
exit 0
