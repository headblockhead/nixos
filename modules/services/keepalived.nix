{ pkgs, ... }:
{
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
      # state and priority should be set by each machine's configuration
      virtualRouterId = 51;
      virtualIps = [ { addr = "172.27.30.100/24"; } ];
      trackScripts = [ "check_haproxy" ];
    };
  };
}
