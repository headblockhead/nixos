{ lib, pkgs, accounts, ... }:
{
  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.gamescope.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    package = pkgs.unstable.steam;
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    highPriority = true;
    autoStart = true;
  };

  boot.plymouth.extraConfig = ''
    DeviceScale=2
  '';
  services.kmscon.extraConfig = lib.mkAfter ''
    font-dpi=192
  '';
  systemd.tmpfiles.rules = [
    ''L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}''
  ] ++ lib.lists.forEach accounts (account: "L+ /home/${account.username}/.config/monitors.xml - - - - ${./monitors.xml}");
  boot.kernelParams = [ "video=HDMI-A-2:panel_orientation=left_side_up" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureUsers = [{ name = "headb"; }];
  };

  networking.firewall.enable = lib.mkForce false;

  environment.systemPackages = [
    pkgs.clonehero
    pkgs.blender-hip
    pkgs.vscode-fhs
    pkgs.prismlauncher
    pkgs.handbrake
    pkgs.anki
    pkgs.go-migrate
    pkgs.qgis
    pkgs.obinskit
    #pkgs.qxmledit

    pkgs.kdePackages.kdenlive
  ];
}
