{ inputs, lib, pkgs, accounts, hostname, stateVersion, system, overlays, ... }:
{
  # Set basic system settings.
  networking.hostName = hostname;
  system.stateVersion = stateVersion;
  nixpkgs = {
    hostPlatform = system;
    config = {
      allowUnfree = true;
    };
    overlays = builtins.attrValues overlays; # all overlays
  };

  # Delete the /tmp directory every boot.
  boot.tmp.cleanOnBoot = true;

  # Enable nixos-help apps.
  documentation.nixos.enable = true;

  # Set regonal settings.
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "us";

  nix.settings = {
    trusted-users = builtins.attrNames (lib.filterAttrs (n: v: v.trusted) accounts);
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    #substituters = [ "https://cache.edwardh.dev" ];
    #trusted-public-keys = [ "cache.edwardh.dev-1:+Gafa747BGilG7GAbTC/1i6HX9NUwzMbdFAc+v5VOPk=" ];
    download-buffer-size = 524288000; # 500MiB
  };

  # Add all inputs to the flake registry to make nix commands consistent with the flake.lock.
  nix.registry = lib.mkOverride 10 ((lib.mapAttrs (_: flake: { inherit flake; })) inputs);

  # Utility packages.
  environment.systemPackages = with pkgs; [
    git
    xc
    vim
    p7zip
    btop

    file
    killall
    pciutils
    usbutils
    inetutils
    dig
  ];
}
