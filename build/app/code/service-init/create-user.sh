#!/bin/bash

if [ -d "/run/secrets" ]; then
	echo "[INFO] parsing docker secrets"
    for f in $(ls /run/secrets)
	do
	  export "$f"=$(cat /run/secrets/$f)
	done
else 
    echo "[INFO] /run/secrets does not exist, if env vars are not set in docker-compose the container will fail"
fi

cd ../service
python manage.py createsuperuser