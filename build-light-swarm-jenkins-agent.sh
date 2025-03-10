#!/usr/bin/env bash
set -eo pipefail

if [ -n "${DOCKER_LOGIN}" ] && [ -n "${DOCKER_PASSWORD}" ] && [ -n "${DOCKER_REGISTRY_URL}" ]; then
    if ! docker login -u "${DOCKER_LOGIN}" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY_URL}"; then
        echo "Docker login failed"
        exit 1
    fi
else
    echo "Skipping Docker login due to missing credentials"
fi

if [ "${DOCKER_SYSTEM_PRUNE}" = 'true' ] ; then
    docker system prune -af
fi

last_arg='.'
if [ "${NO_CACHE}" = 'true' ] ; then
    last_arg='--no-cache .'
fi

docker build \
    -t $DOCKER_REGISTRY_URL/jdk:17 \
    -f jdk/Dockerfile \
    $last_arg

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=jdk \
    --build-arg BASE_TAG=17 \
    -t $DOCKER_REGISTRY_URL/jdk-testutils:latest \
    -f test-utils/Dockerfile \
    $last_arg

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=jdk-testutils \
    --build-arg BASE_TAG=latest \
    -t $DOCKER_REGISTRY_URL/light-jenkins-agent:latest \
    -f swarm-jenkins-agent/Dockerfile \
    $last_arg

if [[ $PUSH_AGENT != "false" ]] ; then
  docker push $DOCKER_REGISTRY_URL/light-jenkins-agent:latest
fi
