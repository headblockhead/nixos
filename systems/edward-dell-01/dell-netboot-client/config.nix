{ pkgs, lib, ... }:
{
  networking = {
    useDHCP = lib.mkDefault false;
    interfaces = {
      enp2s0 = {
        ipv4.addresses = [{ address = "192.168.42.35"; prefixLength = 26; }];
      };
    };
  };

  users.ldap = {
    enable = true;
    base = "dc=BRIDGE,dc=ENTERPRISE";
    server = "ldap://192.168.42.195:389";
    loginPam = true;
    extraConfig = ''
      ldap_version 3
      pam_password md5
    '';
  };
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.settings.KbdInteractiveAuthentication = lib.mkForce true;
  security.pam.services.sshd.makeHomeDir = true;
  # evil, horrifying hack
  systemd.tmpfiles.rules = [
    "L /bin/bash - - - - /run/current-system/sw/bin/bash"
  ];

  security.sudo.wheelNeedsPassword = false;

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      workstation = true;
    };
  };

  programs.ssh = {
    # Redirect SSH connections to GitHub to port 443, to get around firewall.
    extraConfig = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
    '';
  };

  environment.systemPackages = with pkgs; [
    openldap
  ];
}
