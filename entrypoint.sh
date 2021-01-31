#!/bin/bash

set -e

function main() {
  if [[ $GITHUB_REF == *"heads/master"* ]]; then
    IMAGE_TAG="latest"
  else
    IMAGE_TAG=$(echo ${GITHUB_REF} | sed -e "s/refs\/heads\///g" | sed -e "s/\//-/g")
  fi;

  DOCKER_REGISTRY=docker.pkg.github.com

  echo "Github Actor: ${GITHUB_ACTOR}"
  echo ${GITHUB_TOKEN} | docker login -u ${GITHUB_ACTOR} --password-stdin ${DOCKER_REGISTRY}

  DOCKER_IMAGE_NAME=${DOCKER_REGISTRY}/${GITHUB_REPOSITORY}/${INPUT_NAME}:${IMAGE_TAG}

  docker build --build-arg GITHUB_TOKEN -t ${DOCKER_IMAGE_NAME} .
  docker push ${DOCKER_IMAGE_NAME}

  echo "::set-output name=tag::${IMAGE_TAG}"
  DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' ${DOCKER_IMAGE_NAME})
  echo "::set-output name=digest::${DIGEST}"

  docker logout ${DOCKER_REGISTRY}
}

main