#!/bin/bash

COLOR_NC='\033[0m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'

XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-"172.17.0.1"}
XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:-"ide"}

SYSPASS_DIR="/var/www/html/sysPass"

setup_app () {
  if [ ! -e "${SYSPASS_DIR}/index.php" ]; then
    echo -e "${COLOR_YELLOW}setup_app: Unpacking sysPass${COLOR_NC}"

    unzip ${SYSPASS_BRANCH}.zip

    if [ ! -d "${SYSPASS_DIR}" ]; then
      mv -f sysPass-${SYSPASS_BRANCH} ${SYSPASS_DIR}
    else
      cp -a sysPass-${SYSPASS_BRANCH}/* ${SYSPASS_DIR}/
    fi

    echo -e "${COLOR_YELLOW}setup_app: Setting up permissions${COLOR_NC}"

    chown ${APACHE_RUN_USER}:${SYSPASS_UID} -R ${SYSPASS_DIR}/
    chmod g+w -R ${SYSPASS_DIR}/
    chmod 750 ${SYSPASS_DIR}/app/config \
      ${SYSPASS_DIR}/app/backup \
      ${SYSPASS_DIR}/app/cache \
      ${SYSPASS_DIR}/app/temp
  fi
}

setup_composer () {
  pushd ${SYSPASS_DIR}

  if [ -e "composer.lock" -a -d "vendor" ]; then
    echo -e "${COLOR_YELLOW}setup_composer: Composer already set up${COLOR_NC}"
    popd

    run_composer update --optimize-autoloader

    return 0
  fi

  echo -e "${COLOR_YELLOW}setup_composer: Setting up composer${COLOR_NC}"

  if [ ! -e "composer.phar" ]; then
    EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
    gosu ${SYSPASS_UID} php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")"

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
        >&2 echo 'ERROR: Invalid installer signature'
        gosu ${SYSPASS_UID} rm -f composer-setup.php
        exit 1
    fi

    gosu ${SYSPASS_UID} php composer-setup.php --quiet
    gosu ${SYSPASS_UID} rm -f composer-setup.php
  else
    gosu ${SYSPASS_UID} php composer.phar self-update
  fi

  [[ $? -eq 0 && -e "composer.json" ]] \
    && gosu ${SYSPASS_UID} php composer.phar install --optimize-autoloader

  popd
}

setup_locales() {
  if [ ! -e ".setup" ]; then
    LOCALE_GEN="/etc/locale.gen"

    echo -e "${COLOR_YELLOW}setup_locales: Setting up locales${COLOR_NC}"

    echo -e "\n### sysPass locales" >> $LOCALE_GEN
    echo "es_ES.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "en_US.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "en_GB.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "de_DE.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "ca_ES.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "fr_FR.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "ru_RU.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "pl_PL.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "nl_NL.UTF-8 UTF-8" >> $LOCALE_GEN

    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

    dpkg-reconfigure --frontend=noninteractive locales

    update-locale LANG=en_US.UTF-8

    export LANG=en_US.UTF-8

    echo "1" > .setup
  else
    echo -e "${COLOR_YELLOW}setup_locales: Locales already set up${COLOR_NC}"
  fi
}

setup_apache () {
  echo -e "${COLOR_YELLOW}setup_apache: Setting up xdebug variables${COLOR_NC}"
  sed -i 's/__XDEBUG_REMOTE_HOST__/'"$XDEBUG_REMOTE_HOST"'/' /etc/php/7.0/apache2/conf.d/20-xdebug.ini
  sed -i 's/__XDEBUG_IDE_KEY__/'"$XDEBUG_IDE_KEY"'/' /etc/php/7.0/apache2/conf.d/20-xdebug.ini
}

run_composer () {
  pushd ${SYSPASS_DIR}

  if [ -e "./composer.phar" -a -e "./composer.lock" ]; then
    echo -e "${COLOR_YELLOW}run_composer: Running composer${COLOR_NC}"

    gosu ${SYSPASS_UID} php composer.phar "$@" --working-dir ${SYSPASS_DIR}
  else
    echo -e "${COLOR_RED}run_composer: Error, composer not set up${COLOR_NC}"
  fi

  popd
}

echo -e "${COLOR_YELLOW}entrypoint: Starting with UID : ${SYSPASS_UID}${COLOR_NC}"
id ${SYSPASS_UID} > /dev/null 2>&1 || useradd --shell /bin/bash -u ${SYSPASS_UID} -o -c "" -m user
export HOME=${SYSPASS_DIR}

setup_app

case "$1" in
  "apache")
    setup_composer
    setup_locales
    setup_apache

    SELF_IP_ADDRESS=$(grep $HOSTNAME /etc/hosts | cut -f1)

    echo -e "${COLOR_GREEN}######"
    echo -e "sysPass environment installed and configured. Please point your browser to http://${SELF_IP_ADDRESS} to start the installation"
    echo -e "######${COLOR_NC}"
    echo -e "${COLOR_YELLOW}entrypoint: Starting Apache${COLOR_NC}"

    # Apache gets grumpy about PID files pre-existing
    rm -f ${APACHE_PID_FILE}

    exec /usr/sbin/apache2ctl -DFOREGROUND
    ;;
  "update")
    setup_composer
    run_composer update
    ;;
  "composer")
    setup_composer
    shift
    run_composer "$@"
    ;;
  *)
    echo -e "${COLOR_YELLOW}entrypoint: Starting $@${COLOR_NC}"
    exec gosu ${SYSPASS_UID} "$@"
    ;;
esac
