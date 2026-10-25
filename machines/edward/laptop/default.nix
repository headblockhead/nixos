{
  inputs,
  overlays,
  nixosModules,
  hostName,
  reverseDomainName,
  accounts,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs hostName reverseDomainName;
    accounts = inputs.nixpkgs.lib.filterAttrs (
      username: account: builtins.elem username [ "headb" ]
    ) accounts;
  };
  modules = with nixosModules; [
    {
      system.stateVersion = "25.11";
      networking.hostName = hostName;
      nixpkgs = {
        overlays = builtins.attrValues overlays;
        config.allowUnfreePackages = [
          "slack"
          "spotify"
          "x32-edit"
          "obsidian"
          "copilot.vim"
        ];
        config.permittedInsecurePackages = [
          "radicle-node-1.10.3"
        ];
      };
    }

    ./config.nix
    ./hardware.nix

    boot.loader.systemd-boot
    boot.loader.timeout0
    boot.plymouth
    conf.development
    conf.en-gb
    conf.gopass
    conf.graphical-ios
    conf.graphical-multimedia
    conf.graphical-productivity
    conf.graphical-social
    conf.graphical-web
    conf.utility
    fileSystems
    fonts.favourites
    hardware.enableRedistributableFirmware
    networking.networkmanager
    nix.gc
    nix.registry
    nix.settings
    programs.fzf
    programs.git
    programs.gnupg
    programs.neovim
    programs.zsh
    security.rtkit
    services.desktop-managers.gnome
    services.display-managers.gdm
    services.fwupd
    services.openssh
    services.pipewire
    services.printing
    services.printingEnsureHomePrinter
    users.users
  ];
}
