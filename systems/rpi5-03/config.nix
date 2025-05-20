{ outputs, ... }:
{
  networking.hostName = "rpi5-03";

  imports = with outputs.nixosModules; [
    basicConfig
    distributedBuilds
    git
    headless
    monitoring
    ssh
    users
    zsh
  ];

  services.glusterfs = {
    enable = true;
    useRpcbind = false;
  };

  networking.firewall.allowedTCPPorts = [ 9002 ];

  environment.systemPackages = [
  ];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "23.05";
}
