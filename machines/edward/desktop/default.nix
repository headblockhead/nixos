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
      system.stateVersion = "22.05";
      networking.hostName = hostName;
      nixpkgs = {
        overlays = builtins.attrValues overlays;
        config.allowUnfreePackages = [
          "vscode"
          "code"
          "code-with-extensions"
          "copilot.vim"
          "slack"
          "spotify"
          "clonehero"
          "steam"
          "steam-unwrapped"
        ];
        config.permittedInsecurePackages = [
          "radicle-node-1.10.3"
        ];
        config.rocmSupport = true;
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
    nix.buildMachines
    nix.gc
    nix.optimise
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
    #services.wivrn
    users.users
  ];
}
