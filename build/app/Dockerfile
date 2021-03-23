#set vars, global build time
###################################################
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=app
ARG APP_GROUP=app
ARG APP_ROOT=/app
ARG CODE=code




#########################
#builder phase
#########################

#set the source image
###################################################
FROM python:3.8-slim AS builder
LABEL maintainer="gavin"

#set used global variables
###################################################
ARG APP_UID
ARG APP_GID
ARG APP_USER
ARG APP_GROUP
ARG APP_ROOT
ARG CODE

#run as root for setup
###################################################
USER root

#copy code
###################################################
RUN mkdir "$APP_ROOT" && mkdir "$APP_ROOT"/wheel-builder
COPY "$CODE"/ "$APP_ROOT"/

#app dependencies
###################################################
RUN apt-get update

RUN set -ex \
    && BUILD_DEPS=" \
        gcc \
        python3-dev \
        libpq-dev \
        libmagickwand-dev \
    " \
    && apt-get install -y --no-install-recommends $BUILD_DEPS

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS && \
    rm -rf /var/lib/apt/lists/*

#python packages - build wheel
###################################################
RUN pip install --upgrade pip && \
    pip wheel --no-cache-dir --no-deps --wheel-dir "$APP_ROOT"/wheel-builder -r "$APP_ROOT"/service-req/requirements.txt




#########################
#final phase
#########################

#set the source image
###################################################
FROM python:3.8-slim
LABEL maintainer="gavin"

#set used global variables
###################################################
ARG APP_UID
ARG APP_GID
ARG APP_USER
ARG APP_GROUP
ARG APP_ROOT
ARG CODE

#run as root for setup
###################################################
USER root

#add app user/group
###################################################
RUN groupadd -g "$APP_GID" "$APP_GROUP" && \
    useradd -u "$APP_UID" -g "$APP_GROUP" "$APP_USER" && \
    mkdir /home/"$APP_USER" && \
    chown -R "$APP_USER":"$APP_GROUP" /home/"$APP_USER"

#copy code
###################################################
RUN mkdir "$APP_ROOT" && \
	mkdir "$APP_ROOT"/wheel
COPY "$CODE"/ "$APP_ROOT"/
COPY --from=builder "$APP_ROOT"/wheel-builder/ "$APP_ROOT"/wheel/

#add other directories and modify permissions
###################################################
#note /media --> this already exists by default in linux distros
RUN mkdir /static && \
    chown -R "$APP_USER":"$APP_GROUP" "$APP_ROOT" && \
    chown -R "$APP_USER":"$APP_GROUP" /static && \
    chown -R "$APP_USER":"$APP_GROUP" /media && \
    chmod +x "$APP_ROOT"/service-init/run.sh && \
    chmod +x "$APP_ROOT"/service-init/create-user.sh

#python packages - use the pre-built wheel
###################################################
RUN pip install --upgrade pip && \
	pip install --no-cache "$APP_ROOT"/wheel/* && \
	rm -rf "$APP_ROOT"/wheel

#app dependencies
###################################################
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
        libmagickwand-dev \
    " \
    && apt-get install -y --no-install-recommends $BUILD_DEPS

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS && \
    rm -rf /var/lib/apt/lists/*

#set image defaults
###################################################
EXPOSE 8000
USER "$APP_USER"
WORKDIR "$APP_ROOT"
CMD ["/bin/bash", "-l", "/app/service-init/run.sh"]

#set docker healthcheck
###################################################
HEALTHCHECK NONE