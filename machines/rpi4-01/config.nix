{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 9002 ];
  services.keepalived.vrrpInstances.haproxy_vip = {
    state = "MASTER";
    priority = 200;
  };
}
