[
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "matter";
    };
  }
  {
    apiVersion = "v1";
    kind = "PersistentVolumeClaim";
    metadata = {
      name = "matter-pvc";
      namespace = "matter";
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
      name = "matter";
      namespace = "matter";
      labels.app = "matter";
    };
    spec = {
      selector.matchLabels.app = "matter";
      replicas = 1;
      # "security-opt apparmor=unconfined"
      template = {
        metadata.labels.app = "matter";
        spec = {
          hostNetwork = true;
          dnsPolicy = "ClusterFirstWithHostNet";
          containers = [{
            name = "matter";
            image = "ghcr.io/matter-js/python-matter-server:stable"; # Also update services.k3s.images!
            volumeMounts = [{ name = "data-volume"; mountPath = "/data"; }];
          }];
          volumes = [{ name = "data-volume"; persistentVolumeClaim.claimName = "matter-pvc"; }];
        };
      };
    };
  }
]
