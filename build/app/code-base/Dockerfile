#set the source image
#########################
FROM python:3.8-slim
LABEL maintainer="gavin"

#set vars, build time
#########################
ARG APP_ROOT=/app
ARG CODE=code

#copy code
#########################
RUN mkdir "$APP_ROOT"
COPY "$CODE"/ "$APP_ROOT"/

#base dependencies
#########################
RUN apt-get update && \
    pip install --upgrade pip

#app dependencies
#########################
RUN set -ex \
    && RUN_DEPS=" \
        libexpat1 \
        libjpeg62-turbo \
        libpcre3 \
        libpq5 \
        mime-support \
        procps \
        zlib1g \
    " \
    && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
    && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS

RUN set -ex \
    && BUILD_DEPS=" \
        build-essential \
        libexpat1-dev \
        libjpeg62-turbo-dev \
        libpcre3-dev \
        libpq-dev \
        zlib1g-dev \
        gcc \
        python3-dev \
        libpq-dev \
        netcat-openbsd \
        iputils-ping \
    " \
    && apt-get install -y --no-install-recommends $BUILD_DEPS

RUN pip install --no-cache-dir -r "$APP_ROOT"/service-req/requirements.txt && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS && \
    rm -rf /var/lib/apt/lists/*