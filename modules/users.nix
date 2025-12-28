{ lib, accounts, ... }:
{
  users.users = builtins.mapAttrs
    (n: v: {
      description = v.realname;
      isNormalUser = true;
      extraGroups = (if v.trusted then [ "wheel" "dialout" "networkmanager" ] else [ ]);
    })
    accounts;
}
