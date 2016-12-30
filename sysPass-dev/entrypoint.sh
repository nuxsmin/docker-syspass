#!/bin/bash

XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-"172.17.0.1"}
XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:-"ide"}

setup_locales() {
  if [ ! -e ".setup" ]; then
    echo -e "\nSetting up locales ..."
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
    -e 's/# es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' \
    -e 's/# ca_ES.UTF-8 UTF-8/ca_ES.UTF-8 UTF-8/' \
    -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' \
    -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' \ 
    -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

    echo 'LANG="en_US.UTF-8"' > /etc/default/locale
    dpkg-reconfigure --frontend=noninteractive locales
    update-locale LANG=en_US.UTF-8

    LANG=en_US.UTF-8
    
    echo "." > .setup
 fi
}

trap "echo 'Stopping Apache2 ...' && /usr/sbin/apachectl stop" HUP INT QUIT KILL TERM

setup_locales

echo -e "Setting xdebug variables ...\n"
sed -i 's/__XDEBUG_REMOTE_HOST__/'"$XDEBUG_REMOTE_HOST"'/' /etc/php5/apache2/conf.d/20-xdebug.ini
sed -i 's/__XDEBUG_IDE_KEY__/'"$XDEBUG_IDE_KEY"'/' /etc/php5/apache2/conf.d/20-xdebug.ini

echo -e "Starting Apache2 ...\n"
/usr/sbin/apache2ctl -D FOREGROUND &

wait $!
