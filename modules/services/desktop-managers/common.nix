{ pkgs, ... }:
{
  services.xserver.excludePackages = [ pkgs.xterm ];

  # TODO: is this needed?
  # https://github.com/NixOS/nixpkgs/issues/149812
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';
}
