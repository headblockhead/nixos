{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
    hieroglyphic
    citations
    gnome-decoder
    dialect
    forge-sparks
  ];
}
