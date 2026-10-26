{ ... }:
{
  services.haproxy = {
    enable = true;
    config = ''
      frontend prometheus-frontend
          bind *:9090
          mode tcp
          option tcplog
          default_backend prometheus-backend

      backend prometheus-backend
          mode tcp
          option tcp-check
          balance roundrobin
          default-server inter 10s downinter 5s
          server rpi5-alpha 172.27.30.51:9090 check
          server rpi5-bravo 172.27.30.52:9090 check
          server rpi5-charlie 172.27.30.53:9090 check
    '';
  };
}
