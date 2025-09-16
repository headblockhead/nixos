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
