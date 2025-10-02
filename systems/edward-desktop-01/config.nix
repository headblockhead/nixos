{ lib, pkgs, accounts, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  virtualisation.docker.enable = true;

  networking.firewall.allowedTCPPorts = [ 8080 ];

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
    ''C+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}''
  ] ++ lib.lists.forEach accounts (account: "C+ /home/${account.username}/.config/monitors.xml - - - - ${./monitors.xml}");

  # find / -name '*.desktop' 2> /dev/null
  services.xserver.desktopManager.gnome.favoriteAppsOverride = ''
    [org.gnome.shell]
    favorite-apps=[ 'firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop', 'org.gnome.Calculator.desktop', 'org.freecad.FreeCAD.desktop', 'org.kicad.kicad.desktop', 'gnome-system-monitor.desktop', 'thunderbird.desktop', 'slack.desktop', 'spotify.desktop', 'steam.desktop', 'org.openrgb.OpenRGB.desktop']
  '';

  nix.settings.extra-substituters = [ "http://172.16.3.51:8501" ];

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
