{ ... }: {
  networking.firewall.allowedTCPPorts = [
    22 # Knot
    5555 # Knot
    3010 # Tangled
    3000 # PDS
  ];

  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0"
    "pcie_aspm=off"
    "rootwait"
    "rootdelay=5"
  ];
}
