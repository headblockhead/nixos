{
  description = "NixOS configuration for my desktops, laptops, and local network.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";
    wivrn.url = "github:wivrn/wivrn/v26.9";
    tangled.url = "git+https://tangled.org/tangled.org/core";
    nixos-mailserver.url = "git+https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git?ref=main";
    impermanence.url = "github:nix-community/impermanence";

    #edwardh-dev.url = "git+https://knot.edwardh.dev/edwardh.dev/edwardh.dev";
    edwardh-dev.url = "github:headblockhead/edwardh.dev";
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      recurseFindNixFiles =
        yield: directory:
        nixpkgs.lib.foldl'
          (
            accumulated: element:
            accumulated
            // (
              let
                elementPath = directory + "/${element.name}";
              in
              if element.type == "directory" then
                { ${element.name} = recurseFindNixFiles yield elementPath; }
              else if nixpkgs.lib.hasSuffix ".nix" element.name then
                { ${nixpkgs.lib.removeSuffix ".nix" element.name} = yield elementPath; }
              else
                { } # Ignore non-Nix files
            )
          )
          { }
          (
            nixpkgs.lib.mapAttrsToList (name: value: {
              name = name;
              type = value;
            }) (builtins.readDir directory)
          );
    in
    rec {
      overlays = {
        override = (
          final: prev: {
            go-migrate = prev.go-migrate.overrideAttrs (oldAttrs: {
              tags = [ "postgres" ];
            });
          }
        );
        replace = (
          final: prev: {
            librespot = prev.callPackage ./custom-packages/librespot/default.nix {
              withMDNS = true;
              withDNS-SD = true;
              withAvahi = true;
            };
            wivrn = inputs.wivrn.packages.${prev.stdenv.hostPlatform.system}.default;
            xrizer = prev.callPackage ./custom-packages/xrizer/default.nix { };
            unifi = prev.callPackage ./custom-packages/unifi/default.nix { };
          }
        );
      };

      nixosModules = recurseFindNixFiles (file: file) ./modules;

      nixosConfigurations =
        nixpkgs.lib.genAttrs
          (builtins.attrNames (
            nixpkgs.lib.filterAttrs (path: type: type == "directory") (builtins.readDir ./machines)
          ))
          (
            hostname:
            import ./machines/${hostname} {
              inherit
                inputs
                overlays
                nixosModules
                hostname
                ;
              accounts = recurseFindNixFiles (file: import file) ./accounts;
            }
          );

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
