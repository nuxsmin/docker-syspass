#!/bin/bash

TAGS="sysPass sysPass-dev sysPass-dev-php7.1 sysPass-dev-php7.2"

for TAG in ${TAGS}; do
  cp -af entrypoint.sh ../${TAG}/
done
