{ inputs, overlays, nixosModules, hostname, accounts, ... }:
let
  system = "x86_64-linux";
  stateVersion = "22.05";
  canLogin = [ "headb" ];
in
(
  inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs system stateVersion hostname overlays;
      accounts = inputs.nixpkgs.lib.filterAttrs (name: _: builtins.elem name canLogin) accounts;
    };

    modules = with nixosModules; [
      ./config.nix
      ./hardware.nix
    ] ++ [
      basicConfig
      bootloader
      desktop
      desktopApps
      development
      distributedBuilds
      fileSystems
      fonts
      git
      gpg
      kmscon
      network
      printer
      sdr
      sound
      ssd
      ssh
      users
      yubikey
      zsh
    ];
  }
)
