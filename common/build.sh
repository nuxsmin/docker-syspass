#!/bin/bash

set -euo pipefail

BUILDS=`find ../ -type d -name sysPass-*`
BRANCH="${VERSION:=master}"

if [ -z "${VERSION}" ] || [ -z ${BUILD_NUMBER} ]; then
  echo "ERROR: VERSION and BUILD_NUMBER must be set"
  exit 1
fi

build_env() {
  for BUILD in ${BUILDS}; do
    TAG=`echo ${BUILD} | cut -d'-' -f2`

    echo "Building env for ${TAG} (${BUILD})"

    cp -af entrypoint.sh syspass.conf common_fn.sh ${BUILD}/

    sed -i 's/SYSPASS_BRANCH="[a-z0-9\.]\+"/SYSPASS_BRANCH="'${BRANCH}'"/i;
            s/version=[a-z0-9\.\-]\+/version='${VERSION}'/i;
            s/build=[0-9]\+/build='${BUILD_NUMBER}'/' ${BUILD}/Dockerfile
  done

  find ../ -name docker-compose.yml | while read FILE; do
    sed -i 's/syspass:[0-9\.]\+\(-rc[0-9]\+\)\?/syspass:'${VERSION}'/' ${FILE}
  done
}

build_docker() {
  for BUILD in ${BUILDS}; do
    TAG="${VERSION}-`echo ${BUILD} | cut -d'-' -f2`"

    echo "Building Docker for ${TAG} (${BUILD})"

    docker build --tag syspass:${TAG} ${BUILD}
  done

  echo "Cleaning up Docker images (dangling)"
  docker images --filter dangling=true --format {{.ID}} | xargs docker rmi
}

case $1 in
  "env")
    build_env
    ;;
  "docker")
    build_env
    build_docker
    ;;
  *)
    echo "Usage: $0 [env|docker]"
    ;;
esac
