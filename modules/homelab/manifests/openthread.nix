[
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "openthread";
    };
  }
  {
    apiVersion = "v1";
    kind = "PersistentVolumeClaim";
    metadata = {
      name = "openthread-pvc";
      namespace = "openthread";
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
      name = "openthread";
      namespace = "openthread";
      labels.app = "openthread";
    };
    spec = {
      selector.matchLabels.app = "openthread";
      replicas = 1;

      template = {
        metadata.labels.app = "openthread";
        spec = {
          hostNetwork = true;
          dnsPolicy = "ClusterFirstWithHostNet";
          restartPolicy = "Always";
          containers = [{
            name = "openthread";
            image = "openthread/border-router:latest"; # Also update services.k3s.images!
            env = [
              { name = "TZ"; value = "Europe/London"; }
              { name = "OT_RCP_DEVICE"; value = "spinel+hdlc+uart:///dev/ttyACM5?uart-baudrate=460800"; }
              { name = "OT_INFRA_IF"; value = "end0"; }
              { name = "OT_THREAD_IF"; value = "wpan0"; }
              { name = "OT_LOG_LEVEL"; value = "7"; }
              { name = "OT_REST_LISTEN_PORT"; value = "8981"; }
              { name = "OT_WEB_LISTEN_PORT"; value = "8980"; }
            ];
            volumeMounts = [
              { name = "ttyacm"; mountPath = "/dev/ttyACM5"; }
              { name = "tun"; mountPath = "/dev/net/tun"; }
              { name = "data"; mountPath = "/data"; }
            ];
            securityContext = {
              capabilities.add = [ "NET_ADMIN" ];
              #privileged = true;
            };
          }];
          volumes = [
            { name = "ttyacm"; hostPath.path = "/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_E072A1FB7F20-if00"; }
            { name = "tun"; hostPath.path = "/dev/net/tun"; }
            { name = "data"; persistentVolumeClaim.claimName = "openthread-pvc"; }
          ];
        };
      };
    };
  }
]
