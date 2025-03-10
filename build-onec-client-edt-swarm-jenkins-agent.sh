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

#Если версия EDT >= 2024.1.0, использовать JDK 17
# if [[ "$(printf "%s\n" "$EDT_VERSION" "2024" | sort -V | head -n 1)" == "2024" ]]; then
#   jdk_version="17"
# else
#   jdk_version="11"
# fi
jdk_version="17"

# docker build \
# 	--pull \
#     $no_cache_arg \
# 	--build-arg DOCKER_REGISTRY_URL=library \
#     --build-arg BASE_IMAGE=ubuntu \
#     --build-arg BASE_TAG=20.04 \
#     --build-arg ONESCRIPT_PACKAGES="yard" \
#     -t $DOCKER_REGISTRY_URL/oscript-downloader:latest \
# 	-f oscript/Dockerfile \
#     $last_arg

# docker build \
#     --build-arg ONEC_USERNAME=$ONEC_USERNAME \
#     --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
#     --build-arg ONEC_VERSION=$ONEC_VERSION \
#     --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
#     --build-arg BASE_IMAGE=oscript-downloader \
#     --build-arg BASE_TAG=latest \
#     -t $DOCKER_REGISTRY_URL/onec-client:$ONEC_VERSION \
#     -f client/Dockerfile \
#     $last_arg

# docker push $DOCKER_REGISTRY_URL/onec-client:$ONEC_VERSION

# docker build \
#     --pull \
#     --build-arg ONEC_USERNAME=$ONEC_USERNAME \
#     --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
#     --build-arg ONEC_VERSION=$ONEC_VERSION \
#     --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
#     -t $DOCKER_REGISTRY_URL/onec-client-vnc:$ONEC_VERSION \
#     -f client-vnc/Dockerfile \
#     $last_arg

# docker push $DOCKER_REGISTRY_URL/onec-client-vnc:$ONEC_VERSION

# docker build \
#     --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
#     --build-arg BASE_IMAGE=onec-client-vnc \
#     --build-arg BASE_TAG=$ONEC_VERSION \
#     -t $DOCKER_REGISTRY_URL/onec-client-vnc-oscript:$ONEC_VERSION \
#     -f oscript/Dockerfile \
#     $last_arg

onec_jdk_version="${ONEC_VERSION}_JDK${jdk_version}"

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client-vnc-oscript \
    --build-arg BASE_TAG=$ONEC_VERSION \
    --build-arg JDK_VERSION=$jdk_version \
    -t $DOCKER_REGISTRY_URL/onec-client-vnc-oscript-jdkfx:$onec_jdk_version \
    -f jdkfx/Dockerfile \
    $last_arg

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client-vnc-oscript-jdkfx \
    --build-arg BASE_TAG=$onec_jdk_version \
    -t $DOCKER_REGISTRY_URL/onec-client-vnc-oscript-jdkfx-testutils:$onec_jdk_version \
    -f test-utils/Dockerfile \
    $last_arg

edt_version=$EDT_VERSION
edt_escaped="${edt_version// /_}"
onec_edt_version="${ONEC_VERSION}_EDT${edt_escaped}"

docker build \
    --build-arg ONEC_USERNAME=$ONEC_USERNAME \
    --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
    --build-arg EDT_VERSION="$EDT_VERSION" \
    --build-arg BASE_IMAGE=onec-client-vnc-oscript-jdkfx-testutils \
    --build-arg BASE_TAG=$onec_jdk_version \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg DOWNLOADER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg DOWNLOADER_IMAGE=oscript-downloader \
    --build-arg DOWNLOADER_TAG=latest \
    -t $DOCKER_REGISTRY_URL/onec-client-edt:$onec_edt_version \
    -f edt/Dockerfile \
    $last_arg

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client-edt \
    --build-arg BASE_TAG=$onec_edt_version \
    -t $DOCKER_REGISTRY_URL/onec-client-edt-swarm-agent:$onec_edt_version \
    -f swarm-jenkins-agent/Dockerfile \
    $last_arg

if [[ $PUSH_AGENT != "false" ]] ; then
  docker push $DOCKER_REGISTRY_URL/onec-client-edt-swarm-agent:$onec_edt_version
fi