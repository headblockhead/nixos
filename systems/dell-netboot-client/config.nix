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
    #pam_password md5
    #'';
  };

  security.pam.services.sshd.makeHomeDir = true;

  users.users.root = {
    enable = true;
    password = "root";
  };

  environment.systemPackages = [
  ];

  system.stateVersion = "22.05";
}
