{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    # Useful development utils
    xc
    qemu
    tmux
    bat
    fastfetch

    # Networking utils
    openssl
    nmap

    # Nix
    nixfmt-rfc-style

    # Go
    unstable.go_1_25
    gopls
    templ
    go-migrate

    # Python
    python313

    # Javascript
    nodejs

    # Lua
    lua5_4

    # Rust
    rustc
    cargo

    # C
    ccls
    cmake
    gcc
    gcc-arm-embedded
    gnumake

    # Protobuf
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc

    # RPI
    pico-sdk
    picotool

    # Hardware
    pulseview
    minicom
    wireshark
  ];
  services.gnome.core-developer-tools.enable = config.services.desktopManager.gnome;
}
