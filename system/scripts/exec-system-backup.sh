#!/bin/bash

#purpose
##################

#export all persistant files of the blog stack
#30 2 * * * source /home/user/.bash_profile; /opt/docker-stacks/blog/system/scripts/exec-system-backup.sh 2> /dev/null

#configuration
##################

DATE=$(date +"%d_%b_%y_%H-%M-%S" | tr [a-z] [A-Z])
BACKUP_LOCATION=/opt/docker-stacks/blog/system/backups

BACKUP_DIR_1_SRC=/opt/docker-stacks/blog/deploy
BACKUP_DIR_2_SRC=/opt/docker-stacks/blog/persistance
BACKUP_DIR_1_TARGET_FULL_PATH=${BACKUP_LOCATION}/${DATE}

#main
##################

mkdir ${BACKUP_LOCATION}/${DATE}
cp -r ${BACKUP_DIR_1_SRC} ${BACKUP_DIR_2_SRC} ${BACKUP_DIR_1_TARGET_FULL_PATH}

tar -zcvf /opt/docker-stacks/bkp-transfer/${DATE}-blog-backup.tar.gz -C ${BACKUP_LOCATION} ${DATE}
chmod 770 /opt/docker-stacks/bkp-transfer/${DATE}-blog-backup.tar.gz
chown :transfer /opt/docker-stacks/bkp-transfer/${DATE}-blog-backup.tar.gz
