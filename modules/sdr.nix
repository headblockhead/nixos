{ pkgs, lib, accounts, ... }:
{
  environment.systemPackages = [
    pkgs.cubicsdr
  ];
  hardware.rtl-sdr.enable = true;

  # Give trusted users access.
  users.users = lib.genAttrs
    (builtins.attrNames (lib.filterAttrs (n: v: v.trusted) accounts))
    (username: { extraGroups = [ "plugdev" ]; });
}
