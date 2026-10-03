{
  description = "NixOS configuration for my desktops, laptops, and local network.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";
    wivrn.url = "github:wivrn/wivrn/v26.9";

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
            wivrn = inputs.wivrn.packages.${prev.stdenv.hostPlatform.system}.default;
            xrizer = prev.xrizer.overrideAttrs (
              finalAttrs: previousAttrs: {
                version = "unstable-2026-09-15";

                src = prev.fetchFromGitHub {
                  owner = "Supreeeme";
                  repo = "xrizer";
                  rev = "0989a7fac2d1efb7ea82f5fe1a8ed30c3eeb9596";
                  hash = "sha256-Rb1pssAq6Zx6VmQVQtGcThkA6zCwi5X7G7aHmdsDrJo=";
                };

                cargoDeps = prev.rustPlatform.importCargoLock {
                  lockFile = finalAttrs.src + "/Cargo.lock";
                  allowBuiltinFetchGit = true;
                };
                cargoHash = null;

                nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [
                  prev.cmake
                  prev.python3
                ];

                buildInputs = previousAttrs.buildInputs ++ [
                  prev.vulkan-headers
                  prev.libx11
                  prev.libxxf86vm
                  prev.libxrandr
                  prev.wayland
                ];

                cargoBuildFlags = (previousAttrs.cargoBuildFlags or [ ]) ++ [
                  "--features"
                  "static-openxr"
                ];

                postPatch = ''
                  substituteInPlace src/graphics_backends/gl.rs \
                    --replace-fail 'libGLX.so.0' '${prev.lib.getLib prev.libGL}/lib/libGLX.so.0'
                '';
              }
            );
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
