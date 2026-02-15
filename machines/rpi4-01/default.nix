{ inputs, overlays, nixosModules, hostname, accounts, ... }:
inputs.nixos-raspberrypi.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
    nixos-raspberrypi = inputs.nixos-raspberrypi;
    accounts = inputs.nixpkgs.lib.filterAttrs (username: account: builtins.elem username [ "headb" ]) accounts;
  };
  modules = with nixosModules; [
    ({ lib, ... }: {
      system.stateVersion = "25.05";
      networking.hostName = hostname;
      nixpkgs.overlays = builtins.attrValues overlays;
    })

    ./config.nix
    ../rpi4-hardware.nix

    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base

    conf.en-gb
    conf.headless
    conf.passwordless
    conf.utility
    homelab.load-balancer
    nix.gc
    nix.registry
    nix.settings
    programs.fzf
    programs.zsh
    services.openssh
    users.users
  ];
}
