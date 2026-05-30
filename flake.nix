{
  description = "NixOS configuration for my desktops, laptops, and local network.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";

    edwardh-dev.url = "github:headblockhead/edwardh.dev";
  };

  outputs =
    { nixpkgs, ... }@inputs:
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
                { ${element.name} = recurseFindNixFiles yield elementPath; } # Recurse into subdirectory
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
