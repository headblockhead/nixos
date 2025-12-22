{ pkgs, ... }:
{
  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    package = pkgs.unstable.steam;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureUsers = [{ name = "headb"; }];
    settings.max_wal_size = "30GB";
  };

  environment.systemPackages = [
    pkgs.clonehero
    pkgs.blender-hip
    pkgs.vscode-fhs
    pkgs.prismlauncher
    pkgs.handbrake
    pkgs.anki
    pkgs.qgis
    pkgs.obinskit
    #pkgs.qxmledit

    pkgs.kdePackages.kdenlive
  ];
}
