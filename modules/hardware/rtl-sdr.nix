{ accounts, lib, ... }:
{
  hardware.rtl-sdr.enable = true;

  users.users = lib.genAttrs
    (builtins.attrNames (lib.filterAttrs (n: v: v.rootAccess) accounts))
    (username: { extraGroups = [ "plugdev" ]; });
}
