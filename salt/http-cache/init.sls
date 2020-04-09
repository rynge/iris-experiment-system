
docker-ce:
  pkg:
    - installed
  service.running:
    - name: docker
    - enable: True

iris-http-proxy.systemd-unit:
  file.managed:
    - name: /etc/systemd/system/iris-http-proxy.service
    - source: salt://http-cache/iris-http-proxy.service

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: iris-http-proxy.systemd-unit

iris-http-proxy:
  service.running:
    - name: iris-http-proxy
    - reload: True
    - watch:
      - module: iris-http-proxy.systemd-unit

