{ pkgs, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  networking.firewall.allowedTCPPorts = [ 64023 ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureUsers = [{ name = "headb"; }];
    settings.max_wal_size = "30GB";
  };

  #virtualisation.virtualbox.host.enable = true;
  users.users.headb.extraGroups = [ "vboxusers" ];

  environment.systemPackages = [
    pkgs.virtualbox
    pkgs.blender-hip
    pkgs.kdePackages.kdenlive
    pkgs.vscode-fhs
    pkgs.prismlauncher
    pkgs.clonehero
  ];
}
