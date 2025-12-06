{
  description = "NixOS configuration for my desktops, laptops, and local network.";

  nixConfig = {
    extra-substituters = [
      "https://cache.edwardh.dev"
    ];
    extra-trusted-public-keys = [
      "cache.edwardh.dev-1:+Gafa747BGilG7GAbTC/1i6HX9NUwzMbdFAc+v5VOPk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    oldnixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";

    railreader.url = "github:headblockhead/railreader";
    edwardh-dev.url = "github:headblockhead/edwardh.dev";
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixos-raspberrypi, disko, agenix, railreader, edwardh-dev, ... }@inputs:
    let
      # Which accounts can access which systems is handled per-system.
      accounts = [
        {
          username = "headb";
          realname = "Edward Hesketh";
          email = "inbox@edwardh.dev";
          profileicon = ./users/headb.png;
          sshkeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexdKZYlyseEcm1S3xNDqPTGZMfm/NcW1ygY91weDhC cardno:30_797_561" # thunder-mountain
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvDaJmOSXV24B83sIfZqAUurs+cZ7582L4QDePuc3p7 cardno:17_032_332" # depot-37
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvr2FrC9i1bjoVzg+mdytOJ1P0KRtah/HeiMBuKD3DX cardno:23_836_181" # crystal-peak
          ];
          # The first GPG key is used as the default for signing git commits.
          gpgkeys = [
            "8E972E26D6D48C46" # thunder-mountain
            "672FFB8B28B17E09" # depot-37
            "AE25B4F5B6346CCF" # crystal-peak
          ];
          trusted = true; # Root access (trusted-user, wheel)
        }
      ];

      # Packages in nixpkgs that I want to override.
      nixpkgs-overlay = (
        final: prev:
          {
            # Make pkgs.unstable.* point to nixpkgs unstable branch.
            unstable = import inputs.nixpkgs-unstable {
              system = final.system;
              config = {
                allowUnfree = true;
              };
            };

            google-chrome = prev.google-chrome.overrideAttrs (oldAttrs: {
              commandLineArgs = [ "--ozone-platform=wayland" "--disable-features=WaylandFractionalScaleV1" ];
            });
            gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: { mesonFlags = (builtins.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags) ++ [ "-Dssh-agent=false" ]; });
            go-migrate = prev.go-migrate.overrideAttrs (oldAttrs: { tags = [ "postgres" ]; });
            obinskit = (import inputs.oldnixpkgs {
              system = final.system;
              config = {
                allowUnfree = true;
                permittedInsecurePackages = [
                  "electron-13.6.9"
                ];
              };
            }).callPackage ./custom-packages/obinskit/obinskit.nix
              { };

            kmscon = prev.callPackage ./custom-packages/kmscon/kmscon.nix { };
            libtsm = prev.callPackage ./custom-packages/libtsm/libtsm.nix { };
            librespot = prev.callPackage ./custom-packages/librespot/default.nix {
              withMDNS = true;
              withDNS-SD = true;
              withAvahi = true;
            };
          }
      );

      # Configuration for nixpkgs.
      nixpkgs-config = {
        allowUnfree = true;
      };

      # An array of every system folder in ./systems.
      systemNames = builtins.attrNames (inputs.nixpkgs.lib.filterAttrs (path: type: type == "directory") (builtins.readDir ./systems));

      # An array of all the NixOS modules in ./modules/nixos.
      nixosModuleNames = map (name: inputs.nixpkgs.lib.removeSuffix ".nix" name) (builtins.attrNames (builtins.readDir ./modules/nixos));
      # An attribute set of all the NixOS modules in ./modules/nixos.
      nixosModules = inputs.nixpkgs.lib.genAttrs nixosModuleNames (module: ./modules/nixos/${module}.nix);

      # A function that returns the account for a given username.
      accountFromUsername = username: builtins.elemAt (builtins.filter (account: account.username == username) accounts) 0;

      # A mini-module that configures nixpkgs to use our custom overlay and configuration.
      useCustomNixpkgsNixosModule = {
        nixpkgs = {
          overlays = [ nixpkgs-overlay ];
          config = nixpkgs-config;
        };
      };

      # A function that returns for a given system's name:
      # - its NixOS configuration (nixosConfiguration)
      # - its system architecture (system)
      # - the accounts that can log in to it (canLogin)
      callSystem = (hostname: import ./systems/${hostname} {
        # Pass on the inputs and nixosModules.
        inherit inputs nixosModules hostname useCustomNixpkgsNixosModule accountFromUsername;

        # Pass on a function that returns a filtered list of accounts based on an array of usernames.
        accountsForSystem = canLogin: builtins.filter (account: builtins.elem account.username canLogin) accounts;
      });
    in
    {
      nixosConfigurations = inputs.nixpkgs.lib.genAttrs systemNames (hostname: (callSystem hostname).nixosConfiguration);
    };
}
