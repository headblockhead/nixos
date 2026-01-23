{ lib, accounts, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };
  users.users = builtins.mapAttrs
    (n: v: {
      openssh.authorizedKeys.keys = v.sshkeys;
    })
    accounts;
}
