{ pkgs, lib, usernames, accountFromUsername, ... }:
let
  trustedUsernames = builtins.filter (username: (accountFromUsername username).trusted) usernames;
in
{
  environment.systemPackages = [
    pkgs.cubicsdr
  ];
  hardware.rtl-sdr.enable = true;
  users.users = lib.genAttrs trustedUsernames (username: { extraGroups = [ "plugdev" ]; });
}
