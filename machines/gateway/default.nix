{ inputs, overlays, nixosModules, hostname, accounts, ... }:
let
  system = "x86_64-linux";
  stateVersion = "25.11";
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
      inputs.agenix.nixosModules.default

      basicConfig
      bootloader
      distributedBuilds
      fileSystems
      git
      headless
      homeManager
      monitoring
      ssd
      ssh
      users
      zsh
    ];
  }
)
