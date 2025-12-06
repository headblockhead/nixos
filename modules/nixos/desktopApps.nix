{ pkgs, config, ... }: {
  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    #rpi-imager
    anki
    arduino
    audacity
    chiaki
    deja-dup
    discord
    easyeffects
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
    signal-desktop-bin
    slack
    spotify
    thonny
    tor-browser
    unstable.godot
    unstable.thunderbird-latest
    vlc
    warp
    watchmate
    zoom-us
  ];
  # OBS Virutal camera
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  # boot.extraModprobeConfig = ''
  #options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  #'';
}
