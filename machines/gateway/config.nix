{ pkgs, config, ... }:
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
      inf-lan = { id = 10; interface = "ethernet4"; };
      inf-iot = { id = 20; interface = "ethernet4"; };
      inf-gst = { id = 40; interface = "ethernet4"; };
    };
    bridges = {
      brinf = {
        interfaces = [ "ethernet4" ];
      };
      brlan = {
        interfaces = [ "ethernet1" "inf-lan" ];
      };
      briot = {
        interfaces = [ "ethernet2" "inf-iot" ];
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
        ipv4.addresses = [{ address = "172.27.1.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fdae:a100:5f6a:1::1"; prefixLength = 64; }];
      };
      brlan = {
        ipv4.addresses = [{ address = "172.27.10.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fdae:a100:5f6a:10::1"; prefixLength = 64; }];
      };
      briot = {
        ipv4.addresses = [{ address = "172.27.20.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fdae:a100:5f6a:20::1"; prefixLength = 64; }];
      };
      brsrv = {
        ipv4.addresses = [{ address = "172.27.30.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fdae:a100:5f6a:30::1"; prefixLength = 64; }];
      };
      brgst = {
        ipv4.addresses = [{ address = "172.27.40.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fdae:a100:5f6a:40::1"; prefixLength = 64; }];
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
      # Debugging options:
      # logRefusedPackets = true;
      # logReversePathDrops = true;
      # logRefusedConnections = true;
      # logRefusedUnicastsOnly = true;
      # rejectPackets = true;

      trustedInterfaces = [ "brlan" ]; # Allow all input from LAN
      interfaces = {
        ethernet5 = {
          allowedTCPPorts = [ ];
          allowedUDPPorts = [ ];
        };
        brinf = {
          allowedTCPPorts = [ 53 8080 ];
          allowedUDPPorts = [ 53 67 5514 ];
        };
        briot = {
          allowedTCPPorts = [ 53 8072 5060 ];
          allowedUDPPorts = [ 53 67 5353 ];
        };
        brsrv = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 67 5353 ];
        };
        brgst = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 67 ];
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

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
  };

  services.stubby = {
    enable = true;
    settings = pkgs.stubby.passthru.settingsExample // {
      listen_addresses = [
        "127.0.0.1@54"
      ];
      upstream_recursive_servers = [
        {
          address_data = "1.1.1.1";
          tls_auth_name = "cloudflare-dns.com";
        }
        {
          address_data = "1.0.0.1";
          tls_auth_name = "cloudflare-dns.com";
        }
      ];
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
      no-hosts = true; # Don't read /etc/hosts

      # Use our local stubby (dns over TLS) service for DNS resolution.
      server = [
        "127.0.0.1#54"
        "::1#54"
      ];

      address = [
        "/${config.networking.hostName}.inf/172.27.1.1"
        "/${config.networking.hostName}.inf/fdae:a100:5f6a:1::1"
        "/${config.networking.hostName}.lan/172.27.10.1"
        "/${config.networking.hostName}.lan/fdae:a100:5f6a:10::1"
        "/${config.networking.hostName}.iot/172.27.20.1"
        "/${config.networking.hostName}.iot/fdae:a100:5f6a:20::1"
        "/${config.networking.hostName}.srv/172.27.30.1"
        "/${config.networking.hostName}.srv/fdae:a100:5f6a:30::1"
        "/${config.networking.hostName}.gst/172.27.40.1"
        "/${config.networking.hostName}.gst/fdae:a100:5f6a:40::1"

        "/avaya-setup.iot/172.27.20.1"
        "/asterisk.iot/172.27.20.1"
      ];
      # List of interfaces to accept requests from.
      interface = [
        "brinf"
        "brlan"
        "briot"
        "brsrv"
        "brgst"
      ];
      # DNS/DHCP domains for IP ranges.
      domain = [
        "inf,172.27.1.1/24,local"
        "lan,172.27.10.0/24,local"
        "iot,172.27.20.0/24,local"
        "srv,172.27.30.0/24,local"
        "gst,172.27.40.0/24,local"
      ];
      enable-ra = true; # Advertise DNS servers via RA for SLAAC clients.
      dhcp-authoritative = true;
      # Define DHCP ranges for each network.
      dhcp-range = [
        "set:inf,172.27.1.2,172.27.1.254,6h"
        "set:inf,fdae:a100:5f6a:1::2,fdae:a100:5f6a:1:ffff:ffff:ffff:ffff,6h"
        "set:lan,172.27.10.2,172.27.10.254,6h"
        "set:lan,fdae:a100:5f6a:10::2,fdae:a100:5f6a:10:ffff:ffff:ffff:ffff,6h"
        "set:iot,172.27.20.2,172.27.20.254,1h"
        "set:iot,fdae:a100:5f6a:20::2,fdae:a100:5f6a:20:ffff:ffff:ffff:ffff,1h"
        "set:srv,172.27.30.2,172.27.30.254,1h"
        "set:srv,fdae:a100:5f6a:30::2,fdae:a100:5f6a:30:ffff:ffff:ffff:ffff,1h"
        "set:gst,172.27.40.2,172.27.40.254,1h"
        "set:gst,fdae:a100:5f6a:40::2,fdae:a100:5f6a:40:ffff:ffff:ffff:ffff,1h"
      ];
      # Set custom hostnames based on MAC addresses.
      dhcp-host = [
        # inf
        "28:70:4e:8b:98:91,172.27.1.5,u7-pro-01"
        # lan
        "a0:d3:65:bb:f8:ff,172.27.10.10,edward-desktop-01"
        "34:02:86:2b:84:c3,172.27.10.11,edward-laptop-01"
        "a2:24:22:64:89:D2,172.27.10.12,edward-iphone"
        "26:08:b6:4d:79:2c,172.27.10.13,edward-mac-mini"
        # iot
        "a8:13:74:17:b6:18,172.27.20.11,hesketh-tv"
        "4c:b9:ea:5a:4f:03,172.27.20.12,scuttlebug"
        "4c:b9:ea:58:81:22,172.27.20.13,sentinel"
        "0c:fe:45:1d:e6:66,172.27.20.14,ps4"
        "00:0b:81:87:e5:5f,172.27.20.15,officepi"
        "48:e7:29:18:6f:b0,172.27.20.16,charlie-charger"
        "30:c9:22:19:70:14,172.27.20.17,octo-cadlite"
        "48:e1:e9:9f:32:e6,172.27.20.18,meross-bedroom-lamp"
        "48:e1:e9:2d:c9:76,172.27.20.19,meross-printer-lamp"
        "48:e1:e9:2d:c9:70,172.27.20.20,meross-printer-power"
        "ec:64:c9:e9:97:9a,172.27.20.21,prusa-mk4"
        "24:78:23:01:57:b1,172.27.20.22,panasonic-bluray"
        "b8:27:eb:32:39:3b,172.27.20.23,otbr"
        "00:1b:4f:58:7f:cb,172.27.20.24,edward-bedroom-phone"
        # srv
        "2c:cf:67:94:37:82,172.27.30.51,rpi5-01"
        "2c:cf:67:94:38:23,172.27.30.52,rpi5-02"
        "d8:3a:dd:97:a9:c4,172.27.30.53,rpi5-03"
        "dc:a6:32:31:50:3b,172.27.30.41,rpi4-01"
        "e4:5f:01:11:a6:8e,172.27.30.42,rpi4-02"
      ];
      dhcp-option = [
        # Avaya 9600 phones
        "tag:iot,242,\"SIG=2,HTTPSRVR=avaya-setup.iot,HTTPPORT=8072\""
      ];
    };
  };

  services.asterisk = {
    enable = true;
    confFiles = {
      "extensions.conf" = ''
        [from-internal]
        exten => 1010,1,Dial(PJSIP/1010,20) ; edward-desktop-01
        exten => 2024,1,Dial(PJSIP/2024,20) ; edward-bedroom-phone

        ; Dial 1000 for "hello, world"
        exten => 1000,1,Answer()
        same  =>     n,Wait(2)
        same  =>     n,Playback(hello-world)
        same  =>     n,Wait(2)
        same  =>     n,Playback(goodbye)
        same  =>     n,Hangup()
      '';
      "pjsip.conf" = ''
        [transport-tcp]
        type=transport
        protocol=tcp
        bind=0.0.0.0

        [endpoint_internal](!)
        type=endpoint
        context=from-internal
        disallow=all
        allow=alaw,g722

        [auth_userpass](!)
        type=auth
        auth_type=userpass

        [aor_dynamic](!)
        type=aor
        max_contacts=1

        [1010](endpoint_internal)
        auth=1010
        aors=1010
        [1010](auth_userpass)
        password=1010
        username=1010
        [1010](aor_dynamic)

        [2024](endpoint_internal)
        auth=2024
        aors=2024
        [2024](auth_userpass)
        password=2024
        username=2024
        [2024](aor_dynamic)
      '';
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "avaya-setup.iot" = {
        listen = [
          { addr = "172.27.20.1"; port = 8072; }
        ];
        locations."/" = {
          root = ./avaya-http;
        };
      };
    };
  };
}
