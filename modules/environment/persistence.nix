{ inputs, accounts, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  environment.etc = {
    "ssh/ssh_host_rsa_key".source = "/persist/etc/ssh/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "/persist/etc/ssh/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "/persist/etc/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "/persist/etc/ssh/ssh_host_ed25519_key.pub";
  };
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    allowTrash = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
    users = builtins.mapAttrs (n: v: {
      directories = [
        "Documents"
        "Projects"
        "Downloads"
        "Pictures"
        "Music"
        "Videos"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
      ];
      files = [
        ".zsh_history"
      ];
    }) accounts;
  };
}
