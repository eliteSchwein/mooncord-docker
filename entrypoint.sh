#!/bin/sh
if [ -z "$(ls -A /config)" ]; then
  echo "Populating /config with default files"
  cp -r /defaults/* /config/
fi
if [ -n "$SETUP_NAME" ]; then
    exec "$@" setup "$SETUP_NAME"
else
    exec "$@"
fi
