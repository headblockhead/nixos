{ inputs, nixosModules, useCustomNixpkgsNixosModule, accountsForSystem, accountFromUsername, hostname, ... }:
let
  system = "aarch64-linux";
  canLogin = [ "headb" ];
  hasHomeManager = false;
in
{
  nixosConfiguration = inputs.nixos-raspberrypi.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs accountFromUsername system;
      accounts = accountsForSystem canLogin;
      usernames = canLogin;

      nixos-raspberrypi = inputs.nixos-raspberrypi;
    };

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule

      {
        networking.hostName = hostname;
        system.stateVersion = "25.05";
      }

      ./config.nix
      ../rpi5-hardware.nix
      ../rpi5-disko.nix

      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      inputs.agenix.nixosModules.default
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
    ] ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
