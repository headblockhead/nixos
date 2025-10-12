{ pkgs, ... }: {
  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    anki
    arduino
    audacity
    chiaki
    deja-dup
    discord
    firefox
    fractal # matrix messenger
    furnace # chiptune tracker
    gimp
    gnome-pomodoro
    google-chrome
    gopass
    ifuse # optional, to mount using 'ifuse'
    inkscape
    kicad
    libimobiledevice
    libreoffice-fresh
    lmms
    monero-gui
    musescore
    newsflash
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
    unstable.godot
    unstable.thunderbird-latest
    vlc
    warp
    watchmate
    zoom-us
  ];
}
