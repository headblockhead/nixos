{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.age
    inputs.tangled.nixosModules.appview
  ];

  age.secrets.tangled-appview.file = "${inputs.self.outPath}/secrets/tangled-appview.age";

  services.tangled.appview = {
    enable = true;
    port = 3010;
    listenAddr = "0.0.0.0:3010";
    appviewHost = "tangled.edwardh.dev";
    appviewName = "tangled.edwardh.dev";
    pds.host = "https://pds.edwardh.dev";
    # sets TANGLED_COOKIE_SECRET, TANGLED_OAUTH_CLIENT_SECRET.
    environmentFile = config.age.secrets.tangled-appview.path;
  };
  systemd.services.appview.environment = {
    TANGLED_OAUTH_CLIENT_KID = "31d6be32871d716e51b5fb55cd63d105fec1b30e0cf5cdc2b6f6edd441b2a4ab";
  };
}
