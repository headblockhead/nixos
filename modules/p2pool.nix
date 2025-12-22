{ pkgs, ... }:
{
  services.monero = {
    enable = true;
    dataDir = "/var/lib/monero";
    priorityNodes = [
      "nodes.hashvault.pro:18080"
      "p2pmd.xmrvsbeast.com:18080"
    ];
    limits = {
      # 1048576 kB/s = 1GB/s
      # 10485760 kB/s = 10GB/s
      upload = 10485760;
      download = 10485760;
    };
    extraConfig = '' 
      out-peers=64              # Faster sync
      in-peers=1024             # Default is unlimited, but we limit it to 1024
      zmq-pub=tcp://127.0.0.1:18084
    '';
  };
  environment.systemPackages = with pkgs; [
    monero-cli
    p2pool
  ];
  systemd.services.monero.wants = [ "network-online.target" ];
  systemd.services.monero.after = [ "network-online.target" ];
  systemd.services.p2pool = {
    description = "Decentralized pool for Monero mining";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.unstable.p2pool}/bin/p2pool --mini --host 127.0.0.1 --rpc-port 18081 --zmq-port 18084 --wallet 48pEZBjqjNRCbVptEMGRdeYeUgmXaHbz7gLErTneJnN8Uc5r2qHyEPoGmS1NSmQqaK5hUjZUvRG24jBNRKjA51qbDkWM1oX --stratum 172.16.0.0:3333 --p2p 127.0.0.1:37889";
      Restart = "always";
      RestartSec = 10;
    };
  };
}
