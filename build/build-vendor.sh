#!/usr/bin/env bash
#
# Build vendor package for offline installations
#

APP_DIR="$(pwd)/app"
SYSPASS_REPO="https://github.com/nuxsmin/sysPass.git"
COMPOSER_OPTS="--ignore-platform-reqs --no-interaction --no-plugins --no-scripts --prefer-dist --no-dev --optimize-autoloader --classmap-authoritative --working-dir"
COMPOSER_IMAGE="composer:1.8"
VENDOR_PACKAGE="vendor.tar.gz"

if [ ! -d "${APP_DIR}" ]; then
  git clone -b master ${SYSPASS_REPO} ${APP_DIR}
else
  git pull --no-tags ${APP_DIR} master
fi

[[ -e ${VENDOR_PACKAGE} ]] && rm -rf ${VENDOR_PACKAGE}

docker run --rm -v "${APP_DIR}":/app -u 1000 ${COMPOSER_IMAGE} composer install ${COMPOSER_OPTS} /app

pushd ${APP_DIR} > /dev/null

tar czf ../${VENDOR_PACKAGE} vendor/

popd > /dev/null
