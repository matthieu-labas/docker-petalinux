#!/bin/bash
# Run from a PetaLinux project directory
latest=$(docker image list | grep ^petalinux | awk '{ print $2 }' | sort | tail -1)
echo "Starting petalinux:$latest"
docker run -ti -v "$PWD":"$PWD" -w "$PWD" --rm -u petalinux petalinux:$latest $@
