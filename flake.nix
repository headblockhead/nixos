{
  description = "NixOS configuration for my desktops, laptops, and local network.";

  #  nixConfig = {
  #extra-substituters = [
  #"https://cache.edwardh.dev"
  #];
  #extra-trusted-public-keys = [
  #"cache.edwardh.dev-1:+Gafa747BGilG7GAbTC/1i6HX9NUwzMbdFAc+v5VOPk="
  #];
  #};

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-2305.url = "github:NixOS/nixpkgs/nixos-23.05";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";

    edwardh-dev.url = "github:headblockhead/edwardh.dev";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      accounts = {
        headb = {
          realname = "Edward Hesketh";
          email = "inbox@edwardh.dev";
          profileIcon = ./users/headb.png;
          sshkeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexdKZYlyseEcm1S3xNDqPTGZMfm/NcW1ygY91weDhC cardno:30_797_561" # thunder-mountain
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvDaJmOSXV24B83sIfZqAUurs+cZ7582L4QDePuc3p7 cardno:17_032_332" # depot-37
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvr2FrC9i1bjoVzg+mdytOJ1P0KRtah/HeiMBuKD3DX cardno:23_836_181" # crystal-peak
          ];
          # The first GPG key is used for signing git commits.
          gpgkeys = [
            "8E972E26D6D48C46" # thunder-mountain
            "672FFB8B28B17E09" # depot-37
            "AE25B4F5B6346CCF" # crystal-peak
          ];
          trusted = true; # Root access (trusted-user, wheel)
        };
      };
    in
    rec {
      overlays = {
        addUnstable = (final: prev: {
          unstable = import inputs.nixpkgs-unstable { inherit (prev) system config; };
        });
        override = (final: prev: {
          google-chrome = prev.google-chrome.overrideAttrs (oldAttrs: {
            commandLineArgs = [ "--ozone-platform=wayland" "--disable-features=WaylandFractionalScaleV1" ];
          });
          gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: { mesonFlags = (builtins.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags) ++ [ "-Dssh-agent=false" ]; });
          go-migrate = prev.go-migrate.overrideAttrs (oldAttrs: { tags = [ "postgres" ]; });
        });
        replace =
          (final: prev: {
            obinskit =
              (
                import inputs.nixpkgs-2305 {
                  inherit (prev) system;
                  config = prev.config // {
                    permittedInsecurePackages = [
                      "electron-13.6.9"
                    ];
                  };
                }
              ).callPackage ./custom-packages/obinskit/obinskit.nix
                { };
            kmscon = prev.callPackage ./custom-packages/kmscon/kmscon.nix { };
            libtsm = prev.callPackage ./custom-packages/libtsm/libtsm.nix { };
            librespot = prev.callPackage ./custom-packages/librespot/default.nix {
              withMDNS = true;
              withDNS-SD = true;
              withAvahi = true;
            };
          });
      };

      nixosModules = nixpkgs.lib.genAttrs'
        (nixpkgs.lib.attrNames (builtins.readDir ./modules))
        (fileName: nixpkgs.lib.nameValuePair (nixpkgs.lib.removeSuffix ".nix" fileName) (./modules/${fileName}));

      nixosConfigurations = nixpkgs.lib.genAttrs
        (builtins.attrNames (nixpkgs.lib.filterAttrs (path: type: type == "directory") (builtins.readDir ./machines)))
        (hostname: import ./machines/${hostname} {
          inherit inputs overlays nixosModules hostname accounts;
        });
    };
}
