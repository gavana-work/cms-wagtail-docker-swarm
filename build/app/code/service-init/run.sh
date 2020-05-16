#!/bin/bash

#set vars, run.sh
########################################################################

DATETIME=$(date +%m-%d-%Y_%H-%M-%S)

APP_DIR=/app/service
BASE_NAME=base

SSL_CERT=/app/security/app.crt
SSL_KEY=/app/security/app.key

DJANGO_SETTINGS_MODULE=$BASE_NAME.settings.production
UWSGI_WSGI_FILE=$BASE_NAME/wsgi.py

BASE_HTML_FILE=$APP_DIR/$BASE_NAME/templates/base.html
BASE_DEFAULT_HTML_FILE=$APP_DIR/$BASE_NAME/templates/base-default.html

#wait for docker's DNS to be stable
########################################################################

echo "[INFO] waiting five seconds for docker dns to stabilize"
sleep 5

#set variables
########################################################################

if [ -d "/run/secrets" ]; then
	echo "[INFO] parsing docker secrets"
    for f in $(ls /run/secrets)
	do
	  export "$f"=$(cat /run/secrets/$f)
	done
else 
    echo "[INFO] /run/secrets does not exist, if env vars are not set in docker-compose the container will fail"
fi

export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1

export DJANGO_SETTINGS_MODULE
export UWSGI_WSGI_FILE

sed -i.bak 's^SITE_TITLE^'"$SITE_TITLE"'^' $BASE_HTML_FILE
sed -i.bak 's^SITE_FOOTER^'"$SITE_FOOTER"'^' $BASE_HTML_FILE
sed -i.bak 's^A_SITE_NAV_SLUG^'"$A_SITE_NAV_SLUG"'^' $BASE_HTML_FILE
sed -i.bak 's^A_SITE_NAV_TITLE^'"$A_SITE_NAV_TITLE"'^' $BASE_HTML_FILE
sed -i.bak 's^B_SITE_NAV_SLUG^'"$B_SITE_NAV_SLUG"'^' $BASE_HTML_FILE
sed -i.bak 's^B_SITE_NAV_TITLE^'"$B_SITE_NAV_TITLE"'^' $BASE_HTML_FILE
sed -i.bak 's^C_SITE_NAV_SLUG^'"$C_SITE_NAV_SLUG"'^' $BASE_HTML_FILE
sed -i.bak 's^C_SITE_NAV_TITLE^'"$C_SITE_NAV_TITLE"'^' $BASE_HTML_FILE
sed -i.bak 's^D_SITE_NAV_SLUG^'"$D_SITE_NAV_SLUG"'^' $BASE_HTML_FILE
sed -i.bak 's^D_SITE_NAV_TITLE^'"$D_SITE_NAV_TITLE"'^' $BASE_HTML_FILE
sed -i.bak 's^E_SITE_NAV_SLUG^'"$E_SITE_NAV_SLUG"'^' $BASE_HTML_FILE
sed -i.bak 's^E_SITE_NAV_TITLE^'"$E_SITE_NAV_TITLE"'^' $BASE_HTML_FILE
sed -i.bak 's^LINK_GITHUB^'"$LINK_GITHUB"'^' $BASE_HTML_FILE
sed -i.bak 's^LINK_TELEGRAM^'"$LINK_TELEGRAM"'^' $BASE_HTML_FILE
sed -i.bak 's^LINK_YOUTUBE^'"$LINK_YOUTUBE"'^' $BASE_HTML_FILE

sed -i.bak 's^SITE_TITLE^'"$SITE_TITLE"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^SITE_FOOTER^'"$SITE_FOOTER"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^A_SITE_NAV_SLUG^'"$A_SITE_NAV_SLUG"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^A_SITE_NAV_TITLE^'"$A_SITE_NAV_TITLE"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^B_SITE_NAV_SLUG^'"$B_SITE_NAV_SLUG"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^B_SITE_NAV_TITLE^'"$B_SITE_NAV_TITLE"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^C_SITE_NAV_SLUG^'"$C_SITE_NAV_SLUG"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^C_SITE_NAV_TITLE^'"$C_SITE_NAV_TITLE"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^D_SITE_NAV_SLUG^'"$D_SITE_NAV_SLUG"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^D_SITE_NAV_TITLE^'"$D_SITE_NAV_TITLE"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^E_SITE_NAV_SLUG^'"$E_SITE_NAV_SLUG"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^E_SITE_NAV_TITLE^'"$E_SITE_NAV_TITLE"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^LINK_GITHUB^'"$LINK_GITHUB"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^LINK_TELEGRAM^'"$LINK_TELEGRAM"'^' $BASE_DEFAULT_HTML_FILE
sed -i.bak 's^LINK_YOUTUBE^'"$LINK_YOUTUBE"'^' $BASE_HTML_FILE

echo "[INFO] environment set"

#wait for the db
########################################################################

while ! nc -z ${DJANGO_DB_HOST} ${DJANGO_DB_PORT}; do 
  echo "[INFO] db is offline - sleep 10ms"
  sleep 0.1
done
echo "[INFO] db is online"

#wait for the cache
########################################################################

while ! nc -z ${DJANGO_CACHE_HOST} ${DJANGO_CACHE_PORT}; do 
  echo "[INFO] cache is offline - sleep 10ms"
  sleep 0.1
done
echo "[INFO] cache is online"

#wait for the mail
########################################################################

while ! nc -z ${DJANGO_EMAIL_HOST} ${DJANGO_EMAIL_PORT}; do 
  echo "[INFO] mail is offline - sleep 10ms"
  sleep 0.1
done
echo "[INFO] mail is online"

#prepare the webserver
########################################################################

cd ${APP_DIR}

python manage.py collectstatic --no-input --clear
echo "[INFO] intialized django static files"

python manage.py makemigrations
python manage.py migrate
echo "[INFO] intialized django migrations"

#start the web server with multiple http request threads
########################################################################

cd ${APP_DIR}
echo "[INFO] starting web server"

NGINX_IP=$(ping -c 1 fe | sed -n '2 p' | cut -d' ' -f5 | tr --delete "(" | tr --delete ")" | tr --delete ":")
exec gunicorn \
--bind 0.0.0.0:${DJANGO_PORT} \
--workers ${HTTP_WORKER_THREADS} \
--certfile ${SSL_CERT} \
--keyfile ${SSL_KEY} \
--forwarded-allow-ips "${NGINX_IP}" \
${BASE_NAME}.wsgi:application
