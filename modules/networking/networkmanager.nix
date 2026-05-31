{ accounts, ... }:
{
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };
  users.users = builtins.mapAttrs (n: v: {
    extraGroups = (if v.superuser then [ "networkmanager" ] else [ ]);
  }) accounts;
}
