#!/bin/bash

#purpose
##################

#maintains BACKUP_RETENTION quantity of system backups
#30 3 * * * source /home/user/.bash_profile; /opt/docker-stacks/blog/system/scripts/exec-system-backup-cleaning.sh 2> /dev/null

#configuration
##################

BACKUP_LOCATION_1=/opt/docker-stacks/blog/system/backups
BACKUP_LOCATION_2=/opt/docker-stacks/bkp-transfer
BACKUP_RETENTION=7

#main
##################

cd ${BACKUP_LOCATION_1}
find ${BACKUP_LOCATION_1}/* -mtime +${BACKUP_RETENTION} -exec rm -rf {} \;

cd ${BACKUP_LOCATION_2}
find ${BACKUP_LOCATION_2}/* -mtime +${BACKUP_RETENTION} -exec rm -rf {} \;
