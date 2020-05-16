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

sed -i 's^@@APP_USER@@^'$APP_USER'^g' /docker-entrypoint-initdb.d/init-b-app.sql
sed -i 's^@@APP_USER_PASSWORD@@^'$APP_USER_PASSWORD'^g' /docker-entrypoint-initdb.d/init-b-app.sql
sed -i 's^@@APP_DB@@^'$APP_DB'^g' /docker-entrypoint-initdb.d/init-b-app.sql