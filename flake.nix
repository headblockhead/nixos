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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";

    edwardh-dev.url = "github:headblockhead/edwardh.dev";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, nixos-raspberrypi, disko, agenix, edwardh-dev, ... }@inputs:
    let
      # Keys used for SSH access to systems.
      sshkeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvr2FrC9i1bjoVzg+mdytOJ1P0KRtah/HeiMBuKD3DX cardno:23_836_181" # crystal-peak
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvDaJmOSXV24B83sIfZqAUurs+cZ7582L4QDePuc3p7 cardno:17_032_332" # depot-37
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexdKZYlyseEcm1S3xNDqPTGZMfm/NcW1ygY91weDhC cardno:30_797_561" # thunder-mountain
      ];

      # Account details to create my user.
      account = {
        username = "headb";
        realname = "Edward Hesketh";
        profileicon = ./profileicon.png;
      };

      # Packages in nixpkgs that I want to override.
      nixpkgs-overlay = (
        final: prev: {
          # Make pkgs.unstable.* point to nixpkgs unstable.
          unstable = import inputs.nixpkgs-unstable {
            system = final.system;
            config = {
              allowUnfree = true;
            };
          };

          google-chrome = prev.google-chrome.overrideAttrs (oldAttrs: {
            commandLineArgs = [
              "--ozone-platform=wayland"
              "--disable-features=WaylandFractionalScaleV1"
            ];
          });
          gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: {
            mesonFlags = (builtins.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags) ++ [
              "-Dssh-agent=false"
            ];
          });
          librespot = prev.librespot.overrideAttrs (oldAttrs: {
            withDNS-SD = true;
          });
          gdm = prev.gdm.overrideAttrs (oldAttrs: {
            #mesonFlags = oldAttrs.mesonFlags ++ [
            #"-Dplymouth=enabled"
            #];
          });

          # Set pkgs.home-manager to be the flake version.
          home-manager = inputs.home-manager.packages.${final.system}.default;
        }
      );

      # Configuration for nixpkgs.
      nixpkgs-config = {
        allowUnfree = true;
      };

      # Create an array of every system in the systems directory.
      systemNames = builtins.attrNames (builtins.readDir ./systems);
      # Create another array of only the systems that have home-manager configured.
      systemNamesWithHomeManager = builtins.filter (system: builtins.pathExists ./systems/${system}/users/${account.username}.nix) systemNames;
      # Create an array of all the NixOS modules.
      nixosModuleNames = map (name: inputs.nixpkgs.lib.removeSuffix ".nix" name) (builtins.attrNames (builtins.readDir ./modules/nixos));
      # Create an array of all the home-manager modules.
      homeManagerModuleNames = map (name: inputs.nixpkgs.lib.removeSuffix ".nix" name) (builtins.attrNames (builtins.readDir ./modules/home-manager));
    in
    rec {
      nixosModules = inputs.nixpkgs.lib.genAttrs nixosModuleNames (module: ./modules/nixos/${module}.nix);
      homeManagerModules = inputs.nixpkgs.lib.genAttrs homeManagerModuleNames (module: ./modules/home-manager/${module}.nix);

      nixosConfigurations = inputs.nixpkgs.lib.genAttrs systemNames (hostname: import ./systems/${hostname} {
        inherit inputs nixosModules sshkeys account;
        # Custom mini module to configure nixpkgs for every system.
        useCustomNixpkgsNixosModule = {
          nixpkgs = {
            overlays = [ nixpkgs-overlay ];
            config = nixpkgs-config;
          };
        };
      });

      # Generates home-manager configurations for machines where I want home-manager enabled.
      homeConfigurations = inputs.nixpkgs.lib.genAttrs systemNamesWithHomeManager (hostname:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; # FIXME!
          extraSpecialArgs = { inherit inputs account; };
          modules = [ ./systems/${hostname}/users/${account.username}.nix ];
        });
    };
}
