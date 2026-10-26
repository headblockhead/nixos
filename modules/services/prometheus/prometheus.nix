{ config, ... }:
{
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/${config.services.prometheus.stateDir}";
      user = config.users.users.prometheus.name;
      group = config.users.users.prometheus.group;
      mode = "750";
    }
  ];

  services.prometheus = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9090;
    globalConfig.scrape_interval = "10s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "172.27.30.51:9000" ];
            labels.alias = "alpha.rpi5.lan";
          }
          {
            targets = [ "172.27.30.52:9000" ];
            labels.alias = "bravo.rpi5.lan";
          }
          {
            targets = [ "172.27.30.53:9000" ];
            labels.alias = "charlie.rpi5.lan";
          }
        ];
      }

    ];
  };
}
