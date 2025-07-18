{ inputs, nixosModules, useCustomNixpkgsNixosModule, accountsForSystem, accountFromUsername, hostname, ... }:
let
  system = "x86_64-linux";
  canLogin = [ "headb" ];
  hasHomeManager = true;
in
{
  nixosConfiguration = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs accountFromUsername;
      accounts = accountsForSystem canLogin;
      usernames = canLogin;
    };

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule

      {
        networking.hostName = hostname;
        system.stateVersion = "22.05";
      }

      ./config.nix
      ./hardware.nix

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
    ] ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
