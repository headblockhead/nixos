{ outputs, config, lib, ... }:
{
  networking.hostName = "rpi5-01";

  imports = with outputs.nixosModules; [
    basicConfig
    distributedBuilds
    git
    headless
    monitoring
    ssh
    users
    zsh
  ];

  age.secrets.harmonia-signing-key.file = ../../secrets/harmonia-signing-key.age;
  age.secrets.ncps-signing-key.file = ../../secrets/ncps-signing-key.age;
  age.secrets.dendrite-environment-file = {
    file = ../../secrets/dendrite-environment-file.age;
    owner = "dendrite";
    group = "dendrite";
    mode = "400";
  };
  age.secrets.dendrite-matrix-key = {
    file = ../../secrets/dendrite-matrix-key.age;
    owner = "dendrite";
    group = "dendrite";
    mode = "400";
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

  services.ncps = {
    enable = true;
    server.addr = "127.0.0.1:8501";
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
      maxSize = "100G";
      allowPutVerb = false;
      allowDeleteVerb = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 9002 8008 9003 9005 ];

  services.dendrite =
    let
      database = {
        connection_string = "postgresql:///dendrite?host=/run/postgresql";
        max_open_conns = 497;
        max_idle_conns = 5;
        conn_max_lifetime = -1;
      };
    in
    {
      enable = true;
      httpPort = 8008;
      environmentFile = config.age.secrets.dendrite-environment-file.path;
      settings = {
        global = {
          server_name = "edwardh.dev";
          private_key = config.age.secrets.dendrite-matrix-key.path;
          presence = {
            enable_inbound = true;
            enable_outbound = true;
          };
        };

        global.database = database;
        app_service_api.database = database;
        federation_api.database = database;
        key_server.database = database;
        media_api.database = database;
        mscs.database = database;
        relay_api.database = database;
        room_server.database = database;
        sync_api.database = database;
        user_api.account_database = database;
        user_api.pusher_database = database;

        sync_api.search.enabled = true;
        client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET"; # defined in environmentFile
      };
    };
  users.users.dendrite = {
    isSystemUser = true;
    group = "dendrite";
  };
  users.groups.dendrite = { };
  systemd.services.dendrite = {
    after = [ "postgresql.service" ];
    serviceConfig = {
      User = "dendrite";
      Group = "dendrite";
      DynamicUser = lib.mkForce false;
    };
  };

  services.postgresql = {
    enable = true;
    settings = {
      max_connections = 500;
    };
    ensureDatabases = [ "dendrite" ];
    ensureUsers = [
      {
        name = "dendrite";
        ensureDBOwnership = true;
      }
      {
        name = "postgres-exporter";
      }
    ];
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    port = 9003;

    dataSourceName = "postgresql:///dendrite?host=/run/postgresql";
  };

  services.nginx = {
    enable = true;
    statusPage = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "cache.edwardh.dev" = {
        locations."/".proxyPass = "http://127.0.0.1:8501";
      };
    };
  };

  services.prometheus.exporters.nginx = {
    enable = true;
    port = 9005;
  };

  environment.systemPackages = [
  ];

  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "23.05";
}
