{ outputs, ... }:
{
  networking.hostName = "rpi4-02";

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

  networking.firewall.allowedTCPPorts = [ 9002 ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      options = [ "fmask=0137" "dmask=0027" ];
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };

  environment.systemPackages = [
  ];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "23.05";
}
