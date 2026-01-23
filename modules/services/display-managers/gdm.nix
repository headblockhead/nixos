{ accounts, ... }:
{
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  # TODO: don't assume Gnome is the desktop manager
  systemd.tmpfiles.rules =
    builtins.attrValues (builtins.mapAttrs (n: v: "f+ /var/lib/AccountsService/users/${n} 0600 root root - [User]\\nSession=gnome\\nIcon=/var/lib/AccountsService/icons/${n}\\nSystemAccount=false\\n") accounts)
    ++ builtins.attrValues (builtins.mapAttrs (n: v: "L+ /var/lib/AccountsService/icons/${n} - - - - ${v.profileIcon}") accounts);
}
