[
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "home-assistant";
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
      accessModes = [ "ReadWriteMany" ];
      storageClassName = "longhorn";
      resources.requests.storage = "5Gi";
    };
  }
  {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "home-assistant";
      namespace = "home-assistant";
      labels.app = "home-assistant";
    };
    spec = {
      selector.matchLabels.app = "home-assistant";
      replicas = 1;
      template = {
        metadata.labels.app = "home-assistant";
        spec = {
          hostNetwork = true;
          dnsPolicy = "ClusterFirstWithHostNet";
          containers = [{
            name = "home-assistant";
            image = "ghcr.io/home-assistant/aarch64-homeassistant:2026.1.3";
            env = [{ name = "TZ"; value = "Europe/London"; }];
            volumeMounts = [{ name = "config-volume"; mountPath = "/config"; }];
          }];
          volumes = [{ name = "config-volume"; persistentVolumeClaim.claimName = "home-assistant-pvc"; }];
        };
      };
    };
  }
]
