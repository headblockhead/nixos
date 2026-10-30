{
  inputs,
  lib,
  config,
  pkgs,
  radicleAlias,
  radiclePublicKey,
  reverseDomainName,
  radicleNodePort,
  ...
}:
let
  radicleRepos = import "${inputs.self.outPath}/radicle.nix";
  radiclePrefixedRepoIDs = builtins.map (id: "rad:" + id) (builtins.attrValues radicleRepos);
in
{
  imports = [
    inputs.agenix.nixosModules.age
  ];

  age.secrets.radicle.file = "${inputs.self.outPath}/secrets/${reverseDomainName}.radicle.age";

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/radicle";
      user = config.users.users.radicle.name;
      group = config.users.users.radicle.group;
      mode = "750";
    }
  ];

  services.radicle = {
    enable = true;
    httpd = {
      enable = true;
      listenAddress = "[::]";
      listenPort = 3015;
    };
    node = {
      listenAddress = "[::]";
      listenPort = radicleNodePort;
      openFirewall = false;
    };
    publicKey = radiclePublicKey;
    privateKey = config.age.secrets.radicle.path;
    checkConfig = false;
    settings = {
      web = {
        avatarUrl = "https://edwardh.dev/edward-hesketh-close.jpg";
        bannerUrl = "https://edwardh.dev/edward-hesketh.jpg";
        description = "One of Edward Hesketh's personal nodes.";
        pinned.repositories = radiclePrefixedRepoIDs;
      };
      node = {
        alias = radicleAlias;
        externalAddresses = [ "${radicleAlias}:${builtins.toString radicleNodePort}" ];
        seedingPolicy = {
          default = "block";
          scope = "all";
        };
        fetch.signedReferences.featureLevel.minimum = "parent";
      };
    };
  };

  systemd.services.radicle-seed = {
    description = "Seed radicle repositories";
    after = [ "radicle-node.service" ];
    requires = [ "radicle-node.service" ];
    wantedBy = [
      "sysinit-reactivation.target"
      "multi-user.target"
    ];
    before = [ "sysinit-reactivation.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' config.services.radicle.package "rad"} seed ${builtins.concatStringsSep " " radiclePrefixedRepoIDs}";
      User = config.systemd.services.radicle-node.serviceConfig.User;
      Group = config.systemd.services.radicle-node.serviceConfig.Group;
      Environment = lib.toShellVars {
        RAD_HOME = "/var/lib/radicle";
        RUST_LOG = "info";
      };
      BindReadOnlyPaths = config.systemd.services.radicle-node.serviceConfig.BindReadOnlyPaths;
    };
  };
}
