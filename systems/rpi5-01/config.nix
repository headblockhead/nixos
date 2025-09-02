{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 8501 ];

  age.secrets.harmonia-signing-key.file = ../../secrets/harmonia-signing-key.age;
  age.secrets.ncps-signing-key.file = ../../secrets/ncps-signing-key.age;

  nix.gc = {
    automatic = true;
    persistent = false; # don't start garbage collection on boot if the last collection interval was missed.
    dates = "monthly";
    options = "--delete-older-than 30d"; # delete generations older than 30 days.
    randomizedDelaySec = "3d"; # random delay to (most likely) prevent all machines from doing gc at the same time.
  };

  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.age.secrets.harmonia-signing-key.path ];
    settings = {
      bind = "127.0.0.1:5000";
      workers = 8;
      max_connection_rate = 1024;
      priority = 20;
    };
  };

  #  services.atticd = {
  #enable = true;
  #settings = {
  #listen = "127.0.0.1:8080";
  #};
  #};

  services.ncps = {
    enable = true;
    server.addr = "0.0.0.0:8501";
    upstream.caches = [
      "http://localhost:5000" # Harmonia

      "https://cachix.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "https://nixos-raspberrypi.cachix.org"
    ];
    upstream.publicKeys = [
      "localhost-1:gdUftwmkVqD+rHfTvMEb+J63AoUVUwL0v0muBN2BEVQ="

      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    cache = {
      secretKeyPath = config.age.secrets.ncps-signing-key.path;
      hostName = "cache.edwardh.dev";
      maxSize = "128G";
      allowPutVerb = false;
      allowDeleteVerb = false;
    };
  };
}
