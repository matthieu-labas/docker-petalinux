#!/bin/bash
PLXI="$1"
[ ! -f "$PLXI" ] && echo "Cannot find $PLXI" && exit 1
SZLEFT=$(df -B 1 /tmp | tail -1 | awk '{ print $4 }')
SZFILE=$(stat -c %s "$PLXI")
[ $SZLEFT -lt $SZFILE ] && echo "Not enough space on /tmp" && exit 2
SKIP=$(awk '/^##__PLNXSDK_FOLLOWS__/ { print NR + 1; exit 0; }' "$PLXI")
# TODO: Locally check checksum and patch checksum check
head -$(($SKIP -1)) "$PLXI" | sed 's/^accept_license$/# accept_license/' > /tmp/plsh \
&& tail -n +$SKIP "$PLXI" > /tmp/plbin \
&& cat /tmp/plsh /tmp/plbin > "$(basename $PLXI)" \
&& rm -f /tmp/plsh /tmp/plbin
