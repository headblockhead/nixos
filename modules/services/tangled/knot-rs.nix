{
  inputs,
  config,
  reverseDomainName,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.age
    inputs.tangled.nixosModules.knot-rs
  ];

  age.secrets.knot.file = "${inputs.self.outPath}/secrets/${reverseDomainName}.knot.age";

  environment.persistence."/persist".directories = [
    {
      directory = config.services.tangled.knot-rs.stateDir;
      user = config.users.users.knot.name;
      group = config.users.users.knot.group;
      mode = "755";
    }
  ];

  services.tangled.knot-rs = {
    enable = true;
    openFirewall = false;
    # sets KNOT_MASTER_KEY.
    environmentFile = config.age.secrets.knot.path;
    settings = {
      server = {
        hostname = "knot.edwardh.dev";
        admins = [ "did:plc:gbe2ojtpy3f2er6h246kk266" ];
        listen_addr = "[::]:5555";
        ssh_listen_addr = "[::]:22";
      };
      acl.admission = "closed";
      git.object_format = "sha256";
      atproto.plc_directory = "https://plc.directory";
      repo.default_branch = "master";
      xrpc = {
        trusted_proxy_header = "x-forwarded-for";
        trusted_proxies = [ "172.27.100.91" ];
      };
      homepage.enabled = false;
    };
  };
}
