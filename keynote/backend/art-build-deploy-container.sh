#!/usr/bin/env bash

set -ex


usage() {
    echo "Deploy a docker-based build to Artifactory using docker"
    echo "Usage: $1 artifactory address"
    echo "Usage: $2 image name"
    echo "Usage: $3 image tag"
    exit 1
}

if [ -z "$1" ] || [ -z "$2"  ] || [ -z "$3"  ]; then
    usage
fi


REGISTRY=$1
IMAGE_NAME=$2
TAG=$3


docker build -t ${REGISTRY}/${IMAGE_NAME}:${TAG} -t ${REGISTRY}/${IMAGE_NAME}:latest  --build-arg REGISTRY=http://${REGISTRY}/artifactory .
docker push ${REGISTRY}/${IMAGE_NAME}