#!/bin/bash

set -e

function main() {
  if [[ $GITHUB_REF == *"heads/master"* ]]; then
    IMAGE_TAG="latest"
  else
    IMAGE_TAG=$(echo ${GITHUB_REF} | sed -e "s/refs\/heads\///g" | sed -e "s/\//-/g")
  fi;

  echo ${GITHUB_TOKEN} | docker login -u ${GITHUB_ACTOR} --password-stdin ${DOCKER_REGISTRY}

  DOCKER_IMAGE_NAME=docker.pkg.github.com/${GITHUB_REPOSITORY}:${IMAGE_TAG}

  docker build --build-arg GITHUB_TOKEN -t ${DOCKER_IMAGE_NAME} .
  docker push ${DOCKER_IMAGE_NAME}

  echo "::set-output name=tag::${IMAGE_TAG}"
  DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' ${DOCKER_IMAGE_NAME})
  echo "::set-output name=digest::${DIGEST}"

  docker logout ${DOCKER_REGISTRY}
}

main