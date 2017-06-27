#!/bin/bash
# This script is compatible with cbs, obsr, and rdr

# Determine what ahsay product is installed
if [ -d "/cbs" ]; then
    AHSAY_APP=cbs
elif [ -d "/obsr" ]; then
    AHSAY_APP=obsr
elif [ -d "/rdr" ]; then
    AHSAY_APP=rdr
else
    echo "/cbs, /obsr, or /rdr folder must exist!"
    exit 1;
fi


# Change catalina.sh to 'run' (prevent deamonizing)
# Remove `nohup` (prevent backgrounding)
# Change CATALINA_PID path (obsr.pid) to a directory `ahsay` can read/write
sed -i bin/startup.sh \
    -e 's/catalina.sh" start.*/catalina.sh" run/g' \
    -e 's/nohup//g' \
    -e 's@/var/run/obsr\.pid@/obsr/obsr.pid@g'

sed -i bin/shutdown.sh\
    -e 's@/var/run/obsr\.pid@/obsr/obsr.pid@g'


# Use ports 8080 and 8443
# Replace depreciated 'sslProtocols' attribute AND enable SSLv2Hello
# Add requested hostname ("local server name") to Tomcat access logs
sed -i conf/server.xml \
    -e 's/port="80"/port="8080"/g' \
    -e 's/port="443"/port="8443"/g' \
    -e 's/sslProtocols="TLSv1"/sslEnabledProtocols="TLSv1,SSLv2Hello"/g' \
    -e "s/pattern=\"common\"/pattern='%h %l %u %t %v "%r" %s %b'/g"


# Trust X-Forwarded-IPs from internal addresses
if (! grep -q "org.apache.catalina.valves.RemoteIpValve" conf/server.xml); then
  sed -i conf/server.xml \
      -e 's@</Host>@  \
        <Valve className="org.apache.catalina.valves.RemoteIpValve" \
          remoteIpHeader="X-Forwarded-For" \
          internalProxies="172.1[6-9]\.\d+\.\d+, 172.2[0-9]\.\d+\.\d+, \
          172.3[0-1]\.\d+\.\d+, 10\.\d+\.\d+\.\d+" /> \
      </Host>@g'
fi


# Stop catalina properly to avoid corrupting Profile.xml files and then exit
#   the container with exitcode 143 (128 + 15)
catalina_stop () {
  echo "Running Catalina Stop"
  pgrep --uid 400 -f java > /$AHSAY_APP/$AHSAY_APP.pid
  /$AHSAY_APP/bin/shutdown.sh
  exit 143;
}


# Intercept SIGTERM (issued from `docker stop`) then kill `tail -f` and run
#   `catalina_stop`
trap 'kill ${!}; catalina_stop' SIGTERM


# Start AHSAY_APP and get its PID
/$AHSAY_APP/bin/startup.sh &
pid="$!"


# Wait forever
while true; do
  tail -f /dev/null & wait ${!}
done
