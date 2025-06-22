{ inputs, nixosModules, useCustomNixpkgsNixosModule, accountsForSystem, accountFromUsername, hostname, ... }:
let
  system = "aarch64-linux";
  canLogin = [ "headb" ];
  hasHomeManager = false;
in
{
  nixosConfiguration = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs accountFromUsername;
      accounts = accountsForSystem canLogin;
      usernames = canLogin;

      nixos-raspberrypi = inputs.nixos-raspberrypi;
    };

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule

      {
        networking.hostName = hostname;
        system.stateVersion = "23.05";
      }

      ./config.nix

      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base

      basicConfig
      distributedBuilds
      git
      headless
      monitoring
      ssh
      users
      zsh
    ] ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
