[
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "home-assistant";
    };
  }
  {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "home-assistant";
      namespace = "home-assistant";
      labels = {
        app = "home-assistant";
      };
    };
    spec = {
      replicas = 1;
      selector = {
        matchLabels = {
          app = "home-assistant";
        };
      };
      template = {
        metadata = {
          labels = {
            app = "home-assistant";
          };
        };
        spec = {
          hostNetwork = true;
          terminationGracePeriodSeconds = 30;
          containers = [
            {
              name = "home-assistant";
              image = "ghcr.io/home-assistant/aarch64-homeassistant:2026.1.3";
              ports = [{ containerPort = 8123; }];
              volumeMounts = [
                {
                  name = "config-volume";
                  mountPath = "/config";
                }
              ];
              env = [
                {
                  name = "TZ";
                  value = "Europe/London";
                }
              ];
            }
          ];
          volumes = [
            {
              name = "config-volume";
              persistentVolumeClaim = {
                claimName = "home-assistant-pvc";
              };
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
      name = "home-assistant-service";
      namespace = "home-assistant";
    };
    spec = {
      selector = {
        app = "home-assistant";
      };
      ports = [
        {
          protocol = "TCP";
          port = 8123;
          targetPort = 8123;
        }
      ];
      type = "LoadBalancer";
    };
  }
  {
    apiVersion = "v1";
    kind = "PersistentVolumeClaim";
    metadata = {
      name = "home-assistant-pvc";
      namespace = "home-assistant";
    };
    spec = {
      accessModes = [ "ReadWriteOnce" ];
      storageClassName = "longhorn";
      resources = {
        requests = {
          storage = "5Gi";
        };
      };
    };
  }
]
