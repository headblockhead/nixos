{ inputs, lib, config, pkgs, usernames, accountFromUsername, ... }:
let
  trustedUsernames = builtins.filter (username: (accountFromUsername username).trusted) usernames;
in
{
  # Delete the /tmp directory every boot.
  boot.tmp.cleanOnBoot = true;

  # Enable irqbalancer, to balance IRQs across cores.
  services.irqbalance.enable = true;

  # Enable nixos-help apps.
  documentation.nixos.enable = true;

  # Set regonal settings.
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "us";

  nix.settings = {
    trusted-users = trustedUsernames;
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    substituters = [ "https://cache.edwardh.dev" ];
    trusted-public-keys = [ "cache.edwardh.dev-1:+Gafa747BGilG7GAbTC/1i6HX9NUwzMbdFAc+v5VOPk=" ];
    download-buffer-size = 524288000; # 500MiB
  };

  # Add each input as a flake registry to make nix commands consistent.
  nix.registry = lib.mkOverride 10 ((lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs));

  # Add each input to the system channels, to make nix-command consistent too.
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc =
    lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;

  # Use next-gen nixos switch.
  system.switch = {
    enable = false;
    enableNg = true;
  };

  # Useful base packages for every system to have.
  environment.systemPackages = with pkgs; [
    git
    xc
    neovim
    p7zip

    pciutils
    usbutils
    inetutils
    killall
    btop
    dig
  ];

  networking.domain = lib.mkDefault "lan";
}
