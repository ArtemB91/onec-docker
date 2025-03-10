#!/bin/bash

path_1cedtcli=$(find /opt/1C/1CE -type f -name "1cedtcli" -exec dirname {} \; | head -n 1)
if [ -n "$path_1cedtcli" ]; then
    echo "Found 1cedtcli in $path_1cedtcli"
    ln -s $path_1cedtcli /opt/1C/1CE/components/1c-edt
else
    echo "1cedtcli not found in /opt/1C/1CE"
fi


path_ring=$(find /opt/1C/1CE -type f -name "ring" -exec dirname {} \; | head -n 1)
if [ -n "$path_ring" ]; then
    echo "Found ring in $path_ring"
    ln -s $path_ring /opt/1C/1CE/components/1c-enterprise-ring
else
    echo "ring not found in /opt/1C/1CE"
fi