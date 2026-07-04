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
    accounts = inputs.nixpkgs.lib.filterAttrs (
      username: account: builtins.elem username [ "headb" ]
    ) accounts;
  };
  modules = with nixosModules; [
    (
      { lib, ... }:
      {
        system.stateVersion = "26.05";
        networking.hostName = hostname;
        nixpkgs = {
          overlays = builtins.attrValues overlays;
        };
      }
    )

    ./config.nix
    ./hardware.nix

    boot.loader.systemd-boot
    conf.en-gb
    conf.headless
    conf.passwordless
    conf.utility
    fileSystems
    hardware.enableRedistributableFirmware
    nix.gc
    nix.registry
    nix.settings
    programs.fzf
    programs.zsh
    services.openssh
    users.users
  ];
}
