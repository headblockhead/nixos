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

      {
        networking.hostName = "dell-netboot-client";
        system.stateVersion = "25.05";
      }

      ./config.nix
      ./hardware.nix

      basicConfig
      network
      users
      ssh
      zsh
    ];
  }
)
