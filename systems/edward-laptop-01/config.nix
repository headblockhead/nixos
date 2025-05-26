{ outputs, pkgs, ... }:
{
  networking.hostName = "edward-laptop-01";

  imports = with outputs.nixosModules; [
    basicConfig
    bluetooth
    bootloaderGraphical
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
    printer
    sdr
    sound
    ssd
    ssh
    users
    yubikey
    zsh
  ];

  # Grub settings.
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.gfxmodeEfi = "1600x900x32";

  # Do not sleep on lid close when docked/plugged in.
  services.logind.extraConfig = ''
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=ignore
    HandleLidSwitchDocked=ignore
  '';

  environment.systemPackages = [
    pkgs.ardour
    pkgs.x32edit
  ];

  # find / -name '*.desktop' 2> /dev/null
  services.xserver.desktopManager.gnome.favoriteAppsOverride = ''
    [org.gnome.shell]
    favorite-apps=[ 'firefox.desktop', 'torbrowser.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop','org.gnome.Calculator.desktop', 'org.rncbc.qjackctl.desktop', 'ardour8.desktop', 'vlc.desktop', 'audacity.desktop' ]
  '';

  system.stateVersion = "25.05";
}
