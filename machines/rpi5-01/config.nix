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
    "pcie_port_pm=off"
    "nvme_core.default_ps_max_latency_us=0"
    "initcall_blacklist=bcm2835_wdt_driver_init"
  ];
}
