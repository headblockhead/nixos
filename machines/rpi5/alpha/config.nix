{ config, ... }: {
  networking.firewall.allowedTCPPorts = [
    config.services.radicle.node.listenPort # Radicle p2p
    config.services.radicle.httpd.listenPort # Radicle JSON API

    config.services.prometheus.port # Prometheus
    config.services.prometheus.exporters.node.port # Node Exporter
    config.services.grafana.settings.server.http_port # Grafana

    22 # Knot
    5555 # Knot
    3000 # PDS
  ];
}
