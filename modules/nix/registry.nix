{ lib, inputs, ... }:
{
  nix.registry = lib.mkOverride 10 ((lib.mapAttrs (_: flake: { inherit flake; })) inputs);
}
