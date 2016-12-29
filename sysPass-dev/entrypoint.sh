#!/bin/bash

XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-"172.17.0.1"}
XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:-"ide"}

trap "echo 'Stopping Apache2 ...' && /usr/sbin/apachectl stop" HUP INT QUIT KILL TERM

echo -e "Setting xdebug variables ...\n"
sed -i 's/__XDEBUG_REMOTE_HOST__/'"$XDEBUG_REMOTE_HOST"'/' /etc/php5/apache2/conf.d/20-xdebug.ini
sed -i 's/__XDEBUG_IDE_KEY__/'"$XDEBUG_IDE_KEY"'/' /etc/php5/apache2/conf.d/20-xdebug.ini

echo -e "Starting Apache2 ...\n"
/usr/sbin/apache2ctl -D FOREGROUND &

wait $!
