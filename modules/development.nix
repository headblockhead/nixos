{ pkgs, lib, accounts, ... }:
{
  programs.adb.enable = true;
  programs.wireshark.enable = true;

  # Give trusted users access.
  users.users = lib.genAttrs
    (builtins.attrNames (lib.filterAttrs (n: v: v.trusted) accounts))
    (username: { extraGroups = [ "wireshark" "adbusers" ]; });

  environment.systemPackages = with pkgs; [
    #protoc-gen-swift
    #swift
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
    go-migrate
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
    openssl
    pico-sdk
    picotool
    platformio
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    pulseview
    python313
    qemu
    rustc
    templ
    tmux
    unstable.go_1_25
    wireguard-tools
    wireshark
  ];
}
