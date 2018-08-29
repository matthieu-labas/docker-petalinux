#!/bin/bash
if ! ps -fC python | grep "SimpleHTTPServer" > /dev/null ; then
	python -m SimpleHTTPServer &
	HTTPID=$!
	echo "HTTP Server started as PID $HTTPID"
	trap "kill $HTTPID" EXIT KILL QUIT SEGV INT HUP TERM ERR
fi

XILVER=${1:-2018.2}
echo "Creating Docker image petalinux:$XILVER..."
docker build . -t petalinux:$XILVER --build-arg XILVER=${XILVER}
[ -n "$HTTPID" ] && kill $HTTPID && echo "Killed HTTP Server"
