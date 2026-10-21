{ ... }: {
  networking.firewall.allowedTCPPorts = [
    22 # Knot
    5555 # Knot
    3010 # Tangled
    3000 # PDS
  ];
}
