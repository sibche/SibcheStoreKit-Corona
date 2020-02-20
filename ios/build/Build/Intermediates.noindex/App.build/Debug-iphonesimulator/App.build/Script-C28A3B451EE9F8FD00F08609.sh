#!/bin/sh
# echo "CORONA_ROOT: ${CORONA_ROOT}"
if [ ! -d "${CORONA_ROOT}" ]
then
echo "error: Corona Native has not been setup.  Run 'Native/SetupCoronaNative.app' in your Corona install to set it up" >&2

exit 1
else
echo "Building with Corona Native from $(readlink "${CORONA_ROOT}")"
fi

# Check for difficult to debug error involving an item in the Corona
# project directory having the same name as a file in the app bundle
if [ -d "${PROJECT_DIR}/../Corona/${EXECUTABLE_NAME}" ]
then
echo "ERROR: cannot have a directory called '$(ls "${PROJECT_DIR}/../Corona" | grep -iw ${EXECUTABLE_NAME})' in the Corona project directory because it has the same name as the app"
exit 1
fi

