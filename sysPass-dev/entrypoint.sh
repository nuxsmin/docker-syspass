#!/bin/bash

COLOR_NC='\033[0m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'

XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-"172.17.0.1"}
XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:-"ide"}

setup_app () {
  [[ ! -d "./sysPass" ]] && mkdir sysPass

  if [ ! -e "./sysPass/index.php" ]; then
    echo -e "${COLOR_YELLOW}setup_app: Unpacking sysPass${COLOR_NC}"

    unzip ${SYSPASS_BRANCH}.zip
    mv sysPass-${SYSPASS_BRANCH}/* sysPass
    rm -rf sysPass-${SYSPASS_BRANCH}

    echo -e "${COLOR_YELLOW}setup_app: Setting up permissions${COLOR_NC}"

    chown ${APACHE_RUN_USER}:${SYSPASS_UID} -R sysPass/
    chmod g+w -R sysPass/
    chmod 750 sysPass/config sysPass/backup
  fi
}

setup_composer () {
  pushd ./sysPass

  if [ -e "composer.phar" -a -e "composer.lock" -a -d "vendor" ]; then
    echo -e "${COLOR_YELLOW}setup_composer: Composer already set up${COLOR_NC}"
    echo -e "${COLOR_YELLOW}setup_composer: Updating${COLOR_NC}"

    run_composer update
    popd
    return 0
  fi

  echo -e "${COLOR_YELLOW}setup_composer: Setting up composer${COLOR_NC}"

  if [ ! -e "composer.phar" ]; then
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
  sed -i 's/__XDEBUG_REMOTE_HOST__/'"$XDEBUG_REMOTE_HOST"'/' /etc/php5/apache2/conf.d/20-xdebug.ini
  sed -i 's/__XDEBUG_IDE_KEY__/'"$XDEBUG_IDE_KEY"'/' /etc/php5/apache2/conf.d/20-xdebug.ini
}

run_composer () {
  if [ -e "./composer.phar" -a -e "./composer.lock" ]; then
    echo -e "${COLOR_YELLOW}run_composer: Running composer${COLOR_NC}"

    composer.phar "$@"
  else
    echo -e "${COLOR_RED}run_composer: Error, composer not set up${COLOR_NC}"
  fi
}

echo -e "${COLOR_YELLOW}entrypoint: Starting with UID : ${SYSPASS_UID}${COLOR_NC}"
id ${SYSPASS_UID} > /dev/null 2>&1 || useradd --shell /bin/bash -u ${SYSPASS_UID} -o -c "" -m user
export HOME=/home/user

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
    exec "$@"
    ;;
esac
