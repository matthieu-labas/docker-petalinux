#!/bin/bash
VERFILE="SDK/data/dynamic_language_bundle.properties"
[ ! -f "$VERFILE" ] && echo "Could not locate version file" && exit 1
eval $(grep ^DEFAULT_DESTINATION_FOLDER_LIN= "$VERFILE")
[ -z "$DEFAULT_DESTINATION_FOLDER_LIN" ] && echo "Could not guess version" && exit 2
XILVER=$(basename "$DEFAULT_DESTINATION_FOLDER_LIN")
cd SDK && tar czf ../Xilinx-SDK-v${XILVER}.tgz * && cd .. && rm -rf SDK
