{ config, pkgs, ... }:
{
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;

  boot.kernelParams = [ "cgroup_memory=1" "cgroup_enable=memory" "cgroup_enable=cpuset" ];

  networking.firewall.allowedTCPPorts = [
    6443 # k3s
    2379 # k3s etcd
    2380 # k3s etcd 
    10250 # k3s kubelet
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

  services.k3s = {
    enable = true;
    images = [
      config.services.k3s.package.airgap-images
      # nix run nixpkgs#nix-prefetch-docker -- --image-name ghcr.io/home-assistant/aarch64-homeassistant --image-tag "2026.1.3" --arch arm64
      (pkgs.dockerTools.pullImage {
        imageName = "ghcr.io/home-assistant/aarch64-homeassistant";
        imageDigest = "sha256:a0fcf2b00cfcfe71e108bb8d3276c05ab3ebf2950edc820185b2645fcb259acd";
        hash = "sha256-bFVs7Tuk29IiW5aGYf4TxH2VGMAT+bCzP0O2MlQ8hv0=";
        finalImageName = "ghcr.io/home-assistant/aarch64-homeassistant";
        finalImageTag = "2026.1.3";
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
