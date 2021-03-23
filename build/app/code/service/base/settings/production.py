#init
######################
import os
import string
from .base import *

#set basics
######################
DEBUG = False
SECRET_KEY = os.environ["DJANGO_SEC_KEY"]
TIME_ZONE = os.environ["DJANGO_TIMEZONE"]
BASE_URL = 'https://localhost:' + os.environ["DJANGO_PORT"]

#security
######################
ALLOWED_HOSTS = os.environ["DJANGO_DOCKER_HOSTS"].split(',')
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

#database
######################
DATABASES = {
    'default': {
        'ENGINE': os.environ["DJANGO_DB_ENGINE"],
        'NAME': os.environ["DJANGO_DB_NAME"],
        'USER': os.environ["DJANGO_DB_USER"],
        'PASSWORD': os.environ["DJANGO_DB_PASS"],
        'HOST': os.environ["DJANGO_DB_HOST"],
        'PORT': os.environ["DJANGO_DB_PORT"],
    }
}

#cache
######################
INSTALLED_APPS += (
    'wagtail.contrib.frontend_cache',
)
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': os.environ["DJANGO_CACHE"],
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'IGNORE_EXCEPTIONS': True,
        }
    }
}

#emailing
######################
EMAIL_USER = os.environ["DJANGO_EMAIL_USER"]
EMAIL_HOST = os.environ["DJANGO_EMAIL_HOST"]
EMAIL_PORT = os.environ["DJANGO_EMAIL_PORT"]
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

#file-serving
######################
#serving files via nginx - the following urls and directories are shared config for nginx.conf
STATICFILES_FINDERS = [
     'django.contrib.staticfiles.finders.FileSystemFinder',
     'django.contrib.staticfiles.finders.AppDirectoriesFinder',
]
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'
STATIC_ROOT = '/static'
STATIC_URL = '/static/'
MEDIA_ROOT = '/media'
MEDIA_URL = '/media/'
STATICFILES_DIRS = (
    os.path.join(PROJECT_DIR, 'static'),
)

#search
######################
WAGTAILSEARCH_BACKENDS = {
    'default': {
        'BACKEND': 'wagtail.contrib.postgres_search.backend',
    },
}

#logging-config
######################
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': os.environ["DJANGO_LOG_LEVEL"].upper(),
        },
    },
}