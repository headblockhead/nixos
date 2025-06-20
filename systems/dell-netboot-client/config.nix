{ pkgs, ... }:

{
  networking.hostName = "dell-netboot-client";

  users.ldap = {
    enable = true;
    server = "ldap://192.168.42.195:389";
    base = "dc=BRIDGE,dc=ENTERPRISE";
    loginPam = true;
  };

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

  system.stateVersion = "25.05";
}
