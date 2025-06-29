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

      # Pass the netbooted-system system to the host-netboot.nix file.
      netbooted-system = import ./dell-netboot-client {
        inherit inputs nixosModules useCustomNixpkgsNixosModule accountsForSystem;
        hostname = "dell-netboot-client";
      };
    };

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule

      {
        networking.hostName = hostname;
        system.stateVersion = "22.05";
      }

      ./config.nix
      ./hardware.nix

      ./host-netboot.nix

      basicConfig
      bootloader
      desktop
      desktopApps
      fileSystems
      fonts
      fzf
      git
      gpg
      network
      sound
      ssd
      ssh
      users
      zsh
    ] ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
