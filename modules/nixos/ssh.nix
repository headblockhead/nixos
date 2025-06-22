{ lib, usernames, accountFromUsername, ... }:
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
  users.users = lib.genAttrs usernames (username: { openssh.authorizedKeys.keys = (accountFromUsername username).sshkeys; });
}
