{ outputs, lib, ... }:

{
  networking.hostName = "dell-netboot-client";

  imports = with outputs.nixosModules; [
    basicConfig
    fzf
    git
    gpg
    network
    sound
    ssd
    users
    ssh
    zsh
  ];

  boot.loader.timeout = lib.mkForce 5;
  users.ldap = {
    enable = true;
    timeLimit = 15;
    server = "ldap://192.168.42.195";
    base = "DC=BRIDGE,DC=ENTERPRISE";
    loginPam = true;
    nsswitch = true;
    bind.policy = "soft";

    #extraConfig = ''
    #ldap_version 3
    #pam_passord md5
    #'';
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      workstation = true;
    };
  };

  security.pam.services.sshd.makeHomeDir = true;

  programs.ssh = {
    # Redirect SSH connections to GitHub to port 443, to get around firewall.
    extraConfig = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
    '';
  };
  environment.systemPackages = [
  ];

  system.stateVersion = "22.05";
}
