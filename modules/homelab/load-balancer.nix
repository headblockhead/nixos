{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [
    6443
    8123
    8981
    8980
  ];
  services.haproxy = {
    enable = true;
    config = ''
      frontend k3s_frontend
          mode tcp
          bind *:6443
          default_backend k3s_backend
    
      backend k3s_backend
          mode tcp
          option tcp-check
          balance roundrobin
          default-server inter 10s downinter 5s
          server rpi5-01 172.27.30.51:6443 check
          server rpi5-02 172.27.30.52:6443 check
          server rpi5-03 172.27.30.53:6443 check

      frontend homeassistant_frontend
          mode tcp
          bind *:8123
          default_backend homeassistant_backend

      backend homeassistant_backend
          mode tcp
          option tcp-check
          balance roundrobin
          default-server inter 10s downinter 5s
          server rpi5-01 172.27.30.51:8123 check
          server rpi5-02 172.27.30.52:8123 check
          server rpi5-03 172.27.30.53:8123 check

      frontend matter_frontend
          mode tcp
          bind *:5580
          default_backend matter_backend

      backend matter_backend
          mode tcp
          option tcp-check
          balance roundrobin
          default-server inter 10s downinter 5s
          server rpi5-01 172.27.30.51:5580 check
          server rpi5-02 172.27.30.52:5580 check
          server rpi5-03 172.27.30.53:5580 check
    '';
  };
  services.keepalived = {
    enable = true;
    vrrpScripts.check_haproxy = {
      script = "${pkgs.writeShellScript "check-haproxy-is-running.sh" ''
        ${pkgs.killall}/bin/killall -0 haproxy
      ''}";
      interval = 2;
    };
    vrrpInstances.haproxy_vip = {
      interface = "end0";
      # state and priority should be set by the host-specific configuration
      virtualRouterId = 51;
      virtualIps = [{ addr = "172.27.30.100/24"; }];
      trackScripts = [ "check_haproxy" ];
    };
  };
}
