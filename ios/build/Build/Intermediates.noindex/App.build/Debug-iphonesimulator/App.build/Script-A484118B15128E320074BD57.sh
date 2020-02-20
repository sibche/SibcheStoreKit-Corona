#!/bin/sh
"$CORONA_ROOT"/Corona/mac/bin/CreateInfoPlist.sh

if [ $? -ne 0 ]
then
    echo "Exiting due to errors (above)"
    exit -1
fi

