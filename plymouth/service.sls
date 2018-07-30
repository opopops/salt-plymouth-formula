{%- from "plymouth/map.jinja" import plymouth with context %}

include:
  - plymouth.install

plymouth_quit_service:
  file.managed:
    - name: {{ plymouth.service_quit_file }}
    - source: salt://plymouth/files/plymouth-quit.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - module: plymouth_systemctl_reload

plymouth_quit_wait_service:
  file.managed:
    - name: {{ plymouth.service_quit_wait_file }}
    - source: salt://plymouth/files/plymouth-quit-wait.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - module: plymouth_systemctl_reload

plymouth_systemctl_reload:
  module.wait:
    - service.systemctl_reload: []