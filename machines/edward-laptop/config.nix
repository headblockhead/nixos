{ pkgs, ... }:
{
  services.openssh.openFirewall = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  services.flatpak.enable = true;

  # Do not sleep on lid close when docked/plugged in.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  environment.systemPackages = [
    pkgs.ardour
    pkgs.x32edit
    pkgs.obsidian
  ];

  networking.hosts = {
    "crosscountrywifi.co.uk" = [ "192.168.200.1" ];
  };
}
