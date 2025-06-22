{ pkgs, lib, usernames, accountFromUsername, ... }:
let
  trustedUsernames = builtins.filter (username: (accountFromUsername username).trusted) usernames;
in
{
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  users.users = lib.genAttrs trustedUsernames (username: { extraGroups = [ "i2c" ]; });
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [
    openrgb-with-all-plugins
  ];

  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.motherboard = "amd";
}
