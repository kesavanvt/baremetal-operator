#!/bin/sh

set -eux

IS_CONTAINER=${IS_CONTAINER:-false}
CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-podman}"

if [ "${IS_CONTAINER}" != "false" ]; then
  TOP_DIR="${1:-.}"
  export XDG_CACHE_HOME="/tmp/.cache"

  cd "${TOP_DIR}"
  DIRS=$(make show_dirs)

  # shellcheck disable=SC2086
  if [ -n "$(gofmt -l ${DIRS})" ]; then
      make fmt
      exit 1
  fi
else
  "${CONTAINER_RUNTIME}" run --rm \
    --env IS_CONTAINER=TRUE \
    --volume "${PWD}:/workdir:rw,z" \
    --entrypoint sh \
    --workdir /workdir \
    registry.hub.docker.com/library/golang:1.13.7 \
    /workdir/hack/gofmt.sh "${@}"
fi;
