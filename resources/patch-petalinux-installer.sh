#!/bin/bash
PLXI="$1"
[ ! -f "$PLXI" ] && echo "Cannot find $PLXI" && exit 1
# No patching necessary for v >= 2019.2 (installer accepts --skip-license or SKIP_LICENCE=y
VER=$(echo "$PLXI" | cut -f2 -d-)
VER=${VER#v*}
VMAJ=${VER%.*}
VMIN=${VER#*.}
(( $VMAJ > 2019 || $VMAJ == 2019 && $VMIN >= 2 )) && echo "No need to patch v >= 2019.2" && exit
# Patch needed for v < 2019.2
awk '/^accept_license/ { exit 0 } /^# accept_license|^#ccept_license/ { exit 1 }' "$PLXI" \
&& sed -i 's/^accept_license/# accept_license/' "$PLXI" \
|| echo "$PLXI is already patched."
