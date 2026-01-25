{ pkgs, config, lib, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.enable = lib.mkForce false;

  services.asterisk = {
    enable = true;
    confFiles = {
      "extensions.conf" = ''
        [from-internal]
        exten => 8123,1,Dial(PJSIP/8123,20)
        exten => 1002,1,Dial(PJSIP/secondphone,20)
        exten => 1000,1,Dial(PJSIP/desktop-voip,20)

        ; Dial 100 for "hello, world"
        exten => 100,1,Answer()
        same  =>     n,Wait(2)
        same  =>     n,Playback(hello-world)
        same  =>     n,Wait(2)
        same  =>     n,Playback(goodbye)
        same  =>     n,Hangup()

        exten => 01189998819991197253,1,Answer()
        same  =>     n,Wait(2)
        same  =>     n,Playback(goodbye)
        same  =>     n,Hangup()
      '';
      "pjsip.conf" = ''
        [transport-tcp]
        type=transport
        protocol=tcp
        bind=0.0.0.0

        [transport-udp]
        type=transport
        protocol=udp
        bind=0.0.0.0

        ; define macros

        [endpoint_internal](!)
        type=endpoint
        context=from-internal
        disallow=all
        allow=ulaw

        [auth_userpass](!)
        type=auth
        auth_type=userpass

        [aor_dynamic](!)
        type=aor
        max_contacts=1

        ; use macros

        [8123](endpoint_internal)
        auth=8123
        aors=8123
        [8123](auth_userpass)
        password=8123
        username=8123
        [8123](aor_dynamic)

        [secondphone](endpoint_internal)
        auth=secondphone
        aors=secondphone
        [secondphone](auth_userpass)
        password=second
        username=secondphone
        [secondphone](aor_dynamic)

        [desktop-voip](endpoint_internal)
        auth=desktop-voip
        aors=desktop-voip
        [desktop-voip](auth_userpass)
        password=desktop-voip
        username=desktop-voip
        [desktop-voip](aor_dynamic)
      '';
    };
  };

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
    #pkgs.qxmledit

    pkgs.kdePackages.kdenlive
  ];
}
