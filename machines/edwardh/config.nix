{ config, inputs, ... }:
let
  mailboxMappings = import ./mailbox-mappings.nix;
  mailboxList = builtins.map (m: m.mailbox) mailboxMappings;
  autoScript = builtins.concatStringsSep "\n" (builtins.map
    (m: ''
      if address :is ["to, "cc"] "${m.address}" {
        fileinto "${m.mailbox}";
        stop;
      }'')
    mailboxMappings);
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
      822 # railreader
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
        sieveScript =
          builtins.concatStringsSep "\n" [ (builtins.readFile ./mail.sieve) autoScript ];
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
      "Shipping and Recipts" = { auto = "subscribe"; };
      "School" = { auto = "subscribe"; };
      "Performances" = { auto = "subscribe"; };
      "Music" = { auto = "subscribe"; };
    } // builtins.listToAttrs
      (builtins.map
        (m: { name = m; value = { auto = "subscribe"; }; })
        mailboxList);

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
      version "not currently available";
    '';
    zones."edwardh.dev" = {
      master = true;
      file = ./db.edwardh.dev;
      allowQuery = [ "any" ];
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
    appendConfig = ''
      stream {
        upstream railreader {
          server 172.27.3.51:64022;
        }
        server {
          listen 822;
          proxy_pass railreader;
        }
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
      # Local services
      "cache.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://172.27.3.51:8501"; # rpi5-01
          extraConfig = ''
            add_header Alt-Svc 'h3=":443"; ma=86400';
            proxy_read_timeout 300;
          '';
        };
      };
      "lcd.edwardh.dev" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://172.27.3.42:8019"; # rpi4-02
        };
      };
      "grafana.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://172.27.3.1:3000"; # gateway
          extraConfig = ''
            gzip on;
            gzip_types text/html text/css;
            etag on;
            add_header Alt-Svc 'h3=":443"; ma=86400';
          '';
        };
      };
      "hass.edwardh.dev" = {
        forceSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://172.27.3.41:8123"; # rpi4-01
          proxyWebsockets = true;
          extraConfig = ''
            gzip on;
            gzip_types text/html text/css;
            etag on;
            add_header Alt-Svc 'h3=":443"; ma=86400';
          '';
        };
      };
    };
  };
}
