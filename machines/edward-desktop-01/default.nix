{ inputs, overlays, nixosModules, hostname, accounts, ... }:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
    accounts = inputs.nixpkgs.lib.filterAttrs (username: account: builtins.elem username [ "headb" ]) accounts;
  };
  modules = with nixosModules; [
    ({ lib, ... }: {
      system.stateVersion = "22.05";
      networking.hostName = hostname;
      nixpkgs = {
        overlays = builtins.attrValues overlays;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          "slack"
          "spotify"
          "clonehero"
          "code"
          "vscode"
          "steam"
          "steam-unwrapped"
        ];
      };
    })

    ./config.nix
    ./hardware.nix

    boot.loader.systemd-boot
    boot.loader.timeout0
    boot.plymouth
    conf.development
    conf.en-gb
    conf.graphical-ios
    conf.graphical-multimedia
    conf.graphical-productivity
    conf.graphical-social
    conf.graphical-web
    conf.utility
    fileSystems
    fonts.favourites
    networking.networkmanager
    nix.buildMachines
    nix.gc
    nix.registry
    nix.settings
    programs.fzf
    programs.git
    programs.gnupg
    programs.zsh
    security.rtkit
    services.desktop-managers.gnome
    services.display-managers.gdm
    services.openssh
    services.pipewire
    users.users
  ];
}
