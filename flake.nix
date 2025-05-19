{
  description = "Reproducable NixOS (and homemanager) config for my local servers, cloud servers, desktops, and laptops.";

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
    nixpkgs-master.url = "github:NixOS/nixpkgs/master"; # Very unstable! Useful for same-day hotfixes.

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";

    edwardh-dev.url = "github:headblockhead/edwardh.dev";
  };

  outputs =
    { self, nixpkgs, home-manager, deploy-rs, nixos-raspberrypi, agenix, disko, edwardh-dev, ... }@ inputs:
    let
      inherit (self) outputs;

      # System types we want to build our packages for, used to generate pkgs.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      sshkeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvr2FrC9i1bjoVzg+mdytOJ1P0KRtah/HeiMBuKD3DX cardno:23_836_181" # crystal-peak
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvDaJmOSXV24B83sIfZqAUurs+cZ7582L4QDePuc3p7 cardno:17_032_332" # depot-37
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexdKZYlyseEcm1S3xNDqPTGZMfm/NcW1ygY91weDhC cardno:30_797_561" # thunder-mountain
      ];

      account = {
        username = "headb";
        realname = "Edward Hesketh";
        profileicon = ./profileicon.png;
      };

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    rec {
      # Custom packages: accessible through 'nix build', 'nix shell', etc.
      packages = forAllSystems
        (system: import ./pkgs {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          inherit inputs system;
        });

      # Exported overlays. Includes custom packages and flake outputs.
      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = rec {
        # Local servers
        gateway = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs sshkeys account; };
          modules = [
            ./systems/gateway/config.nix
            ./systems/gateway/hardware.nix
            agenix.nixosModules.default
          ];
        };

        rpi5-01 = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs sshkeys account nixos-raspberrypi; };
          modules = [
            ./systems/rpi5-01/config.nix
            ./systems/rpi5-01/hardware.nix
            ./systems/rpi5-01/disko.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-5.base
            agenix.nixosModules.default
            disko.nixosModules.disko
          ];
        };

        rpi5-02 = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs sshkeys account nixos-raspberrypi; };
          modules = [
            ./systems/rpi5-02/config.nix
            ./systems/rpi5-02/hardware.nix
            ./systems/rpi5-02/disko.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-5.base
            agenix.nixosModules.default
            disko.nixosModules.disko
          ];
        };

        rpi5-03 = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs sshkeys account nixos-raspberrypi; };
          modules = [
            ./systems/rpi5-03/config.nix
            ./systems/rpi5-03/hardware.nix
            ./systems/rpi5-03/disko.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-5.base
            agenix.nixosModules.default
            disko.nixosModules.disko
          ];
        };

        rpi4-01 = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs sshkeys account nixos-raspberrypi; };
          modules = [
            ./systems/rpi4-01/config.nix
            ./systems/rpi4-01/hardware.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
          ];
        };

        rpi4-02 = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs sshkeys account nixos-raspberrypi; };
          modules = [
            ./systems/rpi4-02/config.nix
            ./systems/rpi4-02/hardware.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
          ];
        };

        printerpi = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          trustCaches = false;
          specialArgs = { inherit inputs outputs sshkeys account; };
          modules = [
            ./systems/printerpi/config.nix
            ./systems/printerpi/hardware.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
          ];
        };

        # Local clients
        edward-desktop-01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs sshkeys account; };
          modules = [
            ./systems/edward-desktop-01/config.nix
            ./systems/edward-desktop-01/hardware.nix
          ];
        };
        edward-laptop-01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs sshkeys account; };
          modules = [
            ./systems/edward-laptop-01/config.nix
            ./systems/edward-laptop-01/hardware.nix
          ];
        };

        # AWS EC2 nodes
        edwardh = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs sshkeys account edwardh-dev; };
          modules = [
            ./systems/edwardh/config.nix
            "${nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
            agenix.nixosModules.default
          ];
        };

        netboot-client = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs sshkeys account; };
          modules = [
            ./systems/dell-netboot-client/config.nix
            ./systems/dell-netboot-client/hardware.nix
            "${nixpkgs}/nixos/modules/installer/netboot/netboot.nix"
            "${nixpkgs}/nixos/modules/profiles/minimal.nix"
            "${nixpkgs}/nixos/modules/profiles/base.nix"
          ];
        };

        # Old Dell desktop machine.
        edward-dell-01 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs sshkeys account; netboot-client = netboot-client.config.system.build; };
          modules = [
            ./systems/edward-dell-01/config.nix
            ./systems/edward-dell-01/hardware.nix
            agenix.nixosModules.default
          ];
        };
      };

      # SD card images. Also works for NVME drives!
      rpi5-01-sd = nixosConfigurations.rpi5-01.config.system.build.sdImage;
      rpi4-01-sd = nixosConfigurations.rpi4-01.config.system.build.sdImage;
      rpi4-02-sd = nixosConfigurations.rpi4-02.config.system.build.sdImage;
      printerpi-sd = nixosConfigurations.printerpi.config.system.build.sdImage;

      homeConfigurations = {
        "headb@gateway" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./systems/gateway/users/headb.nix ];
        };
        "headb@edward-desktop-01" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./systems/edward-desktop-01/users/headb.nix ];
        };
        "headb@edward-laptop-01" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./systems/edward-laptop-01/users/headb.nix ];
        };
        "headb@edward-dell-01" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./systems/edward-dell-01/users/headb.nix ];
        };
      };
    };
}
