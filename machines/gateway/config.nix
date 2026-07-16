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
    bridges = {
      brlan = {
        interfaces = [
          "ethernet1"
          "ethernet2"
          "ethernet3"
          "ethernet4"
        ];
      };
    };
    defaultGateway = "10.42.0.1";
    interfaces = {
      ethernet1.useDHCP = false;
      ethernet2.useDHCP = false;
      ethernet3.useDHCP = false;
      ethernet4.useDHCP = false;
      ethernet5.useDHCP = true;
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
    };
    nat = {
      enable = true;
      enableIPv6 = true;
      internalInterfaces = [
        "brlan"
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
      };
    };
  };

  services.radvd = {
    enable = true;
    config = ''
      interface brlan {
        AdvSendAdvert on;
        prefix fdae:a100:5f6a:10::/64 { };
      };
    '';
  };

  services.bind = {
    enable = true;
    # When ISP gets ipv6, enable this!
    ipv4Only = true;
    cacheNetworks = [
      # Allow recursive queries from self
      "127.0.0.0/24"
      "::1/128"
      # Allow recursive queries from LAN devices
      "172.27.0.0/16"
    ];
    zones."lan" = {
      master = true;
      allowQuery = [
        "127.0.0.0/24"
        "::1/128"
        "172.27.0.0/16"
      ];
      file = pkgs.writeText "lan.zone" ''
        $TTL 3600

        lan. IN SOA ns.lan. admin.lan. (
          2026071601 	; Serial, MUST be updated every change
          86400       ; Refresh period
          86400       ; Retry period
          86400       ; Expire time
          86400       ; Negative Cache TTL
        )

        lan. IN NS ns.lan.
        ns IN A 172.27.10.1

        gateway IN A 172.27.10.1

        avaya-setup IN A 172.27.10.1
        asterisk IN A 172.27.10.1
      '';
    };
  };

  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        interfaces-config.interfaces = [
          "brlan"
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
                hostname = "edward-laptop-01";
                hw-address = "34:02:86:2b:84:c3";
                ip-address = "172.27.10.11";
              }
              {
                hostname = "phone";
                hw-address = "00:1b:4f:58:7f:cb";
                ip-address = "172.27.10.10";
                option-data = [
                  {
                    name = "avaya";
                    # Commas must be escaped by a double backslash ('\\') in kea.
                    data = "SIG=2\\,HTTPSRVR=avaya-setup.lan\\,HTTPPORT=8072";
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };

  services.asterisk = {
    enable = true;
    confFiles = {
      "extensions.conf" = ''
        [from-internal]
        exten => 2582,1,Dial(PJSIP/2582,20)

        exten => _X.,1,NoOp(Bridging TCP device to UDP Server)
        same => n,Dial(PJSIP/udp-server-trunk/sip:''${EXTEN}@sip.emf.camp:5060)
        same => n,Hangup()

        exten => 0000,1,Answer()
        same  =>      n,Wait(2)
        same  =>      n,Playback(hello-world)
        same  =>      n,Wait(2)
        same  =>      n,Playback(goodbye)
        same  =>      n,Hangup()
      '';
      "pjsip.conf" = ''
        [transport-udp]
        type=transport
        protocol=udp
        bind=0.0.0.0:5060

        [transport-tcp]
        type=transport
        protocol=tcp
        bind=0.0.0.0:5060

        [2582]
        type=endpoint
        transport=transport-tcp
        context=from-internal
        disallow=all
        allow=g722,alaw
        aors=2582
        auth=2582

        [2582]
        type=aor
        max_contacts=1

        [2582]
        type=auth
        auth_type=userpass
        password=2582
        username=2582

        [udp-server-trunk]
        type=endpoint
        transport=transport-udp
        outbound_auth=udp-server-auth
        aors=udp-server-trunk
        disallow=all
        allow=g722,alaw
        context=from-internal
        from_domain=sip.emf.camp
        from_user=2582 

        [udp-server-trunk]
        type=aor
        contact=sip:sip.emf.camp:5060

        [udp-server-auth]
        type=auth
        auth_type=userpass
        username=2582
        password=1234123412341234

        [udp-server-reg]
        type=registration
        transport=transport-udp
        outbound_auth=udp-server-auth
        server_uri=sip:sip.emf.camp:5060
        client_uri=sip:2582@sip.emf.camp:5060
        contact_user=2582
        retry_interval=60

        [udp-server-identify]
        type=identify
        endpoint=udp-server-trunk
        match=sip.emf.camp
      '';
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "avaya-setup.iot" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 8072;
          }
        ];
        locations."/" = {
          root = ./avaya-http;
        };
      };
    };
  };
}
