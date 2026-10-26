{
  inputs,
  config,
  radicleAlias,
  radiclePublicKey,
  reverseDomainName,
  radicleNodePort,
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
        pinned.repositories = [
          "rad:zBJiVgq6DhTjUg8Tqp9DZAQqSJcz" # nixos
          "rad:zudXi8ABTLpwYLAce7NR8KntbcZU" # edwardh.dev
          "rad:z2dQfyStnRiFbU6Sx9pZf7cQk3mDZ" # pio
        ];
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
}
