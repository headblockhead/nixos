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
  };
  modules = with nixosModules; [
    {
      system.stateVersion = "25.05";
      networking.hostName = hostName;
      nixpkgs.overlays = builtins.attrValues overlays;
    }

    ./config.nix
    ../hardware.nix

    conf.en-gb
    conf.passwordless
    conf.utility
    nix.gc
    nix.registry
    nix.settings
    programs.fzf
    programs.zsh
    services.openssh
    users.users
  ];
}
