{ inputs, lib, pkgs, accounts, hostname, stateVersion, system, overlays, allowedUnfreePackages, ... }:
{
  # Set basic system settings.
  networking.hostName = hostname;
  system.stateVersion = stateVersion;
  nixpkgs = {
    hostPlatform = system;
    # Use all overlays.
    overlays = builtins.attrValues overlays;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowedUnfreePackages;
  };

  # Delete the /tmp directory every boot.
  boot.tmp.cleanOnBoot = true;

  # Run fstrim weekly.
  services.fstrim.enable = true;

  # Set preferred regonal settings.
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "us";

  nix = {
    settings = {
      trusted-users = builtins.attrNames (lib.filterAttrs (n: v: v.rootAccess) accounts);
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      #substituters = [ "https://cache.edwardh.dev" ];
      #trusted-public-keys = [ "cache.edwardh.dev-1:+Gafa747BGilG7GAbTC/1i6HX9NUwzMbdFAc+v5VOPk=" ];
    };
    # Add all inputs to the flake registry to make nix commands consistent with the flake.lock file.
    registry = lib.mkOverride 10 ((lib.mapAttrs (_: flake: { inherit flake; })) inputs);
  };

  # Utility packages.
  environment.systemPackages = with pkgs; [
    git
    vim
    p7zip
    btop
    tree

    file
    killall
    pciutils
    usbutils
    inetutils
    lm_sensors
    dig
  ];
}
