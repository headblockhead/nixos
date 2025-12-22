{ lib, accounts, ... }:
{
  networking.firewall.allowedTCPPorts = [ 22 ];
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
