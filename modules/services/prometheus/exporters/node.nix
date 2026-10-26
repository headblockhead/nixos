{ ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9000;
    enabledCollectors = [
      "ethtool"
      "systemd"
      "tcpstat"
      "swap"
    ];
  };
}
