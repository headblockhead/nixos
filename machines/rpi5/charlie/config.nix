{ radicleNodePort, ... }: {
  networking.firewall.allowedTCPPorts = [
    radicleNodePort # Radicle p2p
    3015 # Radicle JSON API
  ];
}
