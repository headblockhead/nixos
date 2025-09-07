{ config, pkgs, inputs, system, ... }:
let
  railreader-image = inputs.railreader.outputs.packages.${system}.railreader-docker;
in
{
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;

  boot.kernelParams = [ "cgroup_memory=1" "cgroup_enable=memory" ];

  networking.firewall.allowedTCPPorts = [
    6443 # k3s
    2379 # k3s etcd
    2380 # k3s etcd 
    10250 # k3s kubelet
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s flannel
  ];

  services.k3s = {
    enable = true;
    images = [
      railreader-image
      config.services.k3s.package.airgapImages
    ];
    manifests = {
      railreaderdeployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "railreader";
        };
        spec = {
          replicas = 1;
          selector = {
            matchLabels = {
              app = "railreader";
            };
          };
          template = {
            metadata = {
              labels = {
                app = "railreader";
              };
            };
            spec = {
              containers = [
                {
                  name = "railreader";
                  image = "${railreader-image.imageName}:${railreader-image.imageTag}";
                  imagePullPolicy = "Never";
                  ports = [
                    {
                      containerPort = 80;
                    }
                  ];
                }
              ];
            };
          };
        };
      };

      railreaderservice.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "railreader";
        };
        spec = {
          selector = {
            app = "railreader";
          };
          ports = [
            {
              protocol = "TCP";
              port = 80;
              targetPort = 80;
            }
          ];
          type = "ClusterIP";
        };
      };

      railreaderingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "railreader";
          annotations = {
            "nginx.ingress.kubernetes.io/rewrite-target" = "/";
          };
        };
        spec = {
          rules = [
            {
              host = "railreader.local"; # update to your domain
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "railreader";
                        port = {
                          number = 80;
                        };
                      };
                    };
                  }
                ];
              };
            }
          ];
        };
      };
    };
    tokenFile = config.age.secrets.k3s-token.path;
    gracefulNodeShutdown.enable = true;
    serverAddr = "https://k3s.edwardh.dev:6443";
    role = "server";
    extraFlags = [
      "--tls-san=k3s.edwardh.dev"
      "--embedded-registry"
    ];
  };
}
