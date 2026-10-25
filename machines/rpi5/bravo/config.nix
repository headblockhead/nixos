{ ... }: {
  networking.firewall.allowedTCPPorts = [
    8776 # Radicle p2p
    3015 # Radicle JSON API
  ];
}
