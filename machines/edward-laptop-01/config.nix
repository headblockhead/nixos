{ pkgs, ... }:
{
  virtualisation.docker.enable = true;

  # Do not sleep on lid close when docked/plugged in.
  services.logind.extraConfig = ''
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=ignore
    HandleLidSwitchDocked=ignore
  '';

  # find / -name '*.desktop' 2> /dev/null
  services.xserver.desktopManager.gnome.favoriteAppsOverride = ''
    [org.gnome.shell]
    favorite-apps=[ 'firefox.desktop', 'torbrowser.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop','org.gnome.Calculator.desktop', 'org.rncbc.qjackctl.desktop', 'ardour8.desktop', 'vlc.desktop', 'audacity.desktop' ]
  '';

  environment.systemPackages = [
    pkgs.ardour
    #pkgs.x32edit
  ];
}
