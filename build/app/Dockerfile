#set the source image
###################################################
FROM app-base:latest
LABEL maintainer="gavin"

#set vars, build time
###################################################
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=app
ARG APP_GROUP=app
ARG APP_ROOT=/app
ARG CODE=code

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
COPY "$CODE"/ "$APP_ROOT"/

#add other directories and modify permissions
###################################################
#note /media --> this already exists by default in linux distros
RUN mkdir /static && \
    chown -R "$APP_USER":"$APP_GROUP" "$APP_ROOT" && \
    chown -R "$APP_USER":"$APP_GROUP" /static && \
    chown -R "$APP_USER":"$APP_GROUP" /media && \
    chmod +x "$APP_ROOT"/service-init/run.sh && \
    chmod +x "$APP_ROOT"/service-init/create-user.sh

#set image defaults
###################################################
EXPOSE 8000
USER "$APP_USER"
WORKDIR "$APP_ROOT"
CMD ["/bin/bash", "-l", "/app/service-init/run.sh"]

#set docker healthcheck
###################################################
HEALTHCHECK NONE