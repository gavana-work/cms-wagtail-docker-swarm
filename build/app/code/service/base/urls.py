from django.conf import settings
from django.conf.urls import include, url
from django.contrib import admin

from wagtail.admin import urls as wagtailadmin_urls
from wagtail.core import urls as wagtail_urls
from wagtail.documents import urls as wagtaildocs_urls

from django.conf.urls import (
handler400, handler403, handler404, handler500
)

handler400 = 'default.views.handler400'
handler403 = 'default.views.handler403'
handler404 = 'default.views.handler404'
handler500 = 'default.views.handler500'

urlpatterns = [
    url(r'^wagmin/', include(wagtailadmin_urls)),
    url(r'^documents/', include(wagtaildocs_urls)),
]
urlpatterns += [ 
    url(r'', include(wagtail_urls)),
]