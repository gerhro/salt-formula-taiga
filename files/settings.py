{%- from "taiga/map.jinja" import server with context %}
{%- from "linux/map.jinja" import system with context %}

from .common import *

DEBUG = {% if system.environment in ['stg', 'dev'] %}True{%- else %}False{%- endif %}
TEMPLATE_DEBUG = DEBUG

PUBLIC_REGISTER_ENABLED = False

MEDIA_URL = "{{ server.server_protocol }}://{{ server.server_name }}/media/"
STATIC_URL = "{{ server.server_protocol }}://{{ server.server_name }}/static/"
ADMIN_MEDIA_PREFIX = "static/admin/"

SITES["front"]["domain"] = "{{ server.server_name }}"
SITES["front"]["scheme"] = "{{ server.server_protocol }}"

DEFAULT_FROM_EMAIL = "{{ server.mail_from }}"
SERVER_EMAIL = DEFAULT_FROM_EMAIL

EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
{%- if server.mail.get('encryption', 'none') == 'tls' %}
EMAIL_USE_TLS = True
EMAIL_USE_SSL = False
{%- endif %}
{%- if server.mail.get('encryption', 'none') == 'ssl' %}
EMAIL_USE_TLS = False
EMAIL_USE_SSL = True
{%- endif %}
EMAIL_HOST = "{{ server.mail.get('host', 'localhost') }}"
EMAIL_HOST_USER = "{{ server.mail.user }}"
EMAIL_HOST_PASSWORD = "{{ server.mail.password }}"
EMAIL_PORT = {{ server.mail.get('port', '25') }}

REST_FRAMEWORK["DEFAULT_RENDERER_CLASSES"] = (
    "rest_framework.renderers.JSONRenderer",
)

DATABASES = {
    'default': {
        {%- if server.database.engine == 'mysql' %}
        'ENGINE': 'django.db.backends.mysql',
        'PORT': '3306',
        'OPTIONS': { 'init_command': 'SET storage_engine=INNODB,character_set_connection=utf8,collation_connection=utf8_unicode_ci', },
        {% else %}
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'PORT': '5432',
        {%- endif %}
        'HOST': '{{ server.database.host }}',
        'NAME': '{{ server.database.name }}',
        'PASSWORD': '{{ server.database.password }}',
        'USER': '{{ server.database.user }}'
    }
}
