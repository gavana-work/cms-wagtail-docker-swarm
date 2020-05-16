#!/bin/bash

#purpose
##################

#obtain the initial server certificate from letsencrypt

#configuration
##################

DOMAIN_NAME_1=domain.ext
DOMAIN_NAME_2=www.domain.ext

#main
##################

docker run -it --rm -p 80:80 --name certbot \
           -v "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/etc:/etc/letsencrypt" \
           -v "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/lib:/var/lib/letsencrypt" \
           certbot/certbot certonly --standalone --preferred-challenges http-01 --agree-tos -d ${DOMAIN_NAME_1} -d ${DOMAIN_NAME_2}
