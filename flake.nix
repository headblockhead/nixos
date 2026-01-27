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

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";

    edwardh-dev.url = "github:headblockhead/edwardh.dev";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      recurseFindNixFiles = yield: directory: nixpkgs.lib.foldl'
        (accumulated: element:
          accumulated // (
            let elementPath = directory + "/${element.name}"; in
            if element.type == "directory" then
              { ${element.name} = recurseFindNixFiles yield elementPath; } # Recurse into subdirectory
            else if nixpkgs.lib.hasSuffix ".nix" element.name then
              { ${nixpkgs.lib.removeSuffix ".nix" element.name} = yield elementPath; }
            else
              { } # Ignore non-Nix files
          )
        )
        { }
        (nixpkgs.lib.mapAttrsToList
          (name: value: { name = name; type = value; })
          (builtins.readDir directory)
        );
    in
    rec {
      overlays = {
        override = (final: prev: {
          go-migrate = prev.go-migrate.overrideAttrs (oldAttrs: { tags = [ "postgres" ]; });
        });
        replace = (final: prev: {
          librespot = prev.callPackage ./custom-packages/librespot/default.nix {
            withMDNS = true;
            withDNS-SD = true;
            withAvahi = true;
          };
        });
      };

      nixosModules = recurseFindNixFiles (file: file) ./modules;

      nixosConfigurations = nixpkgs.lib.genAttrs
        (builtins.attrNames (nixpkgs.lib.filterAttrs (path: type: type == "directory") (builtins.readDir ./machines)))
        (hostname: import ./machines/${hostname} {
          inherit inputs overlays nixosModules hostname;
          accounts = recurseFindNixFiles (file: import file) ./accounts;
        });
    };
}
