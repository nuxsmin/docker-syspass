#!/bin/bash

XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-"172.17.0.1"}
XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:-"ide"}

setup_locales() {
  if [ ! -e ".setup" ]; then
    LOCALE_GEN="/etc/locale.gen"

    echo -e "\nSetting up locales ..."

    echo -e "\n### sysPass locales" >> $LOCALE_GEN    
    echo "es_ES.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "en_US.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "de_DE.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "ca_ES.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "fr_FR.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "ru_RU.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "po_PO.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "nl_NL.UTF-8 UTF-8" >> $LOCALE_GEN
   
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

    dpkg-reconfigure --frontend=noninteractive locales
    update-locale LANG=en_US.UTF-8

    LANG=en_US.UTF-8
    
    echo "1" > .setup
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
