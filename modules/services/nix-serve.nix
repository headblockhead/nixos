{ pkgs, ... }:
{
  services.nix-serve = {
    enable = true;
    # note: firewall configuration should be handled per-machine.
    port = 5000;
    package = pkgs.nix-serve-ng;
  };
}
