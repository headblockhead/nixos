{ inputs, overlays, nixosModules, hostname, allowedUnfreePackages, accounts, ... }:
let
  system = "x86_64-linux";
  stateVersion = "25.05";
  canLogin = [ "headb" ];
in
(
  inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs system stateVersion hostname overlays allowedUnfreePackages;
      accounts = inputs.nixpkgs.lib.filterAttrs (name: _: builtins.elem name canLogin) accounts;
    };

    modules = with nixosModules; [
      ./config.nix
      ./hardware.nix
    ] ++ [
      boot.loader.systemd-boot
      boot.loader.timeout0
      boot.plymouth
      common
      desktopApps
      development
      distributedBuilds
      fonts.favourites
      kmscon
      network
      printer
      programs.fzf
      programs.git
      programs.gnupg
      programs.zsh
      sdr
      security.rtkit
      services.desktop-managers.gnome
      services.display-managers.gdm
      services.openssh
      services.pipewire
      users
    ];
  }
)
