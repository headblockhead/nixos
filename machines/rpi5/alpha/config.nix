{ radicleNodePort, ... }: {
  networking.firewall.allowedTCPPorts = [
    radicleNodePort # Radicle p2p
    3015 # Radicle JSON API

    22 # Knot
    5555 # Knot
    3000 # PDS
  ];
}
