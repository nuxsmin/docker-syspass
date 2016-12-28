#!/bin/bash

trap "echo 'Stopping Apache2 ...' && /usr/sbin/apachectl stop" HUP INT QUIT KILL TERM

echo -e "Starting Apache2 ...\n"
/usr/sbin/apache2ctl -D FOREGROUND &

wait $!



