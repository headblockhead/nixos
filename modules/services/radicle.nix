{
  inputs,
  config,
  radicleAlias,
  radiclePublicKey,
  reverseDomainName,
  ...
}:
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
      mode = "755";
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
      listenPort = 8776;
      openFirewall = false;
    };
    publicKey = radiclePublicKey;
    privateKey = config.age.secrets.radicle.path;
    settings = {
      web = {
        avatarUrl = "https://edwardh.dev/edward-hesketh-close.jpg";
        bannerUrl = "https://edwardh.dev/edward-hesketh.jpg";
        description = "Edward Hesketh's Radicle node";
        pinned = [ ];
      };
      node = {
        alias = radicleAlias;
        externalAddresses = [ "${radicleAlias}:443" ];
        seedingPolicy = {
          default = "block";
          scope = "all";
        };
        fetch.signedReferences.featureLevel.minimum = "parent";
      };
    };
  };
}
