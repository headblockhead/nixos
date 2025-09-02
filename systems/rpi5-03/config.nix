{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 9002 ];

  nix.gc = {
    automatic = true;
    persistent = false; # don't start garbage collection on boot if the last collection interval was missed.
    dates = "monthly";
    options = "--delete-older-than 30d"; # delete generations older than 30 days.
    randomizedDelaySec = "3d"; # random delay to (most likely) prevent all machines from doing gc at the same time.
  };

  services.glusterfs = {
    enable = true;
    useRpcbind = false;
  };
}
