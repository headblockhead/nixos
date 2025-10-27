{ pkgs, config, ... }:
let
  wan_port = "enp5s0";
  lan_port = "enp6s0";
  iot_port = "enp9s0";
  srv_port = "enp1s0f0";
  gst_port = "enp1s0f1";
in
{
  age.secrets.wg0-gateway-key.file = ../../secrets/wg0-gateway-key.age;

  # Allow packet forwarding
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = false; # when ISP will support it, this can be enabled.
  };

  networking = {
    enableIPv6 = true;
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
      ${gst_port} = {
        useDHCP = false;
        ipv4.addresses = [{ address = "172.16.4.1"; prefixLength = 24; }];
      };
    };
    nat = {
      enable = true;
      enableIPv6 = true;
      internalIPs = [ "172.16.0.0/16" ];
      externalInterface = wan_port;
      internalInterfaces = [ lan_port iot_port srv_port gst_port ];
    };
    firewall = {
      trustedInterfaces = [ lan_port ]; # Allow all from LAN
      interfaces = {
        wan = {
          allowedTCPPorts = [ 22 ];
        };
        iot = {
          allowedTCPPorts = [ 53 1704 ];
          allowedUDPPorts = [ 53 67 5353 ];
        };
        srv = {
          allowedTCPPorts = [ 53 1705 4317 ];
          allowedUDPPorts = [ 53 67 5353 ];
        };
        wg0 = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };
      };
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    domainName = "local";
    reflector = true;
    allowInterfaces = [
      lan_port
      iot_port
      srv_port
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
        "/${config.networking.hostName}.lan/172.16.1.1"
        "/${config.networking.hostName}.iot/172.16.2.1"
        "/${config.networking.hostName}.srv/172.16.3.1"
        "/${config.networking.hostName}.gst/172.16.4.1"
      ];

      interface = [ lan_port iot_port srv_port gst_port "wg0" ]; # Listen only on these interfaces.
      no-dhcp-interface = [ "wg0" ];
      bind-interfaces = true; # Bind only to the interfaces specified.
      no-hosts = true; # Don't obtain any hosts from /etc/hosts (this would make 'localhost' equal this machine for all clients!)

      expand-hosts = true;
      domain = [
        "lan,172.16.1.0/24"
        "iot,172.16.2.0/24"
        "srv,172.16.3.0/24"
        "gst,172.16.4.0/24"
      ];
      dhcp-range = [
        "set:lan,172.16.1.2,172.16.1.254,1h"
        "set:iot,172.16.2.2,172.16.2.254,1h"
        "set:srv,172.16.3.2,172.16.3.254,1h"
        "set:gst,172.16.4.2,172.16.4.254,1h"
      ];
      # Set custom hostnames based on MAC addresses.
      dhcp-host = [
        # lan
        "28:70:4e:8b:98:91,johnconnor"
        "a0:d3:65:bb:f8:ff,edward-desktop-01"
        "34:02:86:2b:84:c3,edward-laptop-01"
        "be:d4:81:34:98:3d,edward-iphone"
        # iot
        "74:83:c2:3c:9f:6e,skynet"
        "a8:13:74:17:b6:18,hesketh-tv"
        "4c:b9:ea:5a:4f:03,scuttlebug"
        "4c:b9:ea:58:81:22,sentinel"
        "0c:fe:45:1d:e6:66,ps4"
        "00:0b:81:87:e5:5f,officepi"
        "48:e7:29:18:6f:b0,charlie-charger"
        "30:c9:22:19:70:14,octo-cadlite"
        "48:e1:e9:9f:32:e6,meross-bedroom-lamp"
        "48:e1:e9:2d:c9:76,meross-printer-lamp"
        "48:e1:e9:2d:c9:70,meross-printer-power"
        "ec:64:c9:e9:97:9a,prusa-mk4"
        "24:78:23:01:57:b1,panasonic-bluray"
        # srv
        "2c:cf:67:94:37:82,rpi5-01"
        "2c:cf:67:94:38:23,rpi5-02"
        "d8:3a:dd:97:a9:c4,rpi5-03"
        "dc:a6:32:31:50:3b,rpi4-01"
        "e4:5f:01:11:a6:8e,rpi4-02"
      ];
      # We are the only DHCP server on the network.
      dhcp-authoritative = true;
      log-queries = false;
      log-dhcp = false;
    };
  };

  services.snapserver = {
    enable = true;

    listenAddress = "0.0.0.0"; # Snapclients can connect on any interface (where firewall allows it).
    port = 1704;

    http = {
      enable = true;
      listenAddress = "172.16.1.1"; # Only LAN devices can control the server. 
    };

    buffer = 800; # milliseconds of buffering on clients before playback.
    streamBuffer = 10; # milliseconds of buffering for reading from streams.
    codec = "pcm";
    sampleFormat = "44100:32:2";

    sendToMuted = true;

    streams = {
      "Spotify" = {
        type = "process";
        location = "${pkgs.librespot}/bin/librespot";
        query.params = ''--zeroconf-port=5354 --backend=pipe --bitrate=320 --format=S32 --volume-ctrl=fixed --initial-volume=100 --name=Snapcast --group'';
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
}
