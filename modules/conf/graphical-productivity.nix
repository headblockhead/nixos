{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gimp
    inkscape
    kicad
    prusa-slicer
    libreoffice
    anki
    thunderbird
    # CAD
    openscad-unstable
    freecad-wayland
    # LaTeX tools
    texstudio
    texliveFull
  ];
}
