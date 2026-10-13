{
  config,
  pkgs,
  inputs,
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
    inputs.tangled.nixosModules.knot-rs
    #inputs.tangled.nixosModules.appview
    inputs.nixos-mailserver.nixosModules.default
  ];

  networking.domain = "dev";

  networking.firewall.interfaces.ens5 = {
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS

      53 # DNS
      22 # SSH for Knot
      2941 # SSH for me
    ];
    allowedUDPPorts = [
      # QUIC
      80 # HTTP
      443 # HTTPS

      53 # DNS
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

  age.secrets.mail-hashed-password.file = ../../secrets/mail-hashed-password.age;
  age.secrets.radicale-htpasswd = {
    file = ../../secrets/radicale-htpasswd.age;
    owner = "radicale";
    group = "radicale";
    mode = "400";
  };
  age.secrets.tranquil-pds.file = ../../secrets/tranquil-pds.age;
  age.secrets.knot-rs.file = ../../secrets/knot-rs.age;
  #age.secrets.tangled-appview.file = ../../secrets/tangled-appview.age;

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
        hashedPasswordFile = config.age.secrets.mail-hashed-password.path;
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
    enable = true;
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
        htpasswd_filename = config.age.secrets.radicale-htpasswd.path;
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
          2026101301 	; Serial, MUST be updated every change
          86400       ; Refresh period
          86400       ; Retry period
          86400       ; Expire time
          86400       ; Negative Cache TTL
        )

        edwardh.dev. IN NS ns.edwardh.dev.
        ns IN A 18.135.222.143

        ; Webserver
        edwardh.dev. 600 IN A 18.135.222.143
        www 600 IN CNAME edwardh.dev.

        ; CalDAV and CardDAV
        calendar 600 IN A 18.135.222.143
        contacts 600 IN A 18.135.222.143

        ; Mailserver
        mail 10800 IN A 18.135.222.143
        edwardh.dev. 600 IN MX 10 mail.edwardh.dev.

        ; Mailserver SPF, DKIM, and DMARC
        edwardh.dev. 10800 IN TXT "v=spf1 a:mail.edwardh.dev -all"
        mail._domainkey 10800 IN TXT "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCqdWWB1LMiqpeNve6nTiYSQDtMcTw8KzNESEomkTvsWstjjRA2IQC7oGeW8yMqeCFniKx+TJ1QyH8UTktUvm/XPv0mSSzR4mjYGpY6sSiRB7z57CGtpcV4Tsi5Oz7NNOGt/vm3fZbi7xLQHfIpFrjdBtIbYFfc1LrQOWzceTt+VQIDAQAB"
        _dmarc 10800 IN TXT "v=DMARC1; p=quarantine"

        ; AT Protocol
        _atproto 600 IN TXT "did=did:plc:gbe2ojtpy3f2er6h246kk266"
        pds 600 IN A 18.135.222.143

        ; Tangled
        knot 600 IN A 18.135.222.143

        ; Resend
        resend._domainkey.pds 10800 IN TXT "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDIfnw0joWP/+M0ZmcdRfNETGkOnuY6UuM3aH4IVhi1CaOwVkv02cfCWnG/KvLujM7FGfKMM+YJZ7ccE93cXUy7XVqqWhfRsACwEGlz0CuITAODK8zZKTTbTIpQXVG0N/qRjcgS7Co53kPDneZ77yg/jP00AXqbPAQGESFrchGsUQIDAQAB"
        rsend.pds 600 IN CNAME rsend-euw1.forge.rmta.net.
        send.pds 600 IN CNAME send.forge.rmta.net.
      '';
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@edwardh.dev";

  services.openssh.ports = [ 2941 ];
  services.tangled.knot-rs = {
    enable = true;
    openFirewall = false;
    # sets KNOT_MASTER_KEY.
    environmentFile = config.age.secrets.knot-rs.path;
    settings = {
      server = {
        hostname = "knot.edwardh.dev";
        admins = [ "did:plc:gbe2ojtpy3f2er6h246kk266" ];
        listen_addr = "127.0.0.1:5555";
        ssh_listen_addr = "0.0.0.0:22";
      };
      acl.admission = "closed";
      git.object_format = "sha256";
      atproto.plc_directory = "https://plc.directory";
      repo.default_branch = "master";
      xrpc = {
        trusted_proxy_header = "x-forwarded-for";
        trusted_proxies = [ "127.0.0.1" ];
      };
      homepage.enabled = false;
    };
  };
  #  services.tangled.appview = {
  #enable = true;
  #port = 3010;
  #listenAddr = "127.0.0.1:3010";
  #appviewHost = "tangled.edwardh.dev";
  #appviewName = "tangled.edwardh.dev";
  #pds.host = "https://pds.edwardh.dev";
  ## sets TANGLED_COOKIE_SECRET and TANGLED_OAUTH_CLIENT_SECRET.
  #environmentFile = config.age.secrets.tangled-appview.path;
  #};
  #systemd.services.appview.environment.TANGLED_OAUTH_CLIENT_KID =
  #"31d6be32871d716e51b5fb55cd63d105fec1b30e0cf5cdc2b6f6edd441b2a4ab";

  services.tranquil-pds = {
    enable = true;
    database.createLocally = true;
    # sets JWT_SECRET, DPOP_SECRET, MASTER_KEY, and MAIL_SMARTHOST_PASSWORD.
    environmentFiles = [ config.age.secrets.tranquil-pds.path ];
    settings = {
      server = {
        hostname = "pds.edwardh.dev";
        host = "127.0.0.1";
        user_handle_domains = [ "edwardh.dev" ];
        invite_code_required = true;
        enable_pds_hosted_did_web = true;
        disable_account_verification_gate = true;
        trusted_proxy_count = 1;
      };
      email = {
        from_address = "tranquil@pds.edwardh.dev";
        from_name = "edwardh.dev PDS";
        smarthost = {
          host = "smtp.resend.com";
          port = 587;
          username = "resend";
          password = "_"; # Set by environmentFiles.
        };
      };
    };
  };

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
        http3_hq = true;

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
      "knot.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:5555";
        };
      };
      #      "tangled.edwardh.dev" = {
      #forceSSL = true;
      #enableACME = true;

      #locations."/" = {
      #recommendedProxySettings = true;
      #proxyWebsockets = true;
      #proxyPass = "http://127.0.0.1:3010";
      #};
      #};
      "pds.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:3000";
        };
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
    };
  };
}
