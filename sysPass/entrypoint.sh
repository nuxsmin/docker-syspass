#!/bin/bash

COLOR_NC='\033[0m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'

<<<<<<< HEAD
setup_app () {
  [[ ! -d "./sysPass" ]] && mkdir sysPass

  if [ ! -e "./sysPass/index.php" ]; then
    echo -e "${COLOR_YELLOW}setup_app: Unpacking sysPass '${SYSPASS_BRANCH}'${COLOR_NC}"

    unzip ${SYSPASS_BRANCH}.zip
    mv sysPass-${SYSPASS_BRANCH}/* sysPass
    rm -rf sysPass-${SYSPASS_BRANCH}

    echo -e "${COLOR_YELLOW}setup_app: Setting up permissions${COLOR_NC}"

    chown ${APACHE_RUN_USER}:${SYSPASS_UID} -R sysPass/
    chmod g+w -R sysPass/
    chmod 750 sysPass/config sysPass/backup
=======
XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:-"172.17.0.1"}
XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:-"ide"}

APACHE_RUN_USER="www-data"
APACHE_RUN_GROUP="www-data"
APACHE_LOG_DIR="/var/log/apache2"
APACHE_LOCK_DIR="/var/lock/apache2"
APACHE_PID_FILE="/var/run/apache2.pid"

COMPOSER_OPTIONS="--working-dir ${SYSPASS_DIR} --no-dev --classmap-authoritative"

GOSU="gosu ${SYSPASS_UID}"

if [ -e /usr/local/sbin/init-functions ]; then
  . /usr/local/sbin/init-functions
fi

setup_app () {
  if [ -e "${SYSPASS_DIR}/index.php" ]; then
    echo -e "${COLOR_YELLOW}setup_app: Setting up permissions${COLOR_NC}"

    RW_DIRS="${SYSPASS_DIR}/app/config \
    ${SYSPASS_DIR}/app/backup \
    ${SYSPASS_DIR}/app/cache \
    ${SYSPASS_DIR}/app/resources \
    ${SYSPASS_DIR}/app/temp"

    chown ${APACHE_RUN_USER}:${SYSPASS_UID} -R ${RW_DIRS}

    chmod 750 ${RW_DIRS}

    chown ${SYSPASS_UID}:${SYSPASS_UID} -R \
    ${SYSPASS_DIR}/app/modules/*/plugins \
    ${SYSPASS_DIR}/composer.json \
    ${SYSPASS_DIR}/composer.lock \
    ${SYSPASS_DIR}/vendor
>>>>>>> 3.0
  fi
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
<<<<<<< HEAD
=======
    echo "pt_BR.UTF-8 UTF-8" >> $LOCALE_GEN
    echo "da.UTF-8 UTF-8" >> $LOCALE_GEN
>>>>>>> 3.0

    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

    dpkg-reconfigure --frontend=noninteractive locales

    update-locale LANG=en_US.UTF-8

    export LANG=en_US.UTF-8

    echo "1" > .setup
  else
    echo -e "${COLOR_YELLOW}setup_locales: Locales already set up${COLOR_NC}"
  fi
}

<<<<<<< HEAD
echo -e "${COLOR_YELLOW}entrypoint: Starting with UID : ${SYSPASS_UID}${COLOR_NC}"
id ${SYSPASS_UID} > /dev/null 2>&1 || useradd --shell /bin/bash -u ${SYSPASS_UID} -o -c "" -m user
export HOME=/home/user

setup_app

case "$1" in
  "apache")
    setup_locales

    SELF_IP_ADDRESS=$(grep $HOSTNAME /etc/hosts | cut -f1)

    echo -e "${COLOR_GREEN}######"
    echo -e "sysPass environment installed and configured. Please point your browser to http://${SELF_IP_ADDRESS} to start the installation"
    echo -e "######${COLOR_NC}"
    echo -e "${COLOR_YELLOW}entrypoint: Starting Apache${COLOR_NC}"

    # Apache gets grumpy about PID files pre-existing
    rm -f ${APACHE_PID_FILE}

    exec /usr/sbin/apache2ctl -DFOREGROUND
    ;;
  *)
    echo -e "${COLOR_YELLOW}entrypoint: Starting $@${COLOR_NC}"
    exec "$@"
=======
run_composer () {
  pushd ${SYSPASS_DIR}

  if [ -e "./composer.lock" -a -e "composer.json" ]; then
    echo -e "${COLOR_YELLOW}run_composer: Running composer${COLOR_NC}"

    ${GOSU} composer "$@" --working-dir ${SYSPASS_DIR}
  else
    echo -e "${COLOR_RED}run_composer: Error, composer not set up${COLOR_NC}"
  fi

  popd
}

setup_composer_extensions () {
  if [ -n "${COMPOSER_EXTENSIONS}" ]; then
    echo -e "${COLOR_YELLOW}setup_composer_extensions: ${COMPOSER_EXTENSIONS}${COLOR_NC}"

    run_composer require ${COMPOSER_EXTENSIONS}
  fi
}

echo -e "${COLOR_YELLOW}entrypoint: Starting with UID : ${SYSPASS_UID}${COLOR_NC}"
id ${SYSPASS_UID} > /dev/null 2>&1 || useradd --shell /bin/bash -u ${SYSPASS_UID} -o -c "" -m user
export HOME=${SYSPASS_DIR}

setup_app

case "$1" in
  "apache")
    setup_composer_extensions
    setup_locales
    setup_apache

    SELF_IP_ADDRESS=$(grep $HOSTNAME /etc/hosts | cut -f1)

    echo -e "${COLOR_GREEN}######"
    echo -e "sysPass environment installed and configured. Please point your browser to http://${SELF_IP_ADDRESS} to start the installation"
    echo -e "######${COLOR_NC}"
    echo -e "${COLOR_YELLOW}entrypoint: Starting Apache${COLOR_NC}"

    run_apache
    ;;
  "update")
    run_composer update
    ;;
  "composer")
    shift
    run_composer "$@"
    ;;
  *)
    echo -e "${COLOR_YELLOW}entrypoint: Starting $@${COLOR_NC}"
    exec ${GOSU} "$@"
>>>>>>> 3.0
    ;;
esac
