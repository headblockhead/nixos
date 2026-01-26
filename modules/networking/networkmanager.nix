{ accounts, ... }:
{
  networking.networkmanager.enable = true;
  users.users = builtins.mapAttrs (n: v: { extraGroups = (if v.superuser then [ "networkmanager" ] else [ ]); }) accounts;
}
