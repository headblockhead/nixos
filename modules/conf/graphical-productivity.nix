{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gimp
    inkscape
    kicad
    prusa-slicer
    libreoffice
    hunspell
    hunspellDicts.en-gb-large
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
