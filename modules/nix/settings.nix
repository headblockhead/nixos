{ lib, accounts, ... }:
{
  nix.settings = {
    connect-timeout = 5;
    trusted-users = builtins.attrNames (lib.filterAttrs (n: v: v.superuser) accounts);
    experimental-features = [ "nix-command" "flakes" ];
    #substituters = [ "https://cache.edwardh.dev" ];
    #trusted-public-keys = [ "cache.edwardh.dev-1:+Gafa747BGilG7GAbTC/1i6HX9NUwzMbdFAc+v5VOPk=" ];
  };
}
