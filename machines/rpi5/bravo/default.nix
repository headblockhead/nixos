{
  inputs,
  overlays,
  nixosModules,
  hostName,
  reverseDomainName,
  accounts,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs hostName reverseDomainName;
    nixos-raspberrypi = inputs.nixos-raspberrypi;
    accounts = inputs.nixpkgs.lib.filterAttrs (
      username: account: builtins.elem username [ "headb" ]
    ) accounts;
    radicleAlias = "bravo.seed.edwardh.dev";
    radiclePublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0xLWlmCVFGuuvKEWaBa55nIIpfvsyUKePXMlACN6+H";
    radicleNodePort = 8776;
  };
  modules = with nixosModules; [
    {
      system.stateVersion = "26.11";
      networking.hostName = hostName;
      nixpkgs = {
        config.permittedInsecurePackages = [
          "radicle-node-1.10.3"
        ];
        overlays = builtins.attrValues overlays;
      };
    }

    ./config.nix
    ../hardware.nix

    conf.en-gb
    conf.impermanence
    conf.passwordless
    conf.utility
    disko.rpi5
    nix.buildMachines
    nix.gc
    nix.optimise
    nix.registry
    nix.settings
    programs.fzf
    programs.zsh
    services.openssh
    services.radicle
    users.users
  ];
}
