{ config, ... }:
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
      config.services.k3s.package.airgap-images
    ];
    tokenFile = config.age.secrets.k3s-token.path;
    gracefulNodeShutdown.enable = true;
    serverAddr = "https://172.27.3.100:6443";
    role = "server";
    extraFlags = [
      "--tls-san=172.27.3.100"
      "--embedded-registry"
    ];
  };
}
