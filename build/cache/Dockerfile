#set the source image
###################################################
FROM redis:5.0.8
LABEL maintainer="gavin"

#set vars, build time
###################################################
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=redis
ARG APP_GROUP=redis

#run as root for setup
###################################################
USER root

#modify user/group of existing user
###################################################
RUN usermod -u "$APP_UID" "$APP_USER" && \   
    groupmod -g "$APP_GID" "$APP_GROUP"

#set image defaults
###################################################
USER "$APP_USER"

#set docker healthcheck
###################################################
HEALTHCHECK NONE