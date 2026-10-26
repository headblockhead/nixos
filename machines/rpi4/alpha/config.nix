{
  networking.firewall.allowedTCPPorts = [ 9090 ];
  services.keepalived.vrrpInstances.haproxy_vip = {
    state = "MASTER";
    priority = 200;
  };
}
