{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    ethtool
  ];

  # Allow packet forwarding
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = false; # when ISP will support it, this can be enabled.
  };

  # Assign custom interface names based on MAC addresses.
  systemd.network.links."10-lan0" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:85";
    linkConfig.Name = "lan0";
  };
  systemd.network.links."10-lan1" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:86";
    linkConfig.Name = "lan1";
  };
  systemd.network.links."10-srv" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:87";
    linkConfig.Name = "srv";
  };
  systemd.network.links."10-inf" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:88";
    linkConfig.Name = "inf";
  };
  systemd.network.links."10-wan" = {
    matchConfig.PermanentMACAddress = "20:7c:14:f7:5c:89";
    linkConfig.Name = "wan";
  };

  networking = {
    enableIPv6 = false;
    domain = "lan";
    vlans = {
      inf-lan = { id = 10; interface = "inf"; };
      inf-iot = { id = 20; interface = "inf"; };
      inf-gst = { id = 30; interface = "inf"; };
    };
    bridges = {
      brlan = {
        interfaces = [ "lan0" "lan1" "inf-lan" ];
      };
    };
    interfaces = {
      wan = {
        useDHCP = true; # boring
      };
      inf = {
        ipv4.addresses = [{ address = "172.27.0.1"; prefixLength = 24; }];
      };
      brlan = {
        ipv4.addresses = [{ address = "172.27.1.1"; prefixLength = 24; }];
      };
      inf-iot = {
        ipv4.addresses = [{ address = "172.27.2.1"; prefixLength = 24; }];
      };
      srv = {
        ipv4.addresses = [{ address = "172.27.3.1"; prefixLength = 24; }];
      };
      inf-gst = {
        ipv4.addresses = [{ address = "172.27.4.1"; prefixLength = 24; }];
      };
    };
    nat = {
      enable = true;
      enableIPv6 = false;
      internalInterfaces = [
        "inf"
        "brlan"
        "inf-iot"
        "srv"
        "inf-gst"
      ];
      externalInterface = "wan";
    };
    nftables = {
      enable = true;
      flushRuleset = true;
    };
    firewall = {
      logRefusedConnections = true;
      logRefusedPackets = true;
      logReversePathDrops = true;
      rejectPackets = true;
      trustedInterfaces = [ "brlan" ]; # Allow all input from LAN
      interfaces = {
        "wan" = {
          allowedTCPPorts = [ 22 ];
          allowedUDPPorts = [ ];
        };
        "inf-iot" = {
          allowedTCPPorts = [ 53 1704 ];
          allowedUDPPorts = [ 53 67 5353 ];
        };
        "srv" = {
          allowedTCPPorts = [ 53 1705 4317 ];
          allowedUDPPorts = [ 53 67 5353 ];
        };
      };
      filterForward = true;
      extraInputRules = ''
        log level info prefix "input: "
      '';
      extraForwardRules = ''
        log level info prefix "forward: "
        iifname brlan accept comment "from lan"
        oifname brlan ct state established,related accept comment "to lan, established"
        iifname inf-iot oifname srv accept comment "from iot to srv"
        iifname srv oifname inf-iot accept comment "from srv to iot"
      '';
      extraReversePathFilterRules = ''
        log level info prefix "rpf: "
      '';
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = false;
    domainName = "local";
    reflector = true;
    allowInterfaces = [
      "inf"
      "brlan"
      "inf-iot"
      "srv"
    ];
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      userServices = true;
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

  services.dnsmasq = {
    enable = true;
    settings = {
      domain-needed = true; # Don't forward DNS requests without dots/domain parts to upstream servers.
      bogus-priv = true; # If a private IP lookup fails, it will be answered with "no such domain", instead of forwarded to upstream.

      dnssec = true; # Enable DNSSEC validation.
      dnssec-check-unsigned = true; # Verify unsigned domains are not tampered with.
      # https://data.iana.org/root-anchors/root-anchors.xml
      trust-anchor = [
        ".,19036,8,2,49AAC11D7B6F6446702E54A1607371607A1A41855200FD2CE1CDDE32F24E8FB5"
        ".,20326,8,2,E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D"
        ".,38696,8,2,683D2D0ACB8C9B712A1948B27F741219298D0A450D612C483AF444A4C0FB2B16"
      ];

      no-resolv = true; # Don't read upstream servers from /etc/resolv.conf
      no-poll = true; # Don't poll /etc/resolv.conf for changes.

      server = [ "127.0.0.1#54" ]; # Use local stubby for DNS resolution.
      local = "/lan/iot/srv/gst/";
      address = [
        "/${config.networking.hostName}.inf/172.27.0.1"
        "/${config.networking.hostName}.lan/172.27.1.1"
        "/${config.networking.hostName}.iot/172.27.2.1"
        "/${config.networking.hostName}.srv/172.27.3.1"
        "/${config.networking.hostName}.gst/172.27.4.1"
      ];

      interface = [
        "inf"
        "brlan"
        "inf-iot"
        "srv"
        "inf-gst"
      ];
      bind-dynamic = true;
      no-hosts = true; # Don't obtain any hosts from /etc/hosts (this would make 'localhost' equal this machine for all clients!)

      expand-hosts = true;
      domain = [
        "inf,172.27.0.1/24"
        "lan,172.27.1.0/24"
        "iot,172.27.2.0/24"
        "srv,172.27.3.0/24"
        "gst,172.27.4.0/24"
      ];
      dhcp-range = [
        "set:inf,172.27.0.2,172.27.0.254,6h"
        "set:lan,172.27.1.2,172.27.1.254,6h"
        "set:iot,172.27.2.2,172.27.2.254,1h"
        "set:srv,172.27.3.2,172.27.3.254,1h"
        "set:gst,172.27.4.2,172.27.4.254,1h"
      ];
      # Set custom hostnames based on MAC addresses.
      dhcp-host = [
        # inf
        "28:70:4e:8b:98:91,172.27.0.5,u7-pro-01"
        # lan
        "a0:d3:65:bb:f8:ff,172.27.1.10,edward-desktop-01"
        "34:02:86:2b:84:c3,172.27.1.11,edward-laptop-01"
        "be:d4:81:34:98:3d,172.27.1.12,edward-iphone"
        "26:08:b6:4d:79:2c,172.27.1.13,edward-mac-mini"
        # iot
        "74:83:c2:3c:9f:6e,172.27.2.2,skynet"
        "a8:13:74:17:b6:18,172.27.2.101,hesketh-tv"
        "4c:b9:ea:5a:4f:03,172.27.2.102,scuttlebug"
        "4c:b9:ea:58:81:22,172.27.2.103,sentinel"
        "0c:fe:45:1d:e6:66,172.27.2.104,ps4"
        "00:0b:81:87:e5:5f,172.27.2.105,officepi"
        "48:e7:29:18:6f:b0,172.27.2.106,charlie-charger"
        "30:c9:22:19:70:14,172.27.2.107,octo-cadlite"
        "48:e1:e9:9f:32:e6,172.27.2.108,meross-bedroom-lamp"
        "48:e1:e9:2d:c9:76,172.27.2.109,meross-printer-lamp"
        "48:e1:e9:2d:c9:70,172.27.2.110,meross-printer-power"
        "ec:64:c9:e9:97:9a,172.27.2.111,prusa-mk4"
        "24:78:23:01:57:b1,172.27.2.112,panasonic-bluray"
        "b8:27:eb:32:39:3b,172.27.2.113,livingroompi"
        # srv
        "2c:cf:67:94:37:82,172.27.3.51,rpi5-01"
        "2c:cf:67:94:38:23,172.27.3.52,rpi5-02"
        "d8:3a:dd:97:a9:c4,172.27.3.53,rpi5-03"
        "dc:a6:32:31:50:3b,172.27.3.41,rpi4-01"
        "e4:5f:01:11:a6:8e,172.27.3.42,rpi4-02"
      ];
      # We are the only DHCP server on the network.
      dhcp-authoritative = true;
      log-queries = true;
      log-dhcp = true;
    };
  };

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
  };
}
