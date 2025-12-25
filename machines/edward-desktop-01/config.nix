{ pkgs, config, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.k3s = {
    enable = true;
    role = "server";
    images = [
      config.services.k3s.package.airgap-images
    ];
    manifests = {
      hello-world.content = [
        {
          apiVersion = "v1";
          kind = "Namespace";
          metadata = {
            name = "hello-world";
          };
        }
        {
          apiVersion = "apps/v1";
          kind = "Deployment";
          metadata = {
            name = "hello-world-deployment";
            namespace = "hello-world";
          };
          spec = {
            selector = {
              matchLabels = {
                app = "hello-world";
              };
            };
            replicas = 1;
            template = {
              metadata = {
                labels = {
                  app = "hello-world";
                };
              };
              spec = {
                containers = [
                  {
                    name = "hello-world";
                    image = "hashicorp/http-echo";
                    args = [
                      "-text=Hello, World!"
                      "-listen=:5000"
                    ];
                    ports = [
                      {
                        containerPort = 5000;
                      }
                    ];
                  }
                ];
              };
            };
          };
        }
        {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "hello-world-service";
            namespace = "hello-world";
          };
          spec = {
            selector = {
              app = "hello-world";
            };
            ports = [
              {
                protocol = "TCP";
                targetPort = 5000;
                port = 5000;
              }
            ];
            type = "LoadBalancer";
          };
        }
      ];
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    package = pkgs.unstable.steam;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureUsers = [{ name = "headb"; }];
    settings.max_wal_size = "30GB";
  };

  environment.systemPackages = [
    pkgs.clonehero
    pkgs.blender-hip
    pkgs.vscode-fhs
    pkgs.prismlauncher
    pkgs.handbrake
    pkgs.anki
    pkgs.qgis
    pkgs.obinskit
    #pkgs.qxmledit

    pkgs.kdePackages.kdenlive
  ];
}
