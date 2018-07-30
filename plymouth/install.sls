{%- from "plymouth/map.jinja" import plymouth with context %}

{%- if plymouth.manage_firmwares %}
plymouth_firmwares_packages:
  pkg.installed:
    - pkgs: {{ plymouth.firmwares_pkgs }}
    - require_in:
      - pkg: plymouth_packages
{%- endif %}

plymouth_packages:
  pkg.installed:
    - pkgs: {{ plymouth.pkgs }}