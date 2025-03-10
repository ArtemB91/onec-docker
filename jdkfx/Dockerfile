ARG DOCKER_REGISTRY_URL=library
ARG BASE_IMAGE=ubuntu
ARG BASE_TAG=20.04

FROM ${DOCKER_REGISTRY_URL}/${BASE_IMAGE}:${BASE_TAG}

ARG JDK_VERSION=17

# Download and install dependencies and Azul Zulu JDK FX
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    wget \
    locales \
    apt-transport-https \
    ca-certificates \
    && if [ "$JDK_VERSION" = "17" ]; then \
         wget https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-fx-jdk17.0.14-linux_amd64.deb -O /tmp/zulu.deb; \
       elif [ "$JDK_VERSION" = "11" ]; then \
         wget https://cdn.azul.com/zulu/bin/zulu11.78.15-ca-fx-jdk11.0.26-linux_amd64.deb -O /tmp/zulu.deb; \
       else \
         echo "Unsupported JDK version: $JDK_VERSION" && exit 1; \
       fi \
    && apt-get install -y /tmp/zulu.deb \
    && rm /tmp/zulu.deb \
    && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8 \
    && rm -rf /var/lib/apt/lists/* 

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/zulu-fx-${JDK_VERSION}-amd64

# Verify installation
RUN java -version