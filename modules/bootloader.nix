{ lib, ... }:
{
  boot = {
    consoleLogLevel = lib.mkDefault 6; # info
    initrd = {
      verbose = lib.mkDefault true;
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        editor = false;
      };
    };
  };
}
