{ pkgs, ... }:
{
  # Allow packet forwarding
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  # Assign custom interface names based on MAC addresses.
  systemd.network.links."10-ethernet1" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:85";
    linkConfig.Name = "ethernet1";
  };
  systemd.network.links."10-ethernet2" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:86";
    linkConfig.Name = "ethernet2";
  };
  systemd.network.links."10-ethernet3" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:87";
    linkConfig.Name = "ethernet3";
  };
  systemd.network.links."10-ethernet4" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:88";
    linkConfig.Name = "ethernet4";
  };
  systemd.network.links."10-ethernet5" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:89";
    linkConfig.Name = "ethernet5";
  };

  networking = {
    vlans = {
      inf-lan = {
        id = 10;
        interface = "ethernet4";
      };
      inf-iot = {
        id = 20;
        interface = "ethernet4";
      };
      inf-gst = {
        id = 40;
        interface = "ethernet4";
      };
    };
    bridges = {
      brinf = {
        interfaces = [ "ethernet4" ];
      };
      brlan = {
        interfaces = [
          "ethernet1"
          "inf-lan"
        ];
      };
      briot = {
        interfaces = [
          "ethernet2"
          "inf-iot"
        ];
      };
      brsrv = {
        interfaces = [ "ethernet3" ];
      };
      brgst = {
        interfaces = [ "inf-gst" ];
      };
    };
    interfaces = {
      # Force eths to be up (required to be added to bridges).
      ethernet1.useDHCP = false;
      ethernet2.useDHCP = false;
      ethernet3.useDHCP = false;
      ethernet4.useDHCP = false;

      ethernet5 = {
        useDHCP = true; # boring
      };
      brinf = {
        ipv4.addresses = [
          {
            address = "172.27.1.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fdae:a100:5f6a:1::1";
            prefixLength = 64;
          }
        ];
      };
      brlan = {
        ipv4.addresses = [
          {
            address = "172.27.10.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fdae:a100:5f6a:10::1";
            prefixLength = 64;
          }
        ];
      };
      briot = {
        ipv4.addresses = [
          {
            address = "172.27.20.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fdae:a100:5f6a:20::1";
            prefixLength = 64;
          }
        ];
      };
      brsrv = {
        ipv4.addresses = [
          {
            address = "172.27.30.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fdae:a100:5f6a:30::1";
            prefixLength = 64;
          }
        ];
      };
      brgst = {
        ipv4.addresses = [
          {
            address = "172.27.40.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fdae:a100:5f6a:40::1";
            prefixLength = 64;
          }
        ];
      };
    };
    nat = {
      enable = true;
      enableIPv6 = true;
      # Interfaces that can access the internet.
      internalInterfaces = [
        "brinf"
        "brlan"
        "briot"
        "brsrv"
        "brgst"
      ];
      externalInterface = "ethernet5";
    };
    nftables = {
      enable = true;
      flushRuleset = true;
    };
    firewall = {
      logRefusedPackets = true;
      logReversePathDrops = true;
      logRefusedConnections = true;
      logRefusedUnicastsOnly = true;
      rejectPackets = true;

      trustedInterfaces = [ "brlan" ]; # Allow all input from LAN
      interfaces = {
        ethernet5 = {
          allowedTCPPorts = [ ];
          allowedUDPPorts = [ ];
        };
        brinf = {
          allowedTCPPorts = [
            53 # DNS
            8080 # UniFi inform
          ];
          allowedUDPPorts = [
            53 # DNS
            67 # DHCP
            5514 # UniFi syslog
          ];
        };
        briot = {
          allowedTCPPorts = [
            53 # DNS
          ];
          allowedUDPPorts = [
            53 # DNS
            67 # DHCP
            5353 # mDNS
          ];
        };
        brsrv = {
          allowedTCPPorts = [
            53 # DNS
            8081 # otbr REST
            5580 # matter-server
          ];
          allowedUDPPorts = [
            53 # DNS
            67 # DHCP
            5353 # mDNS
          ];
        };
        brgst = {
          allowedTCPPorts = [
            53 # DNS
          ];
          allowedUDPPorts = [
            53 # DNS
            67 # DHCP
          ];
        };
      };
      filterForward = true;
      extraInputRules = ''
        ip saddr 172.27.20.18 tcp dport 53 drop comment "block meross-bedroom-lamp DNS"
        ip saddr 172.27.20.18 udp dport { 53, 5353 } drop comment "block meross-bedroom-lamp DNS/MDNS"
      '';
      extraForwardRules = ''
        iifname brlan accept comment "from lan"
        oifname brlan ct state established,related accept comment "returning to lan"

        iifname briot oifname brsrv accept comment "from iot to srv"
        iifname brsrv oifname briot accept comment "from srv to iot"

        ip saddr 172.27.20.18 oifname ethernet5 drop comment "block meross-bedroom-lamp internet"
      '';
    };
  };

  services.radvd = {
    enable = true;
    config = ''
      interface brinf {
        AdvSendAdvert on;
        prefix fdae:a100:5f6a:1::/64 { };
      };
      interface brlan {
        AdvSendAdvert on;
        prefix fdae:a100:5f6a:10::/64 { };
      };
      interface briot {
        AdvSendAdvert on;
        prefix fdae:a100:5f6a:20::/64 { };
      };
      interface brsrv {
        AdvSendAdvert on;
        prefix fdae:a100:5f6a:30::/64 { };
      };
      interface brgst {
        AdvSendAdvert on;
        prefix fdae:a100:5f6a:40::/64 { };
      };
    '';
  };

  services.bind = {
    enable = true;
    cacheNetworks = [
      # Allow recursive queries from self
      "127.0.0.0/24"
      "::1/128"
      # Allow recursive queries from LAN devices
      "172.27.0.0/16"
    ];
    zones."lan" = {
      master = true;
      allowQuery = [ "any" ];
      file = pkgs.writeText "lan.zone" ''
        $TTL 3600

        lan. IN SOA ns.lan. admin.lan. (
          2026052703 	; Serial, MUST be updated every change
          86400       ; Refresh period
          86400       ; Retry period
          86400       ; Expire time
          86400       ; Negative Cache TTL
        )

        lan. IN NS ns.lan.
        ns IN A 172.27.1.1
        ns IN A 172.27.10.1
        ns IN A 172.27.20.1
        ns IN A 172.27.30.1
        ns IN A 172.27.40.1

        gateway IN A 172.27.1.1
        gateway IN A 172.27.10.1
        gateway IN A 172.27.20.1
        gateway IN A 172.27.30.1
        gateway IN A 172.27.40.1

        edward-desktop-01 IN A 172.27.10.10

        rpi5-01 IN A 172.27.30.51 
        rpi5-02 IN A 172.27.30.52 
        rpi5-03 IN A 172.27.30.53 
        rpi4-01 IN A 172.27.30.41 
        rpi4-02 IN A 172.27.30.42 

        homeassistant IN A 172.27.30.100
      '';
    };
  };

  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        interfaces-config.interfaces = [
          "brinf"
          "brlan"
          "briot"
          "brsrv"
          "brgst"
        ];
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        option-def = [
          {
            name = "avaya";
            code = 242;
            space = "dhcp4";
            type = "string";
          }
        ];
        subnet4 = [
          {
            id = 1;
            pools = [ { pool = "172.27.1.2 - 172.27.1.254"; } ];
            subnet = "172.27.1.0/24";
            option-data = [
              {
                name = "routers";
                data = "172.27.1.1";
              }
              {
                name = "domain-name-servers";
                data = "172.27.1.1";
              }
            ];
            reservations = [
              {
                hostname = "u7-pro-01";
                hw-address = "28:70:4e:8b:98:91";
                ip-address = "172.27.1.5";
              }
            ];
          }
          {
            id = 10;
            pools = [ { pool = "172.27.10.2 - 172.27.10.254"; } ];
            subnet = "172.27.10.0/24";
            option-data = [
              {
                name = "routers";
                data = "172.27.10.1";
              }
              {
                name = "domain-name-servers";
                data = "172.27.10.1";
              }
            ];
            reservations = [
              {
                hostname = "edward-desktop-01";
                hw-address = "a0:d3:65:bb:f8:ff";
                ip-address = "172.27.10.10";
              }
              {
                hostname = "edward-laptop-01";
                hw-address = "34:02:86:2b:84:c3";
                ip-address = "172.27.10.11";
              }
              {
                hostname = "edward-iphone";
                hw-address = "5a:35:ab:18:40:82";
                ip-address = "172.27.10.12";
              }
              {
                hostname = "edward-mac-mini";
                hw-address = "26:08:b6:4d:79:2c";
                ip-address = "172.27.10.13";
              }
            ];
          }
          {
            id = 20;
            pools = [ { pool = "172.27.20.2 - 172.27.20.254"; } ];
            subnet = "172.27.20.0/24";
            option-data = [
              {
                name = "routers";
                data = "172.27.20.1";
              }
              {
                name = "domain-name-servers";
                data = "172.27.20.1";
              }
            ];
            reservations = [
              {
                hostname = "hesketh-tv";
                hw-address = "a8:13:74:17:b6:18";
                ip-address = "172.27.20.11";
              }
              {
                hostname = "scuttlebug";
                hw-address = "4c:b9:ea:5a:4f:03";
                ip-address = "172.27.20.12";
              }
              {
                hostname = "sentinel";
                hw-address = "4c:b9:ea:58:81:22";
                ip-address = "172.27.20.13";
              }
              {
                hostname = "ps4";
                hw-address = "0c:fe:45:1d:e6:66";
                ip-address = "172.27.20.14";
              }
              {
                hostname = "officepi";
                hw-address = "00:0b:81:87:e5:5f";
                ip-address = "172.27.20.15";
              }
              {
                hostname = "charlie-charger";
                hw-address = "48:e7:29:18:6f:b0";
                ip-address = "172.27.20.16";
              }
              {
                hostname = "octo-cadlite";
                hw-address = "30:c9:22:19:70:14";
                ip-address = "172.27.20.17";
              }
              {
                hostname = "meross-bedroom-lamp";
                hw-address = "48:e1:e9:9f:32:e6";
                ip-address = "172.27.20.18";
              }
              {
                hostname = "meross-printer-lamp";
                hw-address = "48:e1:e9:2d:c9:76";
                ip-address = "172.27.20.19";
              }
              {
                hostname = "meross-printer-power";
                hw-address = "48:e1:e9:2d:c9:70";
                ip-address = "172.27.20.20";
              }
              {
                hostname = "prusa-mk4";
                hw-address = "ec:64:c9:e9:97:9a";
                ip-address = "172.27.20.21";
              }
              {
                hostname = "panasonic-bluray";
                hw-address = "24:78:23:01:57:b1";
                ip-address = "172.27.20.22";
              }
              {
                hostname = "edward-bedroom-phone";
                hw-address = "00:1b:4f:58:7f:cb";
                ip-address = "172.27.20.24";
                option-data = [
                  {
                    name = "avaya";
                    data = "SIG=2,HTTPSRVR=avaya-setup.iot,HTTPPORT=8072";
                  }
                ];
              }
            ];
          }
          {
            id = 30;
            pools = [ { pool = "172.27.30.2 - 172.27.30.254"; } ];
            subnet = "172.27.30.0/24";
            option-data = [
              {
                name = "routers";
                data = "172.27.30.1";
              }
              {
                name = "domain-name-servers";
                data = "172.27.30.1";
              }
            ];
            reservations = [
              {
                hostname = "rpi5-01";
                hw-address = "2c:cf:67:94:37:82";
                ip-address = "172.27.30.51";
              }
              {
                hostname = "rpi5-02";
                hw-address = "2c:cf:67:94:38:23";
                ip-address = "172.27.30.52";
              }
              {
                hostname = "rpi5-03";
                hw-address = "d8:3a:dd:97:a9:c4";
                ip-address = "172.27.30.53";
              }
              {
                hostname = "rpi4-01";
                hw-address = "dc:a6:32:31:50:3b";
                ip-address = "172.27.30.41";
              }
              {
                hostname = "rpi4-02";
                hw-address = "e4:5f:01:11:a6:8e";
                ip-address = "172.27.30.42";
              }
            ];
          }
          {
            id = 40;
            pools = [ { pool = "172.27.40.2 - 172.27.40.254"; } ];
            subnet = "172.27.40.0/24";
            option-data = [
              {
                name = "routers";
                data = "172.27.40.1";
              }
              {
                name = "domain-name-servers";
                data = "172.27.40.1";
              }
            ];
          }
        ];
      };
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    domainName = "local";
    reflector = true;
    allowInterfaces = [
      "brlan"
      "briot"
      "brsrv"
    ];
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      userServices = true;
    };
  };

  services.openthread-border-router = {
    enable = true;
    backboneInterfaces = [
      "brinf"
      "briot"
      "brsrv"
    ];
    interfaceName = "otbr";
    logLevel = "debug";
    radio = {
      device = "/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_E072A1FB7F20-if00";
      baudRate = 460800;
      flowControl = true;
    };
    rest = {
      listenAddress = "172.27.30.1";
      listenPort = 8081;
    };
  };

  services.matter-server = {
    enable = true;
    port = 5580;
    logLevel = "debug";
  };
}
