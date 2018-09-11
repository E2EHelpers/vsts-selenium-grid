#!/bin/bash

ROOT=/opt/selenium
CONF=$ROOT/config.json

/opt/bin/generate_config >$CONF

echo "starting selenium hub with configuration:"
cat $CONF

if [ ! -z "$SE_OPTS" ]; then
  echo "appending selenium options: ${SE_OPTS}"
fi

function shutdown {
    echo "shutting down hub.."
    kill -s SIGTERM $NODE_PID
    wait $NODE_PID
    echo "shutdown complete"
}

# java -cp *:. org.openqa.grid.selenium.GridLauncher -role hub -servlets org.openqa.demo.AllNodes
cd /opt/selenium/ && java ${JAVA_OPTS} -cp *:. org.openqa.grid.selenium.GridLauncherV3 \
  -role hub \
  -hubConfig $CONF \
  -servlets com.aimmac23.hub.servlet.HubVideoDownloadServlet \
  ${SE_OPTS} &
NODE_PID=$!

trap shutdown SIGTERM SIGINT
wait $NODE_PID
