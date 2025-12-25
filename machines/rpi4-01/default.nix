{ inputs, overlays, nixosModules, hostname, accounts, ... }:
let
  system = "aarch64-linux";
  stateVersion = "25.05";
  canLogin = [ "headb" ];
in
(
  inputs.nixos-raspberrypi.lib.nixosSystem {
    specialArgs = {
      inherit inputs system stateVersion hostname overlays;
      accounts = inputs.nixpkgs.lib.filterAttrs (name: _: builtins.elem name canLogin) accounts;
      nixos-raspberrypi = inputs.nixos-raspberrypi;
    };

    modules = with nixosModules; [
      ./config.nix
      ../rpi4-hardware.nix
    ] ++ [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base

      loadBalancer

      basicConfig
      distributedBuilds
      git
      headless
      monitoring
      ssh
      users
      zsh
    ];
  }
)
