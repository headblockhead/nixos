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
      netbooted-system = (import ./dell-netboot-client {
        inherit inputs nixosModules useCustomNixpkgsNixosModule accountsForSystem accountFromUsername;
        hostname = "dell-netboot-client";
      }).nixosConfiguration.config.system.build;
    };

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule

      {
        networking.hostName = hostname;
        system.stateVersion = "22.05";
      }

      ./config.nix
      ./hardware.nix

      inputs.agenix.nixosModules.default

      ./host-netboot.nix

      basicConfig
      bootloader
      desktop
      desktopApps
      development
      fileSystems
      fonts
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
