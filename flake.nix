{
  description = "NixOS configuration for my desktops, laptops, and local network.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-2605.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:headblockhead/disko";
    agenix.url = "github:ryantm/agenix";
    wivrn.url = "github:wivrn/wivrn/v26.9";
    tangled.url = "git+https://tangled.org/tangled.org/core";
    nixos-mailserver.url = "git+https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git?ref=main";
    impermanence.url = "github:nix-community/impermanence";

    edwardh-dev.url = "git+https://seed.edwardh.dev/rad:zudXi8ABTLpwYLAce7NR8KntbcZU";
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      explore =
        do: path:
        builtins.listToAttrs (
          builtins.filter (x: x != null) (
            nixpkgs.lib.mapAttrsToList (name: type: do { inherit name type; }) (builtins.readDir path)
          )
        );

      findFiles =
        do: path:
        explore (
          element:
          let
            elementPath = path + "/${element.name}";
          in
          if element.type == "directory" then
            nixpkgs.lib.nameValuePair element.name (findFiles do elementPath)
          else if nixpkgs.lib.hasSuffix ".nix" element.name then
            nixpkgs.lib.nameValuePair (nixpkgs.lib.removeSuffix ".nix" element.name) (do elementPath)
          else
            null
        ) path;

      findDirectories =
        do: path:
        explore (
          element:
          let
            elementPath = path + "/${element.name}";
          in
          if builtins.pathExists (elementPath + "/default.nix") then
            nixpkgs.lib.nameValuePair element.name (do elementPath)
          else if element.type == "directory" then
            nixpkgs.lib.nameValuePair element.name (findDirectories do elementPath)
          else
            null
        ) path;

      flatten =
        prefix: set:
        nixpkgs.lib.concatMapAttrs (
          name: value:
          let
            key = if prefix == "" then name else "${prefix}-${name}";
          in
          if builtins.isPath value then { ${key} = value; } else flatten key value
        ) set;

      findConfigurations =
        do: path:
        nixpkgs.lib.mapAttrs (name: value: do { inherit name value; }) (
          flatten "" (findDirectories (p: p) path)
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
        downgrade = (
          final: prev:
          let
            previousPkgs = import inputs.nixpkgs-2605 {
              system = prev.stdenv.hostPlatform.system;
              config = {
                inherit (prev.config) allowUnfreePackages permittedInsecurePackages;
              };
            };
          in
          {
            radicle-desktop = previousPkgs.radicle-desktop;
            radicle-httpd = previousPkgs.radicle-httpd;
            radicle-node = previousPkgs.radicle-node;
            radicle-tui = previousPkgs.radicle-tui;
            radicle-explorer = previousPkgs.radicle-explorer;
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
            unifi = prev.callPackage ./custom-packages/unifi/default.nix { };
          }
        );
      };

      nixosModules = findFiles (f: f) ./modules;

      nixosConfigurations = findConfigurations (
        { name, value }:
        import value {
          inherit inputs overlays nixosModules;
          hostName = name;
          reverseDomainName = builtins.replaceStrings [ "-" ] [ "." ] name;
          accounts = findFiles (f: import f) ./accounts;
        }
      ) ./machines;
    };
}
