#!/bin/bash

#set vars, run.sh
########################################################################

APP_DIR=/app
DATETIME=$(date +%m-%d-%Y_%H-%M-%S)
LOGS_DIR=/etc/nginx/logs
CONF_FILE=/etc/nginx/nginx.conf

#wait for docker's DNS to be stable
########################################################################

echo "[INFO] waiting five seconds for docker dns to stabilize"
sleep 5

#clear previous logs or keep them
########################################################################

if [[ "$LOG_RETENTION" == "false" ]]
then
   rm -rf $LOGS_DIR/*
   echo "[INFO] cleared previous log files"
fi

if [[ "$LOG_RETENTION" == "true" ]]
then
   mkdir $LOGS_DIR/$DATETIME
   cp $LOGS_DIR/*.log $LOGS_DIR/$DATETIME
   echo "[INFO] saved previous log files"
fi

#start nginx
########################################################################
nginx -c $CONF_FILE -g 'daemon off;'