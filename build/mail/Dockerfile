#set the source image
###################################################
FROM alpine:3.10
LABEL maintainer="gavin"

#set vars, build time
###################################################
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=exim
ARG APP_GROUP=exim
ARG CODE=code

#run as root for setup
###################################################
USER root

#copy in script and conf files
###################################################
COPY "$CODE"/exim.conf /etc/exim/exim.conf

#app dependencies
###################################################
RUN apk --no-cache add exim shadow && \
    mkdir /var/spool/exim && \
    chmod 777 /var/spool/exim && \
    ln -sf /dev/stdout /var/log/exim/mainlog && \
    ln -sf /dev/stderr /var/log/exim/panic && \
    ln -sf /dev/stderr /var/log/exim/reject && \
    chmod 0755 /usr/sbin/exim

#modify user/group of existing user
###################################################
RUN usermod -u "$APP_UID" "$APP_USER" && \
    groupmod -g "$APP_GID" "$APP_GROUP"

#set image defaults
###################################################
EXPOSE 8025
USER "$APP_USER"
CMD ["exim", "-bdf", "-q15m"]
ENV LOCAL_DOMAINS=@

#set docker healthcheck
###################################################
HEALTHCHECK NONE