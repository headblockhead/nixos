{ grafanaAlias, config, ... }:
{

  environment.persistence."/persist".directories = [
    {
      directory = config.services.grafana.dataDir;
      user = config.users.users.grafana.name;
      group = config.users.users.grafana.group;
      mode = "750";
    }
  ];

  environment.etc."grafana-dashboards/grafana-node-exporter.json".source =
    ./grafana-node-exporter.json;

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3210;
        enforce_domain = true;
        enable_gzip = true;
        domain = grafanaAlias;
      };
      security.secret_key = "c9236cc56b0e16a172c2a294553afa12";
      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;

      dashboards.settings.providers = [
        {
          name = "NixOS dashboards";
          disableDeletion = true;
          options = {
            path = "/etc/grafana-dashboards";
            foldersFromFilesStructure = true;
          };
        }
      ];

      datasources.settings.datasources = [
        {
          name = "Prometheus (HA)";
          type = "prometheus";
          url = "http://172.27.30.100:9090";
          isDefault = true;
          editable = false;
        }
      ];

      # datasources.settings.deleteDatasources = [ { name = "foo"; orgId = 1; } { name = "bar"; orgId = 1; } ];
    };
  };
}
