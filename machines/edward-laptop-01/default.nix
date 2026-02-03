{ inputs, overlays, nixosModules, hostname, accounts, ... }:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
    accounts = inputs.nixpkgs.lib.filterAttrs (username: account: builtins.elem username [ "headb" ]) accounts;
  };
  modules = with nixosModules; [
    ({ lib, ... }: {
      system.stateVersion = "25.05";
      networking.hostName = hostname;
      nixpkgs = {
        overlays = builtins.attrValues overlays;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          "slack"
          "spotify"
          "vscode"
          "x32-edit"
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
    fonts.favourites
    networking.networkmanager
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
