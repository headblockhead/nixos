{
  inputs,
  overlays,
  nixosModules,
  hostname,
  accounts,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
    nixos-raspberrypi = inputs.nixos-raspberrypi;
    accounts = inputs.nixpkgs.lib.filterAttrs (
      username: account: builtins.elem username [ "headb" ]
    ) accounts;
  };
  modules = with nixosModules; [
    {
      system.stateVersion = "26.11";
      networking.hostName = hostname;
      nixpkgs.overlays = builtins.attrValues overlays;
    }

    ./config.nix
    ../rpi5-hardware.nix

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
    users.users
  ];
}
