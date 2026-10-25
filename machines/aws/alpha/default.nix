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
    accounts = inputs.nixpkgs.lib.filterAttrs (
      username: account: builtins.elem username [ "headb" ]
    ) accounts;
  };
  modules = with nixosModules; [
    {
      system.stateVersion = "22.05";
      networking.hostName = hostName;
      nixpkgs.overlays = builtins.attrValues overlays;
    }

    ./config.nix
    ./hardware.nix

    "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"

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
