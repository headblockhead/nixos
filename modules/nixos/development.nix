{ pkgs, account, ... }:
{
  programs.adb.enable = true;
  programs.wireshark.enable = true;

  users.users.${account.username}.extraGroups = [ "wireshark" "adbusers" ];

  environment.systemPackages = with pkgs; [
    asciinema
    awscli2
    bat
    bind
    cargo
    ccls
    cmake
    ec2-ami-tools
    flyctl
    freecad-wayland
    gcc
    gcc-arm-embedded
    gnumake
    gopls
    hugo
    lm_sensors
    lua5_4
    minicom
    neofetch
    ngrok
    nixfmt-rfc-style
    nmap
    nodePackages.aws-cdk
    nodejs
    pico-sdk
    picotool
    platformio
    pulseview
    python313
    qemu
    rustc
    templ
    tmux
    unstable.go_1_24
    wireguard-tools
    wireshark
  ];
}
