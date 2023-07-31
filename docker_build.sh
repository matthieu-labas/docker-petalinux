#!/bin/bash

# Default version 2022.2
XILVER=${1:-2022.2}

# Check SDK and petalinux installers exists
PLNX="resources/petalinux-v${XILVER}-final-installer.run"
if [ ! -f "$PLNX" ] ; then
	echo "$PLNX installers not found"
	exit 1
fi

# Check HTTP server is running
if ! ps -fC python3 | grep http.server > /dev/null ; then
	python3 -m http.server &
	HTTPID=$!
	echo "HTTP Server started as PID $HTTPID"
	trap "kill $HTTPID" EXIT KILL QUIT SEGV INT HUP TERM ERR
fi

echo "Creating Docker image petalinux:$XILVER..."
time docker build . -t petalinux:$XILVER --build-arg XILVER=${XILVER}
[ -n "$HTTPID" ] && kill $HTTPID && echo "Killed HTTP Server"
