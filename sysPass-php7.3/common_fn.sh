: ${XDEBUG_REMOTE_HOST:="172.17.0.1"}
: ${XDEBUG_IDE_KEY:="ide"}
: ${SYSPASS_DEV:=0}
: ${PHP_XDEBUG_FILE:="/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"}
: ${SYSPASS_LOCALES:="es_ES en_US en_GB de_DE ca_ES fr_FR ru_RU pl_PL nl_NL pt_BR da_DK it_IT fo_FO ja_JP"}
: ${COMPOSER_EXTENSIONS:=}
: ${DEBUG:=0}

if [ ${DEBUG} -eq 1 ]; then
  set -x
fi

COMPOSER_OPTIONS="--working-dir ${SYSPASS_DIR} --classmap-authoritative"
GOSU="gosu ${SYSPASS_UID}"

COLOR_NC='\033[0m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'

if [ ${SYSPASS_DEV} -eq 1 ]; then
  COMPOSER_OPTIONS="--working-dir ${SYSPASS_DIR} --optimize-autoloader --dev"
fi

setup_apache () {
  if [ ${SYSPASS_DEV} -eq 0 ]; then
    return 0
  fi

  echo -e "${COLOR_YELLOW}setup_apache: Setting up xdebug variables${COLOR_NC}"

  sed -i 's/__XDEBUG_REMOTE_HOST__/'"$XDEBUG_REMOTE_HOST"'/;
  s/__XDEBUG_IDE_KEY__/'"$XDEBUG_IDE_KEY"'/' \
  ${PHP_XDEBUG_FILE}
}

run_apache () {
  : ${PHP_INI_DIR:=}

  if [ -z "${PHP_INI_DIR}" ]; then
    echo -e "${COLOR_YELLOW}run_apache: Starting Apache${COLOR_NC}"

    # Apache gets grumpy about PID files pre-existing
    rm -f ${APACHE_PID_FILE}

    exec /usr/sbin/apache2ctl -DFOREGROUND
  else
    echo -e "${COLOR_YELLOW}run_apache: Starting Apache (PHP)${COLOR_NC}"

    apache2-foreground
  fi
}

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
  fi
}

setup_locales() {
  if [ ! -e ".setup" ]; then
    LOCALE_GEN="/etc/locale.gen"

    echo -e "${COLOR_YELLOW}setup_locales: Setting up locales${COLOR_NC}"

    echo -e "\n### sysPass locales" >> $LOCALE_GEN

    for LOCALE in ${SYSPASS_LOCALES}; do
      echo "${LOCALE}.UTF-8 UTF-8" >> $LOCALE_GEN
    done

    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

    dpkg-reconfigure --frontend=noninteractive locales

    update-locale LANG=en_US.UTF-8

    export LANG=en_US.UTF-8

    echo "1" > .setup
  else
    echo -e "${COLOR_YELLOW}setup_locales: Locales already set up${COLOR_NC}"
  fi
}

run_composer () {
  pushd ${SYSPASS_DIR}

  if [ -e "./composer.lock" -a -e "composer.json" ]; then
    echo -e "${COLOR_YELLOW}run_composer: Running composer${COLOR_NC}"

    ${GOSU} composer "$@" ${COMPOSER_OPTIONS}
  else
    echo -e "${COLOR_RED}run_composer: Error, composer not set up${COLOR_NC}"
  fi

  popd
}

setup_composer_extensions () {
  if [ -n "${COMPOSER_EXTENSIONS}" ]; then
    echo -e "${COLOR_YELLOW}setup_composer_extensions: ${COMPOSER_EXTENSIONS}${COLOR_NC}"

    run_composer require ${COMPOSER_EXTENSIONS} --update-no-dev
  fi
}
