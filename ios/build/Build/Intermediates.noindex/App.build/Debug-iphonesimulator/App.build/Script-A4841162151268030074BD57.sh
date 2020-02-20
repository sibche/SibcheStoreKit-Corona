#!/bin/bash
export TARGET_PLATFORM=ios
CORONA_MAC_BIN="$CORONA_ROOT/Corona/mac/bin"
CORONA_SHARED_BIN="$CORONA_ROOT/Corona/shared/bin"
export LUA_CPATH="$CORONA_MAC_BIN/?.so"
"$CORONA_MAC_BIN"/lua -e "package.path='$CORONA_SHARED_BIN/?.lua;$CORONA_SHARED_BIN/?/init.lua;'..package.path" "$CORONA_SHARED_BIN"/Compile.lua mac "$CORONA_ROOT"
if [ $? -ne 0 ]
then
    echo "Exiting due to errors (above)"
    exit -1
fi

