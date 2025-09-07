{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.haproxy = {
    enable = true;
    config = ''
      frontend k3s-frontend
          bind *:6443
          mode tcp
          option tcplog
          default_backend k3s-backend
    
      backend k3s-backend
          mode tcp
          option tcp-check
          balance roundrobin
          default-server inter 10s downinter 5s
          server rpi5-01 172.16.3.51:6443 check
          server rpi5-02 172.16.3.52:6443 check
          server rpi5-03 172.16.3.53:6443 check
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
      virtualIps = [{ addr = "172.16.3.100/24"; }];
      trackScripts = [ "check_haproxy" ];
    };
  };
}
