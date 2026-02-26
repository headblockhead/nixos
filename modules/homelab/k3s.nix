{ config, pkgs, ... }:
{
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;

  boot.kernelParams = [ "cgroup_memory=1" "cgroup_enable=memory" "cgroup_enable=cpuset" ];

  networking.firewall.allowedTCPPorts = [
    6443 # k3s
    2379 # k3s etcd
    2380 # k3s etcd 
    10250 # k3s kubelet

    8123 # home assistant
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s flannel
  ];

  # jank to get longhorn working
  environment.systemPackages = [ pkgs.nfs-utils ];
  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}-initiatorhost";
  };
  systemd.services.iscsid.serviceConfig = {
    PrivateMounts = "yes";
    BindPaths = "/run/current-system/sw/bin:/bin";
  };

  # Hass 
  services.avahi.enable = true;

  # To reset:
  # umount $(df -HT | grep '/var/lib/kubelet/pods' | awk '{print $7}')
  # rm -rf /etc/rancher/{k3s,node};
  # rm -rf /var/lib/{rancher/k3s,kubelet,longhorn,etcd,cni}

  # To restart a deployment:
  # kubectl rollout restart deployment/home-assistant --namespace home-assistant

  # To delete a deployment:
  # kubectl delete pods,pvc,services --all --interactive --namespace home-assistant

  services.k3s = {
    enable = true;
    images = [
      config.services.k3s.package.airgap-images
      # nix run nixpkgs#nix-prefetch-docker -- --image-name ghcr.io/home-assistant/aarch64-homeassistant --image-tag "2026.2.3" --arch arm64
      (pkgs.dockerTools.pullImage {
        imageName = "ghcr.io/home-assistant/aarch64-homeassistant";
        imageDigest = "sha256:4219b77148517d696158bfec11e83a354b3e48d9fc6da4aef595cb0e1b85eb83";
        hash = "sha256-3MfeQTiZiuifBRSh2m+XWCLOob+55z6eVM/ToisLWww=";
        finalImageName = "ghcr.io/home-assistant/aarch64-homeassistant";
        finalImageTag = "2026.2.3";
      })
      # nix run nixpkgs#nix-prefetch-docker -- --image-name openthread/border-router --image-tag "latest" --arch arm64
      (pkgs.dockerTools.pullImage {
        imageName = "openthread/border-router";
        imageDigest = "sha256:b180c7ffd30695d7c1cdc15da494fa2bc977fc3ef72aa33012c51360a595dd8e";
        hash = "sha256-+2lWBZFppr99mmRvnkYIE4NsoGpv2m7JzbvovBO6YUs=";
        finalImageName = "openthread/border-router";
        finalImageTag = "latest";
      })
    ];
    nodeName = config.networking.hostName;
    tokenFile = config.age.secrets.k3s-token.path;
    gracefulNodeShutdown.enable = true;
    serverAddr = "https://172.27.30.100:6443";
    extraFlags = [
      "--tls-san=172.27.30.100"
      "--embedded-registry"
    ];
    manifests = {
      home-assistant.content = import ./manifests/home-assistant.nix;
      openthread.content = import ./manifests/openthread.nix;

      kyverno.source = pkgs.fetchurl {
        url = "https://github.com/kyverno/kyverno/releases/download/v1.16.3/install.yaml";
        sha256 = "sha256-zSwMqYsK8+HcFKXFQ22bp49ekGrzQVTwz3HpQtzMwLc=";
      };
      longhorn.source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/longhorn/longhorn/v1.8.1/deploy/longhorn.yaml";
        sha256 = "sha256-eYokZ3AJ1xDMjS4FsDu7V8RtXA/BzNuzuiVUqUO7jc0=";
      };
      longhorn-kyverno.content = import ./manifests/longhorn-kyverno.nix;
    };
  };
}
