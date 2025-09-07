{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 9002 ];
  services.keepalived.vrrpInstances.haproxy_vip = {
    state = "BACKUP";
    priority = 100;
  };
}
