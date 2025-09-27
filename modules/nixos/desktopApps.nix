{ pkgs, ... }: {
  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    anki
    arduino
    audacity
    chiaki
    discord
    firefox
    fractal # matrix messenger
    furnace # chiptune tracker
    gimp
    godot
    google-chrome
    ifuse # optional, to mount using 'ifuse'
    inkscape
    kicad
    libimobiledevice
    libreoffice-fresh
    lmms
    monero-gui
    musescore
    obs-studio
    obsidian
    onedrive
    openscad-unstable
    prusa-slicer
    rpi-imager
    signal-desktop-bin
    slack
    spotify
    thonny
    tor-browser-bundle-bin
    unstable.thunderbird-latest
    vlc
    watchmate
    zoom-us
  ];
}
