{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.age
    inputs.tangled.nixosModules.knot-rs
  ];

  age.secrets.knot-rs.file = "${inputs.self.outPath}/secrets/knot-rs.age";

  environment.persistence."/persist".directories = [
    config.services.tangled.knot-rs.stateDir
  ];

  services.tangled.knot-rs = {
    enable = true;
    openFirewall = false;
    # sets KNOT_MASTER_KEY.
    environmentFile = config.age.secrets.knot-rs.path;
    settings = {
      server = {
        hostname = "knot.edwardh.dev";
        admins = [ "did:plc:gbe2ojtpy3f2er6h246kk266" ];
        listen_addr = "0.0.0.0:5555";
        ssh_listen_addr = "0.0.0.0:22";
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
