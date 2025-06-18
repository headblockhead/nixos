{ outputs, lib, pkgs, account, ... }:

{
  networking.hostName = "edward-desktop-01";

  systemd.services.xmrig.wantedBy = lib.mkForce [ ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  virtualisation.docker.enable = true;

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
    [Daemon]
    DeviceScale=2
  '';
  services.kmscon.extraConfig = lib.mkAfter ''
    font-dpi=192
  '';
  systemd.tmpfiles.rules = [
    ''C+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}''
    ''C+ /home/${account.username}/.config/monitors.xml - - - - ${./monitors.xml}''
  ];

  # find / -name '*.desktop' 2> /dev/null
  services.xserver.desktopManager.gnome.favoriteAppsOverride = ''
    [org.gnome.shell]
    favorite-apps=[ 'firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop', 'org.gnome.Calculator.desktop', 'org.freecad.FreeCAD.desktop', 'org.kicad.kicad.desktop', 'gnome-system-monitor.desktop', 'thunderbird.desktop', 'slack.desktop', 'spotify.desktop', 'steam.desktop', 'org.openrgb.OpenRGB.desktop']
  '';

  environment.systemPackages = [
    pkgs.clonehero
    pkgs.unstable.blender-hip
    pkgs.vscode-fhs
    pkgs.prismlauncher
    pkgs.handbrake
  ];

  system.stateVersion = "22.05";
}
