#!/bin/sh
# Ahsay Online Backup Manager 6.27.0.0

echo "Starting up, please wait ..."

# -------------------------- Set the Build Filename ----------------------------
AUA_BUILD_FILENAME=exec-unx-product.xml

# --------------------------- Change to AUA_HOME -------------------------------
cd `dirname "$0"`
cd ..
AUA_HOME=`pwd`

# ------------------- ApacheANT Execution via Java -----------------------------
# The following properties are referenced from path "/Applications/@mac.app.product.name@/aua"
AUA_ANT_CLASSPATH=./ant/lib/ant.jar:./ant/lib/ant-launcher.jar

# Run ApacheANT with AutoUpdateAgent JVM
"${AUA_HOME}/jvm/bin/java" -Xrs -Dant.home=./ant -cp ${AUA_ANT_CLASSPATH} org.apache.tools.ant.launch.Launcher -f ./builds/${AUA_BUILD_FILENAME}

exit 0
