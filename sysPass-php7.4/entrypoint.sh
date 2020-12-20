#!/usr/bin/env bash

set -euo pipefail

COMMON_FN="common_fn.sh"

source ${COMMON_FN}

echo -e "${COLOR_YELLOW}entrypoint: Starting with UID : ${SYSPASS_UID}${COLOR_NC}"

id ${SYSPASS_UID} > /dev/null 2>&1 \
  || useradd --shell /bin/bash -u ${SYSPASS_UID} -o -c "" -m user

export HOME=${SYSPASS_DIR}

setup_app

case "$1" in
  "apache")
    setup_composer_extensions
    setup_locales
    setup_apache

    SELF_IP_ADDRESS=$(grep $HOSTNAME /etc/hosts | cut -f1)

    echo -e "${COLOR_GREEN}######"
    echo -e "sysPass environment installed and configured. Please point your browser to https://${SELF_IP_ADDRESS} to start the installation."
    echo -e "######${COLOR_NC}"
    echo -e "${COLOR_YELLOW}entrypoint: Starting Apache${COLOR_NC}"

    run_apache
    ;;
  "update")
    echo -e "${COLOR_YELLOW}######"
    echo -e "Please, only run this command for debuging purposes."
    echo -e "In order to update the dependencies, please, download and updated image"
    echo -e "######${COLOR_NC}"

    run_composer update
    ;;
  "composer")
    shift

    echo -e "${COLOR_YELLOW}######"
    echo -e "Please, only run this command for debuging purposes."
    echo -e "In order to update the dependencies, please, download and updated image"
    echo -e "######${COLOR_NC}"

    run_composer "$@"
    ;;
  *)
    echo -e "${COLOR_YELLOW}entrypoint: Starting $@${COLOR_NC}"
    exec ${GOSU} "$@"
    ;;
esac
