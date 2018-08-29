#!/bin/bash

# Default version 2018.2
XILVER=${1:-2018.2}

# Check SDK and petalinux installers exists
SDK="resources/Xilinx-SDK-v${XILVER}.tgz"
PLNX="resources/petalinux-v${XILVER}-final-installer.run"
if [ ! -f "$SDK" -o ! -f "$PLNX" ] ; then
	echo "$SDK or $PLNX installers not found"
	exit 1
fi

# Check HTTP server is running
if ! ps -fC python | grep "SimpleHTTPServer" > /dev/null ; then
	python -m SimpleHTTPServer &
	HTTPID=$!
	echo "HTTP Server started as PID $HTTPID"
	trap "kill $HTTPID" EXIT KILL QUIT SEGV INT HUP TERM ERR
fi

echo "Creating Docker image petalinux:$XILVER..."
time docker build . -t petalinux:$XILVER --build-arg XILVER=${XILVER}
[ -n "$HTTPID" ] && kill $HTTPID && echo "Killed HTTP Server"
