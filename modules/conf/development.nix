{ pkgs, lib, config, accounts, ... }:
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
    go
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
  services.gnome.core-developer-tools.enable = lib.mkDefault config.services.desktopManager.gnome.enable;
  users.users = builtins.mapAttrs (n: v: { extraGroups = (if v.superuser then [ "dialout" ] else [ ]); }) accounts;
}
