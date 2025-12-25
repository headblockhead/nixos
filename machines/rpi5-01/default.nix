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
      ../rpi5-hardware.nix
      ../rpi5-disko.nix
    ] ++ [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      inputs.agenix.nixosModules.age
      inputs.disko.nixosModules.disko

      k3s

      basicConfig
      distributedBuilds
      gc
      headless
      monitoring
      ssh
      users
      zsh
    ];
  }
)
