#set the source image
######################
FROM postgres:12.0
LABEL maintainer="gavin"

#set vars, build time
######################
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=postgres
ARG APP_GROUP=postgres
ARG CODE=code
ARG INIT_DIR=/docker-entrypoint-initdb.d

#run as root for setup
###########################################
USER root

#add app user/group and permissions
###########################################
RUN usermod -u "$APP_UID" "$APP_USER" && \  
    groupmod -g "$APP_GID" "$APP_GROUP"

#copy scripts
###########################################
COPY "$CODE"/ "$INIT_DIR"/

#for sed to work on the INIT_DIR the APP_USER needs permission to create a temp file there
###########################################
RUN chown -R "$APP_USER":"$APP_GROUP" "$INIT_DIR"

#set defaults for the image
###########################################
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]