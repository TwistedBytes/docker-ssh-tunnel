#!/bin/bash

set -e
set -x
# docker buildx create --name mybuilder --driver docker-container --bootstrap

function build(){
  docker buildx use mybuilder

  local IMAGENAME=twistedbytes/docker-ssh-tunnel
  docker buildx build \
    --progress plain \
    --platform ${PLATFORMS} \
    --rm \
    -t "${IMAGENAME}:${IMAGE_VERSION}" \
    -t "${IMAGENAME}:latest" \
    --build-arg CENTOS_VERSION="${CENTOS_VERSION}" \
    --build-arg FROM_VERSION="${FROM_VERSION}" \
    --build-arg IMAGE_VERSION="${IMAGE_VERSION}" \
    --build-arg YUMDNF="${YUMDNF}" \
    --push \
    "${TEMPLATE_DIR}"

#  docker tag "${IMAGENAME}:${IMAGE_VERSION}" "${IMAGENAME}:latest"
#
#  if [[ $PUSH -eq 1 ]]; then
#    docker push "${IMAGENAME}:${IMAGE_VERSION}"
#    docker push "${IMAGENAME}:latest"
#  fi
}

TEMPLATE_DIR=.
FROM_VERSION=latest
IMAGE_VERSION=$( date +%Y.%m.%d ).01

# CENTOSVERSION
declare -a _BUILDS=(
  # 9@linux/amd64,linux/arm64
  9@linux/amd64,linux/arm64
)

for i in "${_BUILDS[@]}"; do
  IFS=@ read CENTOS_VERSION PLATFORMS <<< $i

  if [[ $CENTOS_VERSION -eq 7 ]]; then
    YUMDNF=yum
  else
    YUMDNF=dnf
  fi

  FROM_IMAGE=twistedbytes/centos${CENTOS_VERSION}-stream:${FROM_VERSION}

  echo "Building:"
  echo "CENTOS:  ${CENTOS_VERSION}"
  echo "PLATFORMS:  ${PLATFORMS}"
  build
done
