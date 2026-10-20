{ inputs, accounts, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
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
