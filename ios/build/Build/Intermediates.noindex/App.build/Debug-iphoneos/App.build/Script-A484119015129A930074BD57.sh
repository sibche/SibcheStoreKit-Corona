#!/bin/sh
# Ensures that next attempt to build actually rebuilds the executable so it can be (re)app_sign(ed)
echo "Updating modification time of $PROJECT_DIR/main.mm to trigger relink of $BUILT_PRODUCTS_DIR/$EXECUTABLE_PATH"
echo "We need to do this b/c app_sign can only sign an unsigned executable."
touch "$PROJECT_DIR/main.mm"
