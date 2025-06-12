{ outputs, ... }:
{
  networking.hostName = "rpi4-01";

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

  networking.firewall.allowedTCPPorts = [ 8123 9002 ];

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

  hardware.bluetooth.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [
        "home-assistant:/config"
        "/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = "Europe/London";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      extraOptions = [
        "--network=host"
      ];
    };
  };

  environment.systemPackages = [
  ];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "23.05";
}
