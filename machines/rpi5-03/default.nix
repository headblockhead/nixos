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
    ../rpi5-hardware.nix
    ../rpi5-disko.nix

    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
    inputs.agenix.nixosModules.age
    inputs.disko.nixosModules.disko

    conf.en-gb
    conf.headless
    conf.passwordless
    conf.utility
    homelab.k3s
    nix.buildMachines
    nix.gc
    nix.optimise
    nix.registry
    nix.settings
    programs.fzf
    programs.zsh
    services.openssh
    users.users
  ];
}
