{ inputs, overlays, nixosModules, hostname, accounts, ... }:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
    accounts = inputs.nixpkgs.lib.filterAttrs (username: account: builtins.elem username [ "headb" ]) accounts;
  };
  modules = with nixosModules; [
    ({ lib, ... }: {
      system.stateVersion = "22.05";
      networking.hostName = hostname;
      nixpkgs.overlays = builtins.attrValues overlays;
    })

    ./config.nix
    ./hardware.nix

    "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
    inputs.agenix.nixosModules.default

    conf.en-gb
    conf.utility
    fileSystems
    nix.gc
    nix.registry
    nix.settings
    programs.fzf
    programs.zsh
    services.openssh
    users.users
  ];
}
