{ pkgs, lib, config, ... }:
let
  wan_port = "enp5s0";
  lan_port = "enp6s0";
  iot_port = "enp9s0";
  srv_port = "enp1s0f0";
in
{
  age.secrets.wg0-gateway-key.file = ../../secrets/wg0-gateway-key.age;
  age.secrets.grafana-admin-password.file = ../../secrets/grafana-admin-password.age;

  # Allow packet forwarding
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = false;
  };

  networking = {
    firewall.enable = false; # replaced by nftables
    enableIPv6 = false; # TODO

    useDHCP = lib.mkDefault false; # disable DHCP client by default.
    interfaces = {
      ${wan_port} = {
        useDHCP = true; # boring
      };
      ${lan_port} = {
        useDHCP = false;
        ipv4.addresses = [{ address = "172.16.1.1"; prefixLength = 24; }];
      };
      ${iot_port} = {
        useDHCP = false;
        ipv4.addresses = [{ address = "172.16.2.1"; prefixLength = 24; }];
      };
      ${srv_port} = {
        useDHCP = false;
        ipv4.addresses = [{ address = "172.16.3.1"; prefixLength = 24; }];
      };
    };

    nftables = {
      enable = true;
      flushRuleset = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;

            iifname "lo" accept

            iifname "${lan_port}" accept

            iifname "${iot_port}" tcp dport { 53, 1704 } accept
            iifname "${iot_port}" udp dport { 53, 67, 5353 } accept
            iifname "${iot_port}" ct state { established, related } accept

            iifname "${srv_port}" tcp dport { 53, 1705, 3100, 4317 } accept
            iifname "${srv_port}" udp dport { 53, 67, 5353 } accept
            iifname "${srv_port}" ct state { established, related } accept

            iifname "wg0" tcp dport { 53 } accept
            iifname "wg0" udp dport { 53 } accept
            iifname "wg0" ct state { established, related } accept

            iifname "wg0" tcp dport { 3000, 3100 } accept

            iifname "${wan_port}" ct state { established, related } accept
            iifname "${wan_port}" icmp type { echo-request, destination-unreachable, time-exceeded } accept

            iifname "${wan_port}" udp dport mdns counter accept comment "DELETEME: allow mdns on WAN"
            iifname "${wan_port}" tcp dport 5354 counter accept comment "DELETEME: allow zeroconf"
            iifname "${wan_port}" udp dport 5354 counter accept comment "DELETEME: allow zeroconf"

            counter drop
          }
          chain forward {
            type filter hook forward priority 0; policy drop;

            iifname {"${lan_port}", "${iot_port}", "${srv_port}"} oifname "${wan_port}" accept
            iifname "${wan_port}" oifname {"${lan_port}", "${iot_port}", "${srv_port}"} ct state { established, related } accept

            iifname {"${srv_port}", "${lan_port}"} oifname "${iot_port}" accept
            iifname "${iot_port}" oifname {"${srv_port}", "${lan_port}"} ct state { established, related } accept

            iifname {"${lan_port}", "${iot_port}", "wg0" } oifname "${srv_port}" accept
            iifname "${srv_port}" oifname {"${lan_port}", "${iot_port}", "wg0" } ct state { established, related } accept

            counter drop
          }
          chain output {
            type filter hook output priority 100; policy accept;
          }
        }
        table ip nat {
          chain prerouting {
            type nat hook prerouting priority -100; policy accept;
          }
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "${wan_port}" masquerade
          }
        }
      '';
    };
  };
  services.avahi = {
    enable = true;
    domainName = "local";
    reflector = true;
    allowInterfaces = [
      lan_port
      iot_port
      srv_port
      wan_port
    ];
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      userServices = true;
    };
    nssmdns4 = true;
    hostName = "gateway";
  };
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = [ lan_port iot_port srv_port "wg0" ];
      bind-dynamic = true; # Bind only to interfaces specified above.

      domain-needed = true; # Don't forward DNS requests without dots/domain parts to upstream servers.
      bogus-priv = true; # If a private IP lookup fails, it will be answered with "no such domain", instead of forwarded to upstream.
      no-resolv = true; # Don't read upstream servers from /etc/resolv.conf
      no-hosts = true; # Don't obtain any hosts from /etc/hosts (this would make 'localhost' = this machine for all clients!)

      server = [ "127.0.0.1#54" ]; # Stubby
      domain = "lan";

      # Custom DHCP options
      dhcp-range = [
        "set:lan,172.16.1.2,172.16.1.254,1h"
        "set:iot,172.16.2.2,172.16.2.254,1h"
        "set:srv,172.16.3.2,172.16.3.254,1h"
      ];
      dhcp-option = [
        "tag:lan,option:router,172.16.1.1"
        "tag:lan,option:dns-server,172.16.1.1"
        "tag:lan,option:domain-search,lan"
        "tag:lan,option:domain-name,lan"

        "tag:iot,option:router,172.16.2.1"
        "tag:iot,option:dns-server,172.16.2.1"
        "tag:iot,option:domain-search,lan"
        "tag:iot,option:domain-name,lan"

        "tag:srv,option:router,172.16.3.1"
        "tag:srv,option:dns-server,172.16.3.1"
        "tag:srv,option:domain-search,lan"
        "tag:srv,option:domain-name,lan"
      ];

      # We are the only DHCP server on the network.
      dhcp-authoritative = true;

      address = [
        "/gateway/172.16.1.1"
        "/gateway.lan/172.16.1.1"

        "/k3s.edwardh.dev/172.16.3.100"
      ];

      # Custom static IPs and hostnames
      dhcp-host = [
        # LAN
        "28:70:4e:8b:98:91,172.16.1.2,johnconnor" # AP
        "bc:f4:d4:82:6f:a9,172.16.1.3,edward-desktop-01"
        "34:02:86:2b:84:c3,172.16.1.4,edward-laptop-01"
        "be:d4:81:34:98:3d,172.16.1.5,edward-iphone"
        # IOT
        "74:83:c2:3c:9f:6e,172.16.2.2,skynet" # AP
        "a8:13:74:17:b6:18,172.16.2.101,hesketh-tv"
        "4c:b9:ea:5a:4f:03,172.16.2.102,scuttlebug"
        "4c:b9:ea:58:81:22,172.16.2.103,sentinel"
        "0c:fe:45:1d:e6:66,172.16.2.104,ps4"
        #"dc:a6:32:31:50:3c,172.16.2.105,printerpi"
        "00:0b:81:87:e5:5f,172.16.2.106,officepi"
        "48:e7:29:18:6f:b0,172.16.2.108,charlie-charger"
        "30:c9:22:19:70:14,172.16.2.109,octo-cadlite"
        "48:e1:e9:9f:32:e6,172.16.2.110,meross-bedroom-lamp"
        "48:e1:e9:2d:c9:76,172.16.2.111,meross-printer-lamp"
        "48:e1:e9:2d:c9:70,172.16.2.112,meross-printer-power"
        "ec:64:c9:e9:97:9a,172.16.2.113,prusa-mk4"
        "24:78:23:01:57:b1,172.16.2.114,panasonic-bluray"
        # SRV
        "2c:cf:67:94:37:82,172.16.3.51,rpi5-01"
        "2c:cf:67:94:38:23,172.16.3.52,rpi5-02"
        "d8:3a:dd:97:a9:c4,172.16.3.53,rpi5-03"
        "dc:a6:32:31:50:3b,172.16.3.41,rpi4-01"
        "e4:5f:01:11:a6:8e,172.16.3.42,rpi4-02"
      ];
    };
  };

  services.stubby = {
    enable = true;
    settings = pkgs.stubby.passthru.settingsExample // {
      listen_addresses = [ "127.0.0.1@54" ];
      upstream_recursive_servers = [{
        address_data = "1.1.1.1";
        tls_auth_name = "cloudflare-dns.com";
        tls_pubkey_pinset = [{
          digest = "sha256";
          # echo | openssl s_client -connect '1.1.1.1:853' 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
          value = "SPfg6FluPIlUc6a5h313BDCxQYNGX+THTy7ig5X3+VA=";
        }];
      }
        {
          address_data = "1.0.0.1";
          tls_auth_name = "cloudflare-dns.com";
          tls_pubkey_pinset = [{
            digest = "sha256";
            value = "SPfg6FluPIlUc6a5h313BDCxQYNGX+THTy7ig5X3+VA=";
          }];
        }];
    };
  };

  services.snapserver = {
    enable = true;

    listenAddress = "172.16.2.1";
    port = 1704;

    tcp = {
      listenAddress = "172.16.3.1";
      port = 1705;
    };
    http.enable = false;

    sampleFormat = "44100:32:2";
    codec = "pcm";
    buffer = 1000;
    sendToMuted = true;

    streams = {
      "Spotify" = {
        type = "process";
        location = "${pkgs.librespot}/bin/librespot";
        query = {
          params = ''--zeroconf-port=5354 --name House --bitrate 320 --backend pipe --initial-volume 100 --quiet --format S32 --volume-ctrl fixed --device-type avr'';
        };
      };
    };
  };

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        ips = [ "172.16.10.1/24" ];
        listenPort = 51800;
        privateKeyFile = config.age.secrets.wg0-gateway-key.path;
        peers = [
          {
            name = "edwardh";
            publicKey = "JMk7o494sDBjq9EAOeeAwPHxbF6TpbpFSHGSk2DnJHU=";
            endpoint = "18.135.222.143:51800";

            allowedIPs = [ "172.16.10.2/32" ];
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "z ${config.age.secrets.grafana-admin-password.path} 400 grafana grafana - -"
  ];

  services.grafana = {
    enable = true;
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          editable = false;
          url = "http://127.0.0.1:9001";
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          editable = false;
          url = "http://127.0.0.1:3100";
        }
      ];
    };
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        root_url = "https://grafana.edwardh.dev/";
      };
      users = {
        default_language = "en-GB";
        default_theme = "system";
      };
      security = {
        disable_gravatar = true;
        admin_user = "headblockhead";
        admin_password = "$__file{${config.age.secrets.grafana-admin-password.path}}";
        cookie_secure = true;
        cookie_samesite = "strict";
        content_security_policy = true;
      };
      analytics.reporting_enabled = false;
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    globalConfig = {
      scrape_interval = "5s";
      scrape_timeout = "1s";
    };
    scrapeConfigs = [
      {
        job_name = "${config.networking.hostName}-node-exporter";
        static_configs = [{
          targets = [ "127.0.0.1:9002" ];
        }];
      }
      {
        job_name = "rpi5-01-node-exporter";
        static_configs = [{
          targets = [ "172.16.3.51:9002" ];
        }];
      }
      {
        job_name = "rpi5-02-node-exporter";
        static_configs = [{
          targets = [ "172.16.3.52:9002" ];
        }];
      }
      {
        job_name = "rpi5-03-node-exporter";
        static_configs = [{
          targets = [ "172.16.3.53:9002" ];
        }];
      }
      {
        job_name = "rpi4-01-node-exporter";
        static_configs = [{
          targets = [ "172.16.3.41:9002" ];
        }];
      }
      {
        job_name = "rpi4-02-node-exporter";
        static_configs = [{
          targets = [ "172.16.3.42:9002" ];
        }];
      }
      {
        job_name = "edwardh-node-exporter";
        static_configs = [{
          targets = [ "172.16.10.2:9002" ];
        }];
      }
    ];
  };

  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 3100;
      auth_enabled = false;
      common = {
        replication_factor = 1;
        path_prefix = "/tmp/loki";
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
      };
      schema_config = {
        configs = [{
          from = "2020-10-24";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };
      storage_config.filesystem = {
        directory = "/tmp/loki/chunks";
      };
    };
  };
}
