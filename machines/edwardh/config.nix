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
  # TODO: make this a flake input, see https://nixos-mailserver.readthedocs.io/en/latest/flakes.html
  imports = [
    (builtins.fetchTarball {
      # main as of 2026-05-06
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/e33fbde199eaad513ef5d0746db19d5878150232/nixos-mailserver-e33fbde199eaad513ef5d0746db19d5878150232.tar.gz";
      sha256 = "0x73hf947cky34104cfqdaqpxykvcqhykvvg1jz6wrpfakvx4ghn";
    })
  ];

  networking.domain = "dev";

  networking.firewall.interfaces.ens5 = {
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS

      53 # DNS
      22 # SSH
    ];
    allowedUDPPorts = [
      # QUIC
      80 # HTTP
      443 # HTTPS

      53 # DNS
    ];
  };

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
    };
  };

  age.secrets.mail-hashed-password.file = ../../secrets/mail-hashed-password.age;
  age.secrets.radicale-htpasswd = {
    file = ../../secrets/radicale-htpasswd.age;
    owner = "radicale";
    group = "radicale";
    mode = "400";
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
          2025122401 	; Serial, MUST be updated every change
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
        _atproto 600 IN TXT "did=did:plc:hmxed7odvvlp2xvoc7n52fqn"
      '';
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@edwardh.dev";

  services.nginx = {
    enable = true;
    appendHttpConfig = ''
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
      "calendar.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:5232";
          extraConfig = ''
            add_header Alt-Svc 'h3=":443"; ma=86400';
          '';
        };
        serverAliases = [ "contacts.edwardh.dev" ];
      };
    };
  };
}
