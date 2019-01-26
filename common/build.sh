#!/bin/bash

TAGS="sysPass sysPass-dev sysPass-dev-php7.1 sysPass-dev-php7.2"
BRANCH="master"
VERSION="3.0.4"
BUILD="19012601"

for TAG in ${TAGS}; do
  cp -af entrypoint.sh 000-default.conf default-ssl.conf ../${TAG}/
  sed -i 's/SYSPASS_BRANCH="[a-z0-9\.]\+"/SYSPASS_BRANCH="'${BRANCH}'"/i;
          s/version=[a-z0-9\.\-]\+/version='${VERSION}'/i;
          s/build=[0-9]\+/build='${BUILD}'/' ../${TAG}/Dockerfile
done
