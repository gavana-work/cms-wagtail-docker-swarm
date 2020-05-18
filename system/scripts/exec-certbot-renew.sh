#!/bin/bash

#purpose
##################

#check for certificate renewals from letsencrypt
#1) stop blog stack
#2) sleep 60s
#3) run renewal check
#4) sleep 60s
#5) start blog stack

#cronjob for weekly renewal checks
#0 4 * * 0 source /home/docker-user/.profile; /opt/docker-stacks/blog/system/scripts/exec-certbot-renew.sh >> /opt/docker-stacks/blog/system/logs/certbot.log 2>&1

#main
##################

#0) 
DATE=$(date +"%d_%b_%y_%H-%M-%S" | tr [a-z] [A-Z])
echo $DATE

#1)
docker stack rm blog

#2)
sleep 60

#3)
#the usual t option is only for tty sessions
docker run -i --rm -p 80:80 --name certbot \
           -v "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/etc:/etc/letsencrypt" \
           -v "/opt/docker-stacks/blog/persistance/shared/security/letsencrypt/lib:/var/lib/letsencrypt" \
           certbot/certbot renew

#4)
sleep 60

#5)
docker stack deploy blog -c /opt/docker-stacks/blog/deploy/docker-compose.yml
