{ outputs, lib, pkgs, account, ... }:

{
  networking.hostName = "edward-desktop-01";

  imports = with outputs.nixosModules; [
    basicConfig
    bluetooth
    bootloader
    desktop
    desktopApps
    development
    distributedBuilds
    fileSystems
    fonts
    fzf
    git
    gpg
    homeManager
    network
    openrgb
    printer
    sdr
    sound
    ssd
    ssh
    transmission
    users
    virtualisation
    yubikey
    zsh

    #sheepit

    p2pool
    xmrig
  ];
  systemd.services.xmrig.wantedBy = lib.mkForce [ ];

  boot.plymouth.extraConfig = ''
    [Daemon]
    DeviceScale=2
  '';

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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
    pkgs.prismlauncher
  ];

  system.stateVersion = "22.05";
}
