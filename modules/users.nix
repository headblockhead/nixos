{ accounts, ... }:
{
  users.users = builtins.mapAttrs
    (n: v: {
      description = v.realname;
      isNormalUser = true;
      extraGroups = (if v.rootAccess then [ "wheel" "dialout" "networkmanager" ] else [ ]);
    })
    accounts;
}
