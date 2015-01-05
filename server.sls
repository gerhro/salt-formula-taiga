{%- from "taiga/map.jinja" import server with context %}
{%- if server.enabled %}

include:
- git

taiga_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/srv/taiga:
  virtualenv.manage:
  - system_site_packages: false
  - python: /usr/bin/python3.4
  - requirements: salt://taiga/files/requirements.txt
  - require:
    - pkg: taiga_packages
    - pkg: git_packages

taiga_backend_repo:
  git.latest:
  - name: {{ server.backend_source.address }}
  - target: /srv/taiga/taiga-back
  - rev: {{ server.backend_source.revision }}
  - require:
    - virtualenv: /srv/taiga

taiga_frontend_repo:
  git.latest:
  - name: {{ server.frontend_source.address }}
  - target: /srv/taiga/taiga-front
  - rev: {{ server.frontend_source.revision }}
  - require:
    - virtualenv: /srv/taiga

/srv/taiga/site/server.wsgi:
  file.managed:
  - source: salt://taiga/conf/server.wsgi
  - mode: 755
  - template: jinja
  - require:
    - file: /srv/taiga/site

/srv/taiga/conf:
  file.directory:
  - mode: 755
  - makedirs: true
  - require:
    - virtualenv: /srv/taiga

/srv/taiga/logs:
  file:
  - directory
  - user: www-data
  - group: www-data
  - mode: 755
  - makedirs: true
  - require:
    - virtualenv: /srv/taiga

/srv/taiga/taiga-back/settings/local.py:
  file.managed:
  - source: salt://taiga/files/settings.py
  - template: jinja
  - mode: 644
  - require:
    - git: taiga_backend_repo

/srv/taiga/conf/circus.ini:
  file.managed:
  - source: salt://taiga/files/circus.ini
  - template: jinja
  - mode: 644
  - require:
    - file: /srv/taiga/conf

setup_taiga_database:
  cmd.run:
  - names:
    - source ../bin/activate; python manage.py migrate --noinput
    - source ../bin/activate; python manage.py collectstatic --noinput
  - cwd: /srv/taiga/taiga-back

init_taiga_database:
  cmd.run:
  - names:
    - source ../bin/activate; python manage.py loaddata initial_user
    - source ../bin/activate; python manage.py loaddata initial_project_templates
    - source ../bin/activate; python manage.py loaddata initial_role
    - source ../bin/activate; python manage.py sample_data
  - cwd: /srv/taiga/taiga-back
  - require:
    - cmd: setup_taiga_database

{%- endif %}
