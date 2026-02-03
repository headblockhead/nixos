{ pkgs, ... }:
{
  # Do not sleep on lid close when docked/plugged in.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  environment.systemPackages = [
    pkgs.ardour
    pkgs.x32edit
  ];
}
