{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 9002 ];

  services.glusterfs = {
    enable = true;
    useRpcbind = false;
  };
}
