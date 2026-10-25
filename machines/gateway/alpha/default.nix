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
      system.stateVersion = "25.11";
      networking.hostName = hostName;
      nixpkgs = {
        overlays = builtins.attrValues overlays;
        config.allowUnfreePackages = [
          "unifi-controller" # unfree
          "mongodb" # sspl
        ];
      };
    }

    ./config.nix
    ./hardware.nix

    boot.loader.systemd-boot
    conf.en-gb
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
