#!/bin/bash

/opt/bin/generate_config > /opt/selenium/config.json

export GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"

if [ ! -e /opt/selenium/config.json ]; then
  echo No Selenium Node configuration file, the node-base image is not intended to be run directly. 1>&2
  exit 1
fi

# In the long term the idea is to remove $HUB_PORT_4444_TCP_ADDR and $HUB_PORT_4444_TCP_PORT and only work with
# $HUB_HOST and $HUB_PORT
if [ ! -z "$HUB_HOST" ]; then
  HUB_PORT_PARAM=4444
  if [ ! -z "$HUB_PORT" ]; then
      HUB_PORT_PARAM=${HUB_PORT}
  fi
  echo "Connecting to the Hub using the host ${HUB_HOST} and port ${HUB_PORT_PARAM}"
  HUB_PORT_4444_TCP_ADDR=${HUB_HOST}
  HUB_PORT_4444_TCP_PORT=${HUB_PORT_PARAM}
fi

if [ -z "$HUB_PORT_4444_TCP_ADDR" ]; then
  echo "Not linked with a running Hub container" 1>&2
  exit 1
fi

function shutdown {
  kill -s SIGTERM $NODE_PID
  wait $NODE_PID
}

REMOTE_HOST_PARAM=""
if [ ! -z "$REMOTE_HOST" ]; then
  echo "REMOTE_HOST variable is set, appending -remoteHost"
  REMOTE_HOST_PARAM="-remoteHost $REMOTE_HOST"
fi

if [ ! -z "$SE_OPTS" ]; then
  echo "appending selenium options: ${SE_OPTS}"
fi

rm -f /tmp/.X*lock

cd /opt/selenium/

xvfb-run -a --server-args="-screen 0 $GEOMETRY -ac +extension RANDR" \
   java ${JAVA_OPTS} -cp *:. org.openqa.grid.selenium.GridLauncherV3 \
    -role node \
    -hub http://$HUB_PORT_4444_TCP_ADDR:$HUB_PORT_4444_TCP_PORT/grid/register \
    ${REMOTE_HOST_PARAM} \
    -nodeConfig /opt/selenium/config.json \
    -servlets com.aimmac23.node.servlet.VideoRecordingControlServlet \
    -proxy com.aimmac23.hub.proxy.VideoProxy \
    ${SE_OPTS} &
NODE_PID=$!

trap shutdown SIGTERM SIGINT
wait ${NODE_PID}
