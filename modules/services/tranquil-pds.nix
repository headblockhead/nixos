{
  inputs,
  config,
  reverseDomainName,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.age
  ];

  age.secrets.tranquil.file = "${inputs.self.outPath}/secrets/${reverseDomainName}.tranquil.age";

  environment.persistence."/persist".directories = [
    config.services.postgresql.dataDir
    {
      directory = config.services.tranquil-pds.dataDir;
      user = config.users.users.tranquil-pds.name;
      group = config.users.users.tranquil-pds.group;
      mode = "755";
    }
  ];

  services.tranquil-pds = {
    enable = true;
    database.createLocally = true;
    dataDir = "/var/lib/tranquil-pds";
    # sets JWT_SECRET, DPOP_SECRET, MASTER_KEY, and MAIL_SMARTHOST_PASSWORD.
    environmentFiles = [ config.age.secrets.tranquil.path ];
    settings = {
      server = {
        hostname = "pds.edwardh.dev";
        host = "0.0.0.0";
        port = 3000;
        user_handle_domains = [ "edwardh.dev" ];
        invite_code_required = true;
        disable_account_verification_gate = true;
        trusted_proxy_count = 1;
      };
      email = {
        from_address = "noreply@pds.edwardh.dev";
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
}
