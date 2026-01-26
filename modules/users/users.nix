{ accounts, ... }:
{
  users.users = builtins.mapAttrs
    (n: v: {
      description = v.realname;
      isNormalUser = true;
      extraGroups = (if v.superuser then [ "wheel" ] else [ ]);
    })
    accounts;
}
