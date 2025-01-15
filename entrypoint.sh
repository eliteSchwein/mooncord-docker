#!/bin/sh
if [ -z "$(ls -A /config)" ]; then
  echo "Populating /config with default files"
  cp -r /defaults/* /config/
fi
exec "$@"