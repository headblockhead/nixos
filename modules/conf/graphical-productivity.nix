{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gimp
    inkscape
    kicad
    openscad-unstable
    prusa-slicer
    libreoffice
    anki
    thunderbird
    freecad-wayland
  ];
}
