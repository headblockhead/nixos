{ inputs, nixosModules, sshkeys, account, useCustomNixpkgsNixosModule, ... }:
let
  system = "x86_64-linux";
in
(
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      # Pass on inputs, sshkeys, and account to the modules' inputs.
      inherit inputs sshkeys account;
    };

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule

      ./config.nix
      ./hardware.nix

      basicConfig
      bluetooth
      bootloader
      desktop
      desktopApps
      development
      distributedBuilds
      fileSystems
      fonts
      git
      gpg
      homeManager
      network
      openrgb
      printer
      sdr
      sound
      ssd
      ssh
      users
      virtualisation
      yubikey
      zsh
    ];
  }
)
