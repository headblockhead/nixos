{ lib, ... }:
{
  services.k3s = {
    clusterInit = true;
    serverAddr = lib.mkForce "";
  };
}
