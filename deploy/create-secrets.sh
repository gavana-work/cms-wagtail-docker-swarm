#!/bin/bash

#set docker secrets - app
########################################################################

#-------------------------------------------------------------------
echo -n "3" | docker secret create HTTP_WORKER_THREADS -
#-------------------------------------------------------------------
#set like this - domainname1,domainname2
echo -n "yourdomainname" | docker secret create DJANGO_DOCKER_HOSTS -
#-------------------------------------------------------------------
echo -n "info" | docker secret create DJANGO_LOG_LEVEL -
echo -n "Asia/Qatar" | docker secret create DJANGO_TIMEZONE -
echo -n "8000" | docker secret create DJANGO_PORT -
echo -n "specialkeyhere" | docker secret create DJANGO_SEC_KEY -
#-------------------------------------------------------------------
echo -n "youremailhere@gmail.com" | docker secret create DJANGO_EMAIL_USER -
echo -n "8025" | docker secret create DJANGO_EMAIL_PORT -
echo -n "mail" | docker secret create DJANGO_EMAIL_HOST -
#-------------------------------------------------------------------
echo -n "redis://cache:6379/" | docker secret create DJANGO_CACHE -
echo -n "cache" | docker secret create DJANGO_CACHE_HOST -
echo -n "6379" | docker secret create DJANGO_CACHE_PORT -
#-------------------------------------------------------------------
echo -n "django.db.backends.postgresql_psycopg2" | docker secret create DJANGO_DB_ENGINE -
echo -n "db" | docker secret create DJANGO_DB_HOST -
echo -n "app" | docker secret create DJANGO_DB_USER -
echo -n "apps-R-not4-EATS" | docker secret create DJANGO_DB_PASS -
echo -n "appdb" | docker secret create DJANGO_DB_NAME -
echo -n "5432" | docker secret create DJANGO_DB_PORT -
#-------------------------------------------------------------------

#set docker secrets - db
########################################################################

#-------------------------------------------------------------------
echo -n "root" | docker secret create POSTGRES_USER -
echo -n "r00t5-dont-GROW_here" | docker secret create POSTGRES_PASSWORD -
echo -n "rootdb" | docker secret create POSTGRES_DB -
echo -n "app" | docker secret create APP_USER -
echo -n "apps-R-not4-EATS" | docker secret create APP_USER_PASSWORD -
echo -n "appdb" | docker secret create APP_DB -
#-------------------------------------------------------------------

#set docker secrets - mail
########################################################################

#-------------------------------------------------------------------
echo -n "emailpassword" | docker secret create SMTP_PASSWORD -
#-------------------------------------------------------------------