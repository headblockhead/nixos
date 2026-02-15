{ accounts, ... }:
{
  security.sudo.wheelNeedsPassword = false;
  users.users = (builtins.mapAttrs (n: v: { hashedPassword = "!"; }) accounts) // { root.hashedPassword = "!"; };
}
