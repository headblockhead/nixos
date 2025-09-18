{ pkgs, lib, ... }:
{
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.settings.KbdInteractiveAuthentication = lib.mkForce true;
  security.pam.services.sshd.makeHomeDir = true;
  # evil, horrifying hack
  systemd.tmpfiles.rules = [
    "L /bin/bash - - - - /run/current-system/sw/bin/bash"
  ];

  security.sudo.wheelNeedsPassword = false;

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      workstation = true;
    };
  };

  security = {
    krb5 = {
      enable = true;
      settings = {
        libdefaults = {
          udp_preference_limit = 0;
          default_realm = "BRIDGE.ENTERPRISE";
        };
      };
    };

    pam = {
      makeHomeDir.umask = "077";
      services.login.makeHomeDir = true;
    };

    sudo = {
      extraConfig = ''
        %domain\ admins ALL=(ALL:ALL) NOPASSWD: ALL
        Defaults:%domain\ admins env_keep+=TERMINFO_DIRS
        Defaults:%domain\ admins env_keep+=TERMINFO
      '';

      # Use extraConfig because of blank space in 'domain admins'.
      # Alternatively, you can use the GID.
      # extraRules = [
      #   { groups = [ "domain admins" ];
      #     commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; }  ]; }
      # ];
    };
  };

  #
  # Services
  #
  services = {
    nscd = {
      enable = true;
      config = ''
        server-user nscd
        enable-cache hosts yes
        positive-time-to-live hosts 0
        negative-time-to-live hosts 0
        shared hosts yes
        enable-cache passwd no
        enable-cache group no
        enable-cache netgroup no
        enable-cache services no
      '';
    };

    sssd = {
      enable = true;
      config = ''
        [sssd]
        domains = bridge.enterprise
        config_file_version = 2
        services = nss, pam

        [pam]
        offline_credentials_expiration = 365

        [domain/bridge.enterprise]
        override_shell = /run/current-system/sw/bin/zsh
        krb5_store_password_if_offline = true
        cache_credentials = true
        account_cache_expiration = 365
        entry_cache_timeout = 14400
        krb5_realm = BRIDGE.ENTERPRISE
        realmd_tags = manages-system joined-with-samba
        id_provider = ad
        fallback_homedir = /home/%u
        ad_domain = bridge.enterprise
        use_fully_qualified_names = false
        ldap_id_mapping = false
        auth_provider = ad
        access_provider = ad
        chpass_provider = ad
        ad_gpo_access_control = permissive
        enumerate = true
      '';
    };
  };

  programs.ssh = {
    # Redirect SSH connections to GitHub to port 443, to get around firewall.
    extraConfig = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
    '';
  };

  environment.systemPackages = with pkgs; [
    openldap
    adcli # Helper library and tools for Active Directory client operations
    realmd # Diagnostic command; Does not configure AD client on NixOS
    samba # Standard Windows interoperability suite of programs for Linux and Unix
  ];
}
