{%- from "plymouth/map.jinja" import plymouth with context %}

include:
  - plymouth.install

plymouth_initramfs_modules_file:
  file.managed:
    - name: {{ plymouth.initramfs_modules_file }}
    - replace: False
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

plymouth_initramfs_gpu_module:
  file.append:
    - name: {{ plymouth.initramfs_modules_file }}
    {%- if salt['grains.get']('gpus:vendor')|lower == 'intel' %}
    - source: salt://plymouth/files/intel_gpu_module
    {%- elif salt['grains.get']('gpus:vendor')|lower == 'nvidia' %}
    - source: salt://plymouth/files/nvidia_gpu_module
    {%- elif salt['grains.get']('gpus:vendor')|lower == 'ati' %}
    - source: salt://plymouth/files/ati_gpu_module
    {%- endif %}
    - require:
      - file: plymouth_initramfs_modules_file

plymouth_initramfs_framebuffer:
  file.managed:
    - name: {{ plymouth.splash_conf_file }}
    - user: root
    - group: root
    - mode: 644
    - contents:
      - FRAMEBUFFER=y
    - require:
      - file: plymouth_initramfs_gpu_module

plymouth_config:
  ini.options_present:
    - name: {{plymouth.conf_file}}
    - sections: {{ plymouth.config }}
    - require:
      - pkg: plymouth_packages

{%- for theme, params in plymouth.themes.items() %}
plymouth_{{theme}}_theme:
  archive.extracted:
    - name: {{ plymouth.themes_dir }}/{{theme}}
    - source: {{ params.source }}
    {%- if params.get('source_hash', False) %}
    - source_hash: {{ params.source_hash }}
    {%- endif %}
    - user: {{plymouth.user}}
    - group: {{plymouth.group}}
    - enforce_toplevel: False 
    - options: --strip-components=1 
    - force: True
    - trim_output: True
    - require_in:
      - cmd: plymouth_default_theme
{%- endfor %}

plymouth_default_theme:
  cmd.run:
    - name: plymouth-set-default-theme -R {{plymouth.default_theme}}
    - require:
      - file: plymouth_initramfs_gpu_module
      - file: plymouth_initramfs_framebuffer
