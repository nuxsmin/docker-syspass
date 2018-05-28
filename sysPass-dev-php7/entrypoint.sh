#!/bin/bash

XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-"172.17.0.1"}
XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:-"ide"}

setup_app () {
    [[ ! -d "./sysPass" ]] && mkdir sysPass

    if [ ! -e "./sysPass/index.php" ]; then
        echo -e "\nUnpacking sysPass ..."

        unzip ${SYSPASS_BRANCH}.zip
        mv sysPass-${SYSPASS_BRANCH}/* sysPass
        chown ${APACHE_RUN_USER}:${SYSPASS_UID} -R sysPass/
        chmod g+w -R sysPass/
        chmod 750 sysPass/config sysPass/backup
    fi
}

setup_composer () {
    pushd ./sysPass

    if [ -e "composer.lock" ]; then
        echo -e "\nComposer already set up."
        return 0
    fi

    echo -e "\nSetting up composer ..."

    if [ ! -e "./sysPass/composer.phar" ]; then
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
        php composer-setup.php
        php -r "unlink('composer-setup.php');"
    fi

    php composer.phar self-update

    [[ $? -eq 0 && -e "composer.json" ]] && php composer.phar install

    popd
}

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

setup_apache () {
    echo -e "Setting up xdebug variables ...\n"
    sed -i 's/__XDEBUG_REMOTE_HOST__/'"$XDEBUG_REMOTE_HOST"'/' /etc/php/7.0/apache2/conf.d/20-xdebug.ini
    sed -i 's/__XDEBUG_IDE_KEY__/'"$XDEBUG_IDE_KEY"'/' /etc/php/7.0/apache2/conf.d/20-xdebug.ini
}

echo "Starting with UID : ${SYSPASS_UID}"
id ${SYSPASS_UID} > /dev/null 2>&1 || useradd --shell /bin/bash -u ${SYSPASS_UID} -o -c "" -m user
export HOME=/home/user

setup_locales
setup_apache
setup_app
setup_composer

case "$1" in
    "apache")
        echo -e "Starting Apache ..\n"

        # Apache gets grumpy about PID files pre-existing
        rm -f ${APACHE_PID_FILE}

        exec /usr/sbin/apache2ctl -DFOREGROUND
        ;;
    "update")
        if [ -e "./composer.phar" -a -e "./composer.lock" ]; then
            echo -e "Updating composer ..\n"

            gosu ${SYSPASS_UID} php composer.phar update
        else
            echo -e "ERROR: Composer not set up"
        fi
        ;;
    *)
        echo -e "Starting $@ ...\n"
        exec gosu ${SYSPASS_UID} "$@"
        ;;
esac
