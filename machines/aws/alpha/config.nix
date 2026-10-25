{
  config,
  pkgs,
  inputs,
  reverseDomainName,
  ...
}:
let
  mailboxMappings = import ./mailbox-mappings.nix;
  mailboxList = builtins.map (m: m.mailbox) mailboxMappings;
  autoScript = builtins.concatStringsSep "\n" (
    builtins.map (m: ''
      if address :is ["to", "cc"] "${m.address}" {
        fileinto "${m.mailbox}";
        stop;
      }'') mailboxMappings
  );
in
{
  imports = [
    inputs.agenix.nixosModules.age
    inputs.nixos-mailserver.nixosModules.default
  ];

  networking.domain = "dev";

  networking.firewall.interfaces.ens5 = {
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS

      53 # DNS
      22 # SSH for Knot
      26 # SSH for me
    ];
    allowedUDPPorts = [
      # QUIC
      80 # HTTP
      443 # HTTPS

      53 # DNS

      51820 # WireGuard
    ];
  };

  environment.etc."fail2ban/filter.d/nginx-scraping.conf".text = ''
    [Definition]
    failregex = ^.*?<HOST> - \S+ \[[^\]]+\] "(?:GET|POST|HEAD) [^"]*" (?:403|404) 
    ignoreregex =
  '';
  services.fail2ban = {
    enable = true;
    bantime = "8h";

    bantime-increment = {
      enable = true;
      rndtime = "30m";
      maxtime = "168h";
    };
    jails = {
      sshd.settings = {
        enabled = true;
        mode = "aggressive";
      };
      dovecot.settings = {
        enabled = true;
        mode = "aggressive";
      };
      postfix.settings = {
        enabled = true;
        mode = "aggressive";
      };
      nginx-bot.settings = {
        enabled = true;
      };
      nginx-scraping.settings = {
        enabled = true;
        filter = "nginx-scraping";
        backend = "systemd";
        journalmatch = "_SYSTEMD_UNIT=nginx.service";
        port = "http,https";
        maxretry = 30;
        findtime = 60;
        bantime = 3600;
      };
    };
  };

  age.secrets.mail.file = "${inputs.self.outPath}/secrets/${reverseDomainName}.mail.age";
  age.secrets.radicale = {
    file = "${inputs.self.outPath}/secrets/${reverseDomainName}.radicale.age";
    owner = "radicale";
    group = "radicale";
    mode = "400";
  };
  age.secrets.wg.file = "${inputs.self.outPath}/secrets/${reverseDomainName}.wg.age";

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg = {
        privateKeyFile = config.age.secrets.wg.path;
        listenPort = 51820;
        ips = [
          "172.27.100.91/24"
          "fdae:a100:5f6a:100::91/64"
        ];
        peers = [
          {
            name = "gateway-alpha";
            publicKey = "r7b+VwJA6xi9KcyjzrVrF30Zx0PBU1+/5xozZ+BHLVA=";
            allowedIPs = [
              "172.27.0.0/16"
              "fdae:a100:5f6a::/48"
            ];
          }
        ];
      };
    };
  };
  networking.nat = {
    enable = true;
    externalInterface = "ens5";
    internalInterfaces = [ "wg" ];
    forwardPorts = [
      {
        destination = "172.27.30.51:22";
        proto = "tcp";
        sourcePort = 22;
      }
      {
        destination = "172.27.30.52:8776";
        proto = "tcp";
        sourcePort = 8776;
      }
    ];
    extraCommands = ''
      iptables -t nat -A POSTROUTING -d 172.27.30.51 -p tcp --dport 22 -j MASQUERADE
      iptables -t nat -A POSTROUTING -d 172.27.30.52 -p tcp --dport 8776 -j MASQUERADE
    '';
  };

  # Avoid trying to use our own non-recursive BIND service.
  networking.resolvconf.useLocalResolver = false;

  mailserver = {
    enable = true;
    stateVersion = 3;
    localDnsResolver = false;

    fullTextSearch = {
      enable = true;
      autoIndex = true;
      fallback = false;
    };

    fqdn = "mail.edwardh.dev";
    sendingFqdn = "edwardh.dev";
    domains = [ "edwardh.dev" ];

    accounts = {
      "inbox@edwardh.dev" = {
        # mkpasswd -sm bcrypt
        hashedPasswordFile = config.age.secrets.mail.path;
        aliases = [ "@edwardh.dev" ];
        sieveScript = builtins.concatStringsSep "\n" [
          (builtins.readFile ./mail.sieve)
          autoScript
        ];
      };
    };

    mailboxes = {
      # Special mailboxes
      Drafts = {
        auto = "subscribe";
        special_use = "\\Drafts";
      };
      Junk = {
        auto = "subscribe";
        fts_autoindex = false;
        special_use = "\\Junk";
      };
      Sent = {
        auto = "subscribe";
        special_use = "\\Sent";
      };
      Trash = {
        auto = "subscribe";
        special_use = "\\Trash";
      };
      Archives = {
        auto = "subscribe";
        special_use = "\\Archive";
      };

      # non-auto-sorted mailboxes
      "Shipping and Recipts" = {
        auto = "subscribe";
      };
      "School" = {
        auto = "subscribe";
      };
      "Performances" = {
        auto = "subscribe";
      };
      "Music" = {
        auto = "subscribe";
      };
    }
    // builtins.listToAttrs (
      builtins.map (m: {
        name = m;
        value = {
          auto = "subscribe";
        };
      }) mailboxList
    );

    x509.useACMEHost = "mail.edwardh.dev";
  };

  services.roundcube = {
    # Temporarily disabled due to CVE-2026-109618 and CVE-2026-109619.
    enable = false;
    # Web interface accessible from hostName.
    hostName = "mail.edwardh.dev";
    extraConfig = ''
      $config['imap_host'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "127.0.0.1:5232" ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale.path;
        htpasswd_encryption = "bcrypt";
      };
    };
  };

  services.bind = {
    enable = true;
    ipv4Only = true;
    extraOptions = ''
      recursion no;
      allow-transfer { none; };
    '';
    zones."edwardh.dev" = {
      master = true;
      allowQuery = [ "any" ];
      file = pkgs.writeText "edwardh.dev.zone" ''
        $TTL 86400

        edwardh.dev. IN SOA ns.edwardh.dev. admin.edwardh.dev. (
          2026102503 	; Serial, MUST be updated every change
          1800        ; Refresh period
          900         ; Retry period
          604800      ; Expire time
          300         ; Negative Cache TTL
        )

        edwardh.dev.          600   IN NS     ns.edwardh.dev.
        ns                    600   IN A      18.135.222.143
        alpha                 600   IN A      18.135.222.143

        edwardh.dev.          600   IN A      18.135.222.143
        calendar              600   IN A      18.135.222.143
        contacts              600   IN A      18.135.222.143
        knot                  600   IN A      18.135.222.143
        tangled               600   IN A      18.135.222.143
        pds                   600   IN A      18.135.222.143
        seed                  600   IN A      18.135.222.143
        radicle               600   IN A      18.135.222.143
        mail                  600   IN A      18.135.222.143

        seed._radicle-node._tcp   3600  IN  SRV  32767 32767 8776 seed.edwardh.dev.
        seed._radicle-node._tcp   3600  IN  TXT  "nid=z6MkjNAKEmva2qnGWGGWJXuV46pwYHS3FF2t7mTubb9AoHVg"
        _radicle-node._tcp        3600  IN  PTR  seed._radicle-node._tcp.edwardh.dev.

        edwardh.dev.          600   IN MX  10 mail.edwardh.dev.

        edwardh.dev.          10800 IN TXT    "v=spf1 a:mail.edwardh.dev -all"
        mail._domainkey       10800 IN TXT    "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCqdWWB1LMiqpeNve6nTiYSQDtMcTw8KzNESEomkTvsWstjjRA2IQC7oGeW8yMqeCFniKx+TJ1QyH8UTktUvm/XPv0mSSzR4mjYGpY6sSiRB7z57CGtpcV4Tsi5Oz7NNOGt/vm3fZbi7xLQHfIpFrjdBtIbYFfc1LrQOWzceTt+VQIDAQAB"
        _dmarc                10800 IN TXT    "v=DMARC1; p=quarantine"

        _atproto              600   IN TXT    "did=did:plc:gbe2ojtpy3f2er6h246kk266"

        resend._domainkey.pds 10800 IN TXT    "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDIfnw0joWP/+M0ZmcdRfNETGkOnuY6UuM3aH4IVhi1CaOwVkv02cfCWnG/KvLujM7FGfKMM+YJZ7ccE93cXUy7XVqqWhfRsACwEGlz0CuITAODK8zZKTTbTIpQXVG0N/qRjcgS7Co53kPDneZ77yg/jP00AXqbPAQGESFrchGsUQIDAQAB"
        rsend.pds             600   IN CNAME  rsend-euw1.forge.rmta.net.
        send.pds              600   IN CNAME  send.forge.rmta.net.
        resend._domainkey.tangled 10800 IN TXT    "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCzQwaX7E5h7P5VLIRkyavmfmCLqiaJhAGschJ8KPMPYd2gemuWskfMjDzg5IIcH0NhQXGDIE/YvwaXp+sKAWbWWz7bQHPcJkK6cxv1PMWR4ZZf0HbpXjzVeMyUy4KpzcycEwbhiMfbp/uzD+xeGg2Q+QOCt67KGrtRMeMS7UzC1QIDAQAB"
        rsend.tangled         600   IN CNAME  rsend-euw1.forge.rmta.net.
        send.tangled          600   IN CNAME  send.forge.rmta.net.
      '';
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@edwardh.dev";

  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      error_log stderr;
      access_log syslog:server=unix:/dev/log combined;

      map $sent_http_content_type $expires {
        default                    off;
        text/html                  epoch;
        text/css                   1h;
      }
    '';
    virtualHosts = {
      "edwardh.dev" = {
        default = true;

        addSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;

        locations."/" = {
          root = inputs.edwardh-dev.packages.edwardh-dev;
          extraConfig = ''
            gzip on;
            gzip_types text/html text/css;
            etag on;
            expires $expires;
            add_header Alt-Svc 'h3=":443"; ma=86400';
          '';
        };
      };
      "mail.edwardh.dev" = {
        # temporary placeholder whilst roundcube is vulnerable, see above
        forceSSL = true;
        enableACME = true;
      };
      "calendar.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:5232";
        };
        serverAliases = [ "contacts.edwardh.dev" ];
      };
      "knot.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://172.27.30.51:5555";
        };
      };
      "tangled.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://172.27.30.51:3010";
        };
      };
      "pds.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://172.27.30.51:3000";
        };
      };
      "seed.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://172.27.30.52:3015";
        };
      };
      "radicle.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;

        quic = true;
        http3 = true;

        locations."/" = {
          root = pkgs.radicle-explorer.withConfig {
            preferredSeeds = [
              {
                hostname = "seed.edwardh.dev";
                port = 443;
                scheme = "https";
              }
            ];
          };
          extraConfig = ''
            gzip on;
            gzip_types text/html text/css;
            add_header Alt-Svc 'h3=":443"; ma=86400';
            try_files $uri /index.html;
          '';
        };
      };
    };
  };
}
