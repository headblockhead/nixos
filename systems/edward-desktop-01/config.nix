{ lib, pkgs, accounts, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.gamescope.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    package = pkgs.unstable.steam;
  };
  programs.alvr = {
    enable = true;
    package = pkgs.unstable.alvr;
    openFirewall = true;
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

  # ls /run/current-system/sw/share/applications
  services.xserver.desktopManager.gnome.favoriteAppsOverride = ''
    [org.gnome.shell]
    favorite-apps=[ 'firefox.desktop', 'torbrowser.desktop', 'org.gnome.Ptyxis.desktop', 'anki.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop', 'org.gnome.Calculator.desktop', 'org.freecad.FreeCAD.desktop', 'org.kicad.kicad.desktop', 'org.gnome.SystemMonitor.desktop', 'thunderbird.desktop', 'slack.desktop', 'signal.desktop', 'spotify.desktop', 'steam.desktop' ]
  '';

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureUsers = [{ name = "headb"; }];
  };

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

    pkgs.kdePackages.kdenlive
  ];
}
